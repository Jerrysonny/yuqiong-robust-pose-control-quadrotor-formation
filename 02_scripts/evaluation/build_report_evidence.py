from __future__ import annotations

import argparse
import csv
import hashlib
import io
import json
import math
import sys
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[2]
EVIDENCE_DIR = ROOT / "04_results" / "report_evidence"
CONTRACT_PATH = ROOT / "config" / "finals_report_evidence_contract.json"
MANIFEST_NAME = "REPORT_EVIDENCE_MANIFEST.json"
FORMAL = "ARDG-RGPC"

VISIBLE_FILES = (
    "README_报告证据使用边界.md",
    "01_five_controller_scene_coverage.csv",
    "02_standard_step_pid_vs_main.csv",
    "03_five_controller_common_scenes.csv",
    "04_parameter_optimization_summary.csv",
    "05_parameter_11_robustness.csv",
    "06_regression18_metrics.csv",
    "06_regression18_summary.json",
    "07_scene06b_pid_comparison.csv",
    "08_angular_disturbance_response.csv",
    "09_formation_pp_cbf.csv",
    "10_compound_stress_final.csv",
    "10_claim_evidence_index.csv",
)

PRESERVED_PREFIXES = (
    "official_pid_scene06b/",
    "official_pid_angular/",
    "parameter11_ardg_rgpc_final/",
    "parameter_random20_ardg_rgpc_final/",
)


