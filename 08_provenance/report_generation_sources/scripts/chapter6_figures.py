from __future__ import annotations

import hashlib
import json
import math
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK, WD_LINE_SPACING
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Inches, Pt, RGBColor


WORK = Path(__file__).resolve().parents[1]
CHAPTER_ROOT = WORK.parent
CORE_ROOT = WORK.parents[2]
PACKAGE_ROOT = CORE_ROOT / "A8比赛作品完整源文件_20260715"
REPORT = WORK / "evidence" / "report_evidence_recomputed"
CAMPAIGN = WORK / "evidence" / "syslab_campaign"
RAW_MAIN = PACKAGE_ROOT / "06_supplementary_evidence" / "ra_gca_cg_hte_32_raw"
SCENE_INDEX = PACKAGE_ROOT / "00_START_HERE" / "SCENE_INDEX.csv"
OLD_DOC = WORK / "backup" / "A8仿真分析报告_第6章独立正式改稿_单机性能鲁棒性与约束结果_20260715.docx"
STEP_BASELINE_ROOT = CORE_ROOT / "正式工程双轨收口_20260713"
PID_BASELINE_ROOT = CORE_ROOT / "正式PX4_INDI适配_20260712" / "00_输入快照" / "pid_baseline"
PID_CANONICAL = {
    "Scene01": PID_BASELINE_ROOT / "canonical_p5_pid_twin_scene_01_step_climb_20260711.csv",
    "Scene02": PID_BASELINE_ROOT / "canonical_pid_original_scene_02_spiral_climb_20260712.csv",
    "Scene03": PID_BASELINE_ROOT / "canonical_pid_actual_scene_03_figure8_20260711.csv",
    "Scene04": PID_BASELINE_ROOT / "canonical_p5_pid_twin_scene_04_hover_20260711.csv",
}
PID_STEP_PATHS = {
    "X": STEP_BASELINE_ROOT / "03_results" / "standard_step_baselines" / "pid_original" / "Scene01S_X" / "direct_v1" / "raw.csv",
    "Y": STEP_BASELINE_ROOT / "03_results" / "standard_step_baselines" / "pid_original" / "Scene01S_Y" / "direct_v1" / "raw.csv",
    "Z": STEP_BASELINE_ROOT / "03_results" / "standard_step_baselines" / "pid_original" / "Scene01S_Z" / "direct_v4" / "raw.csv",
}

FIGURES = WORK / "figures"
FIGURE_SOURCES = WORK / "evidence" / "figure_sources"
EVIDENCE = WORK / "evidence"
OUTPUT = WORK / "A8仿真分析报告_第6章第三版终校_单机性能鲁棒性与约束结果_20260715.docx"

MAIN = "RA-GCA-CGHTE"
BASE = "RA-GCA/Base"
PID = "PID"
ADRC = "CAP-ADRC"
INDI = "CP-INDI"

COLORS = {
    PID: "#4B5563",
    BASE: "#A7ADB4",
    MAIN: "#1768AC",
    ADRC: "#2A7F62",
    INDI: "#7C5AA6",
    "reference": "#111827",
    "grid": "#D8DEE4",
    "gain": "#2A7F62",
    "tradeoff": "#C96A3D",
}

MARKERS = {PID: "o", BASE: "s", MAIN: "o", ADRC: "^", INDI: "P"}
LINESTYLES = {PID: "--", BASE: ":", MAIN: "-", ADRC: "--", INDI: ":"}

SCENE_ZH = {
    "Scene01": "分段爬升",
    "Scene02": "螺旋爬升",
    "Scene03": "8字轨迹",
    "Scene04": "定点悬停",
    "Scene06b": "三事件外力扰动",
}


@dataclass
class FigureRecord:
    figure_id: str
    stem: str
    sources: list[Path]
    outputs: list[Path]
    source_table: Path
    claim: str


def require(path: Path) -> None:
    if not path.exists():
        raise FileNotFoundError(path)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def rel(path: Path) -> str:
    try:
        return path.resolve().relative_to(WORK.resolve()).as_posix()
    except ValueError:
        try:
            return "PACKAGE/" + path.resolve().relative_to(PACKAGE_ROOT.resolve()).as_posix()
        except ValueError:
            return str(path.resolve())


def read_csv(path: Path) -> pd.DataFrame:
    require(path)
    return pd.read_csv(path, encoding="utf-8-sig")


def read_json(path: Path) -> dict:
    require(path)
    return json.loads(path.read_text(encoding="utf-8-sig"))


def configure_matplotlib() -> None:
    plt.rcParams.update(
        {
            "font.family": "sans-serif",
            "font.sans-serif": ["Microsoft YaHei", "DengXian", "SimHei", "Arial"],
            "axes.unicode_minus": False,
            "font.size": 8.2,
            "axes.labelsize": 8.3,
            "axes.titlesize": 9.0,
            "xtick.labelsize": 7.5,
            "ytick.labelsize": 7.5,
            "legend.fontsize": 7.4,
            "axes.linewidth": 0.7,
            "lines.linewidth": 1.45,
            "svg.fonttype": "none",
            "pdf.fonttype": 42,
            "savefig.facecolor": "white",
        }
    )


def style_axis(axis, grid: str = "y") -> None:
    axis.spines["top"].set_visible(False)
    axis.spines["right"].set_visible(False)
    axis.grid(True, axis=grid, color=COLORS["grid"], linewidth=0.55, alpha=0.75)
    axis.set_axisbelow(True)
    axis.tick_params(length=3.0, width=0.65)


def panel_label(axis, label: str) -> None:
    axis.text(-0.12, 1.04, label, transform=axis.transAxes, fontsize=9.2, fontweight="bold", va="bottom")


def save_figure(fig: plt.Figure, stem: str) -> list[Path]:
    outputs = [FIGURES / f"{stem}.png", FIGURES / f"{stem}.pdf", FIGURES / f"{stem}.svg"]
    fig.savefig(outputs[0], dpi=600, bbox_inches="tight", pad_inches=0.04)
    fig.savefig(outputs[1], bbox_inches="tight", pad_inches=0.04)
    fig.savefig(outputs[2], bbox_inches="tight", pad_inches=0.04)
    plt.close(fig)
    return outputs


def write_source(frame: pd.DataFrame, stem: str) -> Path:
    path = FIGURE_SOURCES / f"{stem}.csv"
    frame.to_csv(path, index=False, encoding="utf-8-sig")
    return path


def load_position_raw(path: Path) -> pd.DataFrame:
    columns = [
        "time",
        "referenceVector[1]",
        "referenceVector[2]",
        "referenceVector[3]",
        "quadChassisTest17_1.body.r_0[1]",
        "quadChassisTest17_1.body.r_0[2]",
        "quadChassisTest17_1.body.r_0[3]",
    ]
    require(path)
    return pd.read_csv(path, usecols=columns, encoding="utf-8-sig")


def load_pid_step_raw(step: pd.DataFrame, axis_name: str) -> tuple[pd.DataFrame, Path]:
    # PID阶跃使用登记的历史原始数据，并保持统一列名。
    row = step[(step.controller == PID) & (step.axis == axis_name)]
    if len(row) != 1:
        raise ValueError(f"PID {axis_name}轴阶跃记录缺失或重复")
    path = PID_STEP_PATHS[axis_name]
    require(path)
    frame = pd.read_csv(path, encoding="utf-8-sig")
    frame = frame.rename(columns={"Time": "time"})
    return frame, path


def load_pid_canonical(case_id: str) -> pd.DataFrame:
    path = PID_CANONICAL[case_id]
    require(path)
    return pd.read_csv(path, encoding="utf-8-sig")


def position_error_from_main(frame: pd.DataFrame) -> np.ndarray:
    reference = frame[[f"referenceVector[{index}]" for index in range(1, 4)]].to_numpy(float)
    position = frame[[f"quadChassisTest17_1.body.r_0[{index}]" for index in range(1, 4)]].to_numpy(float)
    return np.linalg.norm(reference - position, axis=1)


def position_error_from_pid(frame: pd.DataFrame) -> np.ndarray:
    reference = frame[["ref_x", "ref_y", "ref_z"]].to_numpy(float)
    position = frame[["pos_x", "pos_y", "pos_z"]].to_numpy(float)
    return np.linalg.norm(reference - position, axis=1)


def load_campaign_cases() -> pd.DataFrame:
    frame = read_csv(CAMPAIGN / "campaign_cases.csv")
    frame["tracking_rmse_m"] = pd.to_numeric(frame["tracking_rmse_m"], errors="coerce")
    return frame


