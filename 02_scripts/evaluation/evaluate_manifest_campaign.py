"""Evaluate paired V8/HTE D24, V30, or H60 manifest evidence.

This module is controller-neutral at the case-dispatch layer: case identity,
trajectory, perturbations, stop time, and pairing all come from the frozen CSV
manifest rather than from the fixed 32-scene catalog.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import re
import runpy
import statistics
import tomllib
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence


SCHEMA_VERSION = 1
SAMPLE_TIME_S = 0.01
SCENARIO_SEED_MODULUS = 2_147_483_647
UINT64_MAX = 2**64 - 1
SHA256_PATTERN = re.compile(r"[0-9A-Fa-f]{64}\Z")
CASE_ID_PATTERN = re.compile(r"(?P<split>[DVH])_(?P<category>[NPC])(?P<index>\d{2})\Z")
MANIFEST_FIELDS = (
    "case_id",
    "split_id",
    "category",
    "trajectory_id",
    "lift_scale",
    "mass_scale",
    "inertia_scale",
    "disturbance_mode",
    "scenario_seed",
    "stop_time_s",
)
SPLIT_COUNTS = {
    "D": {"nominal": 6, "parameter": 12, "compound": 6},
    "V": {"nominal": 6, "parameter": 18, "compound": 6},
    "H": {"nominal": 12, "parameter": 36, "compound": 12},
}
CATEGORY_CODES = {"nominal": "N", "parameter": "P", "compound": "C"}
DISTURBANCE_MODES = {"none": 0, "fixed_compound": 1}
STOP_TIME_BY_TRAJECTORY = {1: 30.0, 2: 50.0, 3: 50.0, 4: 60.0, 5: 50.0, 6: 45.0}
HTE_VERSION_CODE = 914.0

POSITION_REFERENCE_COLUMNS = tuple(f"referenceVector[{index}]" for index in range(1, 4))
POSITION_COLUMNS = tuple(
    f"quadChassisTest17_1.body.r_0[{index}]" for index in range(1, 4)
)
ATTITUDE_COLUMNS = tuple(f"sensors1_1.AngleMea[{index}]" for index in range(1, 4))
RATE_COLUMNS = tuple(
    f"quadChassisTest17_1.body.frame_b.R.w[{index}]" for index in range(1, 4)
)
ROTATION_COLUMNS = tuple(
    f"quadChassisTest17_1.body.frame_b.R.T[{row},{column}]"
    for row in range(1, 4)
    for column in range(1, 4)
)
MOTOR_COMMAND_COLUMNS = tuple(f"motorCommand[{index}]" for index in range(1, 5))
MOTOR_APPLIED_COLUMNS = tuple(f"motorApplied[{index}]" for index in range(1, 5))
HTE_DIAGNOSTIC_COLUMNS = tuple(
    f"controllerDiagnostics[{index}]" for index in range(11, 17)
)
SCENARIO_COLUMNS = tuple(
    f"scenarioDiagnostics[{index}]" for index in (*range(1, 14), 21)
)
REQUIRED_RAW_COLUMNS = (
    ("time",)
    + POSITION_REFERENCE_COLUMNS
    + POSITION_COLUMNS
    + ATTITUDE_COLUMNS
    + RATE_COLUMNS
    + ROTATION_COLUMNS
    + MOTOR_COMMAND_COLUMNS
    + MOTOR_APPLIED_COLUMNS
    + HTE_DIAGNOSTIC_COLUMNS
    + SCENARIO_COLUMNS
)


class EvidenceError(RuntimeError):
    """Raised when frozen evidence does not satisfy its structural contract."""


@dataclass(frozen=True)
class ManifestCase:
    case_id: str
    split_id: str
    category: str
    trajectory_id: int
    lift_scale: float
    mass_scale: float
    inertia_scale: float
    disturbance_mode: str
    scenario_seed: int
    stop_time_s: float

    @property
    def disturbance_mode_code(self) -> int:
        return DISTURBANCE_MODES[self.disturbance_mode]

    @property
    def scenario_seed_code(self) -> int:
        return self.scenario_seed % SCENARIO_SEED_MODULUS


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def normalize_sha256(value: str, label: str) -> str:
    normalized = value.strip().upper()
    if SHA256_PATTERN.fullmatch(normalized) is None:
        raise EvidenceError(f"{label} must be a 64-character hexadecimal SHA256")
    return normalized


def require_file(path: Path, label: str) -> Path:
    resolved = path.resolve()
    if not resolved.is_file():
        raise EvidenceError(f"missing {label}: {resolved}")
    return resolved


def _parse_float(row: Mapping[str, str], name: str, case_id: str) -> float:
    try:
        value = float(row[name])
    except (KeyError, TypeError, ValueError) as exc:
        raise EvidenceError(f"invalid {name} in {case_id}") from exc
    if not math.isfinite(value):
        raise EvidenceError(f"non-finite {name} in {case_id}")
    return value


def _parse_int(row: Mapping[str, str], name: str, case_id: str) -> int:
    try:
        return int(row[name])
    except (KeyError, TypeError, ValueError) as exc:
        raise EvidenceError(f"invalid {name} in {case_id}") from exc


def load_manifest(path: Path) -> tuple[list[ManifestCase], dict[str, Any]]:
    # 清单列、场景编号和随机种子必须唯一，避免配对错位。
    resolved = require_file(path, "campaign manifest")
    with resolved.open("r", encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames is None or tuple(reader.fieldnames) != MANIFEST_FIELDS:
            raise EvidenceError(
                f"manifest columns must exactly equal {MANIFEST_FIELDS}: {reader.fieldnames}"
            )
        rows = list(reader)
    if not rows:
        raise EvidenceError("campaign manifest is empty")

    cases: list[ManifestCase] = []
    seen_ids: set[str] = set()
    seen_seeds: set[int] = set()
    for row in rows:
        case_id = row["case_id"].strip()
        split_id = row["split_id"].strip()
        category = row["category"].strip()
        disturbance_mode = row["disturbance_mode"].strip()
        match = CASE_ID_PATTERN.fullmatch(case_id)
        if match is None or case_id in seen_ids:
            raise EvidenceError(f"invalid or duplicate case_id: {case_id!r}")
        if split_id not in SPLIT_COUNTS or match.group("split") != split_id:
            raise EvidenceError(f"case/split mismatch in {case_id}")
        if category not in CATEGORY_CODES or match.group("category") != CATEGORY_CODES[category]:
            raise EvidenceError(f"case/category mismatch in {case_id}")
        expected_mode = "fixed_compound" if category == "compound" else "none"
        if disturbance_mode != expected_mode:
            raise EvidenceError(f"category/disturbance mismatch in {case_id}")
        trajectory_id = _parse_int(row, "trajectory_id", case_id)
        scenario_seed = _parse_int(row, "scenario_seed", case_id)
        stop_time_s = _parse_float(row, "stop_time_s", case_id)
        scales = tuple(
            _parse_float(row, name, case_id)
            for name in ("lift_scale", "mass_scale", "inertia_scale")
        )
        if trajectory_id not in STOP_TIME_BY_TRAJECTORY:
            raise EvidenceError(f"trajectory_id outside 1..6 in {case_id}")
        if not math.isclose(
            stop_time_s, STOP_TIME_BY_TRAJECTORY[trajectory_id], abs_tol=1e-12
        ):
            raise EvidenceError(f"stop_time_s does not match trajectory in {case_id}")
        if not all(0.92 <= value <= 1.08 for value in scales):
            raise EvidenceError(f"physical scale outside [0.92, 1.08] in {case_id}")
        if category == "nominal" and scales != (1.0, 1.0, 1.0):
            raise EvidenceError(f"nominal scales changed in {case_id}")
        if not 0 <= scenario_seed <= UINT64_MAX or scenario_seed in seen_seeds:
            raise EvidenceError(f"invalid or duplicate scenario_seed in {case_id}")
        seen_ids.add(case_id)
        seen_seeds.add(scenario_seed)
        cases.append(
            ManifestCase(
                case_id=case_id,
                split_id=split_id,
                category=category,
                trajectory_id=trajectory_id,
                lift_scale=scales[0],
                mass_scale=scales[1],
                inertia_scale=scales[2],
                disturbance_mode=disturbance_mode,
                scenario_seed=scenario_seed,
                stop_time_s=stop_time_s,
            )
        )

    split_ids = {case.split_id for case in cases}
    if len(split_ids) != 1:
        raise EvidenceError(f"one manifest must contain one split: {sorted(split_ids)}")
    split_id = next(iter(split_ids))
    expected_counts = SPLIT_COUNTS[split_id]
    actual_counts = {
        category: sum(case.category == category for case in cases)
        for category in expected_counts
    }
    if actual_counts != expected_counts:
        raise EvidenceError(
            f"{split_id} manifest category counts mismatch: {actual_counts}"
        )
    for category, count in expected_counts.items():
        trajectories = [case.trajectory_id for case in cases if case.category == category]
        expected_per_trajectory = count // 6
        if any(
            trajectories.count(trajectory_id) != expected_per_trajectory
            for trajectory_id in range(1, 7)
        ):
            raise EvidenceError(f"unbalanced trajectories in {split_id}/{category}")
    return cases, {
        "path": str(resolved),
        "sha256": sha256(resolved),
        "split_id": split_id,
        "case_count": len(cases),
        "category_counts": actual_counts,
    }


def load_candidate_parameters(path: Path) -> dict[str, Any]:
    resolved = require_file(path, "candidate parameter manifest")
    with resolved.open("r", encoding="utf-8") as stream:
        payload = json.load(stream)
    if not isinstance(payload, dict) or payload.get("schema_version") != 1:
        raise EvidenceError("invalid candidate parameter manifest schema")
    parameters = payload.get("parameters")
    names = {
        "activation_covariance_max",
        "activation_persistence_s",
        "scale_rate_per_s",
    }
    if not isinstance(parameters, dict) or set(parameters) != names:
        raise EvidenceError(f"candidate parameter names must exactly equal {sorted(names)}")
    values = {name: float(parameters[name]) for name in names}
    if not 0.00125 <= values["activation_covariance_max"] <= 0.005:
        raise EvidenceError("activation_covariance_max outside registered bounds")
    persistence = values["activation_persistence_s"]
    if not 0.10 <= persistence <= 0.30 or not math.isclose(
        persistence, round(persistence / 0.01) * 0.01, abs_tol=1e-12
    ):
        raise EvidenceError("activation_persistence_s violates registered bounds/quantization")
    if not 0.4 <= values["scale_rate_per_s"] <= 1.0:
        raise EvidenceError("scale_rate_per_s outside registered bounds")
    candidate_id = str(payload.get("candidate_id", "")).strip()
    if not candidate_id:
        raise EvidenceError("candidate_id is missing")
    return {
        "path": str(resolved),
        "sha256": sha256(resolved),
        "candidate_id": candidate_id,
        "controller_source_sha256": normalize_sha256(
            str(payload.get("controller_source_sha256", "")),
            "controller_source_sha256",
        ),
        "parameters": values,
    }


def load_raw_evidence(
    raw_manifest_path: Path,
    raw_directory: Path,
    role: str,
    cases: Sequence[ManifestCase],
) -> tuple[dict[str, Path], dict[str, Any]]:
    # 原始证据按清单顺序加载，避免文件遍历顺序影响结果。
    if role not in {"v8", "hte"}:
        raise ValueError("raw role must be v8 or hte")
    manifest_path = require_file(raw_manifest_path, f"{role} raw manifest")
    directory = raw_directory.resolve()
    if not directory.is_dir():
        raise EvidenceError(f"missing {role} raw directory: {directory}")
    with manifest_path.open("r", encoding="utf-8") as stream:
        payload = json.load(stream)
    if not isinstance(payload, dict) or payload.get("schema_version") != 1:
        raise EvidenceError(f"invalid {role} raw manifest schema")
    if payload.get("algorithm") != role:
        raise EvidenceError(f"raw manifest algorithm mismatch: expected {role}")
    records = payload.get("cases")
    if not isinstance(records, list) or payload.get("case_count") != len(records):
        raise EvidenceError(f"invalid {role} raw manifest case count")

    expected = {case.case_id: case for case in cases}
    actual: dict[str, Path] = {}
    record_hashes: dict[str, str] = {}
    for record in records:
        if not isinstance(record, dict):
            raise EvidenceError(f"invalid {role} raw manifest record")
        case_id = str(record.get("case_id", ""))
        if case_id not in expected or case_id in actual:
            raise EvidenceError(f"unknown or duplicate {role} raw case: {case_id!r}")
        if record.get("scenario_seed") != expected[case_id].scenario_seed:
            raise EvidenceError(f"scenario seed mismatch for {role}/{case_id}")
        raw = record.get("raw")
        if not isinstance(raw, dict):
            raise EvidenceError(f"missing raw record for {role}/{case_id}")
        recorded_hash = normalize_sha256(str(raw.get("sha256", "")), f"{role}/{case_id} raw SHA256")
        target = require_file(directory / f"{case_id}.csv", f"{role}/{case_id} raw CSV")
        if Path(str(raw.get("path", ""))).name != target.name:
            raise EvidenceError(f"raw filename mismatch for {role}/{case_id}")
        actual_hash = sha256(target)
        if actual_hash != recorded_hash:
            raise EvidenceError(
                f"raw SHA256 mismatch for {role}/{case_id}: {actual_hash} != {recorded_hash}"
            )
        actual[case_id] = target
        record_hashes[case_id] = actual_hash
    if set(actual) != set(expected):
        missing = sorted(set(expected) - set(actual))
        raise EvidenceError(f"{role} raw manifest is incomplete: {missing}")
    disk_names = {path.name for path in directory.glob("*.csv")}
    expected_names = {f"{case.case_id}.csv" for case in cases}
    if disk_names != expected_names:
        raise EvidenceError(
            f"{role} raw directory case set mismatch: "
            f"missing={sorted(expected_names-disk_names)}, extra={sorted(disk_names-expected_names)}"
        )
    return actual, {
        "path": str(manifest_path),
        "sha256": sha256(manifest_path),
        "raw_directory": str(directory),
        "case_count": len(actual),
        "case_sha256": record_hashes,
    }


def load_pair_execution_contract(
    v8_raw_manifest: Path,
    hte_raw_manifest: Path,
    campaign_manifest: Mapping[str, Any],
    candidate: Mapping[str, Any],
    cases: Sequence[ManifestCase],
) -> dict[str, Any]:
    v8_manifest = v8_raw_manifest.resolve()
    hte_manifest = hte_raw_manifest.resolve()
    v8_root = v8_manifest.parent.parent
    hte_root = hte_manifest.parent.parent
    expected_cases = [case.case_id for case in cases]

    def read_status(root: Path, label: str) -> tuple[Path, dict[str, Any]]:
        path = require_file(root / "execution_status.json", f"{label} execution status")
        with path.open("r", encoding="utf-8") as stream:
            value = json.load(stream)
        if not isinstance(value, dict) or value.get("schema_version") != 1:
            raise EvidenceError(f"invalid {label} execution status schema")
        if value.get("success") is not True or value.get("status") != "pass":
            raise EvidenceError(f"{label} execution status is not successful")
        status_manifest = value.get("manifest")
        if (
            not isinstance(status_manifest, dict)
            or status_manifest.get("sha256") != campaign_manifest["sha256"]
        ):
            raise EvidenceError(f"{label} execution campaign manifest SHA256 mismatch")
        if value.get("selected_cases") != expected_cases:
            raise EvidenceError(
                f"{label} execution case order does not match the campaign manifest"
            )
        return path, value

    def require_candidate(status: Mapping[str, Any], label: str) -> None:
        status_candidate = status.get("candidate_parameter_manifest")
        if not isinstance(status_candidate, dict):
            raise EvidenceError(f"{label} execution is missing candidate provenance")
        for key in ("sha256", "candidate_id", "controller_source_sha256", "parameters"):
            if status_candidate.get(key) != candidate.get(key):
                raise EvidenceError(f"{label} execution candidate provenance mismatch: {key}")

    def require_raw_record(
        status: Mapping[str, Any], role: str, path: Path, label: str
    ) -> None:
        status_raw = status.get("raw_manifests")
        record = status_raw.get(role) if isinstance(status_raw, dict) else None
        if not isinstance(record, dict) or record.get("sha256") != sha256(path):
            raise EvidenceError(f"{label} {role} raw manifest SHA256 mismatch")
        if Path(str(record.get("path", ""))).resolve() != path:
            raise EvidenceError(f"{label} {role} raw manifest path mismatch")
        if record.get("case_count") != len(cases):
            raise EvidenceError(f"{label} {role} raw manifest count mismatch")

    if v8_root == hte_root:
        status_path, status = read_status(v8_root, "paired")
        if (
            status.get("algorithm_mode") != "pair"
            or status.get("algorithms") != ["v8", "hte"]
            or status.get("single_manifest_pairing") is not True
        ):
            raise EvidenceError("raw evidence was not produced by one paired V8/HTE run")
        require_candidate(status, "paired")
        status_raw = status.get("raw_manifests")
        if not isinstance(status_raw, dict) or set(status_raw) != {"v8", "hte"}:
            raise EvidenceError("paired execution raw manifest registry is incomplete")
        require_raw_record(status, "v8", v8_manifest, "paired execution")
        require_raw_record(status, "hte", hte_manifest, "paired execution")
        return {
            "mode": "single_paired_run",
            "path": str(status_path),
            "sha256": sha256(status_path),
            "paired_run_root": str(v8_root),
            "algorithm_mode": "pair",
            "case_count": len(cases),
            "campaign_manifest_sha256": campaign_manifest["sha256"],
            "candidate_parameter_manifest_sha256": candidate["sha256"],
        }

    v8_status_path, v8_status = read_status(v8_root, "V8 baseline")
    hte_status_path, hte_status = read_status(hte_root, "HTE candidate")
    if v8_status.get("algorithm_mode") not in {"v8", "pair"} or "v8" not in v8_status.get(
        "algorithms", []
    ):
        raise EvidenceError("baseline reuse source does not contain a successful V8 run")
    if hte_status.get("algorithm_mode") != "hte" or hte_status.get("algorithms") != ["hte"]:
        raise EvidenceError("candidate reuse source is not an HTE-only run")
    require_candidate(hte_status, "HTE candidate")
    require_raw_record(v8_status, "v8", v8_manifest, "V8 baseline")
    require_raw_record(hte_status, "hte", hte_manifest, "HTE candidate")

    def dependency_fingerprint(status: Mapping[str, Any]) -> dict[str, str]:
        dependencies = status.get("dependencies")
        if not isinstance(dependencies, list):
            raise EvidenceError("execution dependency registry is missing")
        result = {
            str(item.get("key")): str(item.get("sha256"))
            for item in dependencies
            if isinstance(item, dict) and item.get("key") and item.get("sha256")
        }
        required = {"official", "v8_controller", "hte_controller", "paired_plant"}
        if not required.issubset(result):
            raise EvidenceError("execution dependency registry is incomplete")
        return {key: result[key] for key in sorted(required)}

    if v8_status.get("runner_sha256") != hte_status.get("runner_sha256"):
        raise EvidenceError("baseline reuse runner SHA256 mismatch")
    if dependency_fingerprint(v8_status) != dependency_fingerprint(hte_status):
        raise EvidenceError("baseline reuse dependency SHA256 mismatch")

    return {
        "mode": "frozen_v8_baseline_reuse",
        "v8_execution_status": {
            "path": str(v8_status_path),
            "sha256": sha256(v8_status_path),
        },
        "hte_execution_status": {
            "path": str(hte_status_path),
            "sha256": sha256(hte_status_path),
        },
        "v8_run_root": str(v8_root),
        "hte_run_root": str(hte_root),
        "case_count": len(cases),
        "campaign_manifest_sha256": campaign_manifest["sha256"],
        "candidate_parameter_manifest_sha256": candidate["sha256"],
        "runner_sha256": v8_status.get("runner_sha256"),
        "dependency_sha256": dependency_fingerprint(v8_status),
    }


def load_config(path: Path) -> dict[str, Any]:
    resolved = require_file(path, "campaign contract")
    with resolved.open("rb") as stream:
        config = tomllib.load(stream)
    return config


def _matrix_metrics(values: Sequence[float]) -> tuple[float, float]:
    def value(row: int, column: int) -> float:
        return values[3 * row + column]

    squared_error = 0.0
    for row in range(3):
        for column in range(3):
            gram = math.fsum(value(axis, row) * value(axis, column) for axis in range(3))
            squared_error += (gram - (1.0 if row == column else 0.0)) ** 2
    determinant = (
        value(0, 0) * (value(1, 1) * value(2, 2) - value(1, 2) * value(2, 1))
        - value(0, 1) * (value(1, 0) * value(2, 2) - value(1, 2) * value(2, 0))
        + value(0, 2) * (value(1, 0) * value(2, 1) - value(1, 1) * value(2, 0))
    )
    return math.sqrt(squared_error), determinant


def longest_continuous_duration(
    time_values: Sequence[float], active: Sequence[bool]
) -> float:
    # 连续时长按时间轴实际间隔计算，不假设固定样本数。
    if len(time_values) != len(active):
        raise ValueError("time/activity length mismatch")
    start: int | None = None
    longest = 0.0
    for index, enabled in enumerate(active):
        if enabled and start is None:
            start = index
        elif not enabled and start is not None:
            longest = max(longest, time_values[index - 1] - time_values[start])
            start = None
    if start is not None:
        longest = max(longest, time_values[-1] - time_values[start])
    return longest


def final_disturbance_recovery(
    time_values: Sequence[float],
    errors: Sequence[float],
    disturbance_active: Sequence[bool],
) -> dict[str, Any]:
    # 从最后一次扰动结束后搜索重新进入误差带的首个稳定时刻。
    segments: list[tuple[int, int]] = []
    index = 0
    while index < len(disturbance_active):
        if disturbance_active[index]:
            first = index
            while index + 1 < len(disturbance_active) and disturbance_active[index + 1]:
                index += 1
            segments.append((first, index))
        index += 1
    if not segments:
        return {
            "disturbance_event_count": 0,
            "disturbance_evidence": False,
            "final_disturbance_end_s": None,
            "final_disturbance_recovery_s": None,
        }
    first, last = segments[-1]
    event_end = min(last + 1, len(time_values) - 1)
    baseline_start_time = max(time_values[0], time_values[first] - 1.0)
    baseline_rows = [
        row for row in range(first) if time_values[row] >= baseline_start_time
    ]
    baseline = (
        math.sqrt(math.fsum(errors[row] ** 2 for row in baseline_rows) / len(baseline_rows))
        if baseline_rows
        else errors[max(0, first - 1)]
    )
    threshold = max(0.05, 1.25 * baseline)
    sustained_start: int | None = None
    recovered_at: int | None = None
    for row in range(event_end, len(errors)):
        if errors[row] <= threshold:
            sustained_start = row if sustained_start is None else sustained_start
            if time_values[row] - time_values[sustained_start] >= 1.0 - 1e-12:
                recovered_at = sustained_start
                break
        else:
            sustained_start = None
    recovery = (
        None
        if recovered_at is None
        else max(0.0, time_values[recovered_at] - time_values[event_end])
    )
    return {
        "disturbance_event_count": len(segments),
        "disturbance_evidence": True,
        "final_disturbance_end_s": time_values[event_end],
        "final_disturbance_baseline_rmse_m": baseline,
        "final_disturbance_recovery_threshold_m": threshold,
        "final_disturbance_recovery_s": recovery,
    }


def _gate_le(value: float | None, limit: float) -> bool:
    return value is not None and math.isfinite(value) and value <= limit


def evaluate_raw_file(
    path: Path,
    case: ManifestCase,
    role: str,
    config: Mapping[str, Any],
) -> dict[str, Any]:
    # 单文件评价汇总跟踪、约束、诊断和物理有效性指标。
    # 单文件评价同时生成性能指标和不可被平均值掩盖的物理门。
    if role not in {"v8", "hte"}:
        raise ValueError("role must be v8 or hte")
    resolved = require_file(path, f"{role}/{case.case_id} raw CSV")
    with resolved.open("r", encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream)
        header = reader.fieldnames
        if header is None or len(header) != len(set(header)):
            raise EvidenceError(f"missing or duplicate CSV header in {resolved}")
        missing = sorted(set(REQUIRED_RAW_COLUMNS) - set(header))
        if missing:
            raise EvidenceError(f"required raw columns missing in {resolved}: {missing}")

        time_values: list[float] = []
        signed_errors: list[tuple[float, float, float]] = []
        error_norms: list[float] = []
        scale_hat: list[float] = []
        scale_apply: list[float] = []
        disturbance_active: list[bool] = []
        finite = True
        scenario_consistent = True
        max_tilt = 0.0
        max_rate = 0.0
        max_orthogonality = 0.0
        min_determinant = math.inf
        max_determinant_error = 0.0
        max_motor_command_q = 0.0
        max_motor_applied_q = 0.0
        allocator_limit_min = math.inf
        allocator_limit_max = 0.0
        motor_command_within = True
        motor_applied_within = True
        hte_version_match = True
        hte_scale_hat_projection = True
        hte_scale_apply_projection = True
        hte_fusion_binary = True
        v8_padding_zero = True
        expected_scenario = {
            "scenarioDiagnostics[1]": float(case.trajectory_id),
            "scenarioDiagnostics[2]": case.lift_scale,
            "scenarioDiagnostics[3]": case.mass_scale,
            "scenarioDiagnostics[4]": case.inertia_scale,
            "scenarioDiagnostics[5]": float(case.disturbance_mode_code),
            "scenarioDiagnostics[6]": 0.0 if role == "v8" else 1.0,
            "scenarioDiagnostics[21]": float(case.scenario_seed_code),
        }

        for row_number, row in enumerate(reader, start=2):
            if None in row or any(row.get(name) is None for name in header):
                raise EvidenceError(f"malformed CSV row {row_number} in {resolved}")
            values: dict[str, float] = {}
            try:
                for name in header:
                    values[name] = float(row[name])
            except (TypeError, ValueError) as exc:
                raise EvidenceError(
                    f"non-numeric CSV value at row {row_number} in {resolved}"
                ) from exc
            row_finite = all(math.isfinite(value) for value in values.values())
            finite = finite and row_finite
            time_values.append(values["time"])
            if not row_finite:
                signed_errors.append((math.nan, math.nan, math.nan))
                error_norms.append(math.nan)
                scale_hat.append(values["controllerDiagnostics[11]"])
                scale_apply.append(values["controllerDiagnostics[12]"])
                disturbance_active.append(False)
                continue

            for name, expected in expected_scenario.items():
                scenario_consistent = scenario_consistent and math.isclose(
                    values[name], expected, rel_tol=1e-10, abs_tol=1e-10
                )
            error = tuple(
                values[POSITION_REFERENCE_COLUMNS[index]]
                - values[POSITION_COLUMNS[index]]
                for index in range(3)
            )
            signed_errors.append(error)
            error_norm = math.sqrt(math.fsum(value * value for value in error))
            error_norms.append(error_norm)
            roll = values[ATTITUDE_COLUMNS[0]]
            pitch = values[ATTITUDE_COLUMNS[1]]
            tilt = math.acos(max(-1.0, min(1.0, math.cos(roll) * math.cos(pitch))))
            max_tilt = max(max_tilt, tilt)
            max_rate = max(max_rate, *(abs(values[name]) for name in RATE_COLUMNS))
            orthogonality, determinant = _matrix_metrics(
                [values[name] for name in ROTATION_COLUMNS]
            )
            max_orthogonality = max(max_orthogonality, orthogonality)
            min_determinant = min(min_determinant, determinant)
            max_determinant_error = max(max_determinant_error, abs(determinant - 1.0))
            q_limit = values["scenarioDiagnostics[13]"]
            allocator_limit_min = min(allocator_limit_min, q_limit)
            allocator_limit_max = max(allocator_limit_max, q_limit)
            command_q = max(values[name] ** 2 for name in MOTOR_COMMAND_COLUMNS)
            applied_q = max(values[name] ** 2 for name in MOTOR_APPLIED_COLUMNS)
            max_motor_command_q = max(max_motor_command_q, command_q)
            max_motor_applied_q = max(max_motor_applied_q, applied_q)
            motor_command_within = motor_command_within and command_q <= q_limit + 1e-8
            motor_applied_within = motor_applied_within and applied_q <= q_limit + 1e-8
            scale_hat_value = values["controllerDiagnostics[11]"]
            scale_apply_value = values["controllerDiagnostics[12]"]
            scale_hat.append(scale_hat_value)
            scale_apply.append(scale_apply_value)
            if role == "hte":
                hte_version_match = hte_version_match and math.isclose(
                    values["controllerDiagnostics[16]"], HTE_VERSION_CODE, abs_tol=1e-8
                )
                hte_scale_hat_projection = hte_scale_hat_projection and (
                    0.75 - 1e-12 <= scale_hat_value <= 1.35 + 1e-12
                )
                hte_scale_apply_projection = hte_scale_apply_projection and (
                    0.75 - 1e-12 <= scale_apply_value <= 1.35 + 1e-12
                )
                hte_fusion_binary = hte_fusion_binary and values[
                    "controllerDiagnostics[13]"
                ] in (0.0, 1.0)
            else:
                v8_padding_zero = v8_padding_zero and all(
                    values[f"controllerDiagnostics[{index}]"] == 0.0
                    for index in range(13, 17)
                )
            disturbance_active.append(
                math.sqrt(
                    math.fsum(values[f"scenarioDiagnostics[{index}]"] ** 2 for index in range(7, 13))
                )
                > 1e-12
            )

    row_count = len(time_values)
    expected_rows = int(round(case.stop_time_s / SAMPLE_TIME_S)) + 1
    time_contract = (
        row_count == expected_rows
        and row_count > 0
        and finite
        and abs(time_values[0]) <= 1e-12
        and abs(time_values[-1] - case.stop_time_s) <= 1e-8
        and all(
            right > left and abs((right - left) - SAMPLE_TIME_S) <= 1e-8
            for left, right in zip(time_values, time_values[1:])
        )
    )
    if finite and row_count:
        rmse = math.sqrt(math.fsum(value * value for value in error_norms) / row_count)
        peak = max(error_norms)
        first_steady = max(0, math.floor(0.8 * row_count))
        steady_count = row_count - first_steady
        signed_mean = tuple(
            math.fsum(error[axis] for error in signed_errors[first_steady:]) / steady_count
            for axis in range(3)
        )
        steady_abs = math.sqrt(math.fsum(value * value for value in signed_mean))
        terminal_start = max(0, row_count - 100)
        scale_terminal = math.fsum(scale_apply[terminal_start:]) / (row_count - terminal_start)
        scale_terminal_deviation = abs(scale_terminal - 1.0)
        false_activation_duration = longest_continuous_duration(
            time_values, [abs(value - 1.0) > 0.04 for value in scale_apply]
        )
        recovery = final_disturbance_recovery(
            time_values, error_norms, disturbance_active
        )
    else:
        rmse = peak = steady_abs = None
        scale_terminal = scale_terminal_deviation = false_activation_duration = None
        recovery = {
            "disturbance_event_count": 0,
            "disturbance_evidence": False,
            "final_disturbance_end_s": None,
            "final_disturbance_recovery_s": None,
        }
        max_tilt = max_rate = max_orthogonality = None
        min_determinant = max_determinant_error = None
        max_motor_command_q = max_motor_applied_q = None
        allocator_limit_min = allocator_limit_max = None

    target_scale = case.mass_scale / case.lift_scale
    terminal_relative_error = (
        None
        if scale_terminal is None
        else abs(scale_terminal - target_scale) / abs(target_scale)
    )
    metrics: dict[str, Any] = {
        "case_id": case.case_id,
        "role": role,
        "category": case.category,
        "trajectory_id": case.trajectory_id,
        "raw_path": str(resolved),
        "raw_sha256": sha256(resolved),
        "samples": row_count,
        "tracking_rmse_m": rmse,
        "tracking_peak_m": peak,
        "steady_abs_error_m": steady_abs,
        "max_rotation_orthogonality_error": max_orthogonality,
        "min_rotation_determinant": min_determinant,
        "max_rotation_determinant_error": max_determinant_error,
        "max_yawless_tilt_rad": max_tilt,
        "max_abs_body_rate_radps": max_rate,
        "max_motor_command_q": max_motor_command_q,
        "max_motor_applied_q": max_motor_applied_q,
        "allocator_limit_min": allocator_limit_min,
        "allocator_limit_max": allocator_limit_max,
        "expected_target_scale": target_scale if role == "hte" else None,
        "scale_apply_terminal": scale_terminal if role == "hte" else None,
        "scale_apply_terminal_relative_error": terminal_relative_error if role == "hte" else None,
        "terminal_scale_deviation_from_one": scale_terminal_deviation if role == "hte" else None,
        "false_activation_continuous_duration_s": false_activation_duration if role == "hte" else None,
        **recovery,
    }
    physical = config["physical_gates"]
    gates: dict[str, bool] = {
        "required_finite_numeric_evidence": finite,
        "required_time_contract": time_contract,
        "required_manifest_scenario_match": scenario_consistent,
        "required_rotation_orthogonality": _gate_le(
            max_orthogonality, float(physical["rotation_orthogonality_tolerance"])
        ),
        "required_positive_rotation_determinant": min_determinant is not None
        and min_determinant > 0.0,
        "required_rotation_determinant_accuracy": _gate_le(
            max_determinant_error, float(physical["rotation_determinant_tolerance"])
        ),
        "required_yawless_tilt_limit": _gate_le(
            max_tilt, float(physical["max_yawless_tilt_rad"])
        ),
        "required_body_rate_limit": _gate_le(
            max_rate, float(physical["max_body_rate_radps"])
        ),
        "required_allocator_limit_evidence": allocator_limit_min is not None
        and allocator_limit_min > 0.0,
        "required_motor_command_limit": finite and motor_command_within,
        "required_motor_applied_limit": finite and motor_applied_within,
    }
    if role == "hte":
        gates.update(
            {
                "required_hte_version_match": finite and hte_version_match,
                "required_hte_scale_hat_projection": finite and hte_scale_hat_projection,
                "required_hte_scale_apply_projection": finite and hte_scale_apply_projection,
                "required_hte_fusion_flag_binary": finite and hte_fusion_binary,
            }
        )
    else:
        gates["required_v8_diagnostic_padding"] = finite and v8_padding_zero
    gates["all_physical_pass"] = all(gates.values())
    return {"case": asdict(case), "metrics": metrics, "physical_gates": gates}


def build_pair_row(
    case: ManifestCase,
    v8: Mapping[str, Any],
    hte: Mapping[str, Any],
    config: Mapping[str, Any],
) -> dict[str, Any]:
    # 所有比较都按同一case_id成对计算，先判物理可行再看性能。
    v8_rmse = v8["metrics"]["tracking_rmse_m"]
    hte_rmse = hte["metrics"]["tracking_rmse_m"]
    ratio = (
        None
        if v8_rmse is None or hte_rmse is None or v8_rmse <= 0.0
        else hte_rmse / v8_rmse
    )
    parameter = config["parameter_gates"]
    comparison = config["comparison_gates"]
    performance: dict[str, bool] = {
        "required_paired_rmse_evidence": ratio is not None and math.isfinite(ratio),
        "required_no_more_than_2pct_rmse_regression": _gate_le(
            ratio, float(parameter["per_case_rmse_ratio_vs_v8_max"])
        ),
    }
    if case.category in {"parameter", "compound"}:
        performance.update(
            {
                "required_parameter_peak_error": _gate_le(
                    hte["metrics"]["tracking_peak_m"],
                    float(parameter["peak_error_m_max"]),
                ),
                "required_parameter_steady_error": _gate_le(
                    hte["metrics"]["steady_abs_error_m"],
                    float(parameter["steady_abs_error_m_max"]),
                ),
            }
        )
    if case.category == "nominal":
        performance.update(
            {
                "required_nominal_terminal_scale_transparency": _gate_le(
                    hte["metrics"]["terminal_scale_deviation_from_one"],
                    float(config["hte_diagnostics"]["terminal_nominal_scale_deviation_max"]),
                ),
                "required_no_sustained_false_activation": (
                    hte["metrics"]["false_activation_continuous_duration_s"]
                    is not None
                    and hte["metrics"]["false_activation_continuous_duration_s"]
                    < float(
                        config["hte_diagnostics"][
                            "false_activation_continuous_duration_max_s"
                        ]
                    )
                ),
            }
        )
    if case.disturbance_mode == "fixed_compound":
        v8_recovery = v8["metrics"]["final_disturbance_recovery_s"]
        hte_recovery = hte["metrics"]["final_disturbance_recovery_s"]
        if v8_recovery is None or hte_recovery is None:
            recovery_ratio = None
        elif v8_recovery <= 1e-12:
            recovery_ratio = 1.0 if hte_recovery <= 1e-12 else None
        else:
            recovery_ratio = hte_recovery / v8_recovery
        performance.update(
            {
                "required_fixed_compound_evidence": bool(
                    hte["metrics"]["disturbance_evidence"]
                ),
                "required_final_disturbance_recovery": _gate_le(
                    hte_recovery,
                    float(comparison["disturbance_recovery_max_s"]),
                ),
                "required_final_disturbance_recovery_pair": _gate_le(
                    recovery_ratio,
                    float(comparison["disturbance_recovery_ratio_vs_v8_max"]),
                ),
            }
        )
    else:
        v8_recovery = hte_recovery = recovery_ratio = None
    performance["all_performance_pass"] = all(performance.values())
    return {
        "case_id": case.case_id,
        "split_id": case.split_id,
        "category": case.category,
        "trajectory_id": case.trajectory_id,
        "scenario_seed": case.scenario_seed,
        "v8_tracking_rmse_m": v8_rmse,
        "hte_tracking_rmse_m": hte_rmse,
        "hte_v8_rmse_ratio": ratio,
        "hte_rmse_improvement_fraction": None if ratio is None else 1.0 - ratio,
        "v8_final_disturbance_recovery_s": v8_recovery,
        "hte_final_disturbance_recovery_s": hte_recovery,
        "hte_v8_final_disturbance_recovery_ratio": recovery_ratio,
        "v8_physical_pass": v8["physical_gates"]["all_physical_pass"],
        "hte_physical_pass": hte["physical_gates"]["all_physical_pass"],
        "paired_physical_pass": v8["physical_gates"]["all_physical_pass"]
        and hte["physical_gates"]["all_physical_pass"],
        "performance_gates": performance,
        "performance_pass": performance["all_performance_pass"],
    }


def add_development_retention(
    pairs: list[dict[str, Any]], hte_rows: Mapping[str, Mapping[str, Any]]
) -> float:
    nominal_by_trajectory: dict[int, float] = {}
    for pair in pairs:
        if pair["category"] != "nominal":
            continue
        value = hte_rows[pair["case_id"]]["metrics"]["tracking_rmse_m"]
        if value is None or value <= 0.0 or pair["trajectory_id"] in nominal_by_trajectory:
            raise EvidenceError("D24 requires one positive HTE nominal RMSE per trajectory")
        nominal_by_trajectory[pair["trajectory_id"]] = value
    if set(nominal_by_trajectory) != set(range(1, 7)):
        raise EvidenceError("D24 nominal trajectory coverage is incomplete")
    retentions: list[float] = []
    for pair in pairs:
        if pair["category"] != "parameter":
            continue
        value = pair["hte_tracking_rmse_m"]
        if value is None:
            raise EvidenceError(f"missing HTE RMSE for {pair['case_id']}")
        retention = value / nominal_by_trajectory[pair["trajectory_id"]]
        pair["hte_parameter_retention_ratio"] = retention
        retentions.append(retention)
    if not retentions:
        raise EvidenceError("D24 has no parameter retention observations")
    return max(retentions)


def final_rule_metrics(pairs: Sequence[Mapping[str, Any]]) -> dict[str, Any]:
    nominal_ratios = [
        pair["hte_v8_rmse_ratio"]
        for pair in pairs
        if pair["category"] == "nominal" and pair["hte_v8_rmse_ratio"] is not None
    ]
    parameter_ratios = [
        pair["hte_v8_rmse_ratio"]
        for pair in pairs
        if pair["category"] == "parameter" and pair["hte_v8_rmse_ratio"] is not None
    ]
    if not nominal_ratios or not parameter_ratios:
        raise EvidenceError("nominal or parameter paired RMSE evidence is incomplete")
    improvements = [1.0 - value for value in parameter_ratios]
    return {
        "nominal_max_rmse_ratio_vs_v8": max(nominal_ratios),
        "nominal_degradation_le_2pct": max(nominal_ratios) <= 1.02,
        "parameter_max_rmse_ratio_vs_v8": max(parameter_ratios),
        "parameter_no_case_regression_over_2pct": max(parameter_ratios) <= 1.02,
        "parameter_median_rmse_improvement_fraction": statistics.median(improvements),
        "parameter_median_improvement_ge_50pct": statistics.median(improvements) >= 0.50,
    }


def compute_holdout_statistics(
    successes: int,
    pairs: Sequence[Mapping[str, Any]],
    final_statistics_path: Path,
    config: Mapping[str, Any],
) -> dict[str, Any]:
    # 统计字段仅在样本和配置满足条件时计算，否则保留未完成状态。
    if len(pairs) != 60:
        raise EvidenceError("H60 statistics require exactly 60 complete pairs")
    module = runpy.run_path(str(require_file(final_statistics_path, "final statistics module")))
    paired_rmse = module["PairedRMSE"]
    observations = tuple(
        paired_rmse(
            case_id=str(pair["case_id"]),
            stratum=str(pair["category"]),
            candidate_rmse=float(pair["hte_tracking_rmse_m"]),
            v8_rmse=float(pair["v8_tracking_rmse_m"]),
        )
        for pair in pairs
    )
    holdout = config["holdout_gates"]
    result = module["evaluate_final_statistics"](
        successes,
        60,
        observations,
        minimum_successes=int(holdout["performance_required"]),
        wilson_minimum=float(holdout["wilson_lower_bound_min"]),
        rmse_ratio_maximum=float(holdout["bootstrap_rmse_ratio_upper_max"]),
        confidence=float(holdout["wilson_one_sided_confidence"]),
        bootstrap_samples=int(holdout["bootstrap_samples"]),
    )
    return result.as_dict()


def build_summary(
    cases: Sequence[ManifestCase],
    v8_rows: Mapping[str, Mapping[str, Any]],
    hte_rows: Mapping[str, Mapping[str, Any]],
    pairs: list[dict[str, Any]],
    candidate: Mapping[str, Any],
    config: Mapping[str, Any],
    final_statistics_path: Path,
) -> dict[str, Any]:
    split_id = cases[0].split_id
    count = len(cases)
    v8_physical = sum(row["physical_gates"]["all_physical_pass"] for row in v8_rows.values())
    hte_physical = sum(row["physical_gates"]["all_physical_pass"] for row in hte_rows.values())
    paired_physical = sum(pair["paired_physical_pass"] for pair in pairs)
    performance = sum(pair["performance_pass"] for pair in pairs)
    final_rules = final_rule_metrics(pairs)
    common = {
        "split_id": split_id,
        "case_count": count,
        "candidate_id": candidate["candidate_id"],
        "v8_physical_pass_count": v8_physical,
        "hte_physical_pass_count": hte_physical,
        "paired_physical_pass_count": paired_physical,
        "performance_pass_count": performance,
        "final_rule_metrics": final_rules,
    }
    if split_id == "D":
        worst_retention = add_development_retention(pairs, hte_rows)
        physical_failures = count - paired_physical
        performance_failures = count - performance
        feasible = paired_physical == 24 and performance == 24
        common["decision"] = {
            "stage": "D24_top2_ranking",
            "feasibility_first": True,
            "physical_required": 24,
            "physical_pass": paired_physical == 24,
            "performance_required": 24,
            "performance_pass": performance == 24,
            "feasible": feasible,
            "worst_parameter_retention_ratio": worst_retention,
            "ranking_key": [
                0 if feasible else 1,
                physical_failures,
                performance_failures,
                worst_retention,
                candidate["candidate_id"],
            ],
            "ranking_rule": (
                "all paired physical and performance gates, then minimum worst "
                "parameter retention"
            ),
            "may_tune_controller": True,
        }
    elif split_id == "V":
        required_physical = int(config["validation_gates"]["physical_required"])
        required_performance = int(config["validation_gates"]["performance_required"])
        common["decision"] = {
            "stage": "V30_locked_validation",
            "physical_required": required_physical,
            "performance_required": required_performance,
            "physical_pass": paired_physical == required_physical,
            "performance_pass": performance >= required_performance,
            "validation_pass": paired_physical == required_physical
            and performance >= required_performance,
            "may_tune_controller": False,
            "validation_results_must_not_tune": True,
        }
    else:
        required_physical = int(config["holdout_gates"]["physical_required"])
        statistics_result = compute_holdout_statistics(
            performance, pairs, final_statistics_path, config
        )
        promotion = (
            paired_physical == required_physical
            and statistics_result["passed"]
            and final_rules["nominal_degradation_le_2pct"]
            and final_rules["parameter_no_case_regression_over_2pct"]
            and final_rules["parameter_median_improvement_ge_50pct"]
        )
        common["holdout_statistics"] = statistics_result
        common["decision"] = {
            "stage": "H60_one_shot_final_selection",
            "physical_required": required_physical,
            "physical_pass": paired_physical == required_physical,
            "performance_required": int(config["holdout_gates"]["performance_required"]),
            "performance_pass": statistics_result["wilson_pass"],
            "bootstrap_pass": statistics_result["bootstrap_pass"],
            "promotion_pass": promotion,
            "may_tune_controller": False,
        }
        common["one_shot_evidence"] = {
            "required": True,
            "complete_60_pairs": len(pairs) == 60,
            "partial_allowed": False,
            "used_for_parameter_adjustment": False,
            "evaluated_utc": utc_now(),
        }
    return common


def write_json_atomic(path: Path, value: Any) -> None:
    # 使用同目录临时文件保证写入过程可恢复。
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    if temporary.exists():
        raise EvidenceError(f"stale JSON temporary exists: {temporary}")
    temporary.write_text(
        json.dumps(value, indent=2, ensure_ascii=False, allow_nan=False) + "\n",
        encoding="utf-8",
    )
    with temporary.open("r", encoding="utf-8") as stream:
        json.load(stream)
    temporary.replace(path)


def _csv_value(value: Any) -> Any:
    if isinstance(value, (dict, list, tuple)):
        return json.dumps(value, ensure_ascii=False, allow_nan=False, separators=(",", ":"))
    if value is None:
        return ""
    return value


def write_csv_atomic(
    path: Path, fieldnames: Sequence[str], rows: Iterable[Mapping[str, Any]]
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    if temporary.exists():
        raise EvidenceError(f"stale CSV temporary exists: {temporary}")
    with temporary.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=fieldnames, lineterminator="\n")
        writer.writeheader()
        for row in rows:
            writer.writerow({name: _csv_value(row.get(name)) for name in fieldnames})
    with temporary.open("r", encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames != list(fieldnames):
            raise EvidenceError(f"CSV header verification failed: {temporary}")
        list(reader)
    temporary.replace(path)


def case_csv_rows(rows: Sequence[Mapping[str, Any]]) -> list[dict[str, Any]]:
    output: list[dict[str, Any]] = []
    for row in rows:
        metrics = row["metrics"]
        output.append(
            {
                **metrics,
                "all_physical_pass": row["physical_gates"]["all_physical_pass"],
                "physical_gates": row["physical_gates"],
            }
        )
    return output


def pair_csv_rows(rows: Sequence[Mapping[str, Any]]) -> list[dict[str, Any]]:
    return [
        {
            **{key: value for key, value in row.items() if key != "performance_gates"},
            "performance_gates": row["performance_gates"],
        }
        for row in rows
    ]


def union_fieldnames(rows: Sequence[Mapping[str, Any]]) -> tuple[str, ...]:
    ordered: list[str] = []
    for row in rows:
        for name in row:
            if name not in ordered:
                ordered.append(name)
    if not ordered:
        raise EvidenceError("cannot write a CSV without rows")
    return tuple(ordered)


def evaluate(args: argparse.Namespace) -> dict[str, Any]:
    # 输出目录必须全新，留出集还要求显式确认一次性使用。
    output = args.output.resolve()
    if output.exists():
        raise EvidenceError(f"refusing to reuse evaluation output directory: {output}")
    cases, manifest_metadata = load_manifest(args.manifest.resolve())
    if args.expected_manifest_sha256 is not None:
        expected = normalize_sha256(args.expected_manifest_sha256, "expected manifest SHA256")
        if manifest_metadata["sha256"] != expected:
            raise EvidenceError(
                f"campaign manifest SHA256 mismatch: {manifest_metadata['sha256']} != {expected}"
            )
    if cases[0].split_id == "H" and not args.acknowledge_holdout_one_shot:
        raise EvidenceError("H60 evaluation requires --acknowledge-holdout-one-shot")
    candidate = load_candidate_parameters(args.candidate_parameters.resolve())
    config = load_config(args.config.resolve())
    v8_paths, v8_evidence = load_raw_evidence(
        args.v8_raw_manifest.resolve(), args.v8_raw_dir.resolve(), "v8", cases
    )
    hte_paths, hte_evidence = load_raw_evidence(
        args.hte_raw_manifest.resolve(), args.hte_raw_dir.resolve(), "hte", cases
    )
    if set(v8_paths) != set(hte_paths):
        raise EvidenceError("V8 and HTE raw case sets are not identical")
    paired_execution = load_pair_execution_contract(
        args.v8_raw_manifest,
        args.hte_raw_manifest,
        manifest_metadata,
        candidate,
        cases,
    )

    v8_rows = {
        case.case_id: evaluate_raw_file(v8_paths[case.case_id], case, "v8", config)
        for case in cases
    }
    hte_rows = {
        case.case_id: evaluate_raw_file(hte_paths[case.case_id], case, "hte", config)
        for case in cases
    }
    pairs = [
        build_pair_row(case, v8_rows[case.case_id], hte_rows[case.case_id], config)
        for case in cases
    ]
    summary = build_summary(
        cases,
        v8_rows,
        hte_rows,
        pairs,
        candidate,
        config,
        args.final_statistics.resolve(),
    )
    summary.update(
        {
            "schema_version": SCHEMA_VERSION,
            "evaluator": Path(__file__).name,
            "evaluator_sha256": sha256(Path(__file__).resolve()),
            "created_utc": utc_now(),
            "input_evidence": {
                "campaign_manifest": manifest_metadata,
                "v8_raw": v8_evidence,
                "hte_raw": hte_evidence,
                "candidate_parameters": candidate,
                "paired_execution": paired_execution,
                "campaign_contract": {
                    "path": str(args.config.resolve()),
                    "sha256": sha256(args.config.resolve()),
                },
                "final_statistics": {
                    "path": str(args.final_statistics.resolve()),
                    "sha256": sha256(args.final_statistics.resolve()),
                },
            },
        }
    )

    output.mkdir(parents=True, exist_ok=False)
    case_rows = [*v8_rows.values(), *hte_rows.values()]
    artifacts = {
        "case_metrics_json": output / "case_metrics.json",
        "case_metrics_csv": output / "case_metrics.csv",
        "paired_metrics_json": output / "paired_metrics.json",
        "paired_metrics_csv": output / "paired_metrics.csv",
        "summary_json": output / "summary.json",
        "summary_csv": output / "summary.csv",
    }
    write_json_atomic(artifacts["case_metrics_json"], case_rows)
    case_flat = case_csv_rows(case_rows)
    write_csv_atomic(
        artifacts["case_metrics_csv"], union_fieldnames(case_flat), case_flat
    )
    write_json_atomic(artifacts["paired_metrics_json"], pairs)
    pair_flat = pair_csv_rows(pairs)
    write_csv_atomic(
        artifacts["paired_metrics_csv"], union_fieldnames(pair_flat), pair_flat
    )
    write_json_atomic(artifacts["summary_json"], summary)
    summary_flat = {
        "split_id": summary["split_id"],
        "case_count": summary["case_count"],
        "candidate_id": summary["candidate_id"],
        "v8_physical_pass_count": summary["v8_physical_pass_count"],
        "hte_physical_pass_count": summary["hte_physical_pass_count"],
        "paired_physical_pass_count": summary["paired_physical_pass_count"],
        "performance_pass_count": summary["performance_pass_count"],
        "final_rule_metrics": summary["final_rule_metrics"],
        "decision": summary["decision"],
        "holdout_statistics": summary.get("holdout_statistics"),
        "one_shot_evidence": summary.get("one_shot_evidence"),
    }
    write_csv_atomic(artifacts["summary_csv"], tuple(summary_flat), [summary_flat])
    artifact_records = {
        name: {"path": str(path), "sha256": sha256(path)}
        for name, path in artifacts.items()
    }
    output_manifest = output / "output_manifest.json"
    write_json_atomic(
        output_manifest,
        {
            "schema_version": SCHEMA_VERSION,
            "split_id": summary["split_id"],
            "candidate_id": summary["candidate_id"],
            "artifacts": artifact_records,
        },
    )
    result = {
        "summary": summary,
        "artifacts": artifact_records,
        "output_manifest": {
            "path": str(output_manifest),
            "sha256": sha256(output_manifest),
        },
    }
    print("A8_MANIFEST_CAMPAIGN_EVALUATION=" + json.dumps(result, ensure_ascii=False))
    return result


def parse_args() -> argparse.Namespace:
    workspace = Path(__file__).resolve().parents[2]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--v8-raw-manifest", type=Path, required=True)
    parser.add_argument("--v8-raw-dir", type=Path, required=True)
    parser.add_argument("--hte-raw-manifest", type=Path, required=True)
    parser.add_argument("--hte-raw-dir", type=Path, required=True)
    parser.add_argument("--candidate-parameters", type=Path, required=True)
    parser.add_argument("--expected-manifest-sha256")
    parser.add_argument("--config", type=Path, default=workspace / "config" / "campaign.toml")
    parser.add_argument(
        "--final-statistics",
        type=Path,
        default=workspace / "02_scripts" / "evaluation" / "final_statistics.py",
    )
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--acknowledge-holdout-one-shot", action="store_true")
    return parser.parse_args()


def main() -> int:
    evaluate(parse_args())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
