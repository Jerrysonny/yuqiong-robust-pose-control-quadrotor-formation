"""Run the formal ARDG-RGPC finals simulation suites.

This runner never starts, exits, clears, or changes the directory of Sysplorer.
The promoted controller parameters are fixed and cannot be changed from the CLI.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import mworks.sysplorer as modeling


# 启动前核对官方模型和正式控制器哈希，防止误加载其他版本。
EXPECTED_OFFICIAL_SHA256 = (
    "E16DECED48CFFB9196AB014491C2BB27E7BE864A388E169EF4B775877B4B6658"
)
EXPECTED_MAIN_CONTROLLER_SHA256 = (
    "9C0E784EEA14687C26F9CAE9BC3FBDC9F546492659C56CF12E49BA2C80F7FE0F"
)
INTERVAL_S = 0.01
MAIN_CONTROLLER = "A8FormalRAGCACGHTE_20260715"
MAIN_PLANT = "A8RAGCACGHTEPlant20260715"
STEP_PLANT = "A8RAGCACGHTEStepPlant20260715"
PHASE_PLANT = "A8RAGCACGHTEPhaseValidationPlant20260715"
FORMATION_PLANT = "A8RAGCACGHTEFormationValidationPlant20260715"
ANGULAR_PLANT = "A8ARDGRGPCFinalScenarios20260815"

ACTIVATION_COVARIANCE_DEFAULT = 0.00253218969247675
ACTIVATION_COVARIANCE_MIN = 0.00125
ACTIVATION_COVARIANCE_MAX = 0.005
ACTIVATION_PERSISTENCE_DEFAULT_S = 0.10
ACTIVATION_PERSISTENCE_MIN_S = 0.10
ACTIVATION_PERSISTENCE_MAX_S = 0.30
ACTIVATION_PERSISTENCE_QUANTUM_S = 0.01
SCALE_RATE_DEFAULT_PER_S = 0.868
SCALE_RATE_MIN_PER_S = 0.4
SCALE_RATE_MAX_PER_S = 1.0

SINGLE_V8_VARIABLES = (
    # 单机结果按参考量、状态量、电机量和16维诊断固定列序导出。
    ["time"]
    + [f"referenceVector[{index}]" for index in range(1, 12)]
    + [f"quadChassisTest17_1.body.r_0[{index}]" for index in range(1, 4)]
    + [f"quadChassisTest17_1.body.v_0[{index}]" for index in range(1, 4)]
    + [f"sensors1_1.AngleMea[{index}]" for index in range(1, 4)]
    + [f"quadChassisTest17_1.body.frame_b.R.w[{index}]" for index in range(1, 4)]
    + [
        f"quadChassisTest17_1.body.frame_b.R.T[{row},{column}]"
        for row in range(1, 4)
        for column in range(1, 4)
    ]
    + [f"motorCommand[{index}]" for index in range(1, 5)]
    + [f"speedSensor[{index}].w" for index in range(1, 5)]
    + [f"controllerDiagnostics[{index}]" for index in range(1, 17)]
)
DISTURBANCE_V8_VARIABLES = SINGLE_V8_VARIABLES + [
    "quadChassisTest17_1.perRotorDisturbance"
]

PHYSICAL_V8_VARIABLES = (
    ["time"]
    + [f"referenceVector[{index}]" for index in range(1, 12)]
    + [f"quadChassisTest17_1.body.r_0[{index}]" for index in range(1, 4)]
    + [f"quadChassisTest17_1.body.v_0[{index}]" for index in range(1, 4)]
    + [f"sensors1_1.AngleMea[{index}]" for index in range(1, 4)]
    + [f"quadChassisTest17_1.body.frame_b.R.w[{index}]" for index in range(1, 4)]
    + [
        f"quadChassisTest17_1.body.frame_b.R.T[{row},{column}]"
        for row in range(1, 4)
        for column in range(1, 4)
    ]
    + [f"motorCommand[{index}]" for index in range(1, 5)]
    + [f"motorApplied[{index}]" for index in range(1, 5)]
    + [f"speedSensor[{index}].w" for index in range(1, 5)]
    + [f"controllerDiagnostics[{index}]" for index in range(1, 17)]
    + [f"scenarioDiagnostics[{index}]" for index in range(1, 17)]
)

PARAMETER_V8_VARIABLES = SINGLE_V8_VARIABLES + [
    f"scenarioDiagnostics[{index}]" for index in range(1, 17)
]

FORMATION_VARIABLES = (
    # 编队结果同时保留三机状态、队形参考和安全监督器诊断。
    ["time"]
    + [f"leaderReference[{index}]" for index in range(1, 10)]
    + [f"formationOffset[{index}]" for index in range(1, 10)]
    + [f"formationReference[{index}]" for index in range(1, 28)]
    + [f"supervisorDiagnostics[{index}]" for index in range(1, 9)]
    + [
        f"quad{vehicle}.body.r_0[{axis}]"
        for vehicle in range(1, 4)
        for axis in range(1, 4)
    ]
    + [
        f"quad{vehicle}.body.v_0[{axis}]"
        for vehicle in range(1, 4)
        for axis in range(1, 4)
    ]
    + [
        f"sensors{vehicle}.AngleMea[{axis}]"
        for vehicle in range(1, 4)
        for axis in range(1, 4)
    ]
    + [
        f"quad{vehicle}.body.frame_b.R.w[{axis}]"
        for vehicle in range(1, 4)
        for axis in range(1, 4)
    ]
    + [
        f"quad{vehicle}.body.frame_b.R.T[{row},{column}]"
        for vehicle in range(1, 4)
        for row in range(1, 4)
        for column in range(1, 4)
    ]
    + [
        f"motorCommand{vehicle}[{motor}]"
        for vehicle in range(1, 4)
        for motor in range(1, 5)
    ]
    + [
        f"speedSensor{vehicle}[{motor}].w"
        for vehicle in range(1, 4)
        for motor in range(1, 5)
    ]
    + [
        f"controllerDiagnostics{vehicle}[{index}]"
        for vehicle in range(1, 4)
        for index in range(1, 17)
    ]
)

SCENE_ORDER = (
    # 默认顺序先运行公共单机场景，再运行参数、风扰和编队场景。
    "Scene04",
    "Scene01",
    "Scene02",
    "Scene03",
    "Scene06b",
    "Scene01S_X",
    "Scene01S_Y",
    "Scene01S_Z",
    "Scene05B",
    "Scene08",
    "Scene10",
    "Scene07B",
    "Scene07C",
)
SCENE05A_CASES = (
    "Scene05A_LiftMinus5",
    "Scene05A_PayloadPlus5",
    "Scene05A_CombinedHalf",
)
SCENE05B_CASES = (
    "Scene05B_Nominal",
    "Scene05B_C000",
    "Scene05B_C001",
    "Scene05B_C010",
    "Scene05B_C011",
    "Scene05B_C100",
    "Scene05B_C101",
    "Scene05B_C110",
    "Scene05B_C111",
)
SCENE05B_FOCUS_CASES = (
    "Scene05B_LiftMinus10",
    "Scene05B_PayloadPlus10",
)
NOMINAL_PARAMETER_SCALES = (1.0, 1.0, 1.0)
SCENE05B_SCALES = {
    "Scene05B_Nominal": NOMINAL_PARAMETER_SCALES,
    "Scene05B_LiftMinus10": (0.9, 1.0, 1.0),
    "Scene05B_PayloadPlus10": (1.0, 1.1, 1.1),
}
SCENE05A_SCALES = {
    "Scene05A_LiftMinus5": (0.95, 1.0, 1.0),
    "Scene05A_PayloadPlus5": (1.0, 1.05, 1.05),
    "Scene05A_CombinedHalf": (0.95, 1.05, 1.05),
}
for _bits in ("000", "001", "010", "011", "100", "101", "110", "111"):
    SCENE05B_SCALES[f"Scene05B_C{_bits}"] = tuple(
        0.9 if bit == "0" else 1.1 for bit in _bits
    )
SCENE08_CASES = tuple(f"Scene08_P{index}" for index in range(5))
SCENE10_CASES = tuple(f"Scene10_P{index}" for index in range(5))
SCENE07C_CASES = ("Scene07COff", "Scene07COnPredictiveV5C")
ANGULAR_CASES = ("BODY_ROLL_POS", "BODY_PITCH_NEG")
REGRESSION18_CASES = (
    "Scene04", "Scene01", "Scene02", "Scene03", "Scene06b",
    "Scene01S_X", "Scene01S_Y", "Scene01S_Z",
    *SCENE08_CASES, *SCENE10_CASES,
)
SUPPLEMENTARY_CASES = (
    "Scene05B_Nominal", *SCENE05B_FOCUS_CASES, *SCENE05B_CASES[1:],
    "Scene07B", *SCENE07C_CASES,
)
FINALS_CORE_CASES = REGRESSION18_CASES + ANGULAR_CASES
FULL_REGISTERED_CASES = FINALS_CORE_CASES + SUPPLEMENTARY_CASES


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def compact_utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def require_file(path: Path, label: str) -> Path:
    resolved = path.resolve()
    if not resolved.is_file():
        raise RuntimeError(f"missing {label}: {resolved}")
    return resolved


def require_nominal_parameter_source(path: Path) -> None:
    # 参数场景运行前必须确认共享模型仍处于名义值。
    text = path.read_text(encoding="utf-8")
    match = re.search(r"\bmodel\s+Scene04\b(?P<body>.*?)\bend\s+Scene04\s*;", text, re.S)
    if match is None:
        raise RuntimeError(
            "parameter source is not at the frozen nominal default: "
            f"{path}"
        )
    body = match.group("body")
    if re.search(r"\bextends\s+PlantBase\s*;", body):
        return
    normalized = re.sub(r"\s+", "", body)
    required = (
        "extendsPlantBase(quadChassisTest17_1(lift_cofficient=0.002,",
        "body(m=0.159504,I_11=0.00010556,I_22=0.00010556,I_33=0.00010556)",
        "propellers1(m=0.000913171,I_11=1.59662e-07,I_22=1.59594e-07,I_33=3.16359e-07)",
        "propellers2(m=0.000913171,I_11=1.59662e-07,I_22=1.59594e-07,I_33=3.16359e-07)",
        "propellers3(m=0.000913171,I_11=1.59662e-07,I_22=1.59594e-07,I_33=3.16359e-07)",
        "propellers4(m=0.000913171,I_11=1.59662e-07,I_22=1.59594e-07,I_33=3.16359e-07)))",
    )
    if not all(item in normalized for item in required):
        raise RuntimeError(
            "parameter source is not at the frozen nominal default: "
            f"{path}"
        )


def restore_source_bytes(path: Path, snapshot: bytes) -> bool:
    if path.read_bytes() == snapshot:
        return False
    temporary = path.with_suffix(path.suffix + ".restore.tmp")
    temporary.write_bytes(snapshot)
    temporary.replace(path)
    if path.read_bytes() != snapshot:
        raise RuntimeError(f"failed to restore source snapshot: {path}")
    return True


def restore_frozen_source(
    path: Path, snapshot: bytes, mutation_backup: Path
) -> dict[str, Any]:
    # Sysplorer可能回写序列化文本；先留证，再恢复冻结源码字节。
    current = path.read_bytes()
    snapshot_hash = hashlib.sha256(snapshot).hexdigest().upper()
    mutation_record: dict[str, Any] | None = None
    if current != snapshot:
        mutation_backup.parent.mkdir(parents=True, exist_ok=True)
        previous_backup = backup_existing(mutation_backup)
        mutation_backup.write_bytes(current)
        mutation_hash = sha256(mutation_backup)
        if mutation_hash != hashlib.sha256(current).hexdigest().upper():
            raise RuntimeError(
                f"post-run source mutation backup mismatch: {mutation_backup}"
            )
        mutation_record = {
            "path": str(mutation_backup),
            "sha256": mutation_hash,
            "previous_backup": (
                str(previous_backup) if previous_backup is not None else None
            ),
        }
    restored = restore_source_bytes(path, snapshot)
    after_hash = sha256(path)
    if after_hash != snapshot_hash:
        raise RuntimeError(
            f"frozen source hash mismatch after restore: {after_hash} != {snapshot_hash}"
        )
    return {
        "mutation_detected": current != snapshot,
        "mutation_backup": mutation_record,
        "source_snapshot_restored": restored,
        "sha256_after": after_hash,
    }


def backup_existing(path: Path) -> Path | None:
    if not path.exists():
        return None
    stamp = compact_utc_now()
    backup = path.with_name(f"{path.name}.bak.{stamp}")
    suffix = 1
    while backup.exists():
        backup = path.with_name(f"{path.name}.bak.{stamp}.{suffix}")
        suffix += 1
    path.replace(backup)
    return backup


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(
        json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    temporary.replace(path)


def write_named_columns(
    path: Path, columns: list[tuple[str, list[float]]]
) -> tuple[dict[str, Any], Path | None]:
    if not columns:
        raise RuntimeError("empty column contract")
    row_count = len(columns[0][1])
    if row_count == 0 or any(
        len(values) != row_count
        or any(not math.isfinite(value) for value in values)
        for _, values in columns
    ):
        raise RuntimeError("invalid named-column data")
    path.parent.mkdir(parents=True, exist_ok=True)
    backup = backup_existing(path)
    temporary = path.with_suffix(path.suffix + ".tmp")
    try:
        with temporary.open("w", newline="", encoding="utf-8") as stream:
            writer = csv.writer(stream, lineterminator="\n")
            writer.writerow([name for name, _ in columns])
            writer.writerows(zip(*(values for _, values in columns)))
        temporary.replace(path)
    except Exception:
        if backup is not None and not path.exists():
            backup.replace(path)
        raise
    schema = hashlib.sha256(
        ",".join(name for name, _ in columns).encode("utf-8")
    ).hexdigest().upper()
    return ({
        "path": str(path), "sha256": sha256(path), "rows": row_count,
        "columns": len(columns), "schema_sha256": schema,
    }, backup)


def export_ardg_result(
    raw_path: Path, diagnostics_path: Path, stop_time: float
) -> tuple[dict[str, Any], dict[str, Any], list[Path]]:
    times = [float(value) for value in flatten_values(modeling.GetVarTimes())]
    expected_rows = int(round(stop_time / INTERVAL_S)) + 1
    if len(times) != expected_rows or any(
        abs(value - index * INTERVAL_S) > 1e-12
        for index, value in enumerate(times)
    ):
        raise RuntimeError(
            f"invalid ARDG time axis: rows={len(times)}, expected={expected_rows}"
        )

    prefix = "plant."
    variables: list[tuple[str, str]] = []
    variables.extend((f"reference_{i}", f"{prefix}referenceVector[{i}]") for i in range(1, 12))
    variables.extend((f"position_{axis}_m", f"{prefix}sensors1_1.PosMea[{i}]") for i, axis in enumerate("xyz", 1))
    variables.extend((f"velocity_{axis}_mps", f"{prefix}quadChassisTest17_1.body.v_0[{i}]") for i, axis in enumerate("xyz", 1))
    variables.extend((f"angle_{axis}_rad", f"{prefix}sensors1_1.AngleMea[{i}]") for i, axis in enumerate(("roll", "pitch", "yaw"), 1))
    variables.extend((f"body_rate_{axis}_radps", f"{prefix}quadChassisTest17_1.body.frame_b.R.w[{i}]") for i, axis in enumerate("xyz", 1))
    variables.extend((f"rotation_{row}{column}", f"{prefix}quadChassisTest17_1.body.frame_b.R.T[{row},{column}]") for row in range(1, 4) for column in range(1, 4))
    variables.extend((f"motor_command_{i}", f"{prefix}motorCommand[{i}]") for i in range(1, 5))
    variables.extend((f"rotor_speed_{i}_radps", f"{prefix}speedSensor[{i}].w") for i in range(1, 5))
    variables.extend((f"controller_diagnostic_{i}", f"controllerDiagnostics[{i}]") for i in range(1, 17))
    variables.append(("event_code", f"{prefix}eventCode"))
    variables.extend((f"external_force_world_{axis}_n", f"{prefix}externalForceWorld[{i}]") for i, axis in enumerate("xyz", 1))
    variables.extend((f"external_torque_body_{axis}_nm", f"{prefix}externalTorqueBody[{i}]") for i, axis in enumerate("xyz", 1))

    columns: list[tuple[str, list[float]]] = [("time_s", times)]
    columns.extend((name, result_values(source, times)) for name, source in variables)
    lookup = dict(columns)
    if sorted(set(lookup["controller_diagnostic_16"])) != [97406.0]:
        raise RuntimeError("formal ARDG-RGPC controller identity mismatch")
    for i, axis in enumerate("xyz", 1):
        columns.append((f"position_error_{axis}_m", [
            value - reference for value, reference in zip(
                lookup[f"position_{axis}_m"], lookup[f"reference_{i}"]
            )
        ]))
    raw, raw_backup = write_named_columns(raw_path, columns)

    diagnostic_sources = {
        "ardg_active": "controller.ardg1_active_next.y",
        "ardg_blend": "controller.ardg1_blend_next.y",
        "ardg_correction_x_nm": "controller.ardg1_correction_x_next.y",
        "ardg_correction_y_nm": "controller.ardg1_correction_y_next.y",
        "ardg_residual_tau_x_nm": "controller.ardg1_residual_x.y",
        "ardg_residual_tau_y_nm": "controller.ardg1_residual_y.y",
        "ardg_translation_residual_n": "controller.ardg1_trans_residual_norm.y",
        "ardg_torque_mode": "controller.ardg1_torque_mode.y",
        "ardg_translation_score": "controller.ardg1_trans_score.y",
        "ardg_safety_valid": "controller.ardg1_safety_valid.y",
    }
    diagnostic_columns = [("time_s", times)] + [
        (name, result_values(source, times)) for name, source in diagnostic_sources.items()
    ]
    diagnostics, diagnostics_backup = write_named_columns(diagnostics_path, diagnostic_columns)

    motor_values = [value for i in range(1, 5) for value in lookup[f"motor_command_{i}"]]
    allocator_values = lookup["controller_diagnostic_15"]
    raw.update({
        "start_time_s": times[0], "stop_time_s": times[-1],
        "max_abs_motor_command": max(abs(value) for value in motor_values),
        "max_motor_command_q": max(value * value for value in motor_values),
        "allocator_limit_min": min(allocator_values),
        "allocator_limit_max": max(allocator_values),
    })
    backups = [path for path in (raw_backup, diagnostics_backup) if path is not None]
    return raw, diagnostics, backups


def require_true(label: str, value: Any) -> None:
    if not bool(value):
        raise RuntimeError(f"{label} failed: {modeling.GetLastErrors()!r}")


def apply_fixed_main_parameters(
    values: dict[str, float],
) -> list[dict[str, Any]]:
    # 正式参数只从冻结常量写入，并逐项读回校验。
    assignments = (
        (
            "activation_covariance_max_param",
            "Value",
            values["activation_covariance_max"],
        ),
        (
            "activation_persistence_s_param",
            "Value",
            values["activation_persistence_s"],
        ),
        (
            "scale_rate_per_step_param",
            "Value",
            values["scale_rate_per_step"],
        ),
    )
    records: list[dict[str, Any]] = []
    for component, parameter, expected in assignments:
        before = modeling.GetModelParamValue(
            MAIN_CONTROLLER, component, parameter
        )
        expression = format(expected, ".15g")
        require_true(
            f"SetModelParamValue {component}.{parameter}",
            modeling.SetModelParamValue(
                MAIN_CONTROLLER, component, parameter, expression
            ),
        )
        after = modeling.GetModelParamValue(
            MAIN_CONTROLLER, component, parameter
        )
        try:
            actual = float(after)
        except (TypeError, ValueError) as exc:
            raise RuntimeError(
                f"fixed main parameter readback is not numeric: {component}.{parameter}={after!r}"
            ) from exc
        if not math.isclose(actual, expected, rel_tol=1e-12, abs_tol=1e-15):
            raise RuntimeError(
                f"fixed main parameter readback mismatch: {component}.{parameter} "
                f"expected={expected:.15g}, actual={actual:.15g}"
            )
        records.append(
            {
                "component": component,
                "parameter": parameter,
                "before": before,
                "after": after,
                "expected": expected,
            }
        )
    return records


def apply_parameter_scales(
    model: str, scales: tuple[float, float, float]
) -> list[dict[str, Any]]:
    lift_scale, mass_scale, inertia_scale = scales
    assignments = [
        ("quadChassisTest17_1", "lift_cofficient", 0.002 * lift_scale),
        ("quadChassisTest17_1.body", "m", 0.159504 * mass_scale),
        ("quadChassisTest17_1.body", "I_11", 0.00010556 * inertia_scale),
        ("quadChassisTest17_1.body", "I_22", 0.00010556 * inertia_scale),
        ("quadChassisTest17_1.body", "I_33", 0.00010556 * inertia_scale),
    ]
    for propeller in range(1, 5):
        component = f"quadChassisTest17_1.propellers{propeller}"
        assignments.extend(
            [
                (component, "m", 0.000913171 * mass_scale),
                (component, "I_11", 1.59662e-7 * inertia_scale),
                (component, "I_22", 1.59594e-7 * inertia_scale),
                (component, "I_33", 3.16359e-7 * inertia_scale),
            ]
        )

    records: list[dict[str, Any]] = []
    for component, parameter, expected in assignments:
        before = modeling.GetModelParamValue(model, component, parameter)
        expression = format(expected, ".15g")
        require_true(
            f"SetModelParamValue {component}.{parameter}",
            modeling.SetModelParamValue(model, component, parameter, expression),
        )
        after = modeling.GetModelParamValue(model, component, parameter)
        try:
            actual = float(after)
        except (TypeError, ValueError) as exc:
            raise RuntimeError(
                f"parameter readback is not numeric: {component}.{parameter}={after!r}"
            ) from exc
        if not math.isclose(actual, expected, rel_tol=1e-12, abs_tol=1e-15):
            raise RuntimeError(
                f"parameter readback mismatch: {component}.{parameter} "
                f"expected={expected:.15g}, actual={actual:.15g}"
            )
        records.append(
            {
                "component": component,
                "parameter": parameter,
                "before": before,
                "after": after,
                "expected": expected,
            }
        )
    return records


def flatten_values(value: Any) -> list[Any]:
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
        raise RuntimeError(
            f"result length mismatch for {name}: {len(values)} != {len(time_values)}"
        )
    if any(not math.isfinite(value) for value in values):
        raise RuntimeError(f"non-finite result in {name}")
    return values


def export_result(
    raw_path: Path, variables: list[str], stop_time: float
) -> tuple[dict[str, Any], Path | None]:
    # 导出前先验证时间轴、有限性和执行器边界，拒绝不完整raw。
    time_values = [
        float(value) for value in flatten_values(modeling.GetVarValues("time"))
    ]
    expected_rows = int(round(stop_time / INTERVAL_S)) + 1
    if (
        len(time_values) != expected_rows
        or not time_values
        or abs(time_values[0]) > 1e-12
        or abs(time_values[-1] - stop_time) > 1e-8
        or any(right <= left for left, right in zip(time_values, time_values[1:]))
    ):
        raise RuntimeError(
            f"invalid time result: rows={len(time_values)}, "
            f"expected={expected_rows}, stop={time_values[-1] if time_values else None}"
        )

    columns = [time_values]
    for name in variables[1:]:
        columns.append(result_values(name, time_values))
    column_map = dict(zip(variables, columns))
    if "motorCommand[1]" in column_map:
        motor_names = [f"motorCommand[{index}]" for index in range(1, 5)]
        allocator_names = ["controllerDiagnostics[15]"]
    elif "motorCommand1[1]" in column_map:
        motor_names = [
            f"motorCommand{vehicle}[{motor}]"
            for vehicle in range(1, 4)
            for motor in range(1, 5)
        ]
        allocator_names = [
            f"controllerDiagnostics{vehicle}[15]" for vehicle in range(1, 4)
        ]
    else:
        raise RuntimeError("unregistered motor-column contract")
    motor_values = [value for name in motor_names for value in column_map[name]]
    allocator_values = [
        value for name in allocator_names for value in column_map[name]
    ]

    raw_path.parent.mkdir(parents=True, exist_ok=True)
    backup = backup_existing(raw_path)
    temporary = raw_path.with_suffix(raw_path.suffix + ".tmp")
    try:
        with temporary.open("w", newline="", encoding="utf-8") as stream:
            writer = csv.writer(stream, lineterminator="\n")
            writer.writerow(variables)
            writer.writerows(zip(*columns))
        temporary.replace(raw_path)
    except Exception:
        if backup is not None and not raw_path.exists():
            backup.replace(raw_path)
        raise

    return (
        {
            "path": str(raw_path),
            "sha256": sha256(raw_path),
            "rows": len(time_values),
            "columns": len(variables),
            "start_time_s": time_values[0],
            "stop_time_s": time_values[-1],
            "max_abs_motor_command": max(abs(value) for value in motor_values),
            "max_motor_command_q": max(value * value for value in motor_values),
            "allocator_limit_min": min(allocator_values),
            "allocator_limit_max": max(allocator_values),
        },
        backup,
    )


def dependency_catalog(workspace: Path) -> dict[str, dict[str, Any]]:
    # 依赖表集中描述模型路径、加载类名和预期哈希。
    formation = workspace / "01_models" / "dependencies" / "formation"
    delivery_formation = workspace / "01_models" / "sysblock" / "formation"
    return {
        "official": {
            "class": "QuadrotorModel",
            "path": workspace / "01_models" / "official"
            / "QuadrotorModel" / "package.mo",
        },
        "pid": {
            "class": "A8FormalPidTwin",
            "path": workspace / "01_models" / "dependencies"
            / "A8FormalPidTwin"
            / "package.mo",
        },
        "main_controller": {
            "class": MAIN_CONTROLLER,
            "path": workspace / "01_models" / "sysblock"
            / (MAIN_CONTROLLER + ".mo"),
        },
        "main_plant": {
            "class": MAIN_PLANT,
            "path": workspace / "01_models" / "modelica"
            / MAIN_PLANT / "package.mo",
        },
        "step_plant": {
            "class": STEP_PLANT,
            "path": workspace / "01_models" / "modelica"
            / STEP_PLANT / "package.mo",
        },
        "phase_plant": {
            "class": PHASE_PLANT,
            "path": workspace / "01_models" / "modelica"
            / PHASE_PLANT / "package.mo",
        },
        "formation_nominal_supervisor": {
            "class": "A8FormalFormationNominalSupervisorV1A_20260712",
            "path": formation / "A8FormalFormationNominalSupervisorV1A_20260712.mo",
        },
        "predictive_v5c_pair": {
            "class": "A8CBFPairProjectorPredictiveV5C_20260712",
            "path": delivery_formation / "A8CBFPairProjectorPredictiveV5C_20260712.mo",
        },
        "predictive_v5c_kernel": {
            "class": "A8CBFPredictiveKernelV5C_20260712",
            "path": delivery_formation / "A8CBFPredictiveKernelV5C_20260712.mo",
        },
        "predictive_v5c_supervisor": {
            "class": "A8FormalFormationPredictiveCBFV5C_20260712",
            "path": delivery_formation / "A8FormalFormationPredictiveCBFV5C_20260712.mo",
        },
        "scene07b_base": {
            "class": "A8FormationScene07V1Plant20260712",
            "path": formation / "A8FormationScene07V1Plant20260712" / "package.mo",
        },
        "scene07c_off_base": {
            "class": "A8FormationScene07COffV1Plant20260712",
            "path": formation / "A8FormationScene07COffV1Plant20260712" / "package.mo",
        },
        "scene07c_on_base": {
            "class": "A8FormationScene07COnRobustV3Plant20260712",
            "path": formation / "A8FormationScene07COnRobustV3Plant20260712" / "package.mo",
        },
        "formation_plant": {
            "class": FORMATION_PLANT,
            "path": workspace / "01_models" / "modelica"
            / FORMATION_PLANT / "package.mo",
        },
        "angular_plant": {
            "class": ANGULAR_PLANT,
            "path": workspace / "01_models" / "modelica" / ANGULAR_PLANT / "package.mo",
        },
    }


def case_catalog() -> dict[str, dict[str, Any]]:
    # 每个工况登记模型、停止时间、结果类型和参数缩放方式。
    dependencies = ("official", "pid", "main_controller", "main_plant")
    step_dependencies = dependencies + ("step_plant",)
    cases: dict[str, dict[str, Any]] = {
        "Scene04": {
            "model": f"{MAIN_PLANT}.Scene04",
            "stop_time": 30.0,
            "kind": "single_v8",
            "dependencies": dependencies,
        },
        "Scene01": {
            "model": f"{MAIN_PLANT}.Scene01",
            "stop_time": 50.0,
            "kind": "single_v8",
            "dependencies": dependencies,
        },
        "Scene02": {
            "model": f"{MAIN_PLANT}.Scene02",
            "stop_time": 50.0,
            "kind": "single_v8",
            "dependencies": dependencies,
        },
        "Scene03": {
            "model": f"{MAIN_PLANT}.Scene03",
            "stop_time": 120.0,
            "kind": "single_v8",
            "dependencies": dependencies,
        },
        "Scene06b": {
            "model": f"{MAIN_PLANT}.Scene06b",
            "stop_time": 30.0,
            "kind": "disturbance_v8",
            "dependencies": dependencies,
        },
        "Scene01S_X": {
            "model": f"{STEP_PLANT}.Scene01S_X",
            "stop_time": 30.0,
            "kind": "single_v8",
            "dependencies": step_dependencies,
        },
        "Scene01S_Y": {
            "model": f"{STEP_PLANT}.Scene01S_Y",
            "stop_time": 30.0,
            "kind": "single_v8",
            "dependencies": step_dependencies,
        },
        "Scene01S_Z": {
            "model": f"{STEP_PLANT}.Scene01S_Z",
            "stop_time": 30.0,
            "kind": "single_v8",
            "dependencies": step_dependencies,
        },
    }
    parameter_cases = {
        "Scene05B_Nominal": SCENE05B_SCALES["Scene05B_Nominal"],
        "Scene05B_LiftMinus10": SCENE05B_SCALES["Scene05B_LiftMinus10"],
        "Scene05B_PayloadPlus10": SCENE05B_SCALES["Scene05B_PayloadPlus10"],
        **{case_id: SCENE05B_SCALES[case_id] for case_id in SCENE05B_CASES[1:]},
    }
    for case_id, scales in parameter_cases.items():
        cases[case_id] = {
            "model": f"{MAIN_PLANT}.Scene04",
            "stop_time": 50.0,
            "kind": "parameter_v8",
            "dependencies": dependencies,
            "parameter_scales": scales,
        }
    for case_id in SCENE08_CASES + SCENE10_CASES:
        cases[case_id] = {
            "model": f"{PHASE_PLANT}.{case_id}",
            "stop_time": 40.0,
            "kind": "physical_v8",
            "dependencies": dependencies + ("phase_plant",),
        }
    scene07_dependencies = dependencies[:3] + (
        "predictive_v5c_pair",
        "predictive_v5c_kernel",
        "predictive_v5c_supervisor",
        "scene07b_base",
        "scene07c_off_base",
        "scene07c_on_base",
    )
    cases["Scene07B"] = {
        "model": f"{FORMATION_PLANT}.Scene07B",
        "stop_time": 60.0,
        "kind": "formation",
        "dependencies": scene07_dependencies + ("formation_plant",),
    }
    for case_id in SCENE07C_CASES:
        extra = ("formation_nominal_supervisor",) if case_id == "Scene07COff" else ()
        cases[case_id] = {
            "model": f"{FORMATION_PLANT}.{case_id}",
            "stop_time": 40.0,
            "kind": "formation",
            "dependencies": scene07_dependencies + extra + ("formation_plant",),
        }
    cases["BODY_ROLL_POS"] = {
        "model": f"{ANGULAR_PLANT}.BodyRollPos", "stop_time": 50.0,
        "kind": "ardg_angular", "dependencies": dependencies + ("angular_plant",),
    }
    cases["BODY_PITCH_NEG"] = {
        "model": f"{ANGULAR_PLANT}.BodyPitchNeg", "stop_time": 50.0,
        "kind": "ardg_angular", "dependencies": dependencies + ("angular_plant",),
    }
    return cases


def expand_scenes(requested: list[str]) -> list[str]:
    tokens: list[str] = []
    for item in requested:
        tokens.extend(token.strip() for token in item.split(",") if token.strip())
    if not tokens:
        tokens = ["finals_core"]
    if "all" in tokens:
        if tokens != ["all"]:
            raise ValueError("all cannot be combined with other scene selections")
        tokens = ["full_registered"]

    supported = (set(SCENE_ORDER) | {"finals_core", "regression18", "supplementary", "full_registered", "Scene05B", "Scene08", "Scene10", "Scene07C"}
                  | set(SCENE05B_CASES)
                  | set(SCENE05B_FOCUS_CASES) | set(SCENE08_CASES)
                  | set(SCENE10_CASES) | set(SCENE07C_CASES) | set(ANGULAR_CASES))
    unknown = [token for token in tokens if token not in supported]
    if unknown:
        raise ValueError(f"unsupported scene selection: {unknown}")

    expanded: list[str] = []
    for token in tokens:
        if token == "finals_core":
            members = FINALS_CORE_CASES
        elif token == "regression18":
            members = REGRESSION18_CASES
        elif token == "supplementary":
            members = SUPPLEMENTARY_CASES
        elif token == "full_registered":
            members = FULL_REGISTERED_CASES
        elif token == "Scene05B":
            members = (SCENE05B_CASES[0],) + SCENE05B_FOCUS_CASES + SCENE05B_CASES[1:]
        elif token == "Scene08":
            members = SCENE08_CASES
        elif token == "Scene10":
            members = SCENE10_CASES
        elif token == "Scene07C":
            members = SCENE07C_CASES
        else:
            members = (token,)
        for member in members:
            if member not in expanded:
                expanded.append(member)
    return expanded


def load_dependencies(
    workspace: Path, selected_cases: list[str]
) -> tuple[list[dict[str, Any]], dict[str, str]]:
    dependencies = dependency_catalog(workspace)
    cases = case_catalog()
    required_keys: list[str] = []
    for case_id in selected_cases:
        for key in cases[case_id]["dependencies"]:
            if key not in required_keys:
                required_keys.append(key)

    records: list[dict[str, Any]] = []
    hashes: dict[str, str] = {}
    loaded = bool(modeling.LoadLibrary("Modelica", "4.0.0.TY.1"))
    if not loaded and not bool(modeling.ClassExist("Modelica")):
        raise RuntimeError(f"LoadLibrary Modelica failed: {modeling.GetLastErrors()!r}")
    records.append(
        {
            "key": "Modelica",
            "class": "Modelica",
            "load_returned": loaded,
            "class_exists": bool(modeling.ClassExist("Modelica")),
        }
    )

    for key in required_keys:
        dependency = dependencies[key]
        class_name = str(dependency["class"])
        path = dependency["path"]
        record: dict[str, Any] = {"key": key, "class": class_name}
        if path is None:
            record["source"] = "existing_session"
            record["class_exists"] = bool(modeling.ClassExist(class_name))
            records.append(record)
            if not record["class_exists"]:
                raise RuntimeError(
                    f"required preloaded SEC class is absent: {class_name}; "
                    "the frozen source is not present in this workspace snapshot"
                )
            continue

        resolved = require_file(Path(path), key)
        digest = sha256(resolved)
        hashes[key] = digest
        record.update({"path": str(resolved), "sha256": digest})
        if key == "official" and digest != EXPECTED_OFFICIAL_SHA256:
            raise RuntimeError(f"official model hash mismatch: {digest}")
        if key == "main_controller" and digest != EXPECTED_MAIN_CONTROLLER_SHA256:
            raise RuntimeError(f"main controller hash mismatch: {digest}")
        class_exists = bool(modeling.ClassExist(class_name))
        if class_exists:
            record.update({"source": "existing_session", "class_exists": True})
        else:
            require_true(f"OpenModelFile {key}", modeling.OpenModelFile(str(resolved)))
            record.update(
                {
                    "source": "file",
                    "class_exists": bool(modeling.ClassExist(class_name)),
                }
            )
            if not record["class_exists"]:
                raise RuntimeError(f"OpenModelFile did not create class {class_name}")
        records.append(record)
    return records, hashes


def variables_for(kind: str) -> list[str]:
    if kind == "single_v8":
        return list(SINGLE_V8_VARIABLES)
    if kind == "disturbance_v8":
        return list(DISTURBANCE_V8_VARIABLES)
    if kind == "physical_v8":
        return list(PHYSICAL_V8_VARIABLES)
    if kind == "parameter_v8":
        return list(PARAMETER_V8_VARIABLES)
    if kind == "formation":
        return list(FORMATION_VARIABLES)
    raise ValueError(f"unknown result kind: {kind}")


def run(args: argparse.Namespace) -> dict[str, Any]:
    # 单实例预检通过后按场景串行执行，状态文件记录每个阶段。
    workspace = args.workspace.resolve()
    output = args.output.resolve()
    fixed_main_parameters = {
        "activation_covariance_max": ACTIVATION_COVARIANCE_DEFAULT,
        "activation_persistence_s": ACTIVATION_PERSISTENCE_DEFAULT_S,
        "scale_rate_per_s": SCALE_RATE_DEFAULT_PER_S,
        "scale_rate_per_step": SCALE_RATE_DEFAULT_PER_S * INTERVAL_S,
    }
    selected_cases = expand_scenes(args.scene)
    cases = case_catalog()
    status_path = output / "execution_status.json"
    previous_status = backup_existing(status_path)
    status: dict[str, Any] = {
        "schema_version": 1,
        "runner": "run_main_controller.py",
        "algorithm_id": "ARDG-RGPC",
        "release_version": "finals-20260815",
        "formal_algorithm_id": "ARDG-RGPC",
        "started_utc": utc_now(),
        "finished_utc": None,
        "workspace": str(workspace),
        "output": str(output),
        "port": args.port,
        "requested_scenes": args.scene or ["finals_core"],
        "selected_cases": selected_cases,
        "success": False,
        "status": "precheck",
        "ports_before": [],
        "ports_after": None,
        "connected": False,
        "dependencies": [],
        "dependency_sha256": {},
        "cases": [],
        "backups": ([str(previous_status)] if previous_status is not None else []),
        "parameter_source_guard": None,
        "main_source_guard": None,
        "fixed_main_parameters": fixed_main_parameters,
        "fixed_parameter_readback": [],
        "fixed_parameter_guard": {
            "pre_run_fixed_readback": None,
            "in_memory_default_restore": None,
        },
        "failure": None,
    }
    write_json(status_path, status)

    parameter_source: Path | None = None
    parameter_source_snapshot: bytes | None = None
    parameter_model_touched = False
    main_source: Path | None = None
    main_source_snapshot: bytes | None = None
    main_model_touched = False

    try:
        require_file(workspace / "02_scripts" / "sysplorer" / Path(__file__).name, "runner")
        main_source = require_file(
            dependency_catalog(workspace)["main_controller"]["path"],
            "main controller",
        )
        main_source_snapshot = main_source.read_bytes()
        main_source_hash = hashlib.sha256(
            main_source_snapshot
        ).hexdigest().upper()
        status["main_source_guard"] = {
            "path": str(main_source),
            "sha256_before": main_source_hash,
            "mutation_detected": None,
            "mutation_backup": None,
            "source_snapshot_restored": None,
            "sha256_after": None,
        }
        write_json(status_path, status)
        if main_source_hash != EXPECTED_MAIN_CONTROLLER_SHA256:
            raise RuntimeError(
                f"main controller precheck hash mismatch: {main_source_hash}"
            )
        if any(cases[case_id]["kind"] == "parameter_v8" for case_id in selected_cases):
            parameter_source = require_file(
                dependency_catalog(workspace)["main_plant"]["path"],
                "main plant",
            )
            require_nominal_parameter_source(parameter_source)
            parameter_source_snapshot = parameter_source.read_bytes()
            status["parameter_source_guard"] = {
                "path": str(parameter_source),
                "nominal_precheck": True,
                "sha256_before": sha256(parameter_source),
                "in_memory_nominal_restore": None,
                "source_snapshot_restored": None,
                "sha256_after": None,
            }
        ports_before = sorted(int(port) for port in modeling.FindSysplorer())
        status["ports_before"] = ports_before
        if ports_before != [args.port]:
            raise RuntimeError(
                f"single-instance contract requires only port {args.port}: {ports_before}"
            )

        modeling.ConnectSysplorer(ip="127.0.0.1", port=args.port)
        status["connected"] = True
        dependencies, dependency_hashes = load_dependencies(workspace, selected_cases)
        status["dependencies"] = dependencies
        status["dependency_sha256"] = dependency_hashes
        default_values = {
            "activation_covariance_max": ACTIVATION_COVARIANCE_DEFAULT,
            "activation_persistence_s": ACTIVATION_PERSISTENCE_DEFAULT_S,
            "scale_rate_per_s": SCALE_RATE_DEFAULT_PER_S,
            "scale_rate_per_step": SCALE_RATE_DEFAULT_PER_S * INTERVAL_S,
        }
        reset_assignments = apply_fixed_main_parameters(default_values)
        main_model_touched = True
        status["fixed_parameter_guard"]["pre_run_fixed_readback"] = {
            "status": "pass",
            "assignment_count": len(reset_assignments),
        }
        if parameter_source is not None:
            nominal_assignments = apply_parameter_scales(
                f"{MAIN_PLANT}.Scene04", NOMINAL_PARAMETER_SCALES
            )
            parameter_model_touched = True
            status["parameter_source_guard"]["in_memory_nominal_precheck"] = {
                "status": "pass",
                "assignment_count": len(nominal_assignments),
            }
        status["fixed_parameter_readback"] = apply_fixed_main_parameters(
            fixed_main_parameters
        )
        status["status"] = "running"
        write_json(status_path, status)

        for case_id in selected_cases:
            specification = cases[case_id]
            model = str(specification["model"])
            stop_time = float(specification["stop_time"])
            is_angular = specification["kind"] == "ardg_angular"
            flat_angular_output = is_angular and len(selected_cases) == 1
            case_output = output if flat_angular_output else output / "cases" / case_id
            case_status_path = None if flat_angular_output else case_output / "execution_status.json"
            row: dict[str, Any] = {
                "case": case_id,
                "model": model,
                "kind": specification["kind"],
                "output_directory": str(case_output) if is_angular else str(output),
                "start_time_s": 0.0,
                "stop_time_s": stop_time,
                "interval_s": INTERVAL_S,
                "status": "running",
                "execution_status": "running",
                "acceptance_status": "not_evaluated",
                "check": False,
                "translate": False,
                "simulate": False,
                "read_result": False,
                "raw": None,
                "ardg_diagnostics": None,
                "parameter_scales": specification.get("parameter_scales"),
                "parameter_assignments": [],
                "failure": None,
            }
            status["cases"].append(row)
            write_json(status_path, status)
            try:
                if specification["kind"] == "parameter_v8":
                    parameter_model_touched = True
                    row["parameter_assignments"] = apply_parameter_scales(
                        model, tuple(specification["parameter_scales"])
                    )
                require_true(f"CheckModel {case_id}", modeling.CheckModel(model))
                row["check"] = True
                require_true(f"TranslateModel {case_id}", modeling.TranslateModel(model))
                row["translate"] = True
                simulation_path = output / "simulation" / case_id
                simulation_path.mkdir(parents=True, exist_ok=True)
                require_true(
                    f"SimulateModel {case_id}",
                    modeling.SimulateModel(
                        modelName=model,
                        startTime=0.0,
                        stopTime=stop_time,
                        interval=INTERVAL_S,
                        tolerance=0.0001,
                        algo="Dassl",
                        storeDouble=True,
                        storeEvent=False,
                        simMode=0,
                        path=str(simulation_path),
                    ),
                )
                row["simulate"] = True
                if is_angular:
                    raw, diagnostics, backups = export_ardg_result(
                        case_output / "raw.csv",
                        case_output / "ardg_diagnostics.csv",
                        stop_time,
                    )
                    row["ardg_diagnostics"] = diagnostics
                    status["backups"].extend(str(path) for path in backups)
                else:
                    raw, backup = export_result(
                        output / "raw" / f"{case_id}.csv",
                        variables_for(str(specification["kind"])),
                        stop_time,
                    )
                    if backup is not None:
                        status["backups"].append(str(backup))
                row["raw"] = raw
                row["read_result"] = True
                if raw["allocator_limit_min"] <= 0:
                    raise RuntimeError(
                        f"non-positive allocator limit in {case_id}: "
                        f"{raw['allocator_limit_min']}"
                    )
                if raw["max_abs_motor_command"] <= 1.0:
                    raise RuntimeError(
                        f"motor output inactive in {case_id}: "
                        f"{raw['max_abs_motor_command']}"
                    )
                if raw["max_motor_command_q"] > raw["allocator_limit_max"] + 1e-8:
                    raise RuntimeError(
                        f"motor limit exceeded in {case_id}: "
                        f"{raw['max_motor_command_q']} > {raw['allocator_limit_max']}"
                    )
                row["status"] = "execution_pass"
                row["execution_status"] = "pass"
            except Exception as exc:
                row["status"] = "failed"
                row["execution_status"] = "failed"
                row["failure"] = {"type": type(exc).__name__, "message": str(exc)}
                raise
            finally:
                if case_status_path is not None:
                    write_json(case_status_path, {
                        "schema_version": "ardg_rgpc_finals_case_v1",
                        "algorithm": "ARDG-RGPC", "case": row,
                        "success": row["execution_status"] == "pass",
                    })
                write_json(status_path, status)

        status["session_directory_after"] = str(modeling.GetDirectory())
        status["ports_after"] = list(status["ports_before"])
        status["status"] = "execution_pass"
        status["success"] = True
    except Exception as exc:
        status["status"] = "failed"
        status["failure"] = {"type": type(exc).__name__, "message": str(exc)}
        try:
            status["last_errors"] = str(modeling.GetLastErrors())
        except Exception:
            status["last_errors"] = None
        try:
            status["ports_after"] = sorted(
                int(port) for port in modeling.FindSysplorer()
            )
        except Exception:
            status["ports_after"] = None
    finally:
        # 无论成功或失败，都恢复内存参数和可能被平台改写的源码。
        if main_model_touched and bool(modeling.ClassExist(MAIN_CONTROLLER)):
            try:
                default_values = {
                    "activation_covariance_max": ACTIVATION_COVARIANCE_DEFAULT,
                    "activation_persistence_s": ACTIVATION_PERSISTENCE_DEFAULT_S,
                    "scale_rate_per_s": SCALE_RATE_DEFAULT_PER_S,
                    "scale_rate_per_step": SCALE_RATE_DEFAULT_PER_S * INTERVAL_S,
                }
                restored = apply_fixed_main_parameters(default_values)
                status["fixed_parameter_guard"]["in_memory_default_restore"] = {
                    "status": "pass",
                    "assignment_count": len(restored),
                }
            except Exception as exc:
                status["status"] = "failed"
                status["success"] = False
                status["fixed_parameter_guard"]["in_memory_default_restore"] = {
                    "status": "failed",
                    "type": type(exc).__name__,
                    "message": str(exc),
                }
                if status["failure"] is None:
                    status["failure"] = {
                        "type": "TunableParameterRestoreError",
                        "message": str(exc),
                    }
        if parameter_source is not None and parameter_source_snapshot is not None:
            guard = status["parameter_source_guard"]
            restoration_errors: list[str] = []
            if parameter_model_touched:
                try:
                    restored_assignments = apply_parameter_scales(
                        f"{MAIN_PLANT}.Scene04",
                        NOMINAL_PARAMETER_SCALES,
                    )
                    guard["in_memory_nominal_restore"] = {
                        "status": "pass",
                        "assignment_count": len(restored_assignments),
                    }
                except Exception as exc:
                    guard["in_memory_nominal_restore"] = {
                        "status": "failed",
                        "type": type(exc).__name__,
                        "message": str(exc),
                    }
                    restoration_errors.append(
                        f"in-memory nominal restore: {type(exc).__name__}: {exc}"
                    )
            else:
                guard["in_memory_nominal_restore"] = {
                    "status": "not_needed",
                    "assignment_count": 0,
                }
            try:
                guard["source_snapshot_restored"] = restore_source_bytes(
                    parameter_source, parameter_source_snapshot
                )
                guard["sha256_after"] = sha256(parameter_source)
                if guard["sha256_after"] != guard["sha256_before"]:
                    raise RuntimeError(
                        "parameter source hash changed after snapshot restoration"
                    )
            except Exception as exc:
                restoration_errors.append(
                    f"source snapshot restore: {type(exc).__name__}: {exc}"
                )
            if restoration_errors:
                status["status"] = "failed"
                status["success"] = False
                status["parameter_source_restore_failure"] = restoration_errors
                if status["failure"] is None:
                    status["failure"] = {
                        "type": "ParameterSourceRestoreError",
                        "message": "; ".join(restoration_errors),
                    }

        if main_source is not None and main_source_snapshot is not None:
            guard = status["main_source_guard"]
            try:
                guard.update(
                    restore_frozen_source(
                        main_source,
                        main_source_snapshot,
                        output / "source_guard"
                        / "A8FormalRAGCACGHTE_postrun_autoserialize.mo",
                    )
                )
            except Exception as exc:
                status["status"] = "failed"
                status["success"] = False
                status["main_source_restore_failure"] = {
                    "type": type(exc).__name__,
                    "message": str(exc),
                }
                if status["failure"] is None:
                    status["failure"] = {
                        "type": "CandidateSourceRestoreError",
                        "message": str(exc),
                    }

    status["finished_utc"] = utc_now()
    write_json(status_path, status)
    print("A8_ARDG_RGPC_FINALS=" + json.dumps(status, ensure_ascii=False))
    return status


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--workspace", type=Path, required=True)
    parser.add_argument("--port", type=int, default=49152)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument(
        "--scene",
        action="append",
        default=[],
        help=(
            "scene or suite to run; repeat or use commas. Omit for the 20-case "
            "finals_core suite. Use full_registered explicitly for all 34 cases."
        ),
    )
    parser.add_argument("--list-scenes", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.list_scenes:
        print(
            json.dumps(
                {
                    "default_suite": "finals_core",
                    "finals_core": FINALS_CORE_CASES,
                    "regression18": REGRESSION18_CASES,
                    "supplementary": SUPPLEMENTARY_CASES,
                    "full_registered": FULL_REGISTERED_CASES,
                    "angular_cases": ANGULAR_CASES,
                    "scene05b_cases": SCENE05B_CASES,
                    "scene08_cases": SCENE08_CASES,
                    "scene10_cases": SCENE10_CASES,
                    "scene07c_cases": SCENE07C_CASES,
                    "case_catalog": case_catalog(),
                },
                indent=2,
                ensure_ascii=False,
            )
        )
        return 0
    status = run(args)
    return 0 if status["success"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