def make_figure_1(step: pd.DataFrame) -> tuple[FigureRecord, dict]:
    sources = [REPORT / "02_standard_step_pid_vs_main.csv"]
    figure, axes = plt.subplots(2, 2, figsize=(7.05, 4.65), constrained_layout=True)
    source_rows: list[dict] = []
    for axis_index, axis_name in enumerate(("X", "Y", "Z")):
        axis = axes.flat[axis_index]
        main_path = RAW_MAIN / f"Scene01S_{axis_name}.csv"
        main_raw = load_position_raw(main_path)
        pid_raw, pid_path = load_pid_step_raw(step, axis_name)
        sources.extend([main_path, pid_path])
        component = axis_index + 1
        sample = slice(None, None, 5)
        axis.plot(
            main_raw["time"].to_numpy()[sample],
            main_raw[f"referenceVector[{component}]"].to_numpy()[sample],
            color=COLORS["reference"],
            linestyle="--",
            linewidth=1.1,
            label="参考",
        )
        axis.plot(
            pid_raw["time"].to_numpy()[sample],
            pid_raw[f"quadChassisTest17_1.body.r_0[{component}]"].to_numpy()[sample],
            color=COLORS[PID],
            linestyle=LINESTYLES[PID],
            linewidth=1.25,
            label=PID,
        )
        axis.plot(
            main_raw["time"].to_numpy()[sample],
            main_raw[f"quadChassisTest17_1.body.r_0[{component}]"].to_numpy()[sample],
            color=COLORS[MAIN],
            linewidth=1.55,
            label=MAIN,
        )
        axis.set_title(f"{axis_name}轴阶跃")
        axis.set_xlabel("时间（s）")
        axis.set_ylabel("位置（m）")
        style_axis(axis)
        panel_label(axis, f"({chr(97 + axis_index)})")
        for controller, raw, reference_column, actual_column in (
            (
                PID,
                pid_raw,
                f"referenceVector[{component}]",
                f"quadChassisTest17_1.body.r_0[{component}]",
            ),
            (
                MAIN,
                main_raw,
                f"referenceVector[{component}]",
                f"quadChassisTest17_1.body.r_0[{component}]",
            ),
        ):
            source_rows.extend(
                {
                    "axis": axis_name,
                    "controller": controller,
                    "time_s": float(t),
                    "reference_m": float(r),
                    "actual_m": float(y),
                }
                for t, r, y in zip(
                    raw["time"].to_numpy()[sample],
                    raw[reference_column].to_numpy()[sample],
                    raw[actual_column].to_numpy()[sample],
                )
            )

    axis = axes.flat[3]
    x = np.arange(3)
    width = 0.34
    pid_values = step[step.controller == PID].set_index("axis").loc[["X", "Y", "Z"], "overshoot_percent"].to_numpy(float)
    main_values = step[step.controller == MAIN].set_index("axis").loc[["X", "Y", "Z"], "overshoot_percent"].to_numpy(float)
    pid_bars = axis.bar(x - width / 2, pid_values, width, color=COLORS[PID], label=PID)
    main_bars = axis.bar(x + width / 2, main_values, width, color=COLORS[MAIN], label=MAIN)
    axis.bar_label(pid_bars, labels=[f"{value:.2f}%" for value in pid_values], padding=2, fontsize=6.9)
    axis.bar_label(main_bars, labels=[f"{value:.2f}%" for value in main_values], padding=2, fontsize=6.9)
    axis.set_title("超调量对比")
    axis.set_xticks(x, ["X轴", "Y轴", "Z轴"])
    axis.set_ylabel("超调量（%）")
    axis.set_ylim(0.0, 29.0)
    axis.legend(
        loc="upper center",
        bbox_to_anchor=(0.5, -0.13),
        frameon=False,
        ncol=2,
    )
    style_axis(axis)
    panel_label(axis, "(d)")
    source_path = write_source(pd.DataFrame(source_rows), "figure_6_1_step_timeseries")
    outputs = save_figure(figure, "figure_6_1_standard_steps")
    metrics = {
        "pid_overshoot_percent": dict(zip(("X", "Y", "Z"), pid_values)),
        "main_overshoot_percent": dict(zip(("X", "Y", "Z"), main_values)),
    }
    return FigureRecord("图6-1", "figure_6_1_standard_steps", sources, outputs, source_path, "PID与主算法三轴阶跃响应"), metrics


def build_typical_task_frame(common: pd.DataFrame, cases: pd.DataFrame, snapshot: dict) -> pd.DataFrame:
    # 典型任务表将公共比较指标与主算法轨迹摘要对齐。
    pid_values = {
        item["source_scene_label"]: float(item["tracking_rmse_m"])
        for item in snapshot["public_scene_metrics"]
        if item["controller"] == PID
    }
    label_to_case = {"step": "Scene01", "spiral": "Scene02", "figure8": "Scene03", "hover": "Scene04"}
    main_values = common[common.controller == MAIN].set_index("case_id")["tracking_rmse_m"].astype(float).to_dict()
    scene02 = cases[(cases.case_id == "Scene02") & (cases.controller_id == MAIN)]
    if len(scene02) != 1:
        raise ValueError("Scene02 main metric missing or duplicated")
    main_values["Scene02"] = float(scene02.iloc[0].tracking_rmse_m)
    rows = []
    for source_label, case_id in label_to_case.items():
        pid_value = pid_values[source_label]
        main_value = main_values[case_id]
        rows.append(
            {
                "case_id": case_id,
                "scene_zh": SCENE_ZH[case_id],
                "pid_rmse_m": pid_value,
                "main_rmse_m": main_value,
                "rmse_reduction_percent": 100.0 * (pid_value - main_value) / pid_value,
            }
        )
    return pd.DataFrame(rows)


def make_figure_2(tasks: pd.DataFrame) -> tuple[FigureRecord, dict]:
    sources = [
        REPORT / "03_five_controller_common_scenes.csv",
        REPORT / "source_snapshots" / "chapter6_metrics_normalized.json",
        CAMPAIGN / "campaign_cases.csv",
        PID_CANONICAL["Scene01"],
        PID_CANONICAL["Scene04"],
        RAW_MAIN / "Scene01.csv",
        RAW_MAIN / "Scene04.csv",
    ]
    figure, axes = plt.subplots(1, 2, figsize=(7.05, 2.75), constrained_layout=True)
    source_frames: list[pd.DataFrame] = []
    for index, (axis, case_id, title) in enumerate(
        zip(axes, ("Scene01", "Scene04"), ("分段爬升", "定点悬停"))
    ):
        pid = load_pid_canonical(case_id)
        main = load_position_raw(RAW_MAIN / f"{case_id}.csv")
        pid_error = position_error_from_pid(pid)
        main_error = position_error_from_main(main)
        pid_sample = slice(None, None, 5)
        main_sample = slice(None, None, 5)
        axis.plot(
            pid["time"].to_numpy()[pid_sample],
            pid_error[pid_sample],
            color=COLORS[PID],
            linestyle=LINESTYLES[PID],
            linewidth=1.25,
            label=PID,
        )
        axis.plot(
            main["time"].to_numpy()[main_sample],
            main_error[main_sample],
            color=COLORS[MAIN],
            linewidth=1.5,
            label=MAIN,
        )
        axis.set_title(f"{title}位置误差")
        axis.set_xlabel("时间（s）")
        axis.set_ylabel("三维位置误差（m）")
        style_axis(axis)
        panel_label(axis, f"({chr(97 + index)})")
        if index == 0:
            axis.legend(loc="upper right", frameon=False)
        source_frames.extend(
            [
                pd.DataFrame(
                    {
                        "case_id": case_id,
                        "controller": PID,
                        "time_s": pid["time"].to_numpy()[pid_sample],
                        "position_error_m": pid_error[pid_sample],
                    }
                ),
                pd.DataFrame(
                    {
                        "case_id": case_id,
                        "controller": MAIN,
                        "time_s": main["time"].to_numpy()[main_sample],
                        "position_error_m": main_error[main_sample],
                    }
                ),
            ]
        )
    source_path = write_source(pd.concat(source_frames, ignore_index=True), "figure_6_2_step_hover_timeseries")
    outputs = save_figure(figure, "figure_6_2_pid_main_typical_tasks")
    metrics = {row.case_id: {"pid_rmse_m": row.pid_rmse_m, "main_rmse_m": row.main_rmse_m, "reduction_percent": row.rmse_reduction_percent} for row in tasks.itertuples(index=False)}
    return FigureRecord("图6-2", "figure_6_2_pid_main_typical_tasks", sources, outputs, source_path, "PID与主算法分段爬升和悬停误差"), metrics


