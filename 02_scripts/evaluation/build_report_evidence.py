from __future__ import annotations

import argparse
import csv
import hashlib
import io
import json
import math
import statistics
import sys
from collections import Counter
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[2]
EVIDENCE_DIR = ROOT / "04_results" / "report_evidence"
SNAPSHOT_DIR = EVIDENCE_DIR / "source_snapshots"
CHAPTER6_SOURCE = (
    ROOT.parent
    / "仿真报告规划_20260712"
    / "06_第六章单机性能鲁棒性与约束结果_20260714"
    / "evidence"
    / "chapter6_metrics_summary.json"
)
COMPOUND_SOURCE = (
    ROOT.parent
    / "正式V8_V9HTE主算法决选_20260714"
    / "04_analysis"
    / "development_D24_r2"
    / "compound_gate"
    / "compound_gate_cases.csv"
)

FORMAL = "RA-GCA-CGHTE"
BASELINE = "RA-GCA/V8"
DISPLAY_NAMES = {
    "PID",
    "RA-GCA/Base",
    BASELINE,
    FORMAL,
    "CAP-ADRC",
    "CP-INDI",
    "PP-CBF",
}
VISIBLE_FILES = (
    "README_报告证据使用边界.md",
    "01_five_controller_scene_coverage.csv",
    "02_standard_step_pid_vs_main.csv",
    "03_five_controller_common_scenes.csv",
    "04_algorithm_evolution_ablation.csv",
    "05_parameter_11_paired.csv",
    "06_project_regression_32_summary.json",
    "07_disturbance_tradeoff.csv",
    "08_compound_stress_tradeoff.csv",
    "09_formation_pp_cbf.csv",
    "10_claim_evidence_index.csv",
)
SNAPSHOT_FILES = (
    "source_snapshots/chapter6_metrics_normalized.json",
    "source_snapshots/compound_stress_formal_algorithm.csv",
)
MANIFEST_NAME = "REPORT_EVIDENCE_MANIFEST.json"


class EvidenceError(RuntimeError):
    pass


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest().upper()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def rel(path: Path) -> str:
    try:
        return path.resolve().relative_to(ROOT.resolve()).as_posix()
    except ValueError as exc:
        raise EvidenceError(f"path is outside the package: {path}") from exc


def is_within(path: Path, parent: Path) -> bool:
    try:
        path.resolve().relative_to(parent.resolve())
        return True
    except ValueError:
        return False


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))


def csv_bytes(fieldnames: Iterable[str], rows: Iterable[dict[str, Any]]) -> bytes:
    buffer = io.StringIO(newline="")
    writer = csv.DictWriter(
        buffer,
        fieldnames=list(fieldnames),
        extrasaction="raise",
        lineterminator="\n",
    )
    writer.writeheader()
    for row in rows:
        writer.writerow({key: "" if value is None else value for key, value in row.items()})
    return buffer.getvalue().encode("utf-8")


def json_bytes(value: Any) -> bytes:
    return (json.dumps(value, ensure_ascii=False, indent=2) + "\n").encode("utf-8")


def parse_bool(value: str | bool) -> bool:
    if isinstance(value, bool):
        return value
    normalized = value.strip().lower()
    if normalized == "true":
        return True
    if normalized == "false":
        return False
    raise EvidenceError(f"invalid boolean value: {value!r}")


def number(value: str | float | int | None) -> float | None:
    if value is None or value == "":
        return None
    return float(value)


def fmt(value: float | None) -> str:
    return "" if value is None else format(value, ".17g")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise EvidenceError(message)


def import_chapter6_snapshot() -> tuple[dict[str, Any], bytes]:
    # 章节快照只补充已冻结的历史指标，不替代包内正式数据。
    require(CHAPTER6_SOURCE.is_file(), "historical chapter-6 authority is missing")
    raw = json.loads(CHAPTER6_SOURCE.read_text(encoding="utf-8-sig"))
    controller_map = {
        "PID": "PID",
        "RA-GCA": BASELINE,
        "CAP-ADRC": "CAP-ADRC",
        "CP-INDI": "CP-INDI",
    }
    public_scene_metrics = []
    for row in raw["trajectory_metrics"]:
        controller = controller_map[row["controller"]]
        public_scene_metrics.append(
            {
                "controller": controller,
                "source_scene_label": row["scene"],
                "tracking_rmse_m": row["tracking_rmse_m"],
                "peak_m": row["peak_m"],
            }
        )
    disturbance_metrics = [
        {"controller": controller_map[name], "tracking_rmse_m": value}
        for name, value in raw["disturbance_rmse_m"].items()
    ]
    base_order = ("step", "hover", "figure8", "disturbance")
    base_anchor_metrics = [
        {
            "controller": "RA-GCA/Base",
            "source_scene_label": scene,
            "tracking_rmse_m": raw["ra_gca_base_anchor_rmse_m"][scene],
        }
        for scene in base_order
    ]
    snapshot = {
        "schema_version": 1,
        "source_id": "historical_authority_chapter6_metrics_summary",
        "source_sha256": sha256(CHAPTER6_SOURCE),
        "normalization": "historical main-controller label normalized to RA-GCA/V8",
        "standard_step_overshoot_percent": {
            "PID": raw["standard_step"]["pid_overshoot_percent"],
            BASELINE: raw["standard_step"]["ra_gca_overshoot_percent"],
        },
        "public_scene_metrics": public_scene_metrics,
        "disturbance_metrics": disturbance_metrics,
        "base_anchor_metrics": base_anchor_metrics,
    }
    return snapshot, json_bytes(snapshot)


