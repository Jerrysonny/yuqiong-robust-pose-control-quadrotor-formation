import csv
import math
from pathlib import Path

import mworks.sysplorer as ModelingPy


BASE_VARIABLES = (
    ["time"]
    + [f"climbePath.position_command[{i}]" for i in range(1, 4)]
    + [f"referenceVector[{i}]" for i in range(1, 12)]
    + [f"quadChassisTest17_1.body.frame_a.r_0[{i}]" for i in range(1, 4)]
    + [f"quadChassisTest17_1.body.v_0[{i}]" for i in range(1, 4)]
    + [f"quadChassisTest17_1.body.frame_b.R.T[{i},{j}]" for i in range(1, 4) for j in range(1, 4)]
    + [f"sensors1_1.AngleMea[{i}]" for i in range(1, 4)]
    + [f"quadChassisTest17_1.body.frame_b.R.w[{i}]" for i in range(1, 4)]
    + [f"motorCommand[{i}]" for i in range(1, 5)]
    + [f"speedSensor[{i}].w" for i in range(1, 5)]
    + [f"controllerDiagnostics[{i}]" for i in range(1, 13)]
)


def export_model_raw(model, stop, output, include_disturbance=False):
    # 所有比较算法使用同一变量顺序和0.01 s公共时间轴导出结果。
    variables = BASE_VARIABLES + (
        ["quadChassisTest17_1.perRotorDisturbance"] if include_disturbance else []
    )
    for label, value in (
        ("CheckModel", ModelingPy.CheckModel(model)),
        ("TranslateModel", ModelingPy.TranslateModel(model)),
        ("SimulateModel", ModelingPy.SimulateModel(model)),
    ):
        if value is not True:
            raise RuntimeError(f"{label} failed: {value!r}")

    time = [float(value) for value in ModelingPy.GetVarValues("time")]
    rows = len(time)
    expected_rows = int(round(stop / 0.01)) + 1
    if rows < expected_rows:
        raise RuntimeError(f"truncated result: {rows} < {expected_rows}")
    if abs(time[0]) > 1e-12 or abs(time[-1] - stop) > 1e-8:
        raise RuntimeError("invalid time endpoints")
    if any(right <= left for left, right in zip(time, time[1:])):
        raise RuntimeError("non-increasing time axis")

    columns = [time]
    for name in variables[1:]:
        values = list(ModelingPy.GetVarValues(name))
        # 事件信号可能使用独立时间网格，需在公共时间轴上重新采样。
        if name.endswith("perRotorDisturbance") or len(values) != rows:
            values = [ModelingPy.GetVarValueAt(name, t) for t in time]
        if len(values) != rows:
            raise RuntimeError(f"inconsistent result length for {name}")
        columns.append(values)
    if any(not math.isfinite(float(value)) for column in columns for value in column):
        raise RuntimeError("nonfinite result")

    # CSV列名、行数和时间端点在写入前均已完成一致性检查。
    output = Path(output)
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream, lineterminator="\n")
        writer.writerow(variables)
        writer.writerows(zip(*columns))
    return {
        "model": model,
        "path": str(output),
        "rows": rows,
        "start": time[0],
        "stop": time[-1],
        "columns": len(variables),
    }