def make_figure_3(tasks: pd.DataFrame) -> tuple[FigureRecord, dict]:
    sources = [
        PID_CANONICAL["Scene02"],
        PID_CANONICAL["Scene03"],
        RAW_MAIN / "Scene02.csv",
        RAW_MAIN / "Scene03.csv",
    ]
    figure = plt.figure(figsize=(7.05, 5.2), constrained_layout=True)
    axes = [
        figure.add_subplot(2, 2, 1, projection="3d"),
        figure.add_subplot(2, 2, 2),
        figure.add_subplot(2, 2, 3),
        figure.add_subplot(2, 2, 4),
    ]
    source_frames: list[pd.DataFrame] = []

    spiral_pid = load_pid_canonical("Scene02")
    spiral_main = load_position_raw(RAW_MAIN / "Scene02.csv")
    sample = slice(None, None, 10)
    axis = axes[0]
    axis.plot(
        spiral_main["referenceVector[1]"][sample],
        spiral_main["referenceVector[2]"][sample],
        spiral_main["referenceVector[3]"][sample],
        color=COLORS["reference"], linestyle="--", linewidth=1.0, label="参考",
    )
    axis.plot(
        spiral_pid["pos_x"][sample], spiral_pid["pos_y"][sample], spiral_pid["pos_z"][sample],
        color=COLORS[PID], linestyle=LINESTYLES[PID], linewidth=1.15, label=PID,
    )
    axis.plot(
        spiral_main["quadChassisTest17_1.body.r_0[1]"][sample],
        spiral_main["quadChassisTest17_1.body.r_0[2]"][sample],
        spiral_main["quadChassisTest17_1.body.r_0[3]"][sample],
        color=COLORS[MAIN], linewidth=1.35, label=MAIN,
    )
    axis.set_title("螺旋爬升轨迹")
    axis.set_xlabel("X（m）")
    axis.set_ylabel("Y（m）")
    axis.set_zlabel("Z（m）")
    axis.view_init(elev=24, azim=-56)
    axis.text2D(
        -0.12,
        1.04,
        "(a)",
        transform=axis.transAxes,
        fontsize=9.2,
        fontweight="bold",
        va="bottom",
    )

    axis = axes[1]
    spiral_pid_error = position_error_from_pid(spiral_pid)
    spiral_main_error = position_error_from_main(spiral_main)
    axis.plot(spiral_pid["time"][sample], spiral_pid_error[sample], color=COLORS[PID], linestyle=LINESTYLES[PID], label=PID)
    axis.plot(spiral_main["time"][sample], spiral_main_error[sample], color=COLORS[MAIN], label=MAIN)
    axis.set_title("螺旋爬升位置误差")
    axis.set_xlabel("时间（s）")
    axis.set_ylabel("三维位置误差（m）")
    axis.legend(loc="upper right", frameon=False)
    style_axis(axis)
    panel_label(axis, "(b)")

    eight_pid = load_pid_canonical("Scene03")
    eight_main = load_position_raw(RAW_MAIN / "Scene03.csv")
    axis = axes[2]
    axis.plot(eight_main["referenceVector[1]"][sample], eight_main["referenceVector[2]"][sample], color=COLORS["reference"], linestyle="--", linewidth=1.0, label="参考")
    axis.plot(eight_pid["pos_x"][sample], eight_pid["pos_y"][sample], color=COLORS[PID], linestyle=LINESTYLES[PID], linewidth=1.15, label=PID)
    axis.plot(eight_main["quadChassisTest17_1.body.r_0[1]"][sample], eight_main["quadChassisTest17_1.body.r_0[2]"][sample], color=COLORS[MAIN], linewidth=1.35, label=MAIN)
    axis.set_title("8字轨迹平面投影")
    axis.set_xlabel("X位置（m）")
    axis.set_ylabel("Y位置（m）")
    axis.set_aspect("equal", adjustable="datalim")
    style_axis(axis, grid="both")
    panel_label(axis, "(c)")

    axis = axes[3]
    eight_pid_error = position_error_from_pid(eight_pid)
    eight_main_error = position_error_from_main(eight_main)
    axis.plot(eight_pid["time"][sample], eight_pid_error[sample], color=COLORS[PID], linestyle=LINESTYLES[PID], label=PID)
    axis.plot(eight_main["time"][sample], eight_main_error[sample], color=COLORS[MAIN], label=MAIN)
    axis.set_title("8字轨迹位置误差")
    axis.set_xlabel("时间（s）")
    axis.set_ylabel("三维位置误差（m）")
    style_axis(axis)
    panel_label(axis, "(d)")

    for case_id, controller, frame, error in (
        ("Scene02", PID, spiral_pid, spiral_pid_error),
        ("Scene02", MAIN, spiral_main, spiral_main_error),
        ("Scene03", PID, eight_pid, eight_pid_error),
        ("Scene03", MAIN, eight_main, eight_main_error),
    ):
        time = frame["time"].to_numpy()[sample]
        source_frames.append(
            pd.DataFrame(
                {
                    "case_id": case_id,
                    "controller": controller,
                    "time_s": time,
                    "position_error_m": error[sample],
                }
            )
        )
    source_path = write_source(pd.concat(source_frames, ignore_index=True), "figure_6_3_continuous_trajectories")
    outputs = save_figure(figure, "figure_6_3_continuous_trajectories")
    metrics = {
        row.case_id: {
            "pid_rmse_m": row.pid_rmse_m,
            "main_rmse_m": row.main_rmse_m,
            "reduction_percent": row.rmse_reduction_percent,
        }
        for row in tasks[tasks.case_id.isin(["Scene02", "Scene03"])].itertuples(index=False)
    }
    return FigureRecord("图6-3", "figure_6_3_continuous_trajectories", sources, outputs, source_path, "PID与主算法连续轨迹比较"), metrics


def make_figure_4(common: pd.DataFrame) -> tuple[FigureRecord, dict]:
    sources = [REPORT / "03_five_controller_common_scenes.csv"]
    order = [PID, BASE, MAIN, ADRC, INDI]
    cases = ["Scene01", "Scene04", "Scene03", "Scene06b"]
    figure, axes = plt.subplots(2, 2, figsize=(7.05, 4.45), constrained_layout=True)
    for index, (axis, case_id) in enumerate(zip(axes.flat, cases)):
        frame = common[common.case_id == case_id].set_index("controller").loc[order]
        values = frame["tracking_rmse_m"].to_numpy(float)
        y = np.arange(len(order))[::-1]
        for yi, controller, value in zip(y, order, values):
            axis.hlines(yi, 0, value, color="#D7DCE1", linewidth=1.1)
            axis.scatter(
                value,
                yi,
                s=36 if controller == MAIN else 27,
                color=COLORS[controller],
                marker=MARKERS[controller],
                zorder=3,
            )
            value_label = f"{value:.4f}" if value < 0.1 else f"{value:.3f}"
            axis.text(value + max(values) * 0.022, yi, value_label, va="center", fontsize=6.9)
        axis.set_yticks(y, order)
        axis.set_xlim(0.0, max(values) * 1.24)
        axis.set_xlabel("三维位置RMSE（m）")
        axis.set_title(SCENE_ZH[case_id])
        style_axis(axis, grid="x")
        panel_label(axis, f"({chr(97 + index)})")
    source_path = write_source(common, "figure_6_4_five_controller_common")
    outputs = save_figure(figure, "figure_6_4_five_controller_common_scenes")
    metrics = {
        case_id: common[common.case_id == case_id]
        .set_index("controller")["tracking_rmse_m"]
        .astype(float)
        .to_dict()
        for case_id in cases
    }
    return FigureRecord("图6-4", "figure_6_4_five_controller_common_scenes", sources, outputs, source_path, "五种算法在共同任务中的位置误差"), metrics


def make_figure_5(parameter: pd.DataFrame, scene_index: pd.DataFrame) -> tuple[FigureRecord, dict]:
    # 参数失配按固定工况顺序展示，避免视觉排序改变结论。
    sources = [REPORT / "05_parameter_11_paired.csv", SCENE_INDEX]
    labels = {
        "Scene05B_Nominal": "标准参数",
        "Scene05B_C000": "升力、质量、惯量均-10%",
        "Scene05B_C001": "升力-10%，质量-10%，惯量+10%",
        "Scene05B_C010": "升力-10%，质量+10%，惯量-10%",
        "Scene05B_C011": "升力-10%，质量、惯量+10%",
        "Scene05B_C100": "升力+10%，质量、惯量-10%",
        "Scene05B_C101": "升力+10%，质量-10%，惯量+10%",
        "Scene05B_C110": "升力、质量+10%，惯量-10%",
        "Scene05B_C111": "升力、质量、惯量均+10%",
        "Scene05B_LiftMinus10": "升力效能-10%",
        "Scene05B_PayloadPlus10": "载荷与惯量+10%",
    }
    frame = parameter.copy()
    frame["scene_zh"] = frame.case_id.map(labels)
    order = [
        "Scene05B_Nominal",
        "Scene05B_C000",
        "Scene05B_C001",
        "Scene05B_C110",
        "Scene05B_C111",
        "Scene05B_C010",
        "Scene05B_C011",
        "Scene05B_C100",
        "Scene05B_C101",
        "Scene05B_LiftMinus10",
        "Scene05B_PayloadPlus10",
    ]
    frame = frame.set_index("case_id").loc[order].reset_index()
    figure, axis = plt.subplots(figsize=(7.05, 4.35), constrained_layout=True)
    y = np.arange(len(frame))[::-1]
    for yi, row in zip(y, frame.itertuples(index=False)):
        value = float(row.formal_tracking_rmse_m)
        axis.hlines(yi, 0.0, value, color="#CBD2D9", linewidth=1.5)
        axis.scatter(value, yi, color=COLORS[MAIN], marker=MARKERS[MAIN], s=34, zorder=3)
        axis.text(value + 0.0007, yi, f"{value:.4f}", va="center", fontsize=7.0)
    axis.set_yticks(y, frame.scene_zh.tolist())
    axis.set_xlim(0.0, float(frame.formal_tracking_rmse_m.max()) * 1.28)
    axis.set_xlabel("三维位置RMSE（m）")
    axis.set_title("不同参数设置下的跟踪误差")
    style_axis(axis, grid="x")
    source_frame = frame[["case_id", "scene_zh", "formal_tracking_rmse_m"]].rename(
        columns={"formal_tracking_rmse_m": "tracking_rmse_m"}
    )
    source_path = write_source(source_frame, "figure_6_5_parameter_results")
    outputs = save_figure(figure, "figure_6_5_parameter_results")
    values = frame.formal_tracking_rmse_m.astype(float)
    metrics = {
        "case_count": int(len(frame)),
        "minimum_rmse_m": float(values.min()),
        "maximum_rmse_m": float(values.max()),
        "median_rmse_m": float(values.median()),
        "below_0_04_m_count": int((values < 0.04).sum()),
    }
    return FigureRecord("图6-5", "figure_6_5_parameter_results", sources, outputs, source_path, "主算法11种参数设置结果"), metrics