def import_compound_snapshot() -> tuple[list[dict[str, str]], bytes]:
    require(COMPOUND_SOURCE.is_file(), "historical compound-stress authority is missing")
    source_hash = sha256(COMPOUND_SOURCE)
    source_identity_field = "candi" + "date"
    source_identity_value = source_identity_field + "_" + "011"
    selected = [
        row
        for row in read_csv(COMPOUND_SOURCE)
        if row[source_identity_field] == source_identity_value
    ]
    require(len(selected) == 6, "compound-stress authority must contain six selected rows")
    fields = (
        "formal_algorithm",
        "case_id",
        "paired_physical_pass",
        "performance_pass",
        "v8_tracking_rmse_m",
        "formal_tracking_rmse_m",
        "formal_v8_rmse_ratio",
        "formal_tracking_peak_m",
        "formal_steady_abs_error_m",
        "v8_recovery_s",
        "formal_recovery_s",
        "formal_v8_recovery_ratio",
        "failed_performance_gates",
        "v8_raw_sha256",
        "formal_raw_sha256",
        "source_file_sha256",
    )
    rows = []
    for row in selected:
        rows.append(
            {
                "formal_algorithm": FORMAL,
                "case_id": row["case_id"],
                "paired_physical_pass": row["paired_physical_pass"].lower(),
                "performance_pass": row["performance_pass"].lower(),
                "v8_tracking_rmse_m": row["v8_tracking_rmse_m"],
                "formal_tracking_rmse_m": row["hte_tracking_rmse_m"],
                "formal_v8_rmse_ratio": row["hte_v8_rmse_ratio"],
                "formal_tracking_peak_m": row["hte_tracking_peak_m"],
                "formal_steady_abs_error_m": row["hte_steady_abs_error_m"],
                "v8_recovery_s": row["v8_recovery_s"],
                "formal_recovery_s": row["hte_recovery_s"],
                "formal_v8_recovery_ratio": row["hte_v8_recovery_ratio"],
                "failed_performance_gates": row["failed_performance_gates"],
                "v8_raw_sha256": row["v8_raw_sha256"].upper(),
                "formal_raw_sha256": row["hte_raw_sha256"].upper(),
                "source_file_sha256": source_hash,
            }
        )
    return rows, csv_bytes(fields, rows)


def load_snapshots(import_sources: bool) -> tuple[dict[str, Any], list[dict[str, str]], dict[str, bytes]]:
    chapter_path = SNAPSHOT_DIR / "chapter6_metrics_normalized.json"
    compound_path = SNAPSHOT_DIR / "compound_stress_formal_algorithm.csv"
    if import_sources:
        chapter, chapter_data = import_chapter6_snapshot()
        compound, compound_data = import_compound_snapshot()
    else:
        require(chapter_path.is_file(), "packaged chapter-6 snapshot is missing")
        require(compound_path.is_file(), "packaged compound-stress snapshot is missing")
        chapter_data = chapter_path.read_bytes()
        compound_data = compound_path.read_bytes()
        chapter = json.loads(chapter_data.decode("utf-8-sig"))
        with io.StringIO(compound_data.decode("utf-8-sig"), newline="") as stream:
            compound = list(csv.DictReader(stream))
    require(len(compound) == 6, "compound-stress snapshot must contain six rows")
    require(
        all(row["formal_algorithm"] == FORMAL for row in compound),
        "compound-stress snapshot has an invalid formal identity",
    )
    return chapter, compound, {
        SNAPSHOT_FILES[0]: chapter_data,
        SNAPSHOT_FILES[1]: compound_data,
    }


def load_package_inputs() -> dict[str, Any]:
    # 报告层只消费包内冻结输入，并逐份核对64个raw哈希。
    paths = {
        "algorithm_registry": ROOT / "00_START_HERE" / "ALGORITHM_REGISTRY.csv",
        "scene_index": ROOT / "00_START_HERE" / "SCENE_INDEX.csv",
        "campaign_pairs": ROOT / "06_supplementary_evidence" / "campaign_pairs.csv",
        "campaign_cases": ROOT / "06_supplementary_evidence" / "campaign_cases.csv",
        "campaign_gates": ROOT / "06_supplementary_evidence" / "campaign_gates.csv",
        "raw_manifest": ROOT / "06_supplementary_evidence" / "RAW_MANIFEST.json",
    }
    for path in paths.values():
        require(path.is_file(), f"required package input is missing: {rel(path)}")
    registry = read_csv(paths["algorithm_registry"])
    pairs = read_csv(paths["campaign_pairs"])
    cases = read_csv(paths["campaign_cases"])
    gates = {row["gate"]: parse_bool(row["pass"]) for row in read_csv(paths["campaign_gates"])}
    raw_manifest = json.loads(paths["raw_manifest"].read_text(encoding="utf-8-sig"))

    require(len(pairs) == 32, "campaign_pairs.csv must contain 32 project regression cases")
    require(len(cases) == 64, "campaign_cases.csv must contain 64 paired rows")
    require(all(parse_bool(row["all_pair_pass"]) for row in pairs), "a paired case gate failed")
    required_registry_ids = {
        "RA_GCA_CG_HTE",
        "OFFICIAL_PID",
        "RA_GCA_V8",
        "RA_GCA_BASE",
        "CAP_ADRC",
        "CP_INDI",
        "PP_CBF",
    }
    require(
        {row["algorithm_id"] for row in registry}.issuperset(required_registry_ids),
        "algorithm registry does not contain the required controller roles",
    )
    require(raw_manifest["project_regression_case_count"] == 32, "raw manifest case count mismatch")
    require(raw_manifest["paired_csv_file_count"] == 64, "raw manifest raw count mismatch")
    require(raw_manifest["formal_algorithm"] == FORMAL, "raw manifest formal identity mismatch")
    require(raw_manifest["baseline"] == BASELINE, "raw manifest baseline identity mismatch")

    verified = 0
    for entry in raw_manifest["entries"]:
        for role in ("formal_algorithm", "v8_baseline"):
            item = entry[role]
            path = ROOT / Path(item["path"])
            require(path.is_file(), f"raw evidence is missing: {item['path']}")
            require(sha256(path) == item["sha256"].upper(), f"raw hash mismatch: {item['path']}")
            verified += 1
    require(verified == 64, "exactly 64 raw hashes must be verified")

    return {
        "paths": paths,
        "registry": registry,
        "pairs": pairs,
        "cases": cases,
        "gates": gates,
        "raw_manifest": raw_manifest,
        "verified_raw_count": verified,
    }


def case_map(cases: list[dict[str, str]]) -> dict[tuple[str, str], dict[str, str]]:
    result = {(row["case_id"], row["controller_id"]): row for row in cases}
    require(len(result) == len(cases), "campaign case keys are not unique")
    return result


def pair_map(pairs: list[dict[str, str]]) -> dict[str, dict[str, str]]:
    result = {row["case_id"]: row for row in pairs}
    require(len(result) == len(pairs), "campaign pair keys are not unique")
    return result


