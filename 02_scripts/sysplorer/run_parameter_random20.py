"""Run the frozen 20-case PID/RA-GCA-CGHTE paired experiment in Sysplorer."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import shutil
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

import mworks.sysplorer as modeling


EXPERIMENT_ID = "PARAM_MC20_PID_vs_RA-GCA-CGHTE"
SAMPLE_COUNT = 20
SAMPLE_SEED = 20260719
INTERVAL_S = 0.01
STOP_TIME_S = 50.0
TOLERANCE = 0.0001
EXPECTED_ROWS = 5001
MIN_FREE_BYTES = 2 * 1024**3

EXPECTED_HASHES = {
    "official": "B39A8B23665A3B05CF3FAD406744021F0E65541A02D1EF052D2BD10BA7E76352",
    "pid": "27C075BD15521B234E710025AB7484E0BA7E1B23733664B0BFAECF33E45DA28D",
    "main_controller": "0BADB8524026CA8EFF93BEC55C56AB91866D2E7363DC69697407C234116E1BCA",
    "main_plant": "54BBDD79E1884AC5FF50A92D12F4AADC9E0E0699631BED9A32B610A42EACF280",
}

MAIN_CONTROLLER = "A8FormalRAGCACGHTE_20260715"
PID_MODEL = "A8FormalPidTwin.PidTopologyTwinScene04"
MAIN_MODEL = "A8RAGCACGHTEPlant20260715.Scene04"


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def require_true(label: str, value: Any) -> None:
    if not bool(value):
        raise RuntimeError(f"{label} failed: {modeling.GetLastErrors()!r}")


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(
        json.dumps(value, indent=2, ensure_ascii=False, allow_nan=False) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)


def flatten_values(value: Iterable[Any]) -> list[Any]:
    values = list(value)
    if len(values) != 1 or isinstance(values[0], (str, bytes)):
        return values
    try:
        nested = list(values[0])
    except TypeError:
        return values
    return nested or values


def result_values(name: str, time_values: list[float]) -> list[float]:
    values = [float(value) for value in flatten_values(modeling.GetVarValues(name))]
    if len(values) != len(time_values):
        values = [float(modeling.GetVarValueAt(name, point)) for point in time_values]
    if len(values) != len(time_values):
        raise RuntimeError(f"result length mismatch for {name}")
    if not all(math.isfinite(value) for value in values):
        raise RuntimeError(f"non-finite result in {name}")
    return values


def read_frozen_samples(manifest: Path, sidecar: Path) -> list[dict[str, Any]]:
    expected_digest = sidecar.read_text(encoding="utf-8").split()[0].upper()
    actual_digest = sha256(manifest)
    if actual_digest != expected_digest:
        raise RuntimeError(
            f"sample manifest hash mismatch: {actual_digest} != {expected_digest}"
        )
    with manifest.open("r", encoding="utf-8", newline="") as stream:
        rows = list(csv.DictReader(stream))
    expected_ids = [f"MC20_{index:02d}" for index in range(1, SAMPLE_COUNT + 1)]
    if [row.get("case_id") for row in rows] != expected_ids:
        raise RuntimeError("sample identifiers or order do not match the frozen contract")

    samples: list[dict[str, Any]] = []
    for index, row in enumerate(rows, 1):
        if int(row["seed"]) != SAMPLE_SEED or int(row["draw_index"]) != index:
            raise RuntimeError(f"invalid seed or draw index for {row['case_id']}")
        if row["formal_statistics_eligible"].strip().lower() != "true":
            raise RuntimeError(f"ineligible formal sample: {row['case_id']}")
        scales = tuple(
            float(row[name])
            for name in ("lift_scale", "mass_scale", "inertia_scale")
        )
        if not all(0.90 <= value <= 1.10 for value in scales):
            raise RuntimeError(f"sample out of range: {row['case_id']}")
        samples.append({"case_id": row["case_id"], "scales": scales})
    return samples


def set_parameter(
    model: str, component: str, parameter: str, expected: float
) -> dict[str, Any]:
    before = modeling.GetModelParamValue(model, component, parameter)
    expression = format(expected, ".15g")
    require_true(
        f"SetModelParamValue {model}.{component}.{parameter}",
        modeling.SetModelParamValue(model, component, parameter, expression),
    )
    after = modeling.GetModelParamValue(model, component, parameter)
    actual = float(after)
    if not math.isclose(actual, expected, rel_tol=1e-12, abs_tol=1e-15):
        raise RuntimeError(
            f"parameter readback mismatch for {component}.{parameter}: "
            f"{actual:.15g} != {expected:.15g}"
        )
    return {
        "component": component,
        "parameter": parameter,
        "before": before,
        "after": after,
        "expected": expected,
    }


def apply_parameter_scales(
    model: str, scales: tuple[float, float, float]
) -> list[dict[str, Any]]:
    lift_scale, mass_scale, inertia_scale = scales
    assignments: list[tuple[str, str, float]] = [
        ("quadChassisTest17_1", "lift_cofficient", 0.002 * lift_scale),
        ("quadChassisTest17_1.body", "m", 0.159504 * mass_scale),
        ("quadChassisTest17_1.body", "I_11", 0.00010556 * inertia_scale),
        ("quadChassisTest17_1.body", "I_22", 0.00010556 * inertia_scale),
        ("quadChassisTest17_1.body", "I_33", 0.00010556 * inertia_scale),
    ]
    for index in range(1, 5):
        component = f"quadChassisTest17_1.propellers{index}"
        assignments.extend(
            [
                (component, "m", 0.000913171 * mass_scale),
                (component, "I_11", 1.59662e-7 * inertia_scale),
                (component, "I_22", 1.59594e-7 * inertia_scale),
                (component, "I_33", 3.16359e-7 * inertia_scale),
            ]
        )
    return [set_parameter(model, *assignment) for assignment in assignments]


def apply_fixed_main_parameters() -> list[dict[str, Any]]:
    assignments = (
        ("activation_covariance_max_param", "Value", 0.00253218969247675),
        ("activation_persistence_s_param", "Value", 0.10),
        ("scale_rate_per_step_param", "Value", 0.00868),
    )
    return [
        set_parameter(MAIN_CONTROLLER, component, parameter, value)
        for component, parameter, value in assignments
    ]


def source_paths(snapshot: Path) -> dict[str, Path]:
    return {
        "official": snapshot / "01_models/official/QuadrotorModel/package.mo",
        "pid": snapshot / "01_models/dependencies/A8FormalPidTwin/package.mo",
        "main_controller": snapshot
        / "01_models/sysblock/A8FormalRAGCACGHTE_20260715.mo",
        "main_plant": snapshot
        / "01_models/modelica/A8RAGCACGHTEPlant20260715/package.mo",
    }


def load_source(path: Path, class_name: str) -> dict[str, Any]:
    if not path.is_file():
        raise RuntimeError(f"missing model source: {path}")
    before = bool(modeling.ClassExist(class_name))
    if not before:
        require_true(f"OpenModelFile {class_name}", modeling.OpenModelFile(str(path)))
    after = bool(modeling.ClassExist(class_name))
    if not after:
        raise RuntimeError(f"model class was not loaded: {class_name}")
    return {"path": str(path), "class": class_name, "preloaded": before}


def export_standardized_result(
    output: Path, controller: str, reference_names: list[str], motor_names: list[str]
) -> dict[str, Any]:
    time_values = [float(value) for value in flatten_values(modeling.GetVarValues("time"))]
    if len(time_values) != EXPECTED_ROWS:
        raise RuntimeError(f"unexpected result row count: {len(time_values)}")
    if not math.isclose(time_values[0], 0.0, abs_tol=1e-12) or not math.isclose(
        time_values[-1], STOP_TIME_S, abs_tol=1e-8
    ):
        raise RuntimeError("unexpected simulation time range")

    variables: list[tuple[str, str]] = []
    variables.extend(
        (f"reference_{axis}_m", name)
        for axis, name in zip(("x", "y", "z"), reference_names)
    )
    variables.extend(
        (f"position_{axis}_m", f"quadChassisTest17_1.body.r_0[{index}]")
        for index, axis in enumerate(("x", "y", "z"), 1)
    )
    variables.extend(
        (f"velocity_{axis}_mps", f"quadChassisTest17_1.body.v_0[{index}]")
        for index, axis in enumerate(("x", "y", "z"), 1)
    )
    variables.extend(
        (f"angle_{index}_rad", f"sensors1_1.AngleMea[{index}]")
        for index in range(1, 4)
    )
    variables.extend(
        (f"body_rate_{index}_radps", f"quadChassisTest17_1.body.frame_b.R.w[{index}]")
        for index in range(1, 4)
    )
    variables.extend(
        (
            f"rotation_{row}{column}",
            f"quadChassisTest17_1.body.frame_b.R.T[{row},{column}]",
        )
        for row in range(1, 4)
        for column in range(1, 4)
    )
    variables.extend(
        (f"motor_command_{index}", name)
        for index, name in enumerate(motor_names, 1)
    )
    columns = [("time_s", time_values)] + [
        (column, result_values(variable, time_values))
        for column, variable in variables
    ]

    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.writer(stream, lineterminator="\n")
        writer.writerow([name for name, _ in columns])
        writer.writerows(zip(*(values for _, values in columns)))
    with output.open("r", encoding="utf-8", newline="") as stream:
        reader = csv.reader(stream)
        header = next(reader)
        row_count = sum(1 for _ in reader)
    if row_count != EXPECTED_ROWS or len(header) != len(columns):
        raise RuntimeError("export verification failed")
    return {
        "controller": controller,
        "path": str(output),
        "rows": row_count,
        "columns": len(header),
        "sha256": sha256(output),
    }


def simulate_controller(
    controller: str,
    model: str,
    scales: tuple[float, float, float],
    output: Path,
    reference_names: list[str],
    motor_names: list[str],
) -> dict[str, Any]:
    started = time.perf_counter()
    record: dict[str, Any] = {
        "controller": controller,
        "model": model,
        "parameter_scales": {
            "lift": scales[0],
            "mass": scales[1],
            "inertia": scales[2],
        },
        "parameter_assignments": [],
        "check": False,
        "translate": False,
        "simulate": False,
        "raw": None,
        "success": False,
    }
    try:
        record["parameter_assignments"] = apply_parameter_scales(model, scales)
        if controller == "RA-GCA-CGHTE":
            record["fixed_main_parameters"] = apply_fixed_main_parameters()
        require_true(f"CheckModel {controller}", modeling.CheckModel(model))
        record["check"] = True
        require_true(f"TranslateModel {controller}", modeling.TranslateModel(model))
        record["translate"] = True
        simulation_path = output / "simulation"
        simulation_path.mkdir(parents=True, exist_ok=True)
        require_true(
            f"SimulateModel {controller}",
            modeling.SimulateModel(
                modelName=model,
                startTime=0.0,
                stopTime=STOP_TIME_S,
                interval=INTERVAL_S,
                tolerance=TOLERANCE,
                algo="Dassl",
                storeDouble=True,
                storeEvent=False,
                simMode=0,
                path=str(simulation_path),
            ),
        )
        record["simulate"] = True
        record["raw"] = export_standardized_result(
            output / "raw.csv", controller, reference_names, motor_names
        )
        record["success"] = True
        return record
    except Exception as exc:
        record["failure"] = {"type": type(exc).__name__, "message": str(exc)}
        raise
    finally:
        record["nominal_restore"] = apply_parameter_scales(model, (1.0, 1.0, 1.0))
        if controller == "RA-GCA-CGHTE":
            record["main_parameter_restore"] = apply_fixed_main_parameters()
        record["elapsed_s"] = time.perf_counter() - started
        write_json(output / "execution_status.json", record)


def run(args: argparse.Namespace) -> dict[str, Any]:
    snapshot = args.snapshot.resolve()
    manifest = args.manifest.resolve()
    sidecar = args.manifest_sha256.resolve()
    output = args.output.resolve()
    if output.exists():
        raise RuntimeError(f"refusing to reuse output directory: {output}")
    output.parent.mkdir(parents=True, exist_ok=True)
    if shutil.disk_usage(output.parent).free < MIN_FREE_BYTES:
        raise RuntimeError("less than 2 GiB free space before formal batch")

    samples = read_frozen_samples(manifest, sidecar)
    paths = source_paths(snapshot)
    source_bytes = {name: path.read_bytes() for name, path in paths.items()}
    hashes_before = {name: sha256(path) for name, path in paths.items()}
    for name, expected in EXPECTED_HASHES.items():
        if hashes_before[name] != expected:
            raise RuntimeError(
                f"source hash mismatch for {name}: {hashes_before[name]} != {expected}"
            )

    output.mkdir(parents=True, exist_ok=False)
    status: dict[str, Any] = {
        "schema_version": 1,
        "experiment_id": EXPERIMENT_ID,
        "formal_statistics_eligible": True,
        "started_utc": utc_now(),
        "finished_utc": None,
        "success": False,
        "port": None,
        "sample_manifest": str(manifest),
        "sample_manifest_sha256": sha256(manifest),
        "sample_count": len(samples),
        "session_directory_before": None,
        "session_directory_after": None,
        "source_hashes_before": hashes_before,
        "source_hashes_after": None,
        "source_restored": [],
        "dependencies": [],
        "cases": [],
        "failure": None,
    }
    write_json(output / "batch_execution_status.json", status)

    try:
        ports = sorted(int(port) for port in modeling.FindSysplorer())
        if len(ports) != 1:
            raise RuntimeError(f"single-instance contract failed: {ports}")
        port = ports[0]
        if args.port is not None and port != args.port:
            raise RuntimeError(f"requested Sysplorer port {args.port} is not active: {ports}")
        status["port"] = port
        modeling.ConnectSysplorer(ip="127.0.0.1", port=port)
        status["session_directory_before"] = str(modeling.GetDirectory())

        loaded = bool(modeling.LoadLibrary("Modelica", "4.0.0.TY.1"))
        if not loaded and not bool(modeling.ClassExist("Modelica")):
            raise RuntimeError(f"LoadLibrary Modelica failed: {modeling.GetLastErrors()!r}")
        status["dependencies"].extend(
            [
                load_source(paths["official"], "QuadrotorModel"),
                load_source(paths["pid"], "A8FormalPidTwin"),
                load_source(paths["main_controller"], MAIN_CONTROLLER),
                load_source(paths["main_plant"], "A8RAGCACGHTEPlant20260715"),
            ]
        )

        for sample in samples:
            case_started = time.perf_counter()
            case_output = output / sample["case_id"]
            case_record: dict[str, Any] = {
                "case_id": sample["case_id"],
                "parameter_scales": {
                    "lift": sample["scales"][0],
                    "mass": sample["scales"][1],
                    "inertia": sample["scales"][2],
                },
                "controllers": [],
                "success": False,
            }
            try:
                case_record["controllers"].append(
                    simulate_controller(
                        "PID",
                        PID_MODEL,
                        sample["scales"],
                        case_output / "PID",
                        [f"climbePath.position_command[{index}]" for index in range(1, 4)],
                        [
                            "controller3_2.y",
                            "controller3_2.y1",
                            "controller3_2.y2",
                            "controller3_2.y3",
                        ],
                    )
                )
                case_record["controllers"].append(
                    simulate_controller(
                        "RA-GCA-CGHTE",
                        MAIN_MODEL,
                        sample["scales"],
                        case_output / "RA-GCA-CGHTE",
                        [f"referenceVector[{index}]" for index in range(1, 4)],
                        [f"motorCommand[{index}]" for index in range(1, 5)],
                    )
                )
                case_record["success"] = True
            except Exception as exc:
                case_record["failure"] = {
                    "type": type(exc).__name__,
                    "message": str(exc),
                }
                raise
            finally:
                case_record["elapsed_s"] = time.perf_counter() - case_started
                write_json(case_output / "case_status.json", case_record)
                status["cases"].append(case_record)
                write_json(output / "batch_execution_status.json", status)

        status["session_directory_after"] = str(modeling.GetDirectory())
        if status["session_directory_after"] != status["session_directory_before"]:
            raise RuntimeError("Sysplorer working directory changed during formal batch")
        status["success"] = True
    except Exception as exc:
        status["failure"] = {"type": type(exc).__name__, "message": str(exc)}
        try:
            status["last_errors"] = str(modeling.GetLastErrors())
        except Exception:
            status["last_errors"] = None
    finally:
        for name, path in paths.items():
            if path.read_bytes() != source_bytes[name]:
                path.write_bytes(source_bytes[name])
                status["source_restored"].append(name)
        status["source_hashes_after"] = {name: sha256(path) for name, path in paths.items()}
        if status["source_hashes_after"] != hashes_before:
            status["success"] = False
            if status["failure"] is None:
                status["failure"] = {
                    "type": "SourceGuardError",
                    "message": "model snapshot hashes changed after restoration",
                }
        status["finished_utc"] = utc_now()
        status["completed_case_count"] = sum(
            1 for case in status["cases"] if case.get("success")
        )
        write_json(output / "batch_execution_status.json", status)

    print(f"experiment={EXPERIMENT_ID}")
    print(f"success={str(status['success']).lower()}")
    print(f"completed_case_count={status['completed_case_count']}")
    return status


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--snapshot", type=Path, required=True)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--manifest-sha256", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--port", type=int)
    return parser.parse_args()


if __name__ == "__main__":
    raise SystemExit(0 if run(parse_args())["success"] else 1)