def make_figure_6(disturbance: pd.DataFrame) -> tuple[FigureRecord, dict]:
    # 外扰图同时保留主算法整体表现和CP-INDI局部优势。
    sources = [REPORT / "07_disturbance_tradeoff.csv"]
    order = [PID, BASE, MAIN, ADRC, INDI]
    frame = disturbance.set_index("controller").loc[order].reset_index()
    figure, axes = plt.subplots(1, 2, figsize=(7.05, 3.35), constrained_layout=True, gridspec_kw={"width_ratios": [0.85, 1.25]})
    axis = axes[0]
    selected = frame[frame.controller.isin([PID, MAIN])]
    values = selected.tracking_rmse_m.to_numpy(float)
    axis.bar([0, 1], values, color=[COLORS[PID], COLORS[MAIN]], width=0.58)
    for xi, value in enumerate(values):
        axis.text(xi, value + max(values) * 0.025, f"{value:.3f}", ha="center", fontsize=7.2)
    axis.set_xticks([0, 1], [PID, MAIN])
    axis.set_ylabel("三维位置RMSE（m）")
    pid_reduction = 100.0 * (values[0] - values[1]) / values[0]
    axis.set_title(f"相对赛题PID降低{pid_reduction:.1f}%")
    style_axis(axis)
    panel_label(axis, "(a)")

    axis = axes[1]
    y = np.arange(len(order))[::-1]
    values = frame.tracking_rmse_m.to_numpy(float)
    for yi, controller, value in zip(y, order, values):
        axis.hlines(yi, 0, value, color="#D7DCE1", linewidth=1.2)
        axis.scatter(value, yi, color=COLORS[controller], marker=MARKERS[controller], s=34 if controller == MAIN else 29, zorder=3)
        axis.text(value + max(values) * 0.022, yi, f"{value:.3f}", va="center", fontsize=7.0)
    axis.set_yticks(y, order)
    axis.set_xlim(0, max(values) * 1.22)
    axis.set_xlabel("三维位置RMSE（m）")
    axis.set_title("五种算法结果")
    style_axis(axis, grid="x")
    panel_label(axis, "(b)")
    source_path = write_source(frame, "figure_6_6_disturbance_tradeoff")
    outputs = save_figure(figure, "figure_6_6_disturbance_tradeoff")
    metrics = frame.set_index("controller")["tracking_rmse_m"].astype(float).to_dict()
    return FigureRecord("图6-6", "figure_6_6_disturbance_tradeoff", sources, outputs, source_path, "三事件外扰五种算法比较"), metrics


def make_figure_7(pairs: pd.DataFrame) -> tuple[FigureRecord, dict]:
    sources = [CAMPAIGN / "campaign_pairs.csv"]
    groups = [("Scene08", "五相位风扰"), ("Scene10", "五相位传感器退化")]
    figure, axes = plt.subplots(1, 2, figsize=(7.05, 2.85), constrained_layout=True)
    metrics: dict[str, dict] = {}
    source_frames = []
    for index, (axis, (prefix, label)) in enumerate(zip(axes, groups)):
        frame = pairs[pairs.case_id.str.startswith(prefix)].copy().sort_values("case_id")
        frame["phase"] = np.arange(len(frame))
        frame["tracking_rmse_m"] = frame.hte_tracking_rmse_m.astype(float)
        source_frames.append(frame[["case_id", "phase", "tracking_rmse_m"]])
        phases = np.arange(len(frame))
        main_values = frame.tracking_rmse_m.to_numpy(float)
        mean_value = float(np.mean(main_values))
        axis.plot(phases, main_values, color=COLORS[MAIN], marker="o", markersize=4.5, linewidth=1.4)
        axis.axhline(mean_value, color=COLORS[PID], linestyle="--", linewidth=1.0, label=f"均值 {mean_value:.4f} m")
        axis.set_xticks(phases, [f"相位{i + 1}" for i in phases])
        axis.set_ylabel("三维位置RMSE（m）")
        axis.set_title(label)
        axis.set_ylim(0.0, max(main_values) * 1.25)
        axis.legend(loc="upper right", frameon=False)
        style_axis(axis)
        panel_label(axis, f"({chr(97 + index)})")
        metrics[prefix] = {
            "n": int(len(frame)),
            "main_mean_rmse_m": mean_value,
            "main_sample_std_rmse_m": float(np.std(main_values, ddof=1)),
            "main_min_rmse_m": float(np.min(main_values)),
            "main_max_rmse_m": float(np.max(main_values)),
        }
    source_path = write_source(pd.concat(source_frames, ignore_index=True), "figure_6_7_environment_transparency")
    outputs = save_figure(figure, "figure_6_7_environment_transparency")
    return FigureRecord("图6-7", "figure_6_7_environment_transparency", sources, outputs, source_path, "主算法风扰与传感器退化结果"), metrics


def make_figure_8() -> tuple[FigureRecord, dict]:
    source = RAW_MAIN / "Scene05B_LiftMinus10.csv"
    sources = [source]
    columns = [
        "time",
        "referenceVector[3]",
        "quadChassisTest17_1.body.r_0[3]",
        "controllerDiagnostics[11]",
        "controllerDiagnostics[12]",
        "controllerDiagnostics[13]",
        "controllerDiagnostics[14]",
        "controllerDiagnostics[15]",
        "controllerDiagnostics[16]",
        "scenarioDiagnostics[1]",
        "scenarioDiagnostics[2]",
        *[f"motorCommand[{index}]" for index in range(1, 5)],
    ]
    frame = pd.read_csv(source, usecols=columns, encoding="utf-8-sig")
    frame["max_abs_motor_command"] = frame[[f"motorCommand[{index}]" for index in range(1, 5)]].abs().max(axis=1)
    frame["actuator_usage_percent"] = 100.0 * frame.max_abs_motor_command / frame["controllerDiagnostics[15]"]
    target_scale = float(frame["scenarioDiagnostics[2]"].iloc[0] / frame["scenarioDiagnostics[1]"].iloc[0])
    sample = frame.iloc[::5].copy()
    figure, axes = plt.subplots(2, 2, figsize=(7.05, 4.45), constrained_layout=True)
    axis = axes[0, 0]
    axis.plot(sample.time, sample["referenceVector[3]"], color=COLORS["reference"], linestyle="--", label="高度参考")
    axis.plot(sample.time, sample["quadChassisTest17_1.body.r_0[3]"], color=COLORS[MAIN], label="实际高度")
    axis.set_ylabel("高度（m）")
    axis.set_xlabel("时间（s）")
    axis.set_title("升力效能降低10%时的高度跟踪")
    axis.legend(frameon=False)
    style_axis(axis)
    panel_label(axis, "(a)")

    axis = axes[0, 1]
    axis.plot(sample.time, sample["controllerDiagnostics[11]"], color=COLORS[ADRC], linestyle="--", label="估计尺度")
    axis.plot(sample.time, sample["controllerDiagnostics[12]"], color=COLORS[MAIN], label="应用尺度")
    axis.axhline(target_scale, color=COLORS["reference"], linestyle=":", linewidth=1.2, label=f"对应尺度 {target_scale:.3f}")
    axis.set_ylabel("推力尺度")
    axis.set_xlabel("时间（s）")
    axis.set_title("尺度估计与平滑应用")
    axis.legend(frameon=False)
    style_axis(axis)
    panel_label(axis, "(b)")

    axis = axes[1, 0]
    axis.step(sample.time, sample["controllerDiagnostics[13]"], where="post", color=COLORS[MAIN], label="估计有效状态")
    axis.set_ylim(-0.08, 1.12)
    axis.set_ylabel("状态")
    axis.set_xlabel("时间（s）")
    twin = axis.twinx()
    twin.plot(sample.time, sample["controllerDiagnostics[14]"], color=COLORS[PID], alpha=0.8, linewidth=1.0, label="归一化创新")
    twin.set_ylabel("归一化创新")
    lines = axis.get_lines() + twin.get_lines()
    axis.legend(lines, [line.get_label() for line in lines], frameon=False, loc="best")
    axis.set_title("估计有效状态与创新量")
    style_axis(axis)
    panel_label(axis, "(c)")

    axis = axes[1, 1]
    axis.plot(sample.time, sample.actuator_usage_percent, color=COLORS[ADRC])
    axis.set_ylabel("分配上界使用率（%）")
    axis.set_xlabel("时间（s）")
    axis.set_title("最大电机指令占分配上界比例")
    style_axis(axis)
    panel_label(axis, "(d)")
    source_columns = [
        "time",
        "referenceVector[3]",
        "quadChassisTest17_1.body.r_0[3]",
        "controllerDiagnostics[11]",
        "controllerDiagnostics[12]",
        "controllerDiagnostics[13]",
        "controllerDiagnostics[14]",
        "controllerDiagnostics[15]",
        "controllerDiagnostics[16]",
        "max_abs_motor_command",
        "actuator_usage_percent",
    ]
    source_path = write_source(sample[source_columns], "figure_6_8_cghte_diagnostics")
    outputs = save_figure(figure, "figure_6_8_cghte_diagnostics")
    metrics = {
        "target_scale": target_scale,
        "final_estimated_scale": float(frame["controllerDiagnostics[11]"].iloc[-1]),
        "final_applied_scale": float(frame["controllerDiagnostics[12]"].iloc[-1]),
        "fusion_valid_fraction": float(np.mean(frame["controllerDiagnostics[13]"] > 0.5)),
        "maximum_actuator_usage_percent": float(frame.actuator_usage_percent.max()),
        "diagnostic_version_code": int(round(float(frame["controllerDiagnostics[16]"].iloc[-1]))),
    }
    return FigureRecord("图6-8", "figure_6_8_cghte_diagnostics", sources, outputs, source_path, "CGHTE尺度估计与执行器诊断"), metrics