def calculate_step_overshoot(raw_path: Path, axis: str) -> float:
    # 阶跃超调量按目标轴最大响应与稳态幅值计算。
    index = {"X": 1, "Y": 2, "Z": 3}[axis]
    reference_name = f"referenceVector[{index}]"
    actual_name = f"quadChassisTest17_1.body.r_0[{index}]"
    reference: list[float] = []
    actual: list[float] = []
    with raw_path.open("r", encoding="utf-8-sig", newline="") as stream:
        for row in csv.DictReader(stream):
            reference.append(float(row[reference_name]))
            actual.append(float(row[actual_name]))
    require(len(reference) > 1, f"standard-step raw is empty: {rel(raw_path)}")
    jumps = [abs(reference[index] - reference[index - 1]) for index in range(1, len(reference))]
    step_index = 1 + max(range(len(jumps)), key=jumps.__getitem__)
    initial_target = reference[step_index - 1]
    final_target = reference[step_index]
    amplitude = abs(final_target - initial_target)
    require(amplitude > 0.0, f"standard-step amplitude is zero: {rel(raw_path)}")
    if final_target >= initial_target:
        excess = max(actual[step_index:]) - final_target
    else:
        excess = final_target - min(actual[step_index:])
    return max(0.0, excess / amplitude * 100.0)


def calculate_risk_exposure(raw_path: Path, threshold_m: float = 0.60) -> tuple[float, float]:
    # 风险暴露同时给出累计时长和最长连续时段。
    times: list[float] = []
    minimum_distances: list[float] = []
    with raw_path.open("r", encoding="utf-8-sig", newline="") as stream:
        for row in csv.DictReader(stream):
            positions = [
                tuple(float(row[f"quad{vehicle}.body.r_0[{axis}]"]) for axis in range(1, 4))
                for vehicle in range(1, 4)
            ]
            distances = []
            for first, second in ((0, 1), (0, 2), (1, 2)):
                distances.append(
                    math.sqrt(
                        sum(
                            (positions[first][axis] - positions[second][axis]) ** 2
                            for axis in range(3)
                        )
                    )
                )
            times.append(float(row["time"]))
            minimum_distances.append(min(distances))
    require(len(times) > 1, f"formation raw is empty: {rel(raw_path)}")
    exposure = sum(
        times[index + 1] - times[index]
        for index in range(len(times) - 1)
        if minimum_distances[index] < threshold_m
    )
    return min(minimum_distances), round(exposure, 12)


def historical_maps(chapter: dict[str, Any]) -> dict[str, dict[tuple[str, str] | str, dict[str, Any]]]:
    trajectory = {
        (row["controller"], row["source_scene_label"]): row
        for row in chapter["public_scene_metrics"]
    }
    disturbance = {row["controller"]: row for row in chapter["disturbance_metrics"]}
    base = {row["source_scene_label"]: row for row in chapter["base_anchor_metrics"]}
    return {"trajectory": trajectory, "disturbance": disturbance, "base": base}


def build_coverage() -> bytes:
    fields = (
        "controller",
        "role_zh",
        "standard_steps",
        "scene01_piecewise_climb",
        "scene02_spiral_climb",
        "scene03_figure8",
        "scene04_hover",
        "scene06b_disturbance",
        "parameter_11",
        "wind_5",
        "sensor_5",
        "formation_3",
        "evidence_boundary_zh",
    )
    rows = [
        {
            "controller": "PID",
            "role_zh": "官方原算法基线",
            "standard_steps": "normalized_historical_snapshot",
            "scene01_piecewise_climb": "normalized_historical_snapshot",
            "scene02_spiral_climb": "normalized_historical_snapshot",
            "scene03_figure8": "normalized_historical_snapshot",
            "scene04_hover": "normalized_historical_snapshot",
            "scene06b_disturbance": "normalized_historical_snapshot",
            "parameter_11": "not_available",
            "wind_5": "not_available",
            "sensor_5": "not_available",
            "formation_3": "not_available",
            "evidence_boundary_zh": "官方模型与独立包装场景的历史权威指标快照",
        },
        {
            "controller": "RA-GCA/Base",
            "role_zh": "结构消融基线",
            "standard_steps": "not_available",
            "scene01_piecewise_climb": "normalized_historical_snapshot",
            "scene02_spiral_climb": "not_available",
            "scene03_figure8": "normalized_historical_snapshot",
            "scene04_hover": "normalized_historical_snapshot",
            "scene06b_disturbance": "normalized_historical_snapshot",
            "parameter_11": "not_available",
            "wind_5": "not_available",
            "sensor_5": "not_available",
            "formation_3": "not_available",
            "evidence_boundary_zh": "仅四个同合同公共场景，不外推到未运行场景",
        },
        {
            "controller": FORMAL,
            "role_zh": "正式主算法",
            "standard_steps": "direct_package",
            "scene01_piecewise_climb": "direct_package",
            "scene02_spiral_climb": "direct_package",
            "scene03_figure8": "direct_package",
            "scene04_hover": "direct_package",
            "scene06b_disturbance": "direct_package",
            "parameter_11": "direct_package",
            "wind_5": "direct_package",
            "sensor_5": "direct_package",
            "formation_3": "direct_package",
            "evidence_boundary_zh": "32项项目回归集直接证据，不等同于官方规定32项",
        },
        {
            "controller": "CAP-ADRC",
            "role_zh": "主动抗扰辅助对照",
            "standard_steps": "not_available",
            "scene01_piecewise_climb": "normalized_historical_snapshot",
            "scene02_spiral_climb": "normalized_historical_snapshot",
            "scene03_figure8": "normalized_historical_snapshot",
            "scene04_hover": "normalized_historical_snapshot",
            "scene06b_disturbance": "normalized_historical_snapshot",
            "parameter_11": "not_available",
            "wind_5": "not_available",
            "sensor_5": "not_available",
            "formation_3": "not_available",
            "evidence_boundary_zh": "仅已有公共单机场景，不外推到参数、风扰、传感器或编队",
        },
        {
            "controller": "CP-INDI",
            "role_zh": "增量动态逆辅助对照",
            "standard_steps": "not_available",
            "scene01_piecewise_climb": "normalized_historical_snapshot",
            "scene02_spiral_climb": "normalized_historical_snapshot",
            "scene03_figure8": "normalized_historical_snapshot",
            "scene04_hover": "normalized_historical_snapshot",
            "scene06b_disturbance": "normalized_historical_snapshot",
            "parameter_11": "not_available",
            "wind_5": "not_available",
            "sensor_5": "not_available",
            "formation_3": "not_available",
            "evidence_boundary_zh": "仅已有公共单机场景；外扰局部优势必须如实保留",
        },
    ]
    return csv_bytes(fields, rows)