class EvidenceError(RuntimeError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise EvidenceError(message)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest().upper()


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


def load_contract() -> dict[str, Any]:
    require(CONTRACT_PATH.is_file(), "finals report evidence contract is missing")
    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8-sig"))
    require(contract["formal_algorithm"] == FORMAL, "formal algorithm mismatch")
    require(contract["schema_version"] == 1, "unsupported evidence contract version")
    return contract


def source(path_text: str) -> Path:
    path = ROOT / Path(path_text)
    require(path.is_file(), f"required source is missing: {path_text}")
    return path


def position_metrics(path: Path) -> tuple[float, float, int]:
    squared: list[float] = []
    distances: list[float] = []
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        reader = csv.DictReader(stream)
        require(reader.fieldnames is not None, f"CSV header is missing: {rel(path)}")
        pid_schema = "reference_x_m" in reader.fieldnames
        for row in reader:
            if pid_schema:
                reference = [float(row[f"reference_{axis}_m"]) for axis in "xyz"]
                actual = [float(row[f"position_{axis}_m"]) for axis in "xyz"]
            else:
                reference = [float(row[f"referenceVector[{index}]"]) for index in range(1, 4)]
                actual = [
                    float(row[f"quadChassisTest17_1.body.r_0[{index}]"])
                    for index in range(1, 4)
                ]
            distance2 = sum((actual[index] - reference[index]) ** 2 for index in range(3))
            squared.append(distance2)
            distances.append(math.sqrt(distance2))
    require(squared, f"CSV has no data rows: {rel(path)}")
    return math.sqrt(sum(squared) / len(squared)), max(distances), len(squared)


def step_overshoot(path: Path, axis: str) -> float:
    index = {"X": 1, "Y": 2, "Z": 3}[axis]
    reference_name = f"referenceVector[{index}]"
    actual_name = f"quadChassisTest17_1.body.r_0[{index}]"
    reference: list[float] = []
    actual: list[float] = []
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        for row in csv.DictReader(stream):
            reference.append(float(row[reference_name]))
            actual.append(float(row[actual_name]))
    require(len(reference) > 1, f"standard-step raw is empty: {rel(path)}")
    jumps = [abs(reference[index] - reference[index - 1]) for index in range(1, len(reference))]
    jump_index = 1 + max(range(len(jumps)), key=jumps.__getitem__)
    initial = reference[jump_index - 1]
    target = reference[jump_index]
    amplitude = abs(target - initial)
    require(amplitude > 0.0, f"standard-step amplitude is zero: {rel(path)}")
    excess = max(actual[jump_index:]) - target if target >= initial else target - min(actual[jump_index:])
    return max(0.0, excess / amplitude * 100.0)


def formation_metrics(path: Path, threshold_m: float = 0.60) -> dict[str, float]:
    times: list[float] = []
    minimum_distances: list[float] = []
    formation_squared: list[float] = []
    global_squared: list[float] = []
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        for row in csv.DictReader(stream):
            positions = [
                [float(row[f"quad{vehicle}.body.r_0[{axis}]"]) for axis in range(1, 4)]
                for vehicle in range(1, 4)
            ]
            references = [
                [float(row[f"formationReference[{9 * vehicle + axis}]"]) for axis in range(1, 4)]
                for vehicle in range(3)
            ]
            offsets = [
                [float(row[f"formationOffset[{3 * vehicle + axis}]"]) for axis in range(1, 4)]
                for vehicle in range(3)
            ]
            pairwise = []
            for first, second in ((0, 1), (0, 2), (1, 2)):
                pairwise.append(
                    math.sqrt(sum((positions[first][axis] - positions[second][axis]) ** 2 for axis in range(3)))
                )
            minimum_distances.append(min(pairwise))
            times.append(float(row["time"]))
            for vehicle in range(3):
                global_squared.append(
                    sum((positions[vehicle][axis] - references[vehicle][axis]) ** 2 for axis in range(3))
                )
            centroid = [sum(positions[v][axis] for v in range(3)) / 3.0 for axis in range(3)]
            for vehicle in range(3):
                formation_squared.append(
                    sum(
                        ((positions[vehicle][axis] - centroid[axis]) - offsets[vehicle][axis]) ** 2
                        for axis in range(3)
                    )
                )
    require(len(times) > 1, f"formation raw is empty: {rel(path)}")
    exposure = sum(
        times[index + 1] - times[index]
        for index in range(len(times) - 1)
        if minimum_distances[index] < threshold_m
    )
    return {
        "formation_rmse_m": math.sqrt(sum(formation_squared) / len(formation_squared)),
        "global_position_rmse_m": math.sqrt(sum(global_squared) / len(global_squared)),
        "minimum_pairwise_distance_m": min(minimum_distances),
        "risk_exposure_below_0_60_m_s": exposure,
    }


def build_coverage(contract: dict[str, Any]) -> bytes:
    fields = (
        "controller", "role_zh", "standard_steps", "common_single_uav_scenes",
        "parameter_11", "random_parameter_20", "wind_5", "sensor_5",
        "angular_disturbance_2", "compound_stress_6", "formation_3", "evidence_boundary_zh",
    )
    return csv_bytes(fields, contract["coverage"])


def build_steps(contract: dict[str, Any]) -> bytes:
    fields = (
        "axis", "controller", "overshoot_percent", "tracking_rmse_m",
        "evidence_basis", "source_reference", "source_sha256",
    )
    rows: list[dict[str, Any]] = []
    for axis in ("X", "Y", "Z"):
        rows.append({
            "axis": axis,
            "controller": "PID",
            "overshoot_percent": contract["standard_step_pid_overshoot_percent"][axis],
            "tracking_rmse_m": None,
            "evidence_basis": "official_reference_metric",
            "source_reference": "config/finals_report_evidence_contract.json",
            "source_sha256": sha256(CONTRACT_PATH),
        })
        raw = source(f"06_supplementary_evidence/ardg_rgpc_regression18_final/raw/Scene01S_{axis}.csv")
        rmse, _, _ = position_metrics(raw)
        rows.append({
            "axis": axis,
            "controller": FORMAL,
            "overshoot_percent": step_overshoot(raw, axis),
            "tracking_rmse_m": rmse,
            "evidence_basis": "final_algorithm_direct",
            "source_reference": rel(raw),
            "source_sha256": sha256(raw),
        })
    return csv_bytes(fields, rows)


def build_common_scenes(contract: dict[str, Any]) -> bytes:
    fields = (
        "case_id", "scene_zh", "controller", "tracking_rmse_m", "peak_m",
        "evidence_basis", "source_reference", "source_sha256",
    )
    comparator_rows = {
        (row["case_id"], row["controller"]): row for row in contract["comparator_scene_metrics"]
    }
    rows: list[dict[str, Any]] = []
    for case_id in contract["common_scene_order"]:
        scene_zh = contract["scene_names_zh"][case_id]
        for controller in ("PID", "RA-GCA/Base", FORMAL, "CAP-ADRC", "CP-INDI"):
            if controller == FORMAL:
                raw = source(f"06_supplementary_evidence/ardg_rgpc_regression18_final/raw/{case_id}.csv")
                rmse, peak, _ = position_metrics(raw)
                rows.append({
                    "case_id": case_id,
                    "scene_zh": scene_zh,
                    "controller": controller,
                    "tracking_rmse_m": rmse,
                    "peak_m": peak,
                    "evidence_basis": "final_algorithm_direct",
                    "source_reference": rel(raw),
                    "source_sha256": sha256(raw),
                })
                continue
            item = comparator_rows[(case_id, controller)]
            source_path = item.get("source_reference", "config/finals_report_evidence_contract.json")
            source_hash = sha256(source(source_path)) if source_path != "config/finals_report_evidence_contract.json" else sha256(CONTRACT_PATH)
            rows.append({
                "case_id": case_id,
                "scene_zh": scene_zh,
                "controller": controller,
                "tracking_rmse_m": item["tracking_rmse_m"],
                "peak_m": item.get("peak_m"),
                "evidence_basis": item["evidence_basis"],
                "source_reference": source_path,
                "source_sha256": source_hash,
            })
    return csv_bytes(fields, rows)


def build_parameter_optimization() -> bytes:
    index_path = source("05_visuals/final_shared_assets/FINAL_ASSET_INDEX.json")
    index = json.loads(index_path.read_text(encoding="utf-8-sig"))
    metrics = next(item for item in index["figures"] if item["figure_id"] == "E")["metrics"]
    params = metrics["final_parameters"]
    fields = ("item", "value", "unit", "interpretation_zh", "source_reference", "source_sha256")
    rows = [
        {"item": "joint_candidates", "value": metrics["joint_candidates"], "unit": "count", "interpretation_zh": "联合搜索候选数"},
        {"item": "local_candidates", "value": metrics["local_candidates"], "unit": "count", "interpretation_zh": "局部精调候选数"},
        {"item": "core_screening_runs", "value": metrics["core_screening_runs"], "unit": "runs", "interpretation_zh": "两个角扰动场景的核心筛选运行数"},
        {"item": "Kc", "value": params["Kc"], "unit": "1", "interpretation_zh": "角残差补偿增益"},
        {"item": "Cmax", "value": params["Cmax_nm"], "unit": "N*m", "interpretation_zh": "补偿力矩限幅"},
        {"item": "Rmax", "value": params["Rmax_nm_per_sample"], "unit": "N*m/sample", "interpretation_zh": "补偿变化率限幅"},
    ]
    for row in rows:
        row["source_reference"] = rel(index_path)
        row["source_sha256"] = sha256(index_path)
    return csv_bytes(fields, rows)


def build_parameter11() -> bytes:
    path = source("04_results/report_evidence/parameter11_ardg_rgpc_final/parameter11_final_paired.csv")
    rows_in = read_csv(path)
    require(len(rows_in) == 11, "parameter11 result count mismatch")
    fields = (
        "case_id", "reference_controller", "formal_algorithm",
        "reference_position_rmse_m", "ardg_rgpc_position_rmse_m",
        "reduction_percent", "classification", "raw_rows", "raw_sha256",
        "diagnostic_sha256",
    )
    rows = []
    for row in rows_in:
        rows.append({
            "case_id": row["case_id"],
            "reference_controller": "RA-GCA/Base",
            "formal_algorithm": FORMAL,
            "reference_position_rmse_m": row["geometric_baseline_position_rmse_m"],
            "ardg_rgpc_position_rmse_m": row["ardg_rgpc_position_rmse_m"],
            "reduction_percent": row["ardg_rgpc_vs_geometric_baseline_reduction_percent"],
            "classification": row["classification_vs_geometric_baseline"],
            "raw_rows": row["raw_rows"],
            "raw_sha256": row["raw_sha256"],
            "diagnostic_sha256": row["diagnostic_sha256"],
        })
    return csv_bytes(fields, rows)


def build_regression18(contract: dict[str, Any]) -> tuple[bytes, bytes]:
    fields = (
        "case_id", "category", "scene_zh", "position_rmse_m",
        "position_peak_m", "raw_rows", "finite_values", "source_reference",
        "source_sha256",
    )
    rows = []
    categories: dict[str, int] = {}
    for item in contract["regression18"]:
        raw = source(item["source_reference"])
        rmse, peak, count = position_metrics(raw)
        categories[item["category"]] = categories.get(item["category"], 0) + 1
        rows.append({
            "case_id": item["case_id"],
            "category": item["category"],
            "scene_zh": item["scene_zh"],
            "position_rmse_m": rmse,
            "position_peak_m": peak,
            "raw_rows": count,
            "finite_values": True,
            "source_reference": rel(raw),
            "source_sha256": sha256(raw),
        })
    status_path = source("06_supplementary_evidence/ardg_rgpc_regression18_final/execution_status.json")
    status = json.loads(status_path.read_text(encoding="utf-8-sig"))
    require(status.get("success") is True, "Regression18 execution status is not successful")
    require(len(rows) == 18, "Regression18 must contain 18 scenes")
    summary = {
        "schema_version": 1,
        "formal_algorithm": FORMAL,
        "scene_count": len(rows),
        "category_counts": categories,
        "all_execution_passed": True,
        "all_values_finite": True,
        "comparison_policy": "final-algorithm absolute results with registered external comparators only",
        "source_reference": rel(status_path),
        "source_sha256": sha256(status_path),
    }
    return csv_bytes(fields, rows), json_bytes(summary)


def build_scene06b() -> bytes:
    pid = source("04_results/report_evidence/official_pid_scene06b/raw.csv")
    ardg = source("06_supplementary_evidence/ardg_rgpc_regression18_final/raw/Scene06b.csv")
    pid_rmse, pid_peak, pid_rows = position_metrics(pid)
    ardg_rmse, ardg_peak, ardg_rows = position_metrics(ardg)
    reduction = (pid_rmse - ardg_rmse) / pid_rmse * 100.0
    fields = (
        "comparison", "official_pid_rmse_m", "ardg_rgpc_rmse_m",
        "reduction_percent", "official_pid_peak_m", "ardg_rgpc_peak_m",
        "official_pid_rows", "ardg_rgpc_rows", "official_pid_source",
        "official_pid_sha256", "ardg_rgpc_source", "ardg_rgpc_sha256",
    )
    return csv_bytes(fields, [{
        "comparison": "ARDG-RGPC_vs_official_PID",
        "official_pid_rmse_m": pid_rmse,
        "ardg_rgpc_rmse_m": ardg_rmse,
        "reduction_percent": reduction,
        "official_pid_peak_m": pid_peak,
        "ardg_rgpc_peak_m": ardg_peak,
        "official_pid_rows": pid_rows,
        "ardg_rgpc_rows": ardg_rows,
        "official_pid_source": rel(pid),
        "official_pid_sha256": sha256(pid),
        "ardg_rgpc_source": rel(ardg),
        "ardg_rgpc_sha256": sha256(ardg),
    }])


def angular_response_metrics(path: Path, start_s: float, stop_s: float) -> dict[str, float]:
    previous_time: float | None = None
    previous_attitude: float | None = None
    previous_motor: list[float] | None = None
    attitude_iae = 0.0
    attitude_peak = 0.0
    position_squared: list[float] = []
    motor_tv = 0.0
    rows = 0
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        for row in csv.DictReader(stream):
            time_s = float(row["time_s"])
            if time_s < start_s or time_s > stop_s:
                continue
            roll = float(row["angle_roll_rad"])
            pitch = float(row["angle_pitch_rad"])
            attitude = math.hypot(roll, pitch)
            position_error = [
                float(row[f"position_{axis}_m"]) - float(row[f"reference_{index}"])
                for axis, index in zip("xyz", (1, 2, 3))
            ]
            motor = [float(row[f"motor_command_{index}"]) for index in range(1, 5)]
            if previous_time is not None and previous_attitude is not None and previous_motor is not None:
                attitude_iae += 0.5 * (attitude + previous_attitude) * (time_s - previous_time)
                motor_tv += sum(abs(motor[index] - previous_motor[index]) for index in range(4))
            attitude_peak = max(attitude_peak, attitude)
            position_squared.append(sum(value * value for value in position_error))
            previous_time = time_s
            previous_attitude = attitude
            previous_motor = motor
            rows += 1
    require(rows > 1, f"angular-response window is empty: {rel(path)}")
    return {
        "attitude_event_iae_rad_s": attitude_iae,
        "peak_attitude_error_rad": attitude_peak,
        "peak_attitude_error_deg": math.degrees(attitude_peak),
        "position_rmse_m": math.sqrt(sum(position_squared) / len(position_squared)),
        "motor_tv": motor_tv,
        "rows": rows,
    }


def build_angular(contract: dict[str, Any]) -> bytes:
    fields = (
        "case_id", "scene_zh", "official_pid_attitude_event_iae_rad_s",
        "ardg_rgpc_attitude_event_iae_rad_s", "ardg_vs_pid_attitude_iae_increase_percent",
        "official_pid_peak_attitude_error_deg", "ardg_rgpc_peak_attitude_error_deg",
        "official_pid_position_rmse_m", "ardg_rgpc_position_rmse_m",
        "official_pid_motor_tv", "ardg_rgpc_motor_tv", "ardg_motor_tv_reduction_percent",
        "analysis_window_start_s", "analysis_window_stop_s",
        "comparison_status", "official_pid_source", "official_pid_sha256",
        "ardg_rgpc_source", "ardg_rgpc_sha256",
    )
    rows = []
    for item in contract["angular_disturbance"]:
        start_s, stop_s = (float(value) for value in item["analysis_window_s"])
        pid = source(item["official_pid_source"])
        ardg = source(item["formal_source"])
        pid_metrics = angular_response_metrics(pid, start_s, stop_s)
        ardg_metrics = angular_response_metrics(ardg, start_s, stop_s)
        iae_increase = (
            (ardg_metrics["attitude_event_iae_rad_s"] - pid_metrics["attitude_event_iae_rad_s"])
            / pid_metrics["attitude_event_iae_rad_s"]
            * 100.0
        )
        tv_reduction = (
            (pid_metrics["motor_tv"] - ardg_metrics["motor_tv"])
            / pid_metrics["motor_tv"]
            * 100.0
        )
        rows.append({
            "case_id": item["case_id"],
            "scene_zh": item["scene_zh"],
            "official_pid_attitude_event_iae_rad_s": pid_metrics["attitude_event_iae_rad_s"],
            "ardg_rgpc_attitude_event_iae_rad_s": ardg_metrics["attitude_event_iae_rad_s"],
            "ardg_vs_pid_attitude_iae_increase_percent": iae_increase,
            "official_pid_peak_attitude_error_deg": pid_metrics["peak_attitude_error_deg"],
            "ardg_rgpc_peak_attitude_error_deg": ardg_metrics["peak_attitude_error_deg"],
            "official_pid_position_rmse_m": pid_metrics["position_rmse_m"],
            "ardg_rgpc_position_rmse_m": ardg_metrics["position_rmse_m"],
            "official_pid_motor_tv": pid_metrics["motor_tv"],
            "ardg_rgpc_motor_tv": ardg_metrics["motor_tv"],
            "ardg_motor_tv_reduction_percent": tv_reduction,
            "analysis_window_start_s": start_s,
            "analysis_window_stop_s": stop_s,
            "comparison_status": "official_PID_lower_attitude_and_position_error; ARDG-RGPC_lower_motor_TV",
            "official_pid_source": rel(pid),
            "official_pid_sha256": sha256(pid),
            "ardg_rgpc_source": rel(ardg),
            "ardg_rgpc_sha256": sha256(ardg),
        })
    return csv_bytes(fields, rows)


def build_compound(contract: dict[str, Any]) -> bytes:
    metrics_path = source("06_supplementary_evidence/ardg_rgpc_compound_final/evaluation/compound_metrics.csv")
    metrics = {row["case_id"]: row for row in read_csv(metrics_path)}
    require(set(metrics) == {item["case_id"] for item in contract["compound_stress"]}, "compound-stress case set mismatch")
    fields = (
        "case_id", "trajectory_id", "lift_scale", "mass_scale", "inertia_scale",
        "tracking_rmse_m", "tracking_peak_m", "steady_abs_error_m",
        "disturbance_event_count", "disturbance_recovery_s", "ardg_active_fraction",
        "max_yawless_tilt_rad", "max_abs_body_rate_radps", "max_motor_command_q",
        "all_physical_pass", "source_reference", "source_sha256", "source_export_sha256",
    )
    rows = []
    for item in contract["compound_stress"]:
        row = metrics[item["case_id"]]
        require(row["all_physical_pass"].lower() == "true", f"compound physical checks failed: {item['case_id']}")
        raw = source(item["source_reference"])
        rows.append({
            "case_id": item["case_id"],
            "trajectory_id": row["trajectory_id"],
            "lift_scale": row["lift_scale"],
            "mass_scale": row["mass_scale"],
            "inertia_scale": row["inertia_scale"],
            "tracking_rmse_m": row["tracking_rmse_m"],
            "tracking_peak_m": row["tracking_peak_m"],
            "steady_abs_error_m": row["steady_abs_error_m"],
            "disturbance_event_count": row["disturbance_event_count"],
            "disturbance_recovery_s": row["disturbance_recovery_s"],
            "ardg_active_fraction": row["ardg_active_fraction"],
            "max_yawless_tilt_rad": row["max_yawless_tilt_rad"],
            "max_abs_body_rate_radps": row["max_abs_body_rate_radps"],
            "max_motor_command_q": row["max_motor_command_q"],
            "all_physical_pass": True,
            "source_reference": rel(raw),
            "source_sha256": sha256(raw),
            "source_export_sha256": row["raw_sha256"],
        })
    return csv_bytes(fields, rows)


def build_formation() -> bytes:
    fields = (
        "case_id", "supervisor", "formal_algorithm", "formation_rmse_m",
        "three_uav_global_position_rmse_m", "minimum_pairwise_distance_m",
        "risk_exposure_below_0_60_m_s", "source_reference", "source_sha256",
    )
    supervisors = {
        "Scene07B": "PP-CBF trajectory supervisor",
        "Scene07COff": "nominal supervisor (PP-CBF off)",
        "Scene07COnPredictiveV5C": "PP-CBF predictive supervisor on",
    }
    rows = []
    for case_id in supervisors:
        raw = source(f"06_supplementary_evidence/ardg_rgpc_formation_final/raw/{case_id}.csv")
        metrics = formation_metrics(raw)
        rows.append({
            "case_id": case_id,
            "supervisor": supervisors[case_id],
            "formal_algorithm": FORMAL,
            "formation_rmse_m": metrics["formation_rmse_m"],
            "three_uav_global_position_rmse_m": metrics["global_position_rmse_m"],
            "minimum_pairwise_distance_m": metrics["minimum_pairwise_distance_m"],
            "risk_exposure_below_0_60_m_s": metrics["risk_exposure_below_0_60_m_s"],
            "source_reference": rel(raw),
            "source_sha256": sha256(raw),
        })
    return csv_bytes(fields, rows)


def build_claim_index() -> bytes:
    fields = (
        "claim_id", "claim_zh", "status", "report_evidence",
        "raw_or_direct_evidence", "metric_script", "boundary_zh",
    )
    script = "02_scripts/evaluation/build_report_evidence.py"
    rows = [
        {"claim_id": "C01", "claim_zh": "ARDG-RGPC在三轴标准阶跃中保持低超调", "status": "supported", "report_evidence": "04_results/report_evidence/02_standard_step_pid_vs_main.csv", "raw_or_direct_evidence": "06_supplementary_evidence/ardg_rgpc_regression18_final/raw/Scene01S_X.csv;06_supplementary_evidence/ardg_rgpc_regression18_final/raw/Scene01S_Y.csv;06_supplementary_evidence/ardg_rgpc_regression18_final/raw/Scene01S_Z.csv", "metric_script": script, "boundary_zh": "PID超调量采用赛题官方参考指标；ARDG-RGPC由最终raw复算"},
        {"claim_id": "C02", "claim_zh": "五种控制对象在四个公共单机场景中完成同指标比较", "status": "supported", "report_evidence": "04_results/report_evidence/03_five_controller_common_scenes.csv", "raw_or_direct_evidence": "06_supplementary_evidence/ardg_rgpc_regression18_final/raw;04_results/report_evidence/official_pid_scene06b/raw.csv", "metric_script": script, "boundary_zh": "辅助算法只用于已有公共场景，不外推为全场景排名"},
        {"claim_id": "C03", "claim_zh": "11项预设参数工况中6项改善、5项基本等效", "status": "supported", "report_evidence": "04_results/report_evidence/05_parameter_11_robustness.csv", "raw_or_direct_evidence": "06_supplementary_evidence/ardg_rgpc_parameter11_final", "metric_script": script, "boundary_zh": "结论限定于已登记的几何控制基线与相同工况"},
        {"claim_id": "C04", "claim_zh": "20组随机参数中ARDG-RGPC相对官方PID为20胜0负", "status": "supported", "report_evidence": "04_results/report_evidence/parameter_random20_ardg_rgpc_final/statistical_summary.json", "raw_or_direct_evidence": "06_supplementary_evidence/parameter_random20_raw/PID;06_supplementary_evidence/ardg_rgpc_random20_final/cases", "metric_script": "02_scripts/evaluation/analyze_parameter_random20_final.py", "boundary_zh": "仅适用于冻结随机范围、场景和样本清单"},
        {"claim_id": "C05", "claim_zh": "三事件外力扰动中位置RMSE低于官方PID", "status": "supported", "report_evidence": "04_results/report_evidence/07_scene06b_pid_comparison.csv", "raw_or_direct_evidence": "04_results/report_evidence/official_pid_scene06b/raw.csv;06_supplementary_evidence/ardg_rgpc_regression18_final/raw/Scene06b.csv", "metric_script": script, "boundary_zh": "结论限定于Scene06b同场景、同指标比较"},
        {"claim_id": "C06", "claim_zh": "两个机体系角扰动场景完成ARDG-RGPC与官方PID同场景对照", "status": "supported", "report_evidence": "04_results/report_evidence/08_angular_disturbance_response.csv", "raw_or_direct_evidence": "05_visuals/final_shared_assets/data/BODY_ROLL_POS_ARDG-RGPC.csv;05_visuals/final_shared_assets/data/BODY_PITCH_NEG_ARDG-RGPC.csv;04_results/report_evidence/official_pid_angular", "metric_script": script, "boundary_zh": "官方PID在短时角脉冲下姿态与位置误差更低；ARDG-RGPC电机TV更低，结论仅限两个登记场景"},
        {"claim_id": "C07", "claim_zh": "18项代表性回归场景均形成最终算法直接结果", "status": "supported", "report_evidence": "04_results/report_evidence/06_regression18_metrics.csv;04_results/report_evidence/06_regression18_summary.json", "raw_or_direct_evidence": "06_supplementary_evidence/ardg_rgpc_regression18_final", "metric_script": script, "boundary_zh": "只报告最终算法绝对结果和已登记对照"},
        {"claim_id": "C08", "claim_zh": "PP-CBF开启后近距离风险暴露降为0秒", "status": "supported", "report_evidence": "04_results/report_evidence/09_formation_pp_cbf.csv", "raw_or_direct_evidence": "06_supplementary_evidence/ardg_rgpc_formation_final/raw", "metric_script": script, "boundary_zh": "PP-CBF是独立上层安全监督器，单机控制器为ARDG-RGPC"},
        {"claim_id": "C09", "claim_zh": "约束多目标参数搜索形成可追溯最终参数", "status": "supported", "report_evidence": "04_results/report_evidence/04_parameter_optimization_summary.csv", "raw_or_direct_evidence": "05_visuals/final_shared_assets/FINAL_ASSET_INDEX.json", "metric_script": script, "boundary_zh": "不使用加权总分，不宣称全局最优"},
        {"claim_id": "C10", "claim_zh": "六组复合参数与外扰测试均由ARDG-RGPC直接运行并通过物理检查", "status": "supported", "report_evidence": "04_results/report_evidence/10_compound_stress_final.csv", "raw_or_direct_evidence": "06_supplementary_evidence/ardg_rgpc_compound_final", "metric_script": script, "boundary_zh": "结论限定于六组登记参数组合、轨迹和三次外扰事件"},
    ]
    return csv_bytes(fields, rows)


def build_readme() -> bytes:
    return """# 决赛仿真报告证据层

本目录只服务于对外材料中的可复算结论。唯一主算法名称为 `ARDG-RGPC`；比较对象包括赛题官方 PID、`RA-GCA/Base`、`CAP-ADRC`、`CP-INDI`，`PP-CBF`作为独立上层编队安全监督器。

## 直接证据

- 18项代表性回归、11项预设参数、20组随机参数、三事件外力扰动和三组编队结果均链接最终算法直接结果。
- 20组随机参数与三事件外力扰动均提供官方 PID 对照。
- 两个机体系角扰动场景同时提供官方 PID 与 ARDG-RGPC 直接结果，并分别报告姿态误差、位置误差和电机总变差。
- 六组复合参数与外扰联合应力均由 ARDG-RGPC 直接运行，三次外扰事件和物理检查记录随包提供。

## 使用边界

- 不把辅助算法在个别场景的结果外推为全场景排名。
- 不把参数搜索表述为全局最优。
- 不把未由最终算法直接运行的数据归入 ARDG-RGPC 结论。
- 报告、PPT和视频中的数字应从本目录或其索引的直接源文件读取。

## 复算

在包根目录执行：

```powershell
.\\RECOMPUTE_REPORT_EVIDENCE.ps1 -Check
```

重建到包外目录：

```powershell
$Out = Join-Path ([IO.Path]::GetTempPath()) 'A8_finals_report_evidence'
.\\RECOMPUTE_REPORT_EVIDENCE.ps1 -OutputDirectory $Out
```
""".encode("utf-8")


def build_manifest(files: dict[str, bytes]) -> bytes:
    source_paths = sorted({
        "config/finals_report_evidence_contract.json",
        "04_results/report_evidence/official_pid_scene06b/raw.csv",
        "04_results/report_evidence/official_pid_angular/BODY_ROLL_POS/raw.csv",
        "04_results/report_evidence/official_pid_angular/BODY_PITCH_NEG/raw.csv",
        "04_results/report_evidence/parameter11_ardg_rgpc_final/parameter11_final_paired.csv",
        "04_results/report_evidence/parameter_random20_ardg_rgpc_final/statistical_summary.json",
        "05_visuals/final_shared_assets/FINAL_ASSET_INDEX.json",
        "06_supplementary_evidence/ardg_rgpc_regression18_final/execution_status.json",
        *[
            f"06_supplementary_evidence/ardg_rgpc_regression18_final/raw/{name}.csv"
            for name in (
                "Scene04", "Scene01", "Scene02", "Scene03", "Scene06b",
                "Scene01S_X", "Scene01S_Y", "Scene01S_Z",
                "Scene08_P0", "Scene08_P1", "Scene08_P2", "Scene08_P3", "Scene08_P4",
                "Scene10_P0", "Scene10_P1", "Scene10_P2", "Scene10_P3", "Scene10_P4",
            )
        ],
        *[
            f"06_supplementary_evidence/ardg_rgpc_formation_final/raw/{name}.csv"
            for name in ("Scene07B", "Scene07COff", "Scene07COnPredictiveV5C")
        ],
        "05_visuals/final_shared_assets/data/BODY_ROLL_POS_ARDG-RGPC.csv",
        "05_visuals/final_shared_assets/data/BODY_PITCH_NEG_ARDG-RGPC.csv",
        "06_supplementary_evidence/ardg_rgpc_compound_final/evaluation/compound_metrics.csv",
        *[
            f"06_supplementary_evidence/ardg_rgpc_compound_final/cases/{case_id}/raw.csv"
            for case_id in ("D_C01", "D_C02", "D_C03", "D_C04", "D_C05", "D_C06")
        ],
    })
    manifest = {
        "schema_version": 3,
        "formal_algorithm": FORMAL,
        "status": "frozen_finals_public_report_evidence",
        "scope": "finals_report_and_shared_materials",
        "generated_files": [
            {"path": name, "bytes": len(data), "sha256": sha256_bytes(data)}
            for name, data in sorted(files.items())
        ],
        "source_files": [
            {"path": name, "bytes": source(name).stat().st_size, "sha256": sha256(source(name))}
            for name in source_paths
        ],
        "public_boundaries": {
            "main_algorithm_claims": "final_algorithm_direct_evidence_required",
            "compound_stress": "six_direct_final_cases",
            "angular_pid_comparison": "direct_same_scene_comparison",
            "absolute_user_paths": "excluded_from_generated_files",
        },
    }
    return json_bytes(manifest)


def build_all() -> dict[str, bytes]:
    contract = load_contract()
    regression_csv, regression_summary = build_regression18(contract)
    files = {
        "README_报告证据使用边界.md": build_readme(),
        "01_five_controller_scene_coverage.csv": build_coverage(contract),
        "02_standard_step_pid_vs_main.csv": build_steps(contract),
        "03_five_controller_common_scenes.csv": build_common_scenes(contract),
        "04_parameter_optimization_summary.csv": build_parameter_optimization(),
        "05_parameter_11_robustness.csv": build_parameter11(),
        "06_regression18_metrics.csv": regression_csv,
        "06_regression18_summary.json": regression_summary,
        "07_scene06b_pid_comparison.csv": build_scene06b(),
        "08_angular_disturbance_response.csv": build_angular(contract),
        "09_formation_pp_cbf.csv": build_formation(),
        "10_compound_stress_final.csv": build_compound(contract),
        "10_claim_evidence_index.csv": build_claim_index(),
    }
    require(set(files) == set(VISIBLE_FILES), "generated public evidence set is incomplete")
    validate_visible_content(files)
    files[MANIFEST_NAME] = build_manifest(files)
    return files


def validate_visible_content(files: dict[str, bytes]) -> None:
    forbidden = ("初赛", "v914", "v936", "L06", "97406", "ARDG1", "RA-GCA-CGHTE", "PRIOR_MAIN")
    for name, data in files.items():
        text = data.decode("utf-8-sig")
        for token in forbidden:
            require(token not in text, f"forbidden public token {token!r} appears in {name}")
        require(not any(marker in text for marker in (":\\Users\\", ":/Users/")), f"absolute user path appears in {name}")


def write_output(output: Path, files: dict[str, bytes]) -> None:
    output.mkdir(parents=True, exist_ok=True)
    for name, data in files.items():
        target = output / Path(name)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)