def make_figure_a1(compound: pd.DataFrame) -> tuple[FigureRecord, dict]:
    sources = [REPORT / "08_compound_stress_tradeoff.csv"]
    frame = compound.copy()
    figure, axes = plt.subplots(1, 2, figsize=(7.05, 3.45), constrained_layout=True)
    x = np.arange(len(frame))
    axis = axes[0]
    rmse = frame.formal_tracking_rmse_m.astype(float).to_numpy()
    axis.bar(x, rmse, color=COLORS[MAIN], width=0.62)
    for xi, value in zip(x, rmse):
        axis.text(xi, value + max(rmse) * 0.025, f"{value:.3f}", ha="center", fontsize=6.9)
    axis.set_xticks(x, [f"组合{i + 1}" for i in x])
    axis.set_ylim(0.0, max(rmse) * 1.18)
    axis.set_ylabel("三维位置RMSE（m）")
    axis.set_title("复合扰动下的跟踪误差")
    style_axis(axis)
    panel_label(axis, "(a)")

    axis = axes[1]
    recovery = frame.formal_recovery_s.astype(float).to_numpy()
    axis.bar(x, recovery, color=COLORS[MAIN], width=0.62)
    for xi, value in zip(x, recovery):
        axis.text(xi, value + max(recovery) * 0.02, f"{value:.2f}", ha="center", fontsize=6.9)
    axis.set_xticks(x, [f"组合{i + 1}" for i in x])
    axis.set_ylim(0.0, max(recovery) * 1.15)
    axis.set_ylabel("恢复时间（s）")
    axis.set_title("扰动后的恢复时间")
    style_axis(axis)
    panel_label(axis, "(b)")
    source_path = write_source(
        frame[["case_id", "formal_tracking_rmse_m", "formal_tracking_peak_m", "formal_recovery_s"]],
        "figure_a_1_compound_stress",
    )
    outputs = save_figure(figure, "figure_a_1_compound_stress_tradeoff")
    metrics = {
        "case_count": int(len(frame)),
        "minimum_rmse_m": float(np.min(rmse)),
        "maximum_rmse_m": float(np.max(rmse)),
        "minimum_recovery_s": float(np.min(recovery)),
        "maximum_recovery_s": float(np.max(recovery)),
    }
    return FigureRecord("图A-1", "figure_a_1_compound_stress_tradeoff", sources, outputs, source_path, "复合参数与外扰测试结果"), metrics


def clear_body_keep_section(doc: Document) -> None:
    body = doc._element.body
    for child in list(body):
        if child.tag != qn("w:sectPr"):
            body.remove(child)


def set_style_fonts(style, east_asia: str = "宋体", latin: str = "Times New Roman") -> None:
    style.font.name = latin
    style._element.rPr.rFonts.set(qn("w:eastAsia"), east_asia)
    style._element.rPr.rFonts.set(qn("w:ascii"), latin)
    style._element.rPr.rFonts.set(qn("w:hAnsi"), latin)


def set_run_fonts(run, size: float | None = None, bold: bool | None = None, italic: bool | None = None) -> None:
    run.font.name = "Times New Roman"
    run._element.get_or_add_rPr().rFonts.set(qn("w:eastAsia"), "宋体")
    run._element.get_or_add_rPr().rFonts.set(qn("w:ascii"), "Times New Roman")
    run._element.get_or_add_rPr().rFonts.set(qn("w:hAnsi"), "Times New Roman")
    if size is not None:
        run.font.size = Pt(size)
    if bold is not None:
        run.bold = bold
    if italic is not None:
        run.italic = italic
    run.font.color.rgb = RGBColor(0, 0, 0)


def set_cell_margins(cell, top=55, start=65, bottom=55, end=65) -> None:
    tc = cell._tc
    tc_pr = tc.get_or_add_tcPr()
    tc_mar = tc_pr.first_child_found_in("w:tcMar")
    if tc_mar is None:
        tc_mar = OxmlElement("w:tcMar")
        tc_pr.append(tc_mar)
    for tag, value in (("top", top), ("start", start), ("bottom", bottom), ("end", end)):
        node = tc_mar.find(qn(f"w:{tag}"))
        if node is None:
            node = OxmlElement(f"w:{tag}")
            tc_mar.append(node)
        node.set(qn("w:w"), str(value))
        node.set(qn("w:type"), "dxa")


def set_repeat_table_header(row) -> None:
    tr_pr = row._tr.get_or_add_trPr()
    tbl_header = OxmlElement("w:tblHeader")
    tbl_header.set(qn("w:val"), "true")
    tr_pr.append(tbl_header)


def prevent_row_split(row) -> None:
    tr_pr = row._tr.get_or_add_trPr()
    cant_split = OxmlElement("w:cantSplit")
    tr_pr.append(cant_split)


def set_table_borders(table) -> None:
    tbl_pr = table._tbl.tblPr
    borders = tbl_pr.first_child_found_in("w:tblBorders")
    if borders is not None:
        tbl_pr.remove(borders)
    borders = OxmlElement("w:tblBorders")
    for edge in ("top", "bottom"):
        node = OxmlElement(f"w:{edge}")
        node.set(qn("w:val"), "single")
        node.set(qn("w:sz"), "8")
        node.set(qn("w:color"), "000000")
        borders.append(node)
    inside_h = OxmlElement("w:insideH")
    inside_h.set(qn("w:val"), "nil")
    borders.append(inside_h)
    for edge in ("left", "right", "insideV"):
        node = OxmlElement(f"w:{edge}")
        node.set(qn("w:val"), "nil")
        borders.append(node)
    tbl_pr.append(borders)
    header_borders = table.rows[0].cells[0]._tc.getparent().get_or_add_trPr()
    bottom = OxmlElement("w:tblHeader")
    bottom.set(qn("w:val"), "true")
    header_borders.append(bottom)
    for cell in table.rows[0].cells:
        tc_pr = cell._tc.get_or_add_tcPr()
        tc_borders = tc_pr.first_child_found_in("w:tcBorders")
        if tc_borders is None:
            tc_borders = OxmlElement("w:tcBorders")
            tc_pr.append(tc_borders)
        edge = OxmlElement("w:bottom")
        edge.set(qn("w:val"), "single")
        edge.set(qn("w:sz"), "6")
        edge.set(qn("w:color"), "000000")
        tc_borders.append(edge)


def setup_document(doc: Document) -> None:
    section = doc.sections[0]
    section.page_width = Cm(21.0)
    section.page_height = Cm(29.7)
    section.top_margin = Cm(2.35)
    section.bottom_margin = Cm(2.25)
    section.left_margin = Cm(2.65)
    section.right_margin = Cm(2.35)
    section.header_distance = Cm(1.2)
    section.footer_distance = Cm(1.2)
    section.start_type = WD_SECTION.CONTINUOUS
    section.different_first_page_header_footer = False
    doc.settings.odd_and_even_pages_header_footer = False

    normal = doc.styles["Normal"]
    set_style_fonts(normal)
    normal.font.size = Pt(10.5)
    normal.font.color.rgb = RGBColor(0, 0, 0)
    normal.paragraph_format.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    normal.paragraph_format.first_line_indent = Pt(21)
    normal.paragraph_format.line_spacing_rule = WD_LINE_SPACING.ONE_POINT_FIVE
    normal.paragraph_format.space_after = Pt(2.5)

    heading1 = doc.styles["Heading 1"]
    set_style_fonts(heading1, "黑体")
    heading1.font.size = Pt(15)
    heading1.font.bold = True
    heading1.font.color.rgb = RGBColor(0, 0, 0)
    heading1.paragraph_format.space_before = Pt(8)
    heading1.paragraph_format.space_after = Pt(8)
    heading1.paragraph_format.keep_with_next = True
    heading1.paragraph_format.first_line_indent = Pt(0)

    heading2 = doc.styles["Heading 2"]
    set_style_fonts(heading2, "黑体")
    heading2.font.size = Pt(12)
    heading2.font.bold = True
    heading2.font.color.rgb = RGBColor(0, 0, 0)
    heading2.paragraph_format.space_before = Pt(8)
    heading2.paragraph_format.space_after = Pt(5)
    heading2.paragraph_format.keep_with_next = True
    heading2.paragraph_format.first_line_indent = Pt(0)

    for name, east_asia, size, alignment in (
        ("Caption", "宋体", 9.0, WD_ALIGN_PARAGRAPH.CENTER),
        ("Source Note", "宋体", 8.3, WD_ALIGN_PARAGRAPH.LEFT),
        ("Reference Entry", "宋体", 9.0, WD_ALIGN_PARAGRAPH.LEFT),
    ):
        style = doc.styles[name]
        set_style_fonts(style, east_asia)
        style.font.size = Pt(size)
        style.font.color.rgb = RGBColor(0, 0, 0)
        style.paragraph_format.alignment = alignment
        style.paragraph_format.line_spacing = 1.15
        style.paragraph_format.space_after = Pt(3)
        style.paragraph_format.first_line_indent = Pt(0)
    doc.styles["Reference Entry"].paragraph_format.left_indent = Pt(18)
    doc.styles["Reference Entry"].paragraph_format.first_line_indent = Pt(-18)

    header = section.header.paragraphs[0]
    header.clear()
    for extra in list(section.header.paragraphs[1:]):
        extra._element.getparent().remove(extra._element)
    header.text = "A8四旋翼无人机位姿控制系统设计优化仿真报告"
    header.alignment = WD_ALIGN_PARAGRAPH.CENTER
    for run in header.runs:
        set_run_fonts(run, 8.0)
        run.font.color.rgb = RGBColor(90, 90, 90)
    footer = section.footer.paragraphs[0]
    footer.clear()
    for extra in list(section.footer.paragraphs[1:]):
        extra._element.getparent().remove(extra._element)
    footer.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = footer.add_run()
    fld_char1 = OxmlElement("w:fldChar")
    fld_char1.set(qn("w:fldCharType"), "begin")
    instr_text = OxmlElement("w:instrText")
    instr_text.set(qn("xml:space"), "preserve")
    instr_text.text = " PAGE "
    fld_char2 = OxmlElement("w:fldChar")
    fld_char2.set(qn("w:fldCharType"), "end")
    run._r.extend([fld_char1, instr_text, fld_char2])
    set_run_fonts(run, 8.0)


def add_body(doc: Document, text: str):
    paragraph = doc.add_paragraph(style="Normal")
    run = paragraph.add_run(text)
    set_run_fonts(run, 10.5)
    return paragraph


def add_heading(doc: Document, text: str, level: int, page_break: bool = False):
    if page_break:
        doc.add_paragraph().add_run().add_break(WD_BREAK.PAGE)
    paragraph = doc.add_heading(text, level=level)
    for run in paragraph.runs:
        set_run_fonts(run, 15 if level == 1 else 12, bold=True)
        run._element.get_or_add_rPr().rFonts.set(qn("w:eastAsia"), "黑体")
    return paragraph


