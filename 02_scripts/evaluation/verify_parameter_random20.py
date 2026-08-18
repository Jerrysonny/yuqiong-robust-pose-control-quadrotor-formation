"""Independently verify formal raw data and Syslab summary outputs."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import statistics
from pathlib import Path
from typing import Any


EXPECTED_CASES = [f"MC20_{index:02d}" for index in range(1, 21)]
CONTROLLERS = ("PID", "RA-GCA-CGHTE")
TIE_TOLERANCE_M = 1e-12


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def percentile_type7(values: list[float], probability: float) -> float:
    ordered = sorted(values)
    position = (len(ordered) - 1) * probability
    lower = math.floor(position)
    upper = math.ceil(position)
    if lower == upper:
        return ordered[lower]
    fraction = position - lower
    return ordered[lower] * (1 - fraction) + ordered[upper] * fraction


def determinant3(matrix: list[list[float]]) -> float:
    a, b, c = matrix[0]
    d, e, f = matrix[1]
    g, h, i = matrix[2]
    return a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g)


def raw_metrics(path: Path) -> dict[str, Any]:
    error_norms: list[float] = []
    terminal: list[float] = []
    max_orthogonality = 0.0
    max_determinant = 0.0
    max_body_rate = 0.0
    max_motor_q = 0.0
    first_time = None
    last_time = None
    row_count = 0

    with path.open("r", encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream)
        required = {
            "time_s",
            "reference_x_m",
            "reference_y_m",
            "reference_z_m",
            "position_x_m",
            "position_y_m",
            "position_z_m",
            *(f"rotation_{row}{column}" for row in range(1, 4) for column in range(1, 4)),
            *(f"body_rate_{index}_radps" for index in range(1, 4)),
            *(f"motor_command_{index}" for index in range(1, 5)),
        }
        if not reader.fieldnames or not required.issubset(reader.fieldnames):
            raise RuntimeError(f"missing columns in {path}")
        for row in reader:
            row_count += 1
            time_s = float(row["time_s"])
            first_time = time_s if first_time is None else first_time
            last_time = time_s
            reference = [float(row[f"reference_{axis}_m"]) for axis in "xyz"]
            position = [float(row[f"position_{axis}_m"]) for axis in "xyz"]
            error = math.sqrt(
                math.fsum((reference[index] - position[index]) ** 2 for index in range(3))
            )
            error_norms.append(error)
            if time_s >= 45.0:
                terminal.append(error)

            rotation = [
                [float(row[f"rotation_{i}{j}"]) for j in range(1, 4)]
                for i in range(1, 4)
            ]
            for i in range(3):
                for j in range(3):
                    product = math.fsum(rotation[k][i] * rotation[k][j] for k in range(3))
                    target = 1.0 if i == j else 0.0
                    max_orthogonality = max(max_orthogonality, abs(product - target))
            max_determinant = max(max_determinant, abs(determinant3(rotation) - 1.0))
            max_body_rate = max(
                max_body_rate,
                *(abs(float(row[f"body_rate_{index}_radps"])) for index in range(1, 4)),
            )
            max_motor_q = max(
                max_motor_q,
                *(float(row[f"motor_command_{index}"]) ** 2 for index in range(1, 5)),
            )

    if (
        row_count != 5001
        or first_time is None
        or not math.isclose(first_time, 0.0, abs_tol=1e-12)
    ):
        raise RuntimeError(f"invalid row count or start time in {path}")
    if last_time is None or not math.isclose(last_time, 50.0, abs_tol=1e-8):
        raise RuntimeError(f"invalid stop time in {path}")
    if not terminal:
        raise RuntimeError(f"missing terminal window in {path}")

    rmse = math.sqrt(math.fsum(value * value for value in error_norms) / len(error_norms))
    peak = max(error_norms)
    terminal_mean = math.fsum(terminal) / len(terminal)
    physical = (
        max_orthogonality <= 1e-6
        and max_determinant <= 1e-6
        and max_body_rate <= 20.0
        and max_motor_q <= 3600.0 + 1e-8
    )
    return {
        "rmse_m": rmse,
        "peak_m": peak,
        "p95_m": percentile_type7(error_norms, 0.95),
        "terminal_mean_m": terminal_mean,
        "max_rotation_orthogonality_error": max_orthogonality,
        "max_rotation_determinant_error": max_determinant,
        "max_body_rate_radps": max_body_rate,
        "max_motor_q": max_motor_q,
        "physical_pass": physical,
        "absolute_pass": physical and peak <= 0.50 and terminal_mean <= 0.05,
        "raw_sha256": sha256(path),
    }


def exact_sign_p(wins: int, losses: int) -> float:
    effective = wins + losses
    if effective == 0:
        return 1.0
    tail = min(wins, losses)
    probability = 2 * sum(math.comb(effective, index) for index in range(tail + 1)) / 2**effective
    return min(1.0, probability)


def close(left: float, right: float) -> bool:
    return math.isclose(left, right, rel_tol=1e-11, abs_tol=1e-13)


def read_csv_map(path: Path, keys: tuple[str, ...]) -> dict[tuple[str, ...], dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as stream:
        rows = list(csv.DictReader(stream))
    return {tuple(row[key] for key in keys): row for row in rows}


def atomic_json(path: Path, payload: dict[str, Any]) -> None:
    if path.exists():
        raise RuntimeError(f"refusing to overwrite QA result: {path}")
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(
        json.dumps(payload, indent=2, ensure_ascii=False, allow_nan=False) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)


def resolve_raw(execution_root: Path, case_id: str, controller: str) -> Path:
    candidates = (
        execution_root / case_id / controller / "raw.csv",
        execution_root / controller / f"{case_id}.csv",
    )
    matches = [path for path in candidates if path.is_file()]
    if len(matches) != 1:
        raise RuntimeError(
            f"expected exactly one raw file for {case_id}/{controller}; found {len(matches)}"
        )
    return matches[0]


def verify(args: argparse.Namespace) -> dict[str, Any]:
    execution_root = args.execution_root.resolve()
    statistics_root = args.statistics_root.resolve()
    sample_manifest = args.sample_manifest.resolve()
    failures: list[str] = []

    with sample_manifest.open("r", encoding="utf-8", newline="") as stream:
        samples = list(csv.DictReader(stream))
    if [row["case_id"] for row in samples] != EXPECTED_CASES:
        failures.append("sample manifest identifiers or order changed")

    batch_status_path = execution_root / "batch_execution_status.json"
    if batch_status_path.is_file():
        batch_status = json.loads(batch_status_path.read_text(encoding="utf-8"))
        if not batch_status.get("success") or batch_status.get("completed_case_count") != 20:
            failures.append("batch execution status is incomplete")
        if batch_status.get("source_hashes_before") != batch_status.get("source_hashes_after"):
            failures.append("model source hashes changed during batch")

    recorded_metrics = read_csv_map(
        statistics_root / "controller_metrics.csv", ("case_id", "controller")
    )
    paired = read_csv_map(statistics_root / "paired_results.csv", ("case_id",))
    recomputed: dict[tuple[str, str], dict[str, Any]] = {}

    numeric_metrics = (
        "rmse_m",
        "peak_m",
        "p95_m",
        "terminal_mean_m",
        "max_rotation_orthogonality_error",
        "max_rotation_determinant_error",
        "max_body_rate_radps",
        "max_motor_q",
    )
    for sample in samples:
        case_id = sample["case_id"]
        for controller in CONTROLLERS:
            try:
                raw_path = resolve_raw(execution_root, case_id, controller)
            except RuntimeError as exc:
                failures.append(str(exc))
                continue
            metrics = raw_metrics(raw_path)
            recomputed[(case_id, controller)] = metrics
            recorded = recorded_metrics.get((case_id, controller))
            if recorded is None:
                failures.append(f"missing Syslab metrics row: {case_id}/{controller}")
                continue
            for name in numeric_metrics:
                if not close(metrics[name], float(recorded[name])):
                    failures.append(f"metric mismatch: {case_id}/{controller}/{name}")
            for name in ("physical_pass", "absolute_pass"):
                if str(metrics[name]).lower() != recorded[name].lower():
                    failures.append(f"gate mismatch: {case_id}/{controller}/{name}")
            if metrics["raw_sha256"] != recorded["raw_sha256"].upper():
                failures.append(f"raw hash mismatch: {case_id}/{controller}")

    reductions: list[float] = []
    wins = losses = ties = 0
    for case_id in EXPECTED_CASES:
        pid = recomputed.get((case_id, "PID"))
        main = recomputed.get((case_id, "RA-GCA-CGHTE"))
        row = paired.get((case_id,))
        if pid is None or main is None or row is None:
            failures.append(f"incomplete pair: {case_id}")
            continue
        ratio = main["rmse_m"] / pid["rmse_m"]
        reduction = 100 * (1 - ratio)
        reductions.append(reduction)
        if not close(ratio, float(row["main_pid_rmse_ratio"])):
            failures.append(f"paired ratio mismatch: {case_id}")
        if not close(reduction, float(row["rmse_reduction_percent"])):
            failures.append(f"paired reduction mismatch: {case_id}")
        difference = main["rmse_m"] - pid["rmse_m"]
        if abs(difference) <= TIE_TOLERANCE_M:
            ties += 1
        elif difference < 0:
            wins += 1
        else:
            losses += 1

    with (statistics_root / "statistical_summary.csv").open(
        "r", encoding="utf-8", newline=""
    ) as stream:
        stats = {row["metric"]: row["value"] for row in csv.DictReader(stream)}
    if reductions:
        checks = {
            "main_wins": float(wins),
            "pid_wins": float(losses),
            "ties": float(ties),
            "median_reduction_percent": statistics.median(reductions),
            "sign_test_p_two_sided": exact_sign_p(wins, losses),
        }
        for name, value in checks.items():
            if name not in stats or not close(value, float(stats[name])):
                failures.append(f"statistical summary mismatch: {name}")

    summary_json = json.loads(
        (statistics_root / "statistical_summary.json").read_text(encoding="utf-8")
    )
    if summary_json.get("sample_manifest_sha256") != sha256(sample_manifest):
        failures.append("sample manifest hash mismatch in statistical summary")
    low = float(summary_json["bootstrap"]["low_percent"])
    high = float(summary_json["bootstrap"]["high_percent"])
    median_reduction = statistics.median(reductions) if reductions else math.nan
    if not (low <= median_reduction <= high):
        failures.append("bootstrap interval does not contain the observed median")

    payload = {
        "schema_version": 1,
        "success": not failures,
        "raw_file_count": len(recomputed),
        "case_count": len(samples),
        "main_wins": wins,
        "pid_wins": losses,
        "ties": ties,
        "median_reduction_percent": median_reduction,
        "sign_test_p_two_sided": exact_sign_p(wins, losses),
        "failures": failures,
    }
    atomic_json(args.output.resolve(), payload)
    print(f"independent_verify={'pass' if payload['success'] else 'fail'}")
    print(f"raw_file_count={payload['raw_file_count']} failures={len(failures)}")
    return payload


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--execution-root", type=Path, required=True)
    parser.add_argument("--statistics-root", type=Path, required=True)
    parser.add_argument("--sample-manifest", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args()


if __name__ == "__main__":
    raise SystemExit(0 if verify(parse_args())["success"] else 1)