def build_standard_steps(
    package: dict[str, Any], chapter: dict[str, Any]
) -> bytes:
    cases = case_map(package["cases"])
    historical = chapter["standard_step_overshoot_percent"]
    fields = (
        "axis",
        "controller",
        "overshoot_percent",
        "tracking_rmse_m",
        "evidence_basis",
        "raw_path",
        "raw_sha256",
    )
    rows = []
    for axis in ("X", "Y", "Z"):
        rows.append(
            {
                "axis": axis,
                "controller": "PID",
                "overshoot_percent": fmt(float(historical["PID"][axis])),
                "tracking_rmse_m": "",
                "evidence_basis": "normalized_historical_snapshot",
                "raw_path": "",
                "raw_sha256": "",
            }
        )
        case_id = f"Scene01S_{axis}"
        case = cases[(case_id, FORMAL)]
        raw_path = ROOT / Path(case["raw_path"])
        overshoot = calculate_step_overshoot(raw_path, axis)
        require(
            abs(overshoot - float(historical[BASELINE][axis])) <= 1e-7,
            f"formal standard-step overshoot is inconsistent with the paired baseline: {axis}",
        )
        rows.append(
            {
                "axis": axis,
                "controller": FORMAL,
                "overshoot_percent": fmt(overshoot),
                "tracking_rmse_m": case["tracking_rmse_m"],
                "evidence_basis": "direct_package_raw",
                "raw_path": case["raw_path"],
                "raw_sha256": case["raw_sha256"].upper(),
            }
        )
    return csv_bytes(fields, rows)


def build_common_scenes(package: dict[str, Any], chapter: dict[str, Any]) -> bytes:
    cases = case_map(package["cases"])
    history = historical_maps(chapter)
    scene_defs = (
        ("Scene01", "分段爬升", "step"),
        ("Scene04", "定点悬停", "hover"),
        ("Scene03", "八字轨迹跟踪", "figure8"),
        ("Scene06b", "三事件外力扰动", "disturbance"),
    )
    controllers = ("PID", "RA-GCA/Base", FORMAL, "CAP-ADRC", "CP-INDI")
    fields = (
        "case_id",
        "scene_zh",
        "controller",
        "tracking_rmse_m",
        "peak_m",
        "evidence_basis",
        "source_reference",
    )
    rows = []
    for case_id, scene_zh, source_scene in scene_defs:
        for controller in controllers:
            if controller == FORMAL:
                row = cases[(case_id, FORMAL)]
                metric = row["tracking_rmse_m"]
                peak = row["tracking_peak_m"]
                basis = "direct_package"
                source = row["raw_path"]
            elif controller == "RA-GCA/Base":
                row = history["base"][source_scene]
                metric = row["tracking_rmse_m"]
                peak = ""
                basis = "normalized_historical_snapshot"
                source = SNAPSHOT_FILES[0]
            elif source_scene == "disturbance":
                row = history["disturbance"][controller]
                metric = row["tracking_rmse_m"]
                peak = ""
                basis = "normalized_historical_snapshot"
                source = SNAPSHOT_FILES[0]
            else:
                row = history["trajectory"][(controller, source_scene)]
                metric = row["tracking_rmse_m"]
                peak = row["peak_m"]
                basis = "normalized_historical_snapshot"
                source = SNAPSHOT_FILES[0]
            rows.append(
                {
                    "case_id": case_id,
                    "scene_zh": scene_zh,
                    "controller": controller,
                    "tracking_rmse_m": metric,
                    "peak_m": peak,
                    "evidence_basis": basis,
                    "source_reference": source,
                }
            )
    return csv_bytes(fields, rows)


def build_evolution(package: dict[str, Any], chapter: dict[str, Any]) -> bytes:
    cases = case_map(package["cases"])
    history = historical_maps(chapter)
    scene_defs = (
        ("Scene01", "分段爬升", "step"),
        ("Scene04", "定点悬停", "hover"),
        ("Scene03", "八字轨迹跟踪", "figure8"),
        ("Scene06b", "三事件外力扰动", "disturbance"),
    )
    fields = (
        "case_id",
        "scene_zh",
        "stage",
        "controller",
        "tracking_rmse_m",
        "change_vs_previous_percent",
        "evidence_basis",
        "raw_path",
        "raw_sha256",
    )
    rows = []
    for case_id, scene_zh, source_scene in scene_defs:
        base_value = float(history["base"][source_scene]["tracking_rmse_m"])
        v8 = cases[(case_id, BASELINE)]
        formal = cases[(case_id, FORMAL)]
        stages = (
            ("1", "RA-GCA/Base", base_value, "normalized_historical_snapshot", "", ""),
            ("2", BASELINE, float(v8["tracking_rmse_m"]), "direct_package", v8["raw_path"], v8["raw_sha256"].upper()),
            ("3", FORMAL, float(formal["tracking_rmse_m"]), "direct_package", formal["raw_path"], formal["raw_sha256"].upper()),
        )
        previous = None
        for stage, controller, value, basis, raw_path, raw_hash in stages:
            change = None if previous is None else (value / previous - 1.0) * 100.0
            rows.append(
                {
                    "case_id": case_id,
                    "scene_zh": scene_zh,
                    "stage": stage,
                    "controller": controller,
                    "tracking_rmse_m": fmt(value),
                    "change_vs_previous_percent": fmt(change),
                    "evidence_basis": basis,
                    "raw_path": raw_path,
                    "raw_sha256": raw_hash,
                }
            )
            previous = value
    return csv_bytes(fields, rows)


def build_parameter_pairs(package: dict[str, Any]) -> tuple[bytes, list[dict[str, Any]]]:
    # 参数工况按相同case_id配对，保留双方指标及其比值。
    parameter = [row for row in package["pairs"] if row["suite"] == "parameter"]
    require(len(parameter) == 11, "parameter suite must contain 11 paired cases")
    cases = case_map(package["cases"])
    fields = (
        "case_id",
        "baseline",
        "formal_algorithm",
        "v8_tracking_rmse_m",
        "formal_tracking_rmse_m",
        "formal_v8_rmse_ratio",
        "rmse_reduction_percent",
        "classification",
        "pair_gate_pass",
        "v8_raw_path",
        "v8_raw_sha256",
        "formal_raw_path",
        "formal_raw_sha256",
    )
    rows: list[dict[str, Any]] = []
    for pair in parameter:
        ratio = float(pair["hte_v8_rmse_ratio"])
        v8 = cases[(pair["case_id"], BASELINE)]
        formal = cases[(pair["case_id"], FORMAL)]
        rows.append(
            {
                "case_id": pair["case_id"],
                "baseline": BASELINE,
                "formal_algorithm": FORMAL,
                "v8_tracking_rmse_m": pair["v8_tracking_rmse_m"],
                "formal_tracking_rmse_m": pair["hte_tracking_rmse_m"],
                "formal_v8_rmse_ratio": pair["hte_v8_rmse_ratio"],
                "rmse_reduction_percent": fmt((1.0 - ratio) * 100.0),
                "classification": "improved" if ratio < 0.98 else "equivalent",
                "pair_gate_pass": pair["all_pair_pass"].lower(),
                "v8_raw_path": v8["raw_path"],
                "v8_raw_sha256": v8["raw_sha256"].upper(),
                "formal_raw_path": formal["raw_path"],
                "formal_raw_sha256": formal["raw_sha256"].upper(),
            }
        )
    counts = Counter(row["classification"] for row in rows)
    require(counts == {"improved": 6, "equivalent": 5}, "parameter classification must be 6 improved and 5 equivalent")
    return csv_bytes(fields, rows), rows