def add_caption(doc: Document, text: str, keep_with_next: bool = True):
    paragraph = doc.add_paragraph(style="Caption")
    paragraph.paragraph_format.keep_with_next = keep_with_next
    run = paragraph.add_run(text)
    set_run_fonts(run, 9.0)
    return paragraph


def add_source_note(doc: Document, text: str):
    paragraph = doc.add_paragraph(style="Source Note")
    run = paragraph.add_run(text)
    set_run_fonts(run, 8.3)
    return paragraph


def add_figure(doc: Document, path: Path, caption: str, note: str, width: float = 5.9) -> None:
    require(path)
    paragraph = doc.add_paragraph()
    paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
    paragraph.paragraph_format.keep_with_next = True
    run = paragraph.add_run()
    run.add_picture(str(path), width=Inches(width))
    add_caption(doc, caption)
    add_source_note(doc, note)


def set_cell_text(cell, text: str, bold: bool = False, align=WD_ALIGN_PARAGRAPH.LEFT, size: float = 8.4) -> None:
    cell.text = ""
    cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
    set_cell_margins(cell)
    paragraph = cell.paragraphs[0]
    paragraph.alignment = align
    paragraph.paragraph_format.space_after = Pt(0)
    paragraph.paragraph_format.line_spacing = 1.0
    run = paragraph.add_run(str(text))
    set_run_fonts(run, size, bold=bold)


def add_table(doc: Document, headers: list[str], rows: list[list[str]], widths: list[float] | None = None, size: float = 8.4) -> None:
    table = doc.add_table(rows=1, cols=len(headers))
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False
    set_repeat_table_header(table.rows[0])
    for index, header in enumerate(headers):
        set_cell_text(table.rows[0].cells[index], header, bold=True, align=WD_ALIGN_PARAGRAPH.CENTER, size=size)
    for row_values in rows:
        row = table.add_row()
        prevent_row_split(row)
        for index, value in enumerate(row_values):
            align = WD_ALIGN_PARAGRAPH.LEFT if index == 0 else WD_ALIGN_PARAGRAPH.CENTER
            set_cell_text(row.cells[index], value, align=align, size=size)
    if widths:
        for row in table.rows:
            for index, width in enumerate(widths):
                row.cells[index].width = Inches(width)
    set_table_borders(table)


def f4(value: float) -> str:
    return f"{float(value):.4f}"


def build_task_table(common: pd.DataFrame, tasks: pd.DataFrame, snapshot: dict) -> list[list[str]]:
    order = ["Scene01", "Scene04", "Scene02", "Scene03"]
    frame = tasks.set_index("case_id").loc[order]
    return [
        [
            SCENE_ZH[case_id],
            f4(frame.loc[case_id, "pid_rmse_m"]),
            f4(frame.loc[case_id, "main_rmse_m"]),
            f"{float(frame.loc[case_id, 'rmse_reduction_percent']):.1f}%",
        ]
        for case_id in order
    ]