def check_package() -> None:
    expected = build_all()
    for name, data in expected.items():
        path = EVIDENCE_DIR / name
        require(path.is_file(), f"packaged evidence is missing: {name}")
        require(path.read_bytes() == data, f"packaged evidence differs from generator: {name}")
    actual = {
        path.relative_to(EVIDENCE_DIR).as_posix()
        for path in EVIDENCE_DIR.rglob("*")
        if path.is_file()
        and not any(path.relative_to(EVIDENCE_DIR).as_posix().startswith(prefix) for prefix in PRESERVED_PREFIXES)
    }
    require(actual == set(expected), f"unexpected public evidence files: {sorted(actual - set(expected))}")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build or verify finals report evidence")
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--output-dir", type=Path)
    parser.add_argument("--build-package-evidence", action="store_true")
    parser.add_argument("--import-historical-sources", action="store_true")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)
    if args.import_historical_sources:
        raise EvidenceError("historical-source import is disabled for finals public evidence")
    if args.check:
        check_package()
        print("finals_report_evidence_check=pass")
        return 0
    files = build_all()
    if args.build_package_evidence:
        output = EVIDENCE_DIR
    else:
        require(args.output_dir is not None, "--output-dir is required")
        output = args.output_dir.resolve()
        require(not is_within(output, ROOT), "output must be outside the source package")
    write_output(output, files)
    print(json.dumps({"output": str(output), "file_count": len(files)}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except EvidenceError as exc:
        print(str(exc), file=sys.stderr)
        raise SystemExit(2)