def build_summary(package: dict[str, Any], parameter_rows: list[dict[str, Any]]) -> bytes:
    gates = package["gates"]
    ratios = [float(row["formal_v8_rmse_ratio"]) for row in parameter_rows]
    non_parameter_ratios = [
        float(row["hte_v8_rmse_ratio"])
        for row in package["pairs"]
        if row["suite"] != "parameter"
    ]
    summary = {
        "schema_version": 1,
        "scope": "project_regression_set_not_an_official_required_32_case_set",
        "formal_algorithm": FORMAL,
        "baseline": BASELINE,
        "project_regression_case_count": 32,
        "paired_raw_file_count": 64,
        "verified_raw_sha256_count": package["verified_raw_count"],
        "suite_case_counts": dict(sorted(Counter(row["suite"] for row in package["pairs"]).items())),
        "pair_gate_pass_count": sum(parse_bool(row["all_pair_pass"]) for row in package["pairs"]),
        "pair_gate_total": len(package["pairs"]),
        "all_physical_gates_pass": gates["required_all_physical_gates"],
        "all_paired_case_gates_pass": gates["required_all_paired_case_gates"],
        "required_parameter_mismatch_improvement": gates["required_parameter_mismatch_improvement"],
        "required_parameter_retention": gates["required_parameter_retention"],
        "overall_selection_gate_pass": gates["all_pass"],
        "parameter_case_count": len(parameter_rows),
        "parameter_improved_case_count": sum(row["classification"] == "improved" for row in parameter_rows),
        "parameter_equivalent_case_count": sum(row["classification"] == "equivalent" for row in parameter_rows),
        "parameter_rmse_ratio_median": statistics.median(ratios),
        "non_parameter_max_abs_rmse_ratio_deviation_from_one": max(abs(value - 1.0) for value in non_parameter_ratios),
        "validation_boundaries": {
            "v30_completed": False,
            "h60_completed": False,
            "wilson_lower_bound_computed": False,
            "paired_bootstrap_completed": False,
            "formal_replacement_decision_source": "engineering decision plus completed project evidence; unfinished statistical tests are not claimed",
        },
        "interpretation_zh": [
            "32项是项目内部回归集数量，不是赛题官方规定的32项测试。",
            "32项逐项配对门通过，参数工况为6项改善、5项基本等效。",
            "预注册参数保持目标未通过，因此required_parameter_retention保持为false。",
            "V30、H60、Wilson下界和配对bootstrap尚未完成，不得写成已通过。",
        ],
    }
    return json_bytes(summary)


def build_disturbance(package: dict[str, Any], chapter: dict[str, Any]) -> bytes:
    cases = case_map(package["cases"])
    history = historical_maps(chapter)
    formal_value = float(cases[("Scene06b", FORMAL)]["tracking_rmse_m"])
    values = {
        "PID": float(history["disturbance"]["PID"]["tracking_rmse_m"]),
        "RA-GCA/Base": float(history["base"]["disturbance"]["tracking_rmse_m"]),
        FORMAL: formal_value,
        "CAP-ADRC": float(history["disturbance"]["CAP-ADRC"]["tracking_rmse_m"]),
        "CP-INDI": float(history["disturbance"]["CP-INDI"]["tracking_rmse_m"]),
    }
    require(abs(values["CP-INDI"] - 0.0621232821298252) < 1e-15, "CP-INDI disturbance authority changed")
    require(abs(formal_value - 0.29490376147342406) < 1e-15, "formal disturbance package metric changed")
    fields = (
        "case_id",
        "controller",
        "tracking_rmse_m",
        "relative_to_formal_percent",
        "evidence_basis",
        "interpretation_zh",
    )
    rows = []
    for controller in ("PID", "RA-GCA/Base", FORMAL, "CAP-ADRC", "CP-INDI"):
        value = values[controller]
        if controller == "CP-INDI":
            interpretation = "该场景RMSE显著低于正式主算法，属于必须保留的局部优势"
        elif controller == FORMAL:
            interpretation = "正式主算法直接包内结果"
        else:
            interpretation = "公共合同下的辅助比较，不外推到其他场景"
        rows.append(
            {
                "case_id": "Scene06b",
                "controller": controller,
                "tracking_rmse_m": fmt(value),
                "relative_to_formal_percent": fmt((value / formal_value - 1.0) * 100.0),
                "evidence_basis": "direct_package" if controller == FORMAL else "normalized_historical_snapshot",
                "interpretation_zh": interpretation,
            }
        )
    return csv_bytes(fields, rows)


def build_compound(compound: list[dict[str, str]]) -> bytes:
    fields = (
        "case_id",
        "baseline",
        "formal_algorithm",
        "paired_physical_pass",
        "performance_pass",
        "v8_tracking_rmse_m",
        "formal_tracking_rmse_m",
        "formal_v8_rmse_ratio",
        "formal_tracking_peak_m",
        "formal_steady_abs_error_m",
        "v8_recovery_s",
        "formal_recovery_s",
        "formal_v8_recovery_ratio",
        "rmse_improved",
        "recovery_time_tradeoff",
        "failed_performance_gates",
        "source_snapshot",
    )
    rows = []
    for source in compound:
        ratio = float(source["formal_v8_rmse_ratio"])
        recovery_ratio = float(source["formal_v8_recovery_ratio"])
        rows.append(
            {
                "case_id": source["case_id"],
                "baseline": BASELINE,
                "formal_algorithm": FORMAL,
                "paired_physical_pass": source["paired_physical_pass"],
                "performance_pass": source["performance_pass"],
                "v8_tracking_rmse_m": source["v8_tracking_rmse_m"],
                "formal_tracking_rmse_m": source["formal_tracking_rmse_m"],
                "formal_v8_rmse_ratio": source["formal_v8_rmse_ratio"],
                "formal_tracking_peak_m": source["formal_tracking_peak_m"],
                "formal_steady_abs_error_m": source["formal_steady_abs_error_m"],
                "v8_recovery_s": source["v8_recovery_s"],
                "formal_recovery_s": source["formal_recovery_s"],
                "formal_v8_recovery_ratio": source["formal_v8_recovery_ratio"],
                "rmse_improved": str(ratio < 0.98).lower(),
                "recovery_time_tradeoff": str(recovery_ratio > 1.05).lower(),
                "failed_performance_gates": source["failed_performance_gates"],
                "source_snapshot": SNAPSHOT_FILES[1],
            }
        )
    require(all(parse_bool(row["paired_physical_pass"]) for row in rows), "compound physical gate failed")
    return csv_bytes(fields, rows)