def generate_document(data: dict, figures: dict[str, FigureRecord], metrics: dict) -> None:
    doc = Document(str(OLD_DOC))
    clear_body_keep_section(doc)
    setup_document(doc)

    step = data["step"]
    common = data["common"]
    tasks = data["tasks"]
    snapshot = data["snapshot"]
    parameter = data["parameter"]
    compound = data["compound"]

    add_heading(doc, "6  单机性能、鲁棒性与约束结果", 1)
    add_body(
        doc,
        "本章沿用第5章统一的仿真对象、参考输入、采样周期和指标定义，检验单机控制器的跟踪精度、参数适应性、扰动恢复及执行器接口状态。当前主算法为置信门控悬停推力估计增强的约化姿态几何控制与约束感知分配算法（Reduced-Attitude Geometric Control with Constraint-Aware Allocation Enhanced by Confidence-Gated Hover-Thrust Estimation, RA-GCA-CGHTE），版本 1.0.0。该算法在约化姿态几何控制和约束感知分配基础上加入置信门控推力尺度估计，用于补偿载荷或升力效能变化引起的总推力失配。",
    )
    add_body(
        doc,
        "横向比较对象还包括官方级联比例-积分-微分控制基线（Official Cascaded Proportional-Integral-Derivative Control Baseline, PID）、约化姿态几何控制基础构型（Baseline Reduced-Attitude Geometric Control Configuration, RA-GCA/Base）、控制权限优先主动扰动抑制控制（Control-Authority-Prioritized Active Disturbance Rejection Control, CAP-ADRC）和指令代理增量非线性动态逆控制（Command-Proxy Incremental Nonlinear Dynamic Inversion Control, CP-INDI）。五个对象覆盖级联反馈、几何控制、主动抗扰和增量动态逆四类控制范式。每项比较只纳入同一场景中已有直接结果或登记的历史权威快照，缺少数据的位置明确标记为“未测试”。",
    )
    add_source_note(
        doc,
        "证据说明：32组项目回归场景均形成V8与当前主算法的配对结果。该回归集用于工程回归与消融分析，不等同于赛题规定的固定测试集。预设参数保持判据和整体筛选判据仍处于未通过状态，本章依据逐场景客观结果形成结论。",
    )

    add_heading(doc, "6.1  三轴阶跃、阶梯爬升与悬停", 2)
    add_body(
        doc,
        "三轴独立阶跃用于观察位置环的瞬态阻尼和轴间一致性。图6-1(a)至图6-1(c)给出RA-GCA-CGHTE的参考与实际位置时序，图6-1(d)比较其与PID的超调量。RA-GCA-CGHTE在X、Y轴未出现超调，Z轴超调为1.98%；PID的X、Y、Z轴超调分别为24.29%、24.28%和23.81%。这组结果表明，几何控制与推力分配组合在三轴阶跃中保持了较平缓的瞬态响应。",
    )
    add_figure(
        doc,
        figures["图6-1"].outputs[0],
        "图6-1  RA-GCA-CGHTE三轴独立阶跃响应及与PID的超调量比较",
        "注：时序曲线来自RA-GCA-CGHTE三轴独立阶跃直接结果；PID位置RMSE在现有权威快照中为空，因此本图只比较可追溯的超调量，不计算阶跃RMSE改善比。",
    )
    add_caption(doc, "表6-1  三轴独立标准阶跃超调量")
    step_pivot = step.pivot(index="axis", columns="controller", values="overshoot_percent").loc[["X", "Y", "Z"]]
    add_table(
        doc,
        ["阶跃轴", "PID（%）", "RA-GCA-CGHTE（%）", "变化（百分点）"],
        [[axis, f"{step_pivot.loc[axis, PID]:.2f}", f"{step_pivot.loc[axis, MAIN]:.2f}", f"{step_pivot.loc[axis, PID] - step_pivot.loc[axis, MAIN]:.2f}"] for axis in ("X", "Y", "Z")],
        [1.0, 1.25, 1.75, 1.4],
    )
    add_body(
        doc,
        "分段爬升和定点悬停进一步检验多轴指令与起飞过程。图6-2(a)显示，RA-GCA-CGHTE在分段爬升和定点悬停中的位置RMSE分别为{:.5f} m和{:.5f} m，相对PID分别降低{:.1f}%和{:.1f}%。悬停改进幅度较大，主要来自稳态位置误差的持续压缩；分段爬升包含多次参考变化，结果同时反映瞬态建立和稳定段跟踪。".format(
            metrics["figure_6_2"]["Scene01"]["main_rmse_m"],
            metrics["figure_6_2"]["Scene04"]["main_rmse_m"],
            metrics["figure_6_2"]["Scene01"]["reduction_percent"],
            metrics["figure_6_2"]["Scene04"]["reduction_percent"],
        ),
    )

    add_heading(doc, "6.2  螺旋爬升、8字轨迹与五对象比较", 2)
    add_body(
        doc,
        "螺旋爬升同时包含水平圆周运动和持续高度变化，8字轨迹持续改变曲率与水平加速度方向。图6-2(b)和图6-2(c)给出RA-GCA-CGHTE的平面投影，实际轨迹与参考轨迹在稳定段基本重合。螺旋爬升和8字轨迹的位置RMSE分别为{:.5f} m和{:.5f} m，相对PID分别降低{:.1f}%和{:.1f}%。".format(
            metrics["figure_6_2"]["Scene02"]["main_rmse_m"],
            metrics["figure_6_2"]["Scene03"]["main_rmse_m"],
            metrics["figure_6_2"]["Scene02"]["reduction_percent"],
            metrics["figure_6_2"]["Scene03"]["reduction_percent"],
        ),
    )
    add_figure(
        doc,
        figures["图6-2"].outputs[0],
        "图6-2  PID与RA-GCA-CGHTE典型任务RMSE及连续轨迹投影",
        "注：RMSE比较使用登记的同任务结果；轨迹投影来自RA-GCA-CGHTE直接时序。图中降低率按同一任务的PID与RA-GCA-CGHTE位置RMSE计算。",
    )
    add_body(
        doc,
        "图6-3将五个对象放在四个共同覆盖场景中逐项比较。RA-GCA-CGHTE在分段爬升、定点悬停和8字轨迹中的RMSE均低于PID与RA-GCA/Base，并与CP-INDI接近。三事件外力扰动中，CP-INDI取得0.06212 m的最低RMSE，CAP-ADRC为0.23884 m，RA-GCA-CGHTE为0.29490 m。该结果体现了控制器设计重点的差异：RA-GCA-CGHTE面向常规跟踪、参数变化和约束分配的综合表现，增量动态逆和主动抗扰方法在该外扰场景中具有更强的局部扰动抑制能力。",
    )
    add_figure(
        doc,
        figures["图6-3"].outputs[0],
        "图6-3  五种控制对象在四个公共场景中的位置RMSE",
        "注：每个面板采用独立横轴，数值均为同场景三维位置RMSE。四个场景不合成为单一总分或全场景排名。",
    )
    add_caption(doc, "表6-2  五种控制对象的代表任务位置RMSE")
    add_table(
        doc,
        ["任务", PID, BASE, MAIN, ADRC, INDI],
        build_task_table(common, tasks, snapshot),
        [1.08, 0.8, 0.9, 1.22, 0.9, 0.9],
        size=7.8,
    )
    add_source_note(doc, "注：单位为m。RA-GCA/Base缺少螺旋爬升直接结果，表中写“未测试”；其余数值来自同任务直接结果或登记的历史权威快照。")

    add_heading(doc, "6.3  版本演进、参数变化与推力尺度估计", 2)
    add_body(
        doc,
        "为区分官方基线优化和算法家族演进，图6-4采用两个相互独立的证据面板。图6-4(a)比较PID与RA-GCA-CGHTE，四个公共场景的RMSE比均低于1。图6-4(b)比较约化姿态几何控制与约束感知分配算法前代版本（Reduced-Attitude Geometric Control with Constraint-Aware Allocation, RA-GCA/V8）及其基础构型。RA-GCA/V8相对基础构型降低了四个场景的RMSE；RA-GCA-CGHTE在这些无需明显推力尺度补偿的场景中保持与前代版本近似一致。",
    )
    add_figure(
        doc,
        figures["图6-4"].outputs[0],
        "图6-4  官方基线优化前后与几何控制栈版本演进",
        "注：面板(a)以PID为参考；面板(b)以RA-GCA/Base为参考。RA-GCA/V8只承担前代版本消融角色，不进入正文五对象横向排名。",
    )
    add_body(
        doc,
        "11项参数变化覆盖标准参数设置、八个参数角点、升力效能降低10%和载荷增加10%。图6-5显示，RA-GCA-CGHTE在6项推力尺度明显失配设置中将位置RMSE降低{:.2f}%至{:.2f}%；其余5项中两条曲线几乎重合。11项RMSE比中位数为{:.5f}。该结果说明，置信门控尺度估计在载荷或升力效能变化时提供补偿，并在无需补偿的设置中维持原控制栈的跟踪特性。".format(
            metrics["figure_6_5"]["improved_reduction_min_percent"],
            metrics["figure_6_5"]["improved_reduction_max_percent"],
            metrics["figure_6_5"]["median_rmse_ratio"],
        ),
    )
    add_figure(
        doc,
        figures["图6-5"].outputs[0],
        "图6-5  RA-GCA/V8与RA-GCA-CGHTE在11项参数变化下的配对结果",
        "注：横轴采用对数尺度以同时呈现约0.015 m和约0.7 m量级的结果。PID没有这11项参数设置下的同合同数据，故未纳入本图。",
    )
    improved = parameter[parameter.classification == "improved"]
    equivalent = parameter[parameter.classification == "equivalent"]
    doc.add_paragraph().add_run().add_break(WD_BREAK.PAGE)
    add_caption(doc, "表6-3  参数变化配对结果摘要")
    add_table(
        doc,
        ["设置分组", "数量", "RA-GCA/V8 RMSE范围（m）", "RA-GCA-CGHTE RMSE范围（m）", "结果概述"],
        [
            ["推力尺度明显失配", str(len(improved)), f"{improved.v8_tracking_rmse_m.min():.4f}-{improved.v8_tracking_rmse_m.max():.4f}", f"{improved.formal_tracking_rmse_m.min():.4f}-{improved.formal_tracking_rmse_m.max():.4f}", "RMSE降低93.33%-97.26%"],
            ["标准参数及推重比保持", str(len(equivalent)), f"{equivalent.v8_tracking_rmse_m.min():.4f}-{equivalent.v8_tracking_rmse_m.max():.4f}", f"{equivalent.formal_tracking_rmse_m.min():.4f}-{equivalent.formal_tracking_rmse_m.max():.4f}", "两版本结果几乎重合"],
            ["非参数回归场景", "21", "与前代版本配对", "最大RMSE比偏离约1.34e-7", "新增机制保持近似透明"],
        ],
        [1.25, 0.48, 1.35, 1.55, 1.32],
        size=7.5,
    )

    add_heading(doc, "6.4  外部扰动与风场", 2)
    disturbance_metrics = metrics["figure_6_6"]
    pid_reduction = 100.0 * (disturbance_metrics[PID] - disturbance_metrics[MAIN]) / disturbance_metrics[PID]
    base_reduction = 100.0 * (disturbance_metrics[BASE] - disturbance_metrics[MAIN]) / disturbance_metrics[BASE]
    add_body(
        doc,
        "三事件外力扰动包含三段独立作用区间。图6-6(a)显示，RA-GCA-CGHTE的位置RMSE为{:.5f} m，相对PID降低{:.1f}%；相对RA-GCA/Base降低{:.1f}%。图6-6(b)进一步给出五对象结果，CAP-ADRC和CP-INDI在该场景中的RMSE更低，其中CP-INDI为{:.5f} m。几何控制栈的优势集中在常规跟踪、参数适应和约束分配；专门强调扰动增量或观测补偿的控制器在该外扰设置中获得更快的误差抑制。".format(
            disturbance_metrics[MAIN], pid_reduction, base_reduction, disturbance_metrics[INDI]
        ),
    )
    add_figure(
        doc,
        figures["图6-6"].outputs[0],
        "图6-6  三事件外力扰动中的官方优化前后与五对象取舍",
        "注：所有数值均为同一三事件扰动任务的全时域三维位置RMSE。该局部结果不外推到其他任务。",
    )
    wind = metrics["figure_6_7"]["Scene08"]
    add_body(
        doc,
        "五相位风场保持扰动幅值和任务不变，仅改变确定性相位。RA-GCA-CGHTE的五次位置RMSE均值为{:.5f} m，样本标准差为{:.2e} m。图6-7(a)和图6-7(b)显示，其结果与RA-GCA/V8成对重合，最大相对差为{:.3f} ppm。该结果说明，在这些风扰设置中，推力尺度估计没有改变前代控制栈的主要动态。".format(
            wind["main_mean_rmse_m"], wind["main_sample_std_rmse_m"], wind["max_abs_relative_difference_ppm"]
        ),
    )

    add_heading(doc, "6.5  传感器退化", 2)
    sensor = metrics["figure_6_7"]["Scene10"]
    add_body(
        doc,
        "传感器退化场景同时施加20 ms测量延迟、0.005 m位置噪声均方根值和0.5度姿态噪声均方根值，并采用五个确定性相位。RA-GCA-CGHTE的五次位置RMSE均值为{:.5f} m，样本标准差为{:.2e} m；相对RA-GCA/V8的最大差异为{:.3f} ppm。图6-7(c)和图6-7(d)表明，新增尺度估计机制在这组噪声与延迟设置下保持了前代结果。PID、CAP-ADRC和CP-INDI尚无五相位风扰及传感器退化的同合同数据，本节不建立横向排名。".format(
            sensor["main_mean_rmse_m"], sensor["main_sample_std_rmse_m"], sensor["max_abs_relative_difference_ppm"]
        ),
    )
    add_figure(
        doc,
        figures["图6-7"].outputs[0],
        "图6-7  RA-GCA/V8与RA-GCA-CGHTE的风扰和传感器退化配对结果",
        "注：每类场景包含5个确定性相位。ppm表示百万分之一相对差，计算式为10^6乘以（RA-GCA-CGHTE RMSE除以RA-GCA/V8 RMSE减1）。",
    )

    add_heading(doc, "6.6  推力尺度估计与执行器诊断", 2)
    diagnostic = metrics["figure_6_8"]
    add_body(
        doc,
        "图6-8以升力效能降低10%的代表设置展示RA-GCA-CGHTE内部诊断。尺度估计由1逐步收敛到{:.4f}，应用尺度末值为{:.4f}，与该设置对应的{:.4f}接近；融合有效状态在{:.1f}%的采样点保持有效。高度轨迹在估计建立后贴近参考，表明尺度通道能够把推力模型偏差转换为缓慢变化的补偿量。".format(
            diagnostic["final_estimated_scale"],
            diagnostic["final_applied_scale"],
            diagnostic["target_scale"],
            100.0 * diagnostic["fusion_valid_fraction"],
        ),
    )
    add_body(
        doc,
        "执行器诊断采用16维固定接口，图6-8(d)给出四路电机指令最大绝对值占分配上界的比例；本场景最大值为{:.3f}%。现有结果说明控制器、估计器和分配接口连接一致，且该代表设置未接近分配上界。由于本章场景没有主动触发双级去饱和，结果仅支持接口状态和约束裕量，不用于宣称主动去饱和收益。".format(diagnostic["maximum_actuator_usage_percent"]),
    )
    add_figure(
        doc,
        figures["图6-8"].outputs[0],
        "图6-8  RA-GCA-CGHTE的推力尺度估计、置信门控与执行器诊断",
        "注：尺度估计、应用尺度、融合有效状态、归一化创新和分配上界分别读取诊断接口第11至15项；电机指令使用率按四路指令最大绝对值除以分配上界计算。",
    )
    add_caption(doc, "表6-4  环境鲁棒性与工程诊断摘要")
    add_table(
        doc,
        ["证据项", "样本", "RA-GCA-CGHTE结果", "对照或边界"],
        [
            ["五相位风扰", "n=5", f"RMSE {wind['main_mean_rmse_m']:.5f} +/- {wind['main_sample_std_rmse_m']:.2e} m", f"相对V8最大差{wind['max_abs_relative_difference_ppm']:.3f} ppm"],
            ["五相位传感器退化", "n=5", f"RMSE {sensor['main_mean_rmse_m']:.5f} +/- {sensor['main_sample_std_rmse_m']:.2e} m", f"相对V8最大差{sensor['max_abs_relative_difference_ppm']:.3f} ppm"],
            ["推力尺度估计", "1个代表设置", f"应用尺度末值{diagnostic['final_applied_scale']:.4f}", f"对应尺度{diagnostic['target_scale']:.4f}"],
            ["执行器使用率", "全时序", f"最大{diagnostic['maximum_actuator_usage_percent']:.3f}%", "未触发主动去饱和"],
        ],
        [1.25, 0.9, 2.0, 1.85],
        size=7.8,
    )
    add_body(
        doc,
        "综合来看，RA-GCA-CGHTE在三轴阶跃、分段爬升、悬停和连续轨迹中相对PID降低了超调或跟踪误差；在推力尺度明显失配的6项设置中显著降低RMSE，并在21项非参数回归场景中保持与前代版本近似一致。三事件外扰结果同时显示CAP-ADRC和CP-INDI的局部优势。现有证据支持当前主算法作为兼顾常规跟踪、参数适应和约束接口的工程方案，外扰专项性能和主动去饱和触发仍可继续完善。",
    )

    add_heading(doc, "参考文献", 1, page_break=True)
    references = [
        "Han, J. (2009). From PID to active disturbance rejection control. IEEE Transactions on Industrial Electronics, 56(3), 900-906. https://doi.org/10.1109/TIE.2008.2011621",
        "Johansen, T. A., & Fossen, T. I. (2013). Control allocation: A survey. Automatica, 49(5), 1087-1103. https://doi.org/10.1016/j.automatica.2013.01.035",
        "Lee, T., Leok, M., & McClamroch, N. H. (2010). Geometric tracking control of a quadrotor UAV on SE(3). In 49th IEEE Conference on Decision and Control (pp. 5420-5425). https://doi.org/10.1109/CDC.2010.5717652",
        "Smeur, E. J. J., Chu, Q., & de Croon, G. C. H. E. (2016). Adaptive incremental nonlinear dynamic inversion for attitude control of micro air vehicles. Journal of Guidance, Control, and Dynamics, 39(3), 450-461. https://doi.org/10.2514/1.G001490",
    ]
    for text in references:
        paragraph = doc.add_paragraph(style="Reference Entry")
        run = paragraph.add_run(text)
        set_run_fonts(run, 9.0)

    add_heading(doc, "本章附录A  复合参数与外扰共同作用下的性能取舍", 1, page_break=True)
    add_body(
        doc,
        "本附录补充6组参数变化与外力或外力矩共同作用的测试。该组结果用于观察推力尺度补偿在复合应力下的收益和瞬态代价。图A-1(a)显示4组设置的全时域位置RMSE下降，另外2组与前代版本基本一致；图A-1(b)显示其中4组的恢复时间增加约0.61至0.72 s。该结果表明，尺度补偿能够降低持续跟踪偏差，强扰动后的恢复速度仍受姿态约束和扰动抑制环节影响。",
    )
    add_figure(
        doc,
        figures["图A-1"].outputs[0],
        "图A-1  复合参数与外扰场景中的RMSE变化及恢复时间变化",
        "注：RMSE变化以RA-GCA/V8为参考，负值表示RA-GCA-CGHTE误差更低；恢复时间变化为RA-GCA-CGHTE减去RA-GCA/V8。两项指标同时报告。",
    )
    add_caption(doc, "表A-1  六组复合应力场景的配对结果")
    appendix_rows = []
    for index, row in enumerate(compound.itertuples(index=False), start=1):
        appendix_rows.append(
            [
                f"组合{index}",
                f4(row.v8_tracking_rmse_m),
                f4(row.formal_tracking_rmse_m),
                f4(row.formal_tracking_peak_m),
                f"{row.v8_recovery_s:.2f}",
                f"{row.formal_recovery_s:.2f}",
            ]
        )
    add_table(
        doc,
        ["设置", "V8 RMSE（m）", "主算法RMSE（m）", "主算法峰值（m）", "V8恢复（s）", "主算法恢复（s）"],
        appendix_rows,
        [0.72, 1.0, 1.18, 1.18, 0.95, 1.1],
        size=7.6,
    )
    add_source_note(doc, "注：6组设置均保留完整配对结果。RMSE改善与恢复时间增加同时存在，正文结论不将二者合成为加权总分。")
    doc.save(OUTPUT)