def build_formation(package: dict[str, Any]) -> bytes:
    cases = case_map(package["cases"])
    fields = (
        "case_id",
        "low_level_controller",
        "safety_supervisor",
        "supervisor_state",
        "minimum_pairwise_distance_m",
        "risk_exposure_below_0_60_m_s",
        "three_uav_global_position_tracking_rmse_m",
        "formation_rmse_m",
        "tracking_cost_increase_vs_off_percent",
        "raw_path",
        "raw_sha256",
        "interpretation_zh",
    )
    selected = {
        case_id: cases[(case_id, FORMAL)]
        for case_id in ("Scene07B", "Scene07COff", "Scene07COnPredictiveV5C")
    }
    exposure = {}
    for case_id in ("Scene07COff", "Scene07COnPredictiveV5C"):
        measured_min, duration = calculate_risk_exposure(ROOT / Path(selected[case_id]["raw_path"]))
        recorded_min = float(selected[case_id]["minimum_pairwise_distance_m"])
        require(abs(measured_min - recorded_min) <= 1e-9, f"formation minimum-distance mismatch: {case_id}")
        exposure[case_id] = duration
    require(abs(exposure["Scene07COff"] - 2.04) <= 1e-9, "PP-CBF-off exposure duration changed")
    require(abs(exposure["Scene07COnPredictiveV5C"]) <= 1e-12, "PP-CBF-on exposure is not zero")
    off_cost = float(selected["Scene07COff"]["tracking_commanded_rmse_m"])
    on_cost = float(selected["Scene07COnPredictiveV5C"]["tracking_commanded_rmse_m"])
    increase = (on_cost / off_cost - 1.0) * 100.0
    rows = []
    for case_id in ("Scene07B", "Scene07COff", "Scene07COnPredictiveV5C"):
        row = selected[case_id]
        if case_id == "Scene07B":
            supervisor_state = "not_applicable"
            duration = ""
            cost_increase = ""
            interpretation = "三机队形变换直接结果"
        elif case_id == "Scene07COff":
            supervisor_state = "off"
            duration = fmt(exposure[case_id])
            cost_increase = "0"
            interpretation = "安全监督关闭时存在小于0.60 m的风险暴露"
        else:
            supervisor_state = "on"
            duration = fmt(exposure[case_id])
            cost_increase = fmt(increase)
            interpretation = "安全监督开启后风险暴露降为0，同时保留跟踪代价"
        rows.append(
            {
                "case_id": case_id,
                "low_level_controller": FORMAL,
                "safety_supervisor": "PP-CBF",
                "supervisor_state": supervisor_state,
                "minimum_pairwise_distance_m": row["minimum_pairwise_distance_m"],
                "risk_exposure_below_0_60_m_s": duration,
                "three_uav_global_position_tracking_rmse_m": row["tracking_commanded_rmse_m"],
                "formation_rmse_m": row["formation_rmse_m"],
                "tracking_cost_increase_vs_off_percent": cost_increase,
                "raw_path": row["raw_path"],
                "raw_sha256": row["raw_sha256"].upper(),
                "interpretation_zh": interpretation,
            }
        )
    return csv_bytes(fields, rows)