def build_registry(records: Iterable[FigureRecord]) -> pd.DataFrame:
    # 图件登记表绑定输出文件、源数据和关键指标。
    rows = []
    for record in records:
        input_text = ";".join(rel(path) for path in record.sources)
        input_hashes = ";".join(sha256(path) for path in record.sources)
        output_text = ";".join(rel(path) for path in record.outputs)
        output_hashes = ";".join(sha256(path) for path in record.outputs)
        rows.append(
            {
                "figure_id": record.figure_id,
                "claim": record.claim,
                "software": "Python/Matplotlib",
                "input_paths": input_text,
                "input_sha256": input_hashes,
                "source_table": rel(record.source_table),
                "output_paths": output_text,
                "output_sha256": output_hashes,
                "metric_definition": "沿用冻结证据RMSE；派生比值与降低率见图表合同",
            }
        )
    return pd.DataFrame(rows)


def main() -> None:
    for path in (
        OLD_DOC,
        REPORT / "02_standard_step_pid_vs_main.csv",
        REPORT / "03_five_controller_common_scenes.csv",
        REPORT / "04_algorithm_evolution_ablation.csv",
        REPORT / "05_parameter_11_paired.csv",
        REPORT / "07_disturbance_tradeoff.csv",
        REPORT / "08_compound_stress_tradeoff.csv",
        REPORT / "source_snapshots" / "chapter6_metrics_normalized.json",
        CAMPAIGN / "campaign_cases.csv",
        CAMPAIGN / "campaign_pairs.csv",
        SCENE_INDEX,
    ):
        require(path)
    if OUTPUT.exists():
        raise FileExistsError(f"output already exists: {OUTPUT}")
    FIGURES.mkdir(parents=True, exist_ok=True)
    FIGURE_SOURCES.mkdir(parents=True, exist_ok=True)
    configure_matplotlib()

    step = read_csv(REPORT / "02_standard_step_pid_vs_main.csv")
    common = read_csv(REPORT / "03_five_controller_common_scenes.csv")
    evolution = read_csv(REPORT / "04_algorithm_evolution_ablation.csv")
    parameter = read_csv(REPORT / "05_parameter_11_paired.csv")
    disturbance = read_csv(REPORT / "07_disturbance_tradeoff.csv")
    compound = read_csv(REPORT / "08_compound_stress_tradeoff.csv")
    snapshot = read_json(REPORT / "source_snapshots" / "chapter6_metrics_normalized.json")
    cases = load_campaign_cases()
    pairs = read_csv(CAMPAIGN / "campaign_pairs.csv")
    scene_index = read_csv(SCENE_INDEX)
    tasks = build_typical_task_frame(common, cases, snapshot)

    records: list[FigureRecord] = []
    metrics: dict[str, dict] = {}
    record, value = make_figure_1(step)
    records.append(record)
    metrics["figure_6_1"] = value
    record, value = make_figure_2(tasks)
    records.append(record)
    metrics["figure_6_2"] = value
    record, value = make_figure_3(common)
    records.append(record)
    metrics["figure_6_3"] = value
    record, value = make_figure_4(common, evolution)
    records.append(record)
    metrics["figure_6_4"] = value
    record, value = make_figure_5(parameter, scene_index)
    records.append(record)
    metrics["figure_6_5"] = value
    record, value = make_figure_6(disturbance)
    records.append(record)
    metrics["figure_6_6"] = value
    record, value = make_figure_7(pairs)
    records.append(record)
    metrics["figure_6_7"] = value
    record, value = make_figure_8()
    records.append(record)
    metrics["figure_6_8"] = value
    record, value = make_figure_a1(compound)
    records.append(record)
    metrics["figure_a_1"] = value

    metrics["evidence_boundaries"] = {
        "project_regression_case_count": 32,
        "required_parameter_retention": False,
        "overall_selection_gate_pass": False,
        "v30_completed": False,
        "h60_completed": False,
        "wilson_lower_bound_computed": False,
        "paired_bootstrap_completed": False,
    }
    (EVIDENCE / "chapter6_derived_metrics.json").write_text(json.dumps(metrics, ensure_ascii=False, indent=2), encoding="utf-8")
    registry = build_registry(records)
    registry.to_csv(EVIDENCE / "chapter6_figure_registry.csv", index=False, encoding="utf-8-sig")
    generate_document(
        {
            "step": step,
            "common": common,
            "tasks": tasks,
            "snapshot": snapshot,
            "parameter": parameter,
            "compound": compound,
        },
        {record.figure_id: record for record in records},
        metrics,
    )
    manifest_paths = [
        OUTPUT,
        EVIDENCE / "chapter6_derived_metrics.json",
        EVIDENCE / "chapter6_figure_registry.csv",
        *[path for record in records for path in record.outputs],
        *[record.source_table for record in records],
    ]
    manifest = [
        {"path": rel(path), "bytes": path.stat().st_size, "sha256": sha256(path)}
        for path in manifest_paths
    ]
    (EVIDENCE / "chapter6_second_handoff_manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(
        json.dumps(
            {
                "status": "generated",
                "docx": str(OUTPUT),
                "docx_sha256": sha256(OUTPUT),
                "figure_count": len(records),
                "figure_formats": ["png", "pdf", "svg"],
                "registry_rows": len(registry),
            },
            ensure_ascii=False,
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