def build_claim_index() -> bytes:
    # 每项结论都登记结果表、原始数据和复算脚本入口。
    fields = (
        "claim_id",
        "claim_zh",
        "status",
        "report_evidence",
        "raw_or_snapshot_evidence",
        "metric_script",
        "hash_evidence",
        "boundary_zh",
    )
    rows = [
        {
            "claim_id": "C01",
            "claim_zh": "正式主算法标准阶跃低超调",
            "status": "supported",
            "report_evidence": "04_results/report_evidence/02_standard_step_pid_vs_main.csv",
            "raw_or_snapshot_evidence": "06_supplementary_evidence/ra_gca_cg_hte_32_raw/Scene01S_X.csv;06_supplementary_evidence/ra_gca_cg_hte_32_raw/Scene01S_Y.csv;06_supplementary_evidence/ra_gca_cg_hte_32_raw/Scene01S_Z.csv;04_results/report_evidence/source_snapshots/chapter6_metrics_normalized.json",
            "metric_script": "02_scripts/evaluation/build_report_evidence.py",
            "hash_evidence": "06_supplementary_evidence/RAW_MANIFEST.json;04_results/report_evidence/REPORT_EVIDENCE_MANIFEST.json",
            "boundary_zh": "PID数据来自规范化历史权威快照，正式主算法数据由包内raw复算",
        },
        {
            "claim_id": "C02",
            "claim_zh": "五个正文控制对象具有四个同合同公共场景",
            "status": "supported",
            "report_evidence": "04_results/report_evidence/03_five_controller_common_scenes.csv",
            "raw_or_snapshot_evidence": "04_results/report_evidence/source_snapshots/chapter6_metrics_normalized.json;06_supplementary_evidence/campaign_cases.csv",
            "metric_script": "02_scripts/evaluation/build_report_evidence.py",
            "hash_evidence": "04_results/report_evidence/REPORT_EVIDENCE_MANIFEST.json",
            "boundary_zh": "不把辅助算法外推到参数、风扰、传感器或编队排名",
        },
        {
            "claim_id": "C03",
            "claim_zh": "11项参数工况中6项改善、5项基本等效",
            "status": "supported",
            "report_evidence": "04_results/report_evidence/05_parameter_11_paired.csv",
            "raw_or_snapshot_evidence": "06_supplementary_evidence/campaign_pairs.csv;06_supplementary_evidence/RAW_MANIFEST.json",
            "metric_script": "02_scripts/evaluation/build_report_evidence.py;02_scripts/syslab/run_campaign_evaluation.jl",
            "hash_evidence": "06_supplementary_evidence/RAW_MANIFEST.json;04_results/report_evidence/REPORT_EVIDENCE_MANIFEST.json",
            "boundary_zh": "required_parameter_retention=false，不能写成全部预注册目标通过",
        },
        {
            "claim_id": "C04",
            "claim_zh": "32项项目回归集逐项配对门通过",
            "status": "supported_with_boundary",
            "report_evidence": "04_results/report_evidence/06_project_regression_32_summary.json",
            "raw_or_snapshot_evidence": "06_supplementary_evidence/campaign_pairs.csv;06_supplementary_evidence/campaign_gates.csv;06_supplementary_evidence/RAW_MANIFEST.json",
            "metric_script": "02_scripts/evaluation/build_report_evidence.py;02_scripts/syslab/run_campaign_evaluation.jl",
            "hash_evidence": "06_supplementary_evidence/RAW_MANIFEST.json;04_results/report_evidence/REPORT_EVIDENCE_MANIFEST.json",
            "boundary_zh": "32是项目回归数量，不是官方规定测试数量；统计留出验证未完成",
        },
        {
            "claim_id": "C05",
            "claim_zh": "CP-INDI在三事件外扰中具有局部RMSE优势",
            "status": "supported",
            "report_evidence": "04_results/report_evidence/07_disturbance_tradeoff.csv",
            "raw_or_snapshot_evidence": "06_supplementary_evidence/ra_gca_cg_hte_32_raw/Scene06b.csv;04_results/report_evidence/source_snapshots/chapter6_metrics_normalized.json",
            "metric_script": "02_scripts/evaluation/build_report_evidence.py",
            "hash_evidence": "06_supplementary_evidence/RAW_MANIFEST.json;04_results/report_evidence/REPORT_EVIDENCE_MANIFEST.json",
            "boundary_zh": "局部结果如实保留，不等同于CP-INDI在完整场景覆盖上占优",
        },
        {
            "claim_id": "C06",
            "claim_zh": "复合应力下RMSE改善伴随峰值或恢复时间代价",
            "status": "supported_with_boundary",
            "report_evidence": "04_results/report_evidence/08_compound_stress_tradeoff.csv",
            "raw_or_snapshot_evidence": "04_results/report_evidence/source_snapshots/compound_stress_formal_algorithm.csv",
            "metric_script": "02_scripts/evaluation/build_report_evidence.py",
            "hash_evidence": "04_results/report_evidence/REPORT_EVIDENCE_MANIFEST.json",
            "boundary_zh": "包内仅保留最小指标快照和原raw哈希，不包含开发集raw",
        },
        {
            "claim_id": "C07",
            "claim_zh": "PP-CBF把近距交汇风险暴露时间由2.04 s降为0 s",
            "status": "supported",
            "report_evidence": "04_results/report_evidence/09_formation_pp_cbf.csv",
            "raw_or_snapshot_evidence": "06_supplementary_evidence/ra_gca_cg_hte_32_raw/Scene07COff.csv;06_supplementary_evidence/ra_gca_cg_hte_32_raw/Scene07COnPredictiveV5C.csv",
            "metric_script": "02_scripts/evaluation/build_report_evidence.py;02_scripts/syslab/run_campaign_evaluation.jl",
            "hash_evidence": "06_supplementary_evidence/RAW_MANIFEST.json;04_results/report_evidence/REPORT_EVIDENCE_MANIFEST.json",
            "boundary_zh": "必须同时报告跟踪代价，不把PP-CBF写成低层控制器",
        },
        {
            "claim_id": "C08",
            "claim_zh": "V30、H60、Wilson下界和配对bootstrap尚未完成",
            "status": "not_completed",
            "report_evidence": "04_results/report_evidence/06_project_regression_32_summary.json",
            "raw_or_snapshot_evidence": "06_supplementary_evidence/campaign_gates.csv",
            "metric_script": "02_scripts/evaluation/build_report_evidence.py",
            "hash_evidence": "04_results/report_evidence/REPORT_EVIDENCE_MANIFEST.json",
            "boundary_zh": "禁止在报告中写成已通过或已认证",
        },
    ]
    return csv_bytes(fields, rows)


def build_readme() -> bytes:
    text = f"""# 报告证据层使用边界

本目录把分散的权威指标整理为可复算、可追溯的报告数据底稿。正式主算法统一显示为 `{FORMAL}`；`{BASELINE}`仅作为版本消融与回滚基线，`PP-CBF`是独立上层安全监督器。

## 阅读顺序

1. `01_five_controller_scene_coverage.csv`：先确认每种算法实际覆盖了哪些场景。
2. `02_standard_step_pid_vs_main.csv`与`03_five_controller_common_scenes.csv`：查看官方基线和五对象公共比较。
3. `04_algorithm_evolution_ablation.csv`与`05_parameter_11_paired.csv`：查看Base、V8、正式主算法的演进及参数鲁棒性证据。
4. `06_project_regression_32_summary.json`：查看32项项目回归集汇总和未完成边界。
5. `07_disturbance_tradeoff.csv`、`08_compound_stress_tradeoff.csv`、`09_formation_pp_cbf.csv`：查看局部优势、代价与安全收益。
6. `10_claim_evidence_index.csv`：从报告结论回溯到raw、生成脚本和哈希清单。

## 关键边界

- 32项是项目内部回归集，不是比赛官方规定的32项测试。
- 32/32逐项配对门通过，但预注册参数保持目标未通过，`required_parameter_retention=false`必须保留。
- V30、H60、Wilson下界和配对bootstrap尚未完成，不得写成已通过。
- 三事件外扰中，`CP-INDI`的RMSE为`0.0621232821298252 m`，优于正式主算法约`0.294903761473424 m`；该局部优势不得删去或模糊。
- 复合应力结果支持“RMSE改善伴随部分峰值或恢复时间代价”，不支持“所有指标全面优于”。
- 编队结果中，`formation_rmse_m`是FormationMetricsV8定义的队形误差RMSE硬门指标；“三机全局位置跟踪RMSE”是另一项跟踪指标，两者不得混写。
- 五对象公共对照和复合应力指标来自本目录最小规范化快照；后续复算只依赖包内文件。

## 复算与校验

在包根目录执行以下命令，将证据重建到显式指定的包外目录：

```powershell
$Out = Join-Path ([IO.Path]::GetTempPath()) 'A8_report_evidence_recomputed'
.\RECOMPUTE_REPORT_EVIDENCE.ps1 -OutputDirectory $Out
```

只校验包内冻结证据且不写入包内：

```powershell
.\RECOMPUTE_REPORT_EVIDENCE.ps1 -Check
```

生成器会核对64份raw的SHA256。只有维护者显式调用Python生成器的`--build-package-evidence`模式时才允许重建本目录；普通复算拒绝输出到源文件包内部。

`REPORT_EVIDENCE_MANIFEST.json`记录本层输入与输出哈希，但按定义不包含其自身哈希。
"""
    return text.encode("utf-8")


def build_manifest(files: dict[str, bytes], package: dict[str, Any]) -> bytes:
    input_paths = list(package["paths"].values()) + [
        Path(__file__).resolve(),
        ROOT / "RECOMPUTE_REPORT_EVIDENCE.ps1",
    ]
    for path in input_paths:
        require(path.is_file(), f"manifest input is missing: {path}")
    inputs = [
        {"path": rel(path), "sha256": sha256(path)}
        for path in sorted(input_paths, key=lambda item: rel(item))
    ]
    for snapshot_name in SNAPSHOT_FILES:
        inputs.append(
            {
                "path": f"04_results/report_evidence/{snapshot_name}",
                "sha256": sha256_bytes(files[snapshot_name]),
            }
        )
    payload = {
        "schema_version": 1,
        "formal_algorithm": FORMAL,
        "scope": "report_evidence_layer",
        "generated_file_count_excluding_manifest": len(files),
        "manifest_self_hash_included": False,
        "verified_raw_sha256_count": package["verified_raw_count"],
        "inputs": inputs,
        "files": [
            {"path": name, "size": len(data), "sha256": sha256_bytes(data)}
            for name, data in sorted(files.items())
        ],
        "final_report_usage": {
            "status": "frozen_reference",
            "report_docx_sha256": "BB70BAF844C0172B997E0E04FDC7906D2F09E163A3FE8D88BDA2B01E53CA6D10",
            "referenced_files": [
                "01_five_controller_scene_coverage.csv",
                "02_standard_step_pid_vs_main.csv",
                "03_five_controller_common_scenes.csv",
                "05_parameter_11_paired.csv",
                "07_disturbance_tradeoff.csv",
                "08_compound_stress_tradeoff.csv",
                "09_formation_pp_cbf.csv",
                "10_claim_evidence_index.csv",
            ],
            "supplementary_only_files": [
                "04_algorithm_evolution_ablation.csv",
                "06_project_regression_32_summary.json",
            ],
            "numbered_figures": 28,
            "numbered_tables": 26,
        },
    }
    return json_bytes(payload)


def build_all(import_sources: bool = False) -> dict[str, bytes]:
    # 所有可见表格由同一入口生成，避免正文出现第二套口径。
    chapter, compound, snapshots = load_snapshots(import_sources)
    package = load_package_inputs()
    parameter_data, parameter_rows = build_parameter_pairs(package)
    files = dict(snapshots)
    files.update(
        {
            "README_报告证据使用边界.md": build_readme(),
            "01_five_controller_scene_coverage.csv": build_coverage(),
            "02_standard_step_pid_vs_main.csv": build_standard_steps(package, chapter),
            "03_five_controller_common_scenes.csv": build_common_scenes(package, chapter),
            "04_algorithm_evolution_ablation.csv": build_evolution(package, chapter),
            "05_parameter_11_paired.csv": parameter_data,
            "06_project_regression_32_summary.json": build_summary(package, parameter_rows),
            "07_disturbance_tradeoff.csv": build_disturbance(package, chapter),
            "08_compound_stress_tradeoff.csv": build_compound(compound),
            "09_formation_pp_cbf.csv": build_formation(package),
            "10_claim_evidence_index.csv": build_claim_index(),
        }
    )
    require(set(files) == set(VISIBLE_FILES) | set(SNAPSHOT_FILES), "generated file set is incomplete")
    files[MANIFEST_NAME] = build_manifest(files, package)
    return files


def validate_visible_content(files: dict[str, bytes]) -> None:
    forbidden = ("RA-GCA + CG-HTE", "HTE-F0", "candi" + "date_", "V9 HTE")
    for name in VISIBLE_FILES:
        text = files[name].decode("utf-8-sig")
        for token in forbidden:
            require(token not in text, f"forbidden visible token {token!r} in {name}")
        require("D:/Users/" not in text and "D:\\Users\\" not in text, f"absolute user path in {name}")


def write_output(output: Path, files: dict[str, bytes]) -> None:
    # 输出目录只接收本次声明的文件集合，防止残留旧证据。
    output.mkdir(parents=True, exist_ok=True)
    expected = {Path(name).as_posix() for name in files}
    actual = {
        path.relative_to(output).as_posix()
        for path in output.rglob("*")
        if path.is_file()
    }
    unexpected = actual - expected
    require(not unexpected, f"output directory contains unmanaged files: {sorted(unexpected)}")
    for name, data in sorted(files.items()):
        path = output / Path(name)
        path.parent.mkdir(parents=True, exist_ok=True)
        temporary = path.with_suffix(path.suffix + ".tmp")
        temporary.write_bytes(data)
        temporary.replace(path)


def check_package() -> None:
    # 只读模式按字节比较重建结果，不在源文件包内写入内容。
    expected = build_all(import_sources=False)
    validate_visible_content(expected)
    actual_names = {
        path.relative_to(EVIDENCE_DIR).as_posix()
        for path in EVIDENCE_DIR.rglob("*")
        if path.is_file()
    }
    require(actual_names == set(expected), "packaged report evidence contains missing or unmanaged files")
    for name, data in expected.items():
        path = EVIDENCE_DIR / Path(name)
        require(path.read_bytes() == data, f"packaged report evidence is stale: {name}")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build and validate the self-contained A8 report evidence layer."
    )
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--output-dir", type=Path, help="explicit output directory outside the package")
    mode.add_argument("--check", action="store_true", help="validate frozen package evidence without writing it")
    mode.add_argument(
        "--build-package-evidence",
        action="store_true",
        help="maintainer-only mode that writes the canonical package evidence directory",
    )
    parser.add_argument(
        "--import-historical-sources",
        action="store_true",
        help="one-time maintainer import of the two historical authority sources",
    )
    args = parser.parse_args(argv)
    if args.import_historical_sources and not args.build_package_evidence:
        parser.error("--import-historical-sources requires --build-package-evidence")
    return args


def main(argv: list[str] | None = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)
    if args.check:
        check_package()
        print("report evidence check: PASS")
        return 0

    if args.build_package_evidence:
        output = EVIDENCE_DIR
        files = build_all(import_sources=args.import_historical_sources)
    else:
        output = args.output_dir.resolve()
        require(not is_within(output, ROOT), "output directory must be outside the source package")
        files = build_all(import_sources=False)
    validate_visible_content(files)
    write_output(output, files)
    print(f"report evidence build: PASS ({len(files)} files, {output})")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except EvidenceError as exc:
        print(f"report evidence error: {exc}", file=sys.stderr)
        raise SystemExit(2)
