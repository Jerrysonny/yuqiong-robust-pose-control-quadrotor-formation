#!/usr/bin/env python3
"""Build final-algorithm report figures, package visuals, GIFs, and public evidence.

The script is intentionally split into build and promote phases. Build writes only
to ``tmp/finals_revision_assets_20260816/stage``. Promotion is allowed only after
the generated manifest reports a passed visual and data audit.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import io
import json
import math
import shutil
from dataclasses import dataclass
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch
from PIL import Image, ImageDraw, ImageFont, ImageSequence


ALGORITHM = "ARDG-RGPC"
PUBLIC_DISPLAY_NAMES = {
    "PID": "官方PID",
    "RA-GCA/Base": "几何控制基线",
    "ARDG-RGPC": "ARDG-RGPC",
}
FIG_DPI = 240
SCREEN_DPI = 100
SCREEN_SIZE = (12.8, 7.2)
TEAL = "#007C83"
TEAL_DARK = "#005A60"
CHARCOAL = "#374151"
GRAY = "#9CA3AF"
LIGHT_GRAY = "#E5E7EB"
GREEN = "#2F855A"
AMBER = "#B7791F"
RED = "#B8323C"
BLUE = "#2B6CB0"
PURPLE = "#6B46C1"
OFF_WHITE = "#F8FAFC"
SAFETY_DISTANCE_M = 0.60


@dataclass(frozen=True)
class Paths:
    root: Path
    research: Path

    @property
    def stage(self) -> Path:
        return self.root / "tmp" / "finals_revision_assets_20260816" / "stage"

    @property
    def final_regression_source(self) -> Path:
        return (
            self.research
            / "74_v936_ardg1_final_local_search"
            / "03_results"
            / "l06_regression18_20260814T115638Z"
            / "candidate"
        )

    @property
    def formation_source(self) -> Path:
        return self.research / "75_final_materials_rerun" / "formation_20260816" / "raw"

    @property
    def pid_scene06b_source(self) -> Path:
        return (
            self.research
            / "05_disturbance_comparison"
            / "06_runtime"
            / "official_pid_scene06b_rep01"
            / "raw.csv"
        )

    @property
    def public_evidence_refresh(self) -> Path:
        return self.research / "78_finals_public_evidence_refresh" / "03_results"

    @property
    def pid_angular_source(self) -> Path:
        return self.public_evidence_refresh / "official_pid_angular_20260816"

    @property
    def compound_source(self) -> Path:
        return self.public_evidence_refresh / "compound_ardg_rgpc_20260816"


def configure_matplotlib() -> None:
    plt.rcParams.update(
        {
            "font.family": "sans-serif",
            "font.sans-serif": ["Microsoft YaHei", "SimHei", "Arial Unicode MS", "DejaVu Sans"],
            "axes.unicode_minus": False,
            "font.size": 9.5,
            "axes.labelsize": 9.5,
            "xtick.labelsize": 8.5,
            "ytick.labelsize": 8.5,
            "legend.fontsize": 8.2,
            "axes.edgecolor": "#6B7280",
            "axes.linewidth": 0.7,
            "axes.spines.top": False,
            "axes.spines.right": False,
            "grid.color": "#E5E7EB",
            "grid.linewidth": 0.6,
            "savefig.facecolor": "white",
            "figure.facecolor": "white",
        }
    )


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def ensure_sources(paths: Paths) -> None:
    required = [
        paths.root / "MAIN_ALGORITHM.json",
        paths.root / "06_supplementary_evidence" / "ardg_rgpc_parameter11_final",
        paths.root / "06_supplementary_evidence" / "ardg_rgpc_random20_final",
        paths.root / "05_visuals" / "final_shared_assets" / "data" / "BODY_ROLL_POS_ARDG-RGPC.csv",
        paths.root / "05_visuals" / "final_shared_assets" / "data" / "BODY_PITCH_NEG_ARDG-RGPC.csv",
        paths.final_regression_source / "raw" / "Scene01.csv",
        paths.final_regression_source / "raw" / "Scene06b.csv",
        paths.formation_source / "Scene07B.csv",
        paths.formation_source / "Scene07COff.csv",
        paths.formation_source / "Scene07COnPredictiveV5C.csv",
        paths.pid_scene06b_source,
        paths.pid_angular_source / "BODY_ROLL_POS" / "raw.csv",
        paths.pid_angular_source / "BODY_ROLL_POS" / "execution_status.json",
        paths.pid_angular_source / "BODY_PITCH_NEG" / "raw.csv",
        paths.pid_angular_source / "BODY_PITCH_NEG" / "execution_status.json",
        paths.compound_source / "evaluation" / "compound_metrics.csv",
        paths.compound_source / "evaluation" / "summary.json",
    ]
    for case_id in ("D_C01", "D_C02", "D_C03", "D_C04", "D_C05", "D_C06"):
        required.extend(
            [
                paths.compound_source / "cases" / case_id / "raw.csv",
                paths.compound_source / "cases" / case_id / "ardg_diagnostics.csv",
                paths.compound_source / "cases" / case_id / "execution_status.json",
            ]
        )
    missing = [str(item) for item in required if not item.exists()]
    if missing:
        raise FileNotFoundError("Missing required final evidence:\n" + "\n".join(missing))


def reset_stage(paths: Paths) -> None:
    if paths.stage.exists() and any(paths.stage.iterdir()):
        raise RuntimeError(f"Stage is not empty: {paths.stage}")
    paths.stage.mkdir(parents=True, exist_ok=True)


def staged(paths: Paths, relative: str | Path) -> Path:
    result = paths.stage / Path(relative)
    result.parent.mkdir(parents=True, exist_ok=True)
    return result


def read_csv(path: Path) -> pd.DataFrame:
    return pd.read_csv(path, low_memory=False)


def copy_public_csv(source: Path, target: Path) -> dict[str, object]:
    frame = read_csv(source)
    internal_identity_columns = [
        column
        for column in frame.columns
        if column == "controllerDiagnostics[16]"
        or (column.startswith("controllerDiagnostics") and column.endswith("[16]"))
    ]
    if internal_identity_columns:
        frame = frame.drop(columns=internal_identity_columns)
    frame.to_csv(target, index=False, encoding="utf-8-sig")
    return {
        "source_sha256": sha256_file(source),
        "public_sha256": sha256_file(target),
        "rows": int(len(frame)),
        "columns": int(len(frame.columns)),
        "removed_internal_identity_columns": internal_identity_columns,
    }


def write_public_json(target: Path, payload: dict[str, object]) -> None:
    target.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def position_error(df: pd.DataFrame, *, reference_prefix: str = "referenceVector", actual_prefix: str = "quadChassisTest17_1.body.r_0") -> np.ndarray:
    reference = df[[f"{reference_prefix}[{i}]" for i in (1, 2, 3)]].to_numpy(float)
    actual = df[[f"{actual_prefix}[{i}]" for i in (1, 2, 3)]].to_numpy(float)
    return np.linalg.norm(actual - reference, axis=1)


def position_rmse(df: pd.DataFrame, **kwargs: str) -> float:
    error = position_error(df, **kwargs)
    return float(np.sqrt(np.mean(error**2)))


def downsample(df: pd.DataFrame, maximum: int = 1500) -> pd.DataFrame:
    if len(df) <= maximum:
        return df
    return df.iloc[np.linspace(0, len(df) - 1, maximum, dtype=int)]


def save_figure(fig: plt.Figure, path: Path, *, dpi: int = FIG_DPI) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(path, dpi=dpi, bbox_inches="tight", pad_inches=0.06)
    plt.close(fig)


def label_panel(ax: plt.Axes, label: str) -> None:
    ax.text(-0.10, 1.04, label, transform=ax.transAxes, fontsize=10, fontweight="bold", va="bottom")


def clean_axis(ax: plt.Axes, *, grid: str | None = "y") -> None:
    if grid:
        ax.grid(True, axis=grid, alpha=0.9)
    ax.set_axisbelow(True)


def draw_box(ax: plt.Axes, xy: tuple[float, float], wh: tuple[float, float], text: str, *, edge: str = TEAL, face: str = "#ECF7F7", fontsize: float = 9.2) -> None:
    x, y = xy
    w, h = wh
    box = FancyBboxPatch(
        (x, y),
        w,
        h,
        boxstyle="round,pad=0.012,rounding_size=0.015",
        linewidth=1.0,
        edgecolor=edge,
        facecolor=face,
    )
    ax.add_patch(box)
    ax.text(x + w / 2, y + h / 2, text, ha="center", va="center", fontsize=fontsize, color=CHARCOAL, linespacing=1.25)


def draw_arrow(ax: plt.Axes, start: tuple[float, float], end: tuple[float, float], *, color: str = CHARCOAL, style: str = "-") -> None:
    arrow = FancyArrowPatch(start, end, arrowstyle="-|>", mutation_scale=10, linewidth=1.0, color=color, linestyle=style)
    ax.add_patch(arrow)


def build_architecture_figure(path: Path) -> None:
    fig, ax = plt.subplots(figsize=(13.2, 6.4))
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")

    columns = [0.03, 0.20, 0.39, 0.58, 0.77]
    widths = [0.13, 0.14, 0.15, 0.15, 0.17]
    rows = [0.72, 0.42, 0.12]
    h = 0.14

    draw_box(ax, (columns[0], rows[0]), (widths[0], h), "位置/速度参考\n状态反馈")
    draw_box(ax, (columns[1], rows[0]), (widths[1], h), "几何位置外环\n期望合力与推力轴")
    draw_box(ax, (columns[2], rows[0]), (widths[2], h), "约化姿态内环\n滚转/俯仰期望力矩")
    draw_box(ax, (columns[3], rows[0]), (widths[3], h), "力矩合成\n基础力矩 + 受限补偿", edge=GREEN, face="#EDF7F0")
    draw_box(ax, (columns[4], rows[0]), (widths[4], h), "约束感知分配\n四路电机指令", edge=AMBER, face="#FFF8E8")

    draw_box(ax, (columns[0], rows[1]), (widths[0], h), "四路转子转速\n机体系角速度")
    draw_box(ax, (columns[1], rows[1]), (widths[1], h), "实际力矩重构\n角加速度估计")
    draw_box(ax, (columns[2], rows[1]), (widths[2], h), "角残差与方向证据\n滚转/俯仰通道判别")
    draw_box(ax, (columns[3], rows[1]), (widths[3], h), "滞回与渐变守卫\n限幅/变化率约束", edge=GREEN, face="#EDF7F0")
    draw_box(ax, (columns[4], rows[1]), (widths[4], h), "ARDG独立诊断\n激活、融合、补偿、残差", edge=BLUE, face="#EFF6FF")

    draw_box(ax, (columns[0], rows[2]), (widths[0], h), "有限值/时间\n剪裁与分配状态", edge=RED, face="#FFF1F2")
    draw_box(ax, (columns[1], rows[2]), (widths[1], h), "安全旁路判定\n异常时补偿归零", edge=RED, face="#FFF1F2")
    draw_box(ax, (columns[2], rows[2]), (widths[2], h), "控制权限检查\n幅值、速率与持续时间", edge=RED, face="#FFF1F2")
    draw_box(ax, (columns[3], rows[2]), (widths[3], h), "公共16维诊断\n接口合同保持不变", edge=BLUE, face="#EFF6FF")
    draw_box(ax, (columns[4], rows[2]), (widths[4], h), "四旋翼物理模型\n电机、机体与传感器", edge=CHARCOAL, face="#F3F4F6")

    for row in rows[:2]:
        for i in range(4):
            draw_arrow(ax, (columns[i] + widths[i], row + h / 2), (columns[i + 1], row + h / 2))
    for i in range(3):
        draw_arrow(ax, (columns[i] + widths[i], rows[2] + h / 2), (columns[i + 1], rows[2] + h / 2), color=RED)
    draw_arrow(ax, (columns[3] + widths[3], rows[2] + h / 2), (columns[4], rows[2] + h / 2), color=BLUE)
    draw_arrow(ax, (columns[3] + widths[3] / 2, rows[1] + h), (columns[3] + widths[3] / 2, rows[0]), color=GREEN)
    draw_arrow(ax, (columns[1] + widths[1] / 2, rows[2] + h), (columns[1] + widths[1] / 2, rows[1]), color=RED)
    route_x = 0.965
    allocation_y = rows[0] + h / 2
    physical_y = rows[2] + h / 2
    ax.plot(
        [columns[4] + widths[4], route_x, route_x],
        [allocation_y, allocation_y, physical_y],
        color=CHARCOAL,
        linewidth=1.0,
        linestyle="--",
    )
    draw_arrow(ax, (route_x, physical_y), (columns[4] + widths[4], physical_y), color=CHARCOAL, style="--")

    ax.text(0.03, 0.94, "基础几何控制主链", color=TEAL_DARK, fontsize=10.5, fontweight="bold")
    ax.text(0.03, 0.64, "角残差驱动补偿支链", color=GREEN, fontsize=10.5, fontweight="bold")
    ax.text(0.03, 0.34, "安全旁路与接口诊断链", color=RED, fontsize=10.5, fontweight="bold")
    ax.text(0.97, 0.02, "补偿只在证据充分且安全状态有效时介入", ha="right", color=CHARCOAL, fontsize=8.8)
    save_figure(fig, path)


def build_formation_architecture_figure(path: Path) -> None:
    fig, ax = plt.subplots(figsize=(13.2, 6.4))
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")

    draw_box(ax, (0.03, 0.79), (0.18, 0.14), "领导机参考\n与编队偏置")
    draw_box(
        ax,
        (0.31, 0.76),
        (0.38, 0.20),
        "PP-CBF上层安全监督器\n预测三对机间约束并最小修正参考",
        edge=GREEN,
        face="#EDF7F0",
        fontsize=10.2,
    )
    draw_box(ax, (0.79, 0.79), (0.18, 0.14), "三机位置与速度\n状态反馈", edge=BLUE, face="#EFF6FF")
    draw_arrow(ax, (0.21, 0.86), (0.31, 0.86), color=GREEN)
    draw_arrow(ax, (0.79, 0.86), (0.69, 0.86), color=GREEN)

    rows = [0.53, 0.30, 0.07]
    for index, y in enumerate(rows, start=1):
        draw_box(ax, (0.07, y), (0.14, 0.13), f"安全参考 {index}\n位置 / 速度 / 加速度", edge=GREEN, face="#EDF7F0", fontsize=8.7)
        draw_box(ax, (0.32, y), (0.20, 0.13), f"ARDG-RGPC {index}\n几何控制 + 受限补偿", edge=TEAL, face="#ECF7F7", fontsize=9.0)
        draw_box(ax, (0.63, y), (0.14, 0.13), f"四旋翼 {index}\n电机与机体", edge=CHARCOAL, face="#F3F4F6", fontsize=9.0)
        draw_box(ax, (0.85, y), (0.12, 0.13), f"状态 {index}\n位置 / 速度", edge=BLUE, face="#EFF6FF", fontsize=8.7)
        draw_arrow(ax, (0.21, y + 0.065), (0.32, y + 0.065), color=TEAL)
        draw_arrow(ax, (0.52, y + 0.065), (0.63, y + 0.065), color=CHARCOAL)
        draw_arrow(ax, (0.77, y + 0.065), (0.85, y + 0.065), color=BLUE)

    branch_x = 0.035
    ax.plot([0.50, 0.50, branch_x, branch_x], [0.76, 0.72, 0.72, rows[-1] + 0.065], color=GREEN, linewidth=1.1)
    for y in rows:
        draw_arrow(ax, (branch_x, y + 0.065), (0.07, y + 0.065), color=GREEN)

    feedback_x = 0.985
    ax.plot([feedback_x, feedback_x, 0.88], [rows[-1] + 0.065, 0.72, 0.72], color=BLUE, linewidth=1.0, linestyle="--")
    for y in rows:
        ax.plot([0.97, feedback_x], [y + 0.065, y + 0.065], color=BLUE, linewidth=1.0, linestyle="--")
    draw_arrow(ax, (0.88, 0.72), (0.88, 0.79), color=BLUE, style="--")

    ax.text(0.03, 0.965, "上层参考安全修正", color=GREEN, fontsize=10.5, fontweight="bold")
    ax.text(0.32, 0.685, "三套独立低层闭环", color=TEAL_DARK, fontsize=10.5, fontweight="bold")
    ax.text(0.97, 0.015, "设计距离 0.615 m；安全判定值 0.60 m。PP-CBF只修正参考，不替代低层控制器。", ha="right", color=CHARCOAL, fontsize=8.6)
    save_figure(fig, path)


def build_c1_flow(path: Path) -> None:
    fig, ax = plt.subplots(figsize=(13.2, 5.8))
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    xs = [0.02, 0.18, 0.35, 0.52, 0.69, 0.85]
    labels = [
        "转子转速与角速度",
        "实际滚转/俯仰\n力矩重构",
        "角加速度估计\n与角残差计算",
        "方向、持续时间\n与滞回证据",
        "渐变融合\n限幅与变化率约束",
        "受限补偿力矩\n并入基础控制",
    ]
    for x, label in zip(xs, labels):
        draw_box(ax, (x, 0.58), (0.13, 0.18), label, edge=GREEN, face="#EDF7F0")
    for i in range(len(xs) - 1):
        draw_arrow(ax, (xs[i] + 0.13, 0.67), (xs[i + 1], 0.67), color=GREEN)

    draw_box(ax, (0.18, 0.20), (0.18, 0.16), "非有限值、时间异常\n剪裁或不可行分配", edge=RED, face="#FFF1F2")
    draw_box(ax, (0.43, 0.20), (0.18, 0.16), "安全旁路\n补偿立即归零", edge=RED, face="#FFF1F2")
    draw_box(ax, (0.68, 0.20), (0.18, 0.16), "独立诊断CSV\n记录激活与旁路状态", edge=BLUE, face="#EFF6FF")
    draw_arrow(ax, (0.36, 0.28), (0.43, 0.28), color=RED)
    draw_arrow(ax, (0.61, 0.28), (0.68, 0.28), color=BLUE)
    draw_arrow(ax, (0.52, 0.36), (0.74, 0.58), color=RED, style="--")
    ax.text(0.02, 0.90, "ARDG补偿支路", fontsize=11, fontweight="bold", color=GREEN)
    ax.text(0.18, 0.10, "异常条件优先级高于性能补偿，基础几何控制输出始终保留。", fontsize=9.2, color=CHARCOAL)
    save_figure(fig, path)


def build_c2_sysblock(path: Path) -> None:
    fig, ax = plt.subplots(figsize=(13.2, 6.2))
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    draw_box(ax, (0.02, 0.66), (0.15, 0.16), "11维参考总线\n位置/速度/加速度")
    draw_box(ax, (0.02, 0.40), (0.15, 0.16), "18维状态总线\n位置/速度/姿态/角速度")
    draw_box(ax, (0.02, 0.14), (0.15, 0.16), "转子转速、使能、时间\n与分配上下限")

    draw_box(ax, (0.24, 0.62), (0.18, 0.20), "GeometricCore\n位置外环 + 约化姿态内环", edge=TEAL, face="#ECF7F7")
    draw_box(ax, (0.24, 0.30), (0.18, 0.20), "AngularResidualGuard\n力矩重构 + 角残差守卫", edge=GREEN, face="#EDF7F0")
    draw_box(ax, (0.48, 0.62), (0.18, 0.20), "TorqueMerge\n基础力矩与受限补偿合成", edge=GREEN, face="#EDF7F0")
    draw_box(ax, (0.48, 0.30), (0.18, 0.20), "SafetyBypass\n有限值、时间与分配检查", edge=RED, face="#FFF1F2")
    draw_box(ax, (0.72, 0.62), (0.16, 0.20), "ConstrainedAllocator\n两阶段去饱和与限幅", edge=AMBER, face="#FFF8E8")
    draw_box(ax, (0.72, 0.30), (0.16, 0.20), "Diagnostics\n公共16维 + 独立ARDG字段", edge=BLUE, face="#EFF6FF")
    draw_box(ax, (0.91, 0.62), (0.07, 0.20), "4维\n电机\n指令", edge=CHARCOAL, face="#F3F4F6")
    draw_box(ax, (0.91, 0.30), (0.07, 0.20), "诊断\n输出", edge=BLUE, face="#EFF6FF")

    draw_arrow(ax, (0.17, 0.74), (0.24, 0.72))
    draw_arrow(ax, (0.17, 0.48), (0.24, 0.70))
    draw_arrow(ax, (0.17, 0.22), (0.24, 0.40))
    draw_arrow(ax, (0.42, 0.72), (0.48, 0.72))
    draw_arrow(ax, (0.42, 0.40), (0.48, 0.68), color=GREEN)
    draw_arrow(ax, (0.42, 0.40), (0.48, 0.40), color=RED)
    draw_arrow(ax, (0.66, 0.72), (0.72, 0.72))
    draw_arrow(ax, (0.66, 0.40), (0.72, 0.40), color=BLUE)
    draw_arrow(ax, (0.80, 0.62), (0.80, 0.50), color=RED, style="--")
    draw_arrow(ax, (0.88, 0.72), (0.91, 0.72))
    draw_arrow(ax, (0.88, 0.40), (0.91, 0.40), color=BLUE)
    ax.text(0.02, 0.92, "最终控制器的Sysblock功能分区与端口关系", fontsize=11, fontweight="bold", color=CHARCOAL)
    ax.text(0.98, 0.08, "示意依据正式Sysblock源码和公开接口合同绘制", ha="right", fontsize=8.7, color=CHARCOAL)
    save_figure(fig, path)


def build_c3_regions(path: Path) -> None:
    fig, axes = plt.subplots(1, 3, figsize=(13.2, 4.8))
    panels = [
        ("(a) 几何控制主干", ["位置/速度误差", "期望合力", "推力轴方向", "约化姿态误差", "基础力矩"]),
        ("(b) ARDG补偿支路", ["转子响应", "实际力矩重构", "角残差", "滞回守卫", "受限补偿"]),
        ("(c) 分配与安全旁路", ["力矩合成", "分配可行性", "两阶段去饱和", "异常旁路", "电机与诊断输出"]),
    ]
    colors = [(TEAL, "#ECF7F7"), (GREEN, "#EDF7F0"), (AMBER, "#FFF8E8")]
    for ax, (title, labels), (edge, face) in zip(axes, panels, colors):
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
        ax.axis("off")
        ax.text(0.02, 0.95, title, fontsize=10.3, fontweight="bold", va="top", color=CHARCOAL)
        ys = np.linspace(0.76, 0.12, len(labels))
        for i, (y, label) in enumerate(zip(ys, labels)):
            draw_box(ax, (0.18, y), (0.64, 0.11), label, edge=edge, face=face, fontsize=8.9)
            if i < len(labels) - 1:
                draw_arrow(ax, (0.50, y), (0.50, ys[i + 1] + 0.11), color=edge)
    fig.subplots_adjust(wspace=0.18)
    save_figure(fig, path)


def final_raw(paths: Paths, case_id: str) -> pd.DataFrame:
    return read_csv(paths.final_regression_source / "raw" / f"{case_id}.csv")


def build_figure_6_1(paths: Paths, path: Path) -> dict[str, float]:
    pid_source = read_csv(paths.root / "05_visuals" / "assets" / "report_sources" / "data" / "FIG_6-1__figure_6_1_step_timeseries.csv")
    mapping = {"X": "Scene01S_X", "Y": "Scene01S_Y", "Z": "Scene01S_Z"}
    fig, axes = plt.subplots(2, 2, figsize=(12.4, 7.2))
    overshoot: dict[str, list[float]] = {"PID": [], ALGORITHM: []}
    metrics: dict[str, float] = {}
    for index, (axis_name, case_id) in enumerate(mapping.items()):
        ax = axes.flat[index]
        pid = pid_source[(pid_source["axis"] == axis_name) & (pid_source["controller"] == "PID")]
        final = downsample(final_raw(paths, case_id), 1200)
        component = {"X": 1, "Y": 2, "Z": 3}[axis_name]
        time = final["time"].to_numpy(float)
        reference = final[f"referenceVector[{component}]"].to_numpy(float)
        actual = final[f"quadChassisTest17_1.body.r_0[{component}]"].to_numpy(float)
        ax.plot(pid["time_s"], pid["reference_m"], linestyle="--", color=CHARCOAL, linewidth=1.0, label="参考")
        ax.plot(pid["time_s"], pid["actual_m"], color=CHARCOAL, linewidth=1.2, label="官方PID")
        ax.plot(time, actual, color=TEAL, linewidth=1.5, label=ALGORITHM)
        ax.set_xlabel("时间 / s")
        ax.set_ylabel("位置 / m")
        clean_axis(ax, grid="both")
        label_panel(ax, f"({chr(97 + index)}) {axis_name}轴")
        if index == 0:
            ax.legend(frameon=False, ncol=3, loc="lower right")
        pid_target = float(pid["reference_m"].iloc[-1] - pid["reference_m"].iloc[0])
        final_target = float(reference[-1] - reference[0])
        pid_ov = max(0.0, 100.0 * (float(pid["actual_m"].max()) - float(pid["reference_m"].iloc[-1])) / max(abs(pid_target), 1e-9))
        final_ov = max(0.0, 100.0 * (float(actual.max()) - float(reference[-1])) / max(abs(final_target), 1e-9))
        overshoot["PID"].append(pid_ov)
        overshoot[ALGORITHM].append(final_ov)
        metrics[f"{axis_name.lower()}_final_overshoot_percent"] = final_ov

    ax = axes.flat[3]
    x = np.arange(3)
    width = 0.34
    ax.bar(x - width / 2, overshoot["PID"], width, label="官方PID", color=CHARCOAL)
    ax.bar(x + width / 2, overshoot[ALGORITHM], width, label=ALGORITHM, color=TEAL)
    ax.set_xticks(x, ["X轴", "Y轴", "Z轴"])
    ax.set_ylabel("超调量 / %")
    clean_axis(ax)
    label_panel(ax, "(d) 超调量对比")
    ax.legend(frameon=False)
    for bars in ax.containers:
        ax.bar_label(bars, fmt="%.2f", padding=2, fontsize=8)
    fig.subplots_adjust(hspace=0.34, wspace=0.26)
    save_figure(fig, path)
    return metrics


def build_figure_6_2(paths: Paths, path: Path) -> None:
    source = read_csv(paths.root / "05_visuals" / "assets" / "report_sources" / "data" / "FIG_6-2__figure_6_2_step_hover_timeseries.csv")
    fig, axes = plt.subplots(1, 2, figsize=(12.4, 4.5))
    for ax, case_id, label in zip(axes, ("Scene01", "Scene04"), ("(a) 分段爬升", "(b) 定点悬停")):
        pid = source[(source["case_id"] == case_id) & (source["controller"] == "PID")]
        final = downsample(final_raw(paths, case_id), 1400)
        ax.plot(pid["time_s"], pid["position_error_m"], color=CHARCOAL, linewidth=1.2, linestyle="--", label="官方PID")
        ax.plot(final["time"], position_error(final), color=TEAL, linewidth=1.5, label=ALGORITHM)
        ax.set_xlabel("时间 / s")
        ax.set_ylabel("三维位置误差 / m")
        clean_axis(ax, grid="both")
        label_panel(ax, label)
    axes[0].legend(frameon=False)
    fig.subplots_adjust(wspace=0.24)
    save_figure(fig, path)


def build_figure_6_3(paths: Paths, path: Path) -> None:
    source = read_csv(paths.root / "05_visuals" / "assets" / "report_sources" / "data" / "FIG_6-3__figure_6_3_continuous_trajectories.csv")
    spiral = downsample(final_raw(paths, "Scene02"), 1600)
    eight = downsample(final_raw(paths, "Scene03"), 1800)
    fig = plt.figure(figsize=(12.4, 7.2))
    ax1 = fig.add_subplot(2, 2, 1, projection="3d")
    ax2 = fig.add_subplot(2, 2, 2)
    ax3 = fig.add_subplot(2, 2, 3)
    ax4 = fig.add_subplot(2, 2, 4)

    ax1.plot(spiral["referenceVector[1]"], spiral["referenceVector[2]"], spiral["referenceVector[3]"], color=CHARCOAL, linestyle="--", linewidth=1.0, label="参考")
    ax1.plot(spiral["quadChassisTest17_1.body.r_0[1]"], spiral["quadChassisTest17_1.body.r_0[2]"], spiral["quadChassisTest17_1.body.r_0[3]"], color=TEAL, linewidth=1.5, label=ALGORITHM)
    ax1.set_xlabel("X / m")
    ax1.set_ylabel("Y / m")
    ax1.set_zlabel("Z / m")
    ax1.legend(frameon=False)
    ax1.text2D(-0.08, 1.02, "(a) 螺旋爬升轨迹", transform=ax1.transAxes, fontweight="bold")

    pid_spiral = source[(source["case_id"] == "Scene02") & (source["controller"] == "PID")]
    ax2.plot(pid_spiral["time_s"], pid_spiral["position_error_m"], color=CHARCOAL, linestyle="--", linewidth=1.1, label="官方PID")
    ax2.plot(spiral["time"], position_error(spiral), color=TEAL, linewidth=1.4, label=ALGORITHM)
    ax2.set_xlabel("时间 / s")
    ax2.set_ylabel("三维位置误差 / m")
    clean_axis(ax2, grid="both")
    label_panel(ax2, "(b) 螺旋爬升位置误差")

    ax3.plot(eight["referenceVector[1]"], eight["referenceVector[2]"], color=CHARCOAL, linestyle="--", linewidth=1.0, label="参考")
    ax3.plot(eight["quadChassisTest17_1.body.r_0[1]"], eight["quadChassisTest17_1.body.r_0[2]"], color=TEAL, linewidth=1.4, label=ALGORITHM)
    ax3.set_xlabel("X / m")
    ax3.set_ylabel("Y / m")
    ax3.set_aspect("equal", adjustable="box")
    clean_axis(ax3, grid="both")
    label_panel(ax3, "(c) 8字轨迹平面投影")

    pid_eight = source[(source["case_id"] == "Scene03") & (source["controller"] == "PID")]
    ax4.plot(pid_eight["time_s"], pid_eight["position_error_m"], color=CHARCOAL, linestyle="--", linewidth=1.1, label="官方PID")
    ax4.plot(eight["time"], position_error(eight), color=TEAL, linewidth=1.4, label=ALGORITHM)
    ax4.set_xlabel("时间 / s")
    ax4.set_ylabel("三维位置误差 / m")
    clean_axis(ax4, grid="both")
    label_panel(ax4, "(d) 8字轨迹位置误差")
    ax4.legend(frameon=False)
    fig.subplots_adjust(hspace=0.34, wspace=0.24)
    save_figure(fig, path)


def build_common_metrics(paths: Paths) -> pd.DataFrame:
    source = read_csv(paths.root / "05_visuals" / "assets" / "report_sources" / "data" / "FIG_6-4__figure_6_4_five_controller_common.csv")
    source = source[(source["controller"] != "RA-GCA-CGHTE") & (source["controller"] != ALGORITHM)].copy()
    pid_scene06b = read_csv(paths.pid_scene06b_source)
    pid_reference = pid_scene06b[["reference_x_m", "reference_y_m", "reference_z_m"]].to_numpy(float)
    pid_position = pid_scene06b[["position_x_m", "position_y_m", "position_z_m"]].to_numpy(float)
    pid_scene06b_rmse = float(np.sqrt(np.mean(np.linalg.norm(pid_position - pid_reference, axis=1) ** 2)))
    pid_mask = (source["case_id"] == "Scene06b") & (source["controller"] == "PID")
    source.loc[pid_mask, "tracking_rmse_m"] = pid_scene06b_rmse
    source.loc[pid_mask, "evidence_basis"] = "official_pid_direct"
    source.loc[pid_mask, "source_reference"] = "04_results/report_evidence/official_pid_scene06b/raw.csv"
    final_cases = {"Scene01": "分段爬升", "Scene04": "定点悬停", "Scene03": "8字轨迹跟踪", "Scene06b": "三事件外力扰动"}
    additions = []
    for case_id, scene_zh in final_cases.items():
        df = final_raw(paths, case_id)
        additions.append(
            {
                "case_id": case_id,
                "scene_zh": scene_zh,
                "controller": ALGORITHM,
                "tracking_rmse_m": position_rmse(df),
                "peak_m": float(position_error(df).max()),
                "evidence_basis": "final_algorithm_direct",
                "source_reference": f"06_supplementary_evidence/ardg_rgpc_regression18_final/raw/{case_id}.csv",
            }
        )
    result = pd.concat([source, pd.DataFrame(additions)], ignore_index=True)
    if result.duplicated(["case_id", "controller"]).any():
        raise RuntimeError("Duplicate case/controller rows remain in common metrics")
    controller_order = ["PID", "RA-GCA/Base", ALGORITHM, "CAP-ADRC", "CP-INDI"]
    result["controller"] = pd.Categorical(result["controller"], controller_order, ordered=True)
    return result.sort_values(["case_id", "controller"]).reset_index(drop=True)


def build_figure_6_4(common: pd.DataFrame, path: Path) -> None:
    cases = [("Scene01", "分段爬升"), ("Scene04", "定点悬停"), ("Scene03", "8字轨迹"), ("Scene06b", "三事件外力扰动")]
    palette = {"PID": CHARCOAL, "RA-GCA/Base": GRAY, ALGORITHM: TEAL, "CAP-ADRC": GREEN, "CP-INDI": PURPLE}
    markers = {"PID": "o", "RA-GCA/Base": "s", ALGORITHM: "o", "CAP-ADRC": "^", "CP-INDI": "P"}
    fig, axes = plt.subplots(2, 2, figsize=(12.4, 7.2))
    for index, (ax, (case_id, scene)) in enumerate(zip(axes.flat, cases)):
        subset = common[common["case_id"] == case_id].sort_values("controller")
        y = np.arange(len(subset))
        for row, ypos in zip(subset.itertuples(), y):
            controller = str(row.controller)
            ax.scatter(row.tracking_rmse_m, ypos, s=44 if controller == ALGORITHM else 34, color=palette[controller], marker=markers[controller], zorder=3)
            ax.text(row.tracking_rmse_m, ypos, f"  {row.tracking_rmse_m:.4f}", va="center", fontsize=8)
        controller_labels = [PUBLIC_DISPLAY_NAMES.get(str(item), str(item)) for item in subset["controller"]]
        ax.set_yticks(y, controller_labels)
        ax.set_xlabel("三维位置RMSE / m")
        clean_axis(ax, grid="x")
        label_panel(ax, f"({chr(97 + index)}) {scene}")
        ax.invert_yaxis()
    fig.subplots_adjust(hspace=0.36, wspace=0.36)
    save_figure(fig, path)


def public_parameter_data(paths: Paths) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    p11 = read_csv(paths.root / "04_results" / "report_evidence" / "parameter11_ardg_rgpc_final" / "parameter11_final_paired.csv")
    p11_rename = {
        "reference_baseline_position_rmse_m": "geometric_baseline_position_rmse_m",
        "ardg_position_rmse_m": "ardg_rgpc_position_rmse_m",
        "ardg_vs_reference_baseline_rmse_reduction_percent": "ardg_rgpc_vs_geometric_baseline_reduction_percent",
        "classification_vs_reference_baseline": "classification_vs_geometric_baseline",
    }
    if set(p11_rename).issubset(p11.columns):
        p11 = p11.rename(columns=p11_rename)
    p11_columns = [
        "case_id", "geometric_baseline_position_rmse_m", "ardg_rgpc_position_rmse_m",
        "ardg_rgpc_vs_geometric_baseline_reduction_percent", "classification_vs_geometric_baseline",
        "raw_rows", "raw_sha256", "diagnostic_sha256",
    ]
    missing_p11 = [column for column in p11_columns if column not in p11.columns]
    if missing_p11:
        raise KeyError(f"Parameter11 public columns missing: {missing_p11}")
    p11_public = p11[p11_columns].copy()
    random20 = read_csv(paths.root / "04_results" / "report_evidence" / "parameter_random20_ardg_rgpc_final" / "paired_results.csv")
    random_rename = {"ardg_rmse_m": "ardg_rgpc_rmse_m", "ardg_beats_pid": "ardg_rgpc_beats_pid"}
    if set(random_rename).issubset(random20.columns):
        random20 = random20.rename(columns=random_rename)
    random_columns = [
        "case_id", "lift_scale", "mass_scale", "inertia_scale", "pid_rmse_m",
        "ardg_rgpc_rmse_m", "ardg_vs_pid_reduction_percent", "ardg_rgpc_beats_pid",
    ]
    missing_random = [column for column in random_columns if column not in random20.columns]
    if missing_random:
        raise KeyError(f"Random20 public columns missing: {missing_random}")
    random_public = random20[random_columns].copy()
    stat = pd.DataFrame(
        [
            ["sample_count", 20],
            ["ardg_rgpc_wins", 20],
            ["official_pid_wins", 0],
            ["ties", 0],
            ["median_reduction_percent", float(random_public["ardg_vs_pid_reduction_percent"].median())],
            ["mean_reduction_percent", float(random_public["ardg_vs_pid_reduction_percent"].mean())],
            ["minimum_reduction_percent", float(random_public["ardg_vs_pid_reduction_percent"].min())],
            ["maximum_reduction_percent", float(random_public["ardg_vs_pid_reduction_percent"].max())],
            ["bootstrap_ci_low_percent", 83.7408486007854],
            ["bootstrap_ci_high_percent", 90.18645642154547],
            ["sign_test_p_two_sided", 1.9073486328125e-06],
        ],
        columns=["metric", "value"],
    )
    return p11_public, random_public, stat


def build_figure_6_6(p11: pd.DataFrame, random20: pd.DataFrame, path: Path) -> None:
    fig, axes = plt.subplots(1, 3, figsize=(12.8, 4.6), gridspec_kw={"width_ratios": [1.35, 1.10, 1.0]})
    ax = axes[0]
    labels = [item.replace("Scene05B_", "") for item in p11["case_id"]]
    values = p11["ardg_rgpc_vs_geometric_baseline_reduction_percent"].to_numpy(float)
    classifications = p11["classification_vs_geometric_baseline"].astype(str).to_numpy()
    colors = [TEAL if classification == "improved" else GRAY for classification in classifications]
    bars = ax.barh(np.arange(len(labels)), values, color=colors)
    ax.set_yticks(np.arange(len(labels)), labels)
    ax.set_xlabel("相对几何基线RMSE降幅 / %")
    ax.set_xlim(-2.0, max(102.0, float(np.max(values)) + 6.0))
    ax.invert_yaxis()
    clean_axis(ax, grid="x")
    label_panel(ax, "(a) 11项预设参数工况")
    for bar, value, classification in zip(bars, values, classifications):
        y = bar.get_y() + bar.get_height() / 2
        if classification == "improved":
            ax.text(value + 1.2, y, f"{value:.1f}%", va="center", fontsize=7.4, color=CHARCOAL)
        else:
            ax.scatter([0.0], [y], marker="|", s=68, linewidths=1.5, color=GRAY, zorder=4)
            ax.text(1.2, y, "等效", va="center", fontsize=7.4, color=GRAY)

    ax = axes[1]
    parts = ax.violinplot(random20["ardg_vs_pid_reduction_percent"], showextrema=True, showmedians=True)
    for body in parts["bodies"]:
        body.set_facecolor(TEAL)
        body.set_edgecolor(TEAL_DARK)
        body.set_alpha(0.35)
    ax.scatter(np.ones(len(random20)), random20["ardg_vs_pid_reduction_percent"], color=TEAL_DARK, s=16, alpha=0.9)
    median = float(random20["ardg_vs_pid_reduction_percent"].median())
    ax.axhline(median, color=AMBER, linestyle="--", linewidth=1.1)
    ax.text(1.03, median, f"中位数 {median:.2f}%", va="center", fontsize=8.2, color=AMBER)
    ax.set_xticks([1], ["ARDG-RGPC\n相对官方PID"])
    ax.set_ylabel("三维位置RMSE降幅 / %")
    clean_axis(ax)
    label_panel(ax, "(b) 20组随机参数")

    ax = axes[2]
    counts = [int((p11["classification_vs_geometric_baseline"] == "improved").sum()), int((p11["classification_vs_geometric_baseline"] == "equivalent").sum()), 20, 0]
    names = ["预设参数改善", "预设参数等效", "随机参数胜官方PID", "随机参数负官方PID"]
    count_bars = ax.barh(np.arange(4), counts, color=[TEAL, GRAY, GREEN, RED])
    ax.set_yticks(np.arange(4), names)
    ax.set_xlabel("工况数")
    ax.set_xlim(0, 22.5)
    ax.invert_yaxis()
    clean_axis(ax, grid="x")
    label_panel(ax, "(c) 结果计数")
    ax.bar_label(count_bars, fmt="%d", padding=3, fontsize=8.2)
    fig.subplots_adjust(wspace=0.40)
    save_figure(fig, path)


def build_angular_diagnostic(paths: Paths, path: Path) -> dict[str, float]:
    data_dir = paths.root / "05_visuals" / "final_shared_assets" / "data"
    cases = [
        ("BODY_ROLL_POS", "正滚转冲击", "angle_roll_rad", "ardg_residual_tau_x_nm", "ardg_correction_x_nm"),
        ("BODY_PITCH_NEG", "负俯仰冲击", "angle_pitch_rad", "ardg_residual_tau_y_nm", "ardg_correction_y_nm"),
    ]
    fig, axes = plt.subplots(3, 2, figsize=(12.4, 7.2), sharex="col")
    metrics: dict[str, float] = {}
    for col, (case_id, title, angle_col, residual_col, correction_col) in enumerate(cases):
        raw = read_csv(data_dir / f"{case_id}_ARDG-RGPC.csv")
        pid = read_csv(paths.pid_angular_source / case_id / "raw.csv")
        diag = read_csv(data_dir / f"{case_id}_ARDG-RGPC_diagnostics.csv")
        mask = (raw["time_s"] >= 7.8) & (raw["time_s"] <= 12.3)
        pid_mask = (pid["time_s"] >= 7.8) & (pid["time_s"] <= 12.3)
        dmask = (diag["time_s"] >= 7.8) & (diag["time_s"] <= 12.3)
        t = raw.loc[mask, "time_s"]
        tp = pid.loc[pid_mask, "time_s"]
        td = diag.loc[dmask, "time_s"]
        axes[0, col].plot(tp, np.degrees(pid.loc[pid_mask, angle_col]), color=CHARCOAL, linestyle="--", linewidth=1.2, label="官方PID")
        axes[0, col].plot(t, np.degrees(raw.loc[mask, angle_col]), color=TEAL, linewidth=1.5, label=ALGORITHM)
        axes[0, col].axvspan(8.0, 8.25, color=AMBER, alpha=0.15)
        axes[0, col].set_ylabel("姿态角 / °")
        clean_axis(axes[0, col], grid="both")
        label_panel(axes[0, col], f"({'a' if col == 0 else 'b'}) {title}")
        if col == 0:
            axes[0, col].legend(frameon=False, ncol=2)

        axes[1, col].plot(td, diag.loc[dmask, residual_col] * 1e6, color=CHARCOAL, linewidth=1.1, label="角残差")
        axes[1, col].plot(td, diag.loc[dmask, correction_col] * 1e6, color=GREEN, linewidth=1.4, label="补偿力矩")
        axes[1, col].axvspan(8.0, 8.25, color=AMBER, alpha=0.15)
        axes[1, col].set_ylabel("力矩 / μN·m")
        clean_axis(axes[1, col], grid="both")
        if col == 0:
            axes[1, col].legend(frameon=False, ncol=2)

        axes[2, col].plot(td, diag.loc[dmask, "ardg_blend"], color=GREEN, linewidth=1.4, label="融合系数")
        axes[2, col].step(td, diag.loc[dmask, "ardg_active"], where="post", color=TEAL_DARK, linewidth=1.0, label="激活")
        axes[2, col].step(td, diag.loc[dmask, "ardg_safety_valid"], where="post", color=BLUE, linewidth=1.0, linestyle="--", label="安全有效")
        axes[2, col].set_ylim(-0.05, 1.08)
        axes[2, col].set_xlabel("时间 / s")
        axes[2, col].set_ylabel("状态")
        clean_axis(axes[2, col], grid="both")
        if col == 0:
            axes[2, col].legend(frameon=False, ncol=3)
        event = (raw["time_s"] >= 8.0) & (raw["time_s"] <= 12.25)
        pid_event = (pid["time_s"] >= 8.0) & (pid["time_s"] <= 12.25)
        final_attitude = np.hypot(raw.loc[event, "angle_roll_rad"], raw.loc[event, "angle_pitch_rad"])
        pid_attitude = np.hypot(pid.loc[pid_event, "angle_roll_rad"], pid.loc[pid_event, "angle_pitch_rad"])
        final_position_error = np.linalg.norm(raw.loc[event, ["position_x_m", "position_y_m", "position_z_m"]].to_numpy(float) - raw.loc[event, ["reference_1", "reference_2", "reference_3"]].to_numpy(float), axis=1)
        pid_position_error = np.linalg.norm(pid.loc[pid_event, ["position_x_m", "position_y_m", "position_z_m"]].to_numpy(float) - pid.loc[pid_event, ["reference_1", "reference_2", "reference_3"]].to_numpy(float), axis=1)
        motor_columns = [f"motor_command_{index}" for index in range(1, 5)]
        final_motor_tv = float(np.abs(np.diff(raw.loc[event, motor_columns].to_numpy(float), axis=0)).sum())
        pid_motor_tv = float(np.abs(np.diff(pid.loc[pid_event, motor_columns].to_numpy(float), axis=0)).sum())
        final_iae = float(np.trapezoid(final_attitude, raw.loc[event, "time_s"]))
        pid_iae = float(np.trapezoid(pid_attitude, pid.loc[pid_event, "time_s"]))
        metrics[f"{case_id}_ardg_rgpc_event_iae_rad_s"] = final_iae
        metrics[f"{case_id}_official_pid_event_iae_rad_s"] = pid_iae
        metrics[f"{case_id}_ardg_rgpc_peak_attitude_error_rad"] = float(final_attitude.max())
        metrics[f"{case_id}_official_pid_peak_attitude_error_rad"] = float(pid_attitude.max())
        metrics[f"{case_id}_ardg_rgpc_position_rmse_m"] = float(np.sqrt(np.mean(final_position_error**2)))
        metrics[f"{case_id}_official_pid_position_rmse_m"] = float(np.sqrt(np.mean(pid_position_error**2)))
        metrics[f"{case_id}_ardg_rgpc_motor_tv"] = final_motor_tv
        metrics[f"{case_id}_official_pid_motor_tv"] = pid_motor_tv
        metrics[f"{case_id}_motor_tv_reduction_percent"] = 100.0 * (pid_motor_tv - final_motor_tv) / pid_motor_tv
        metrics[f"{case_id}_attitude_iae_change_percent"] = 100.0 * (final_iae - pid_iae) / pid_iae
    metrics["average_official_pid_event_iae_rad_s"] = float(np.mean([metrics[f"{case_id}_official_pid_event_iae_rad_s"] for case_id, *_ in cases]))
    metrics["average_ardg_rgpc_event_iae_rad_s"] = float(np.mean([metrics[f"{case_id}_ardg_rgpc_event_iae_rad_s"] for case_id, *_ in cases]))
    metrics["average_official_pid_motor_tv"] = float(np.mean([metrics[f"{case_id}_official_pid_motor_tv"] for case_id, *_ in cases]))
    metrics["average_ardg_rgpc_motor_tv"] = float(np.mean([metrics[f"{case_id}_ardg_rgpc_motor_tv"] for case_id, *_ in cases]))
    metrics["average_motor_tv_reduction_percent"] = 100.0 * (metrics["average_official_pid_motor_tv"] - metrics["average_ardg_rgpc_motor_tv"]) / metrics["average_official_pid_motor_tv"]
    fig.subplots_adjust(hspace=0.18, wspace=0.24)
    save_figure(fig, path)
    return metrics


def compound_metrics(paths: Paths) -> pd.DataFrame:
    metrics = read_csv(paths.compound_source / "evaluation" / "compound_metrics.csv")
    expected = {f"D_C{index:02d}" for index in range(1, 7)}
    if set(metrics["case_id"].astype(str)) != expected:
        raise RuntimeError("Compound-stress case set is incomplete")
    if not metrics["all_physical_pass"].astype(str).str.lower().eq("true").all():
        raise RuntimeError("Compound-stress physical checks did not all pass")
    return metrics.sort_values("case_id").reset_index(drop=True)


def build_figure_d2(compound: pd.DataFrame, path: Path) -> None:
    labels = compound["case_id"].astype(str).to_list()
    x = np.arange(len(labels))
    fig, axes = plt.subplots(1, 2, figsize=(12.6, 4.6))
    width = 0.38
    rmse_bars = axes[0].bar(x - width / 2, compound["tracking_rmse_m"], width, color=TEAL, label="位置RMSE")
    peak_bars = axes[0].bar(x + width / 2, compound["tracking_peak_m"], width, color=GRAY, label="峰值位置误差")
    axes[0].set_xticks(x, labels)
    axes[0].set_ylabel("位置误差 / m")
    axes[0].legend(frameon=False, ncol=2)
    clean_axis(axes[0])
    label_panel(axes[0], "(a) 六组复合参数与外扰响应")
    axes[0].bar_label(rmse_bars, fmt="%.3f", padding=2, fontsize=7.4)
    axes[0].bar_label(peak_bars, fmt="%.3f", padding=2, fontsize=7.4)
    recovery_bars = axes[1].bar(x, compound["disturbance_recovery_s"], color=GREEN, width=0.58)
    axes[1].set_xticks(x, labels)
    axes[1].set_ylabel("末次扰动恢复时间 / s")
    clean_axis(axes[1])
    label_panel(axes[1], "(b) 恢复时间与守卫介入比例")
    axes[1].bar_label(recovery_bars, fmt="%.2f", padding=2, fontsize=7.8)
    active_axis = axes[1].twinx()
    active_axis.plot(x, 100.0 * compound["ardg_active_fraction"].to_numpy(float), color=AMBER, marker="o", linewidth=1.4, label="ARDG介入比例")
    active_axis.set_ylabel("ARDG介入比例 / %")
    active_axis.set_ylim(0.0, 15.0)
    active_axis.spines["top"].set_visible(False)
    active_axis.legend(frameon=False, loc="upper right")
    fig.subplots_adjust(wspace=0.34)
    save_figure(fig, path)


def build_scene06b(paths: Paths, path: Path) -> dict[str, float]:
    final_full = final_raw(paths, "Scene06b")
    pid_full = read_csv(paths.pid_scene06b_source)
    final_error_full = position_error(final_full)
    required_pid_columns = [
        "time_s",
        "reference_x_m",
        "reference_y_m",
        "reference_z_m",
        "position_x_m",
        "position_y_m",
        "position_z_m",
    ]
    missing_pid_columns = [column for column in required_pid_columns if column not in pid_full.columns]
    if missing_pid_columns:
        raise KeyError(f"Official PID Scene06b columns missing: {missing_pid_columns}")
    pid_reference = pid_full[["reference_x_m", "reference_y_m", "reference_z_m"]].to_numpy(float)
    pid_position = pid_full[["position_x_m", "position_y_m", "position_z_m"]].to_numpy(float)
    pid_error_full = np.linalg.norm(pid_position - pid_reference, axis=1)
    final_rmse = float(np.sqrt(np.mean(final_error_full**2)))
    pid_rmse = float(np.sqrt(np.mean(pid_error_full**2)))
    reduction = 100.0 * (1.0 - final_rmse / pid_rmse)
    final_indices = np.linspace(0, len(final_full) - 1, min(1600, len(final_full)), dtype=int)
    pid_indices = np.linspace(0, len(pid_full) - 1, min(1600, len(pid_full)), dtype=int)
    final = final_full.iloc[final_indices]
    pid = pid_full.iloc[pid_indices]
    final_error = final_error_full[final_indices]
    pid_error = pid_error_full[pid_indices]
    fig, axes = plt.subplots(2, 1, figsize=(12.2, 6.0), gridspec_kw={"height_ratios": [2.2, 1.0]})
    axes[0].plot(pid["time_s"], pid_error, color=CHARCOAL, linestyle="--", linewidth=1.2, label=f"官方PID  RMSE={pid_rmse:.4f} m")
    axes[0].plot(final["time"], final_error, color=TEAL, linewidth=1.5, label=f"{ALGORITHM}  RMSE={final_rmse:.4f} m")
    for start, end in ((8.0, 8.5), (14.0, 15.0), (20.0, 22.0)):
        axes[0].axvspan(start, end, color=AMBER, alpha=0.14)
    axes[0].set_ylabel("三维位置误差 / m")
    axes[0].legend(frameon=False, ncol=2)
    clean_axis(axes[0], grid="both")
    label_panel(axes[0], "(a) 三事件外力扰动位置误差")

    axes[1].bar([0, 1], [pid_rmse, final_rmse], color=[CHARCOAL, TEAL], width=0.55)
    axes[1].set_xticks([0, 1], ["官方PID", ALGORITHM])
    axes[1].set_xlim(-0.75, 1.75)
    axes[1].set_ylabel("RMSE / m")
    axes[1].text(0.5, max(pid_rmse, final_rmse) * 0.82, f"降低 {reduction:.2f}%", ha="center", color=GREEN, fontweight="bold")
    clean_axis(axes[1])
    label_panel(axes[1], "(b) 全时域RMSE")
    for bars in axes[1].containers:
        axes[1].bar_label(bars, fmt="%.4f", padding=3, fontsize=8.4)
    fig.subplots_adjust(hspace=0.24)
    save_figure(fig, path)
    return {"ardg_rgpc_rmse_m": final_rmse, "official_pid_rmse_m": pid_rmse, "reduction_percent": reduction}


def build_environment(paths: Paths, path: Path) -> dict[str, float]:
    wind = []
    sensor = []
    for i in range(5):
        wind.append(position_rmse(final_raw(paths, f"Scene08_P{i}")))
        sensor.append(position_rmse(final_raw(paths, f"Scene10_P{i}")))
    fig, axes = plt.subplots(1, 2, figsize=(12.0, 4.4))
    for index, (ax, values, label) in enumerate(((axes[0], wind, "五相位风扰"), (axes[1], sensor, "五相位传感器退化"))):
        ax.plot(np.arange(5), values, color=TEAL, marker="o", linewidth=1.5)
        ax.axhline(np.mean(values), color=CHARCOAL, linestyle="--", linewidth=1.0, label=f"均值 {np.mean(values):.7f} m")
        ax.set_xticks(np.arange(5), [f"P{i}" for i in range(5)])
        ax.set_xlabel("相位")
        ax.set_ylabel("三维位置RMSE / m")
        clean_axis(ax, grid="both")
        label_panel(ax, f"({chr(97 + index)}) {label}")
        ax.legend(frameon=False)
    fig.subplots_adjust(wspace=0.26)
    save_figure(fig, path)
    return {
        "wind_mean_rmse_m": float(np.mean(wind)),
        "wind_std_rmse_m": float(np.std(wind, ddof=0)),
        "sensor_mean_rmse_m": float(np.mean(sensor)),
        "sensor_std_rmse_m": float(np.std(sensor, ddof=0)),
    }


def formation_data(path: Path) -> dict[str, object]:
    df = read_csv(path)
    vehicles = []
    desired = []
    for vehicle, start in zip((1, 2, 3), (1, 10, 19)):
        vehicles.append(df[[f"quad{vehicle}.body.r_0[{axis}]" for axis in (1, 2, 3)]].to_numpy(float))
        desired.append(df[[f"formationReference[{start + axis - 1}]" for axis in (1, 2, 3)]].to_numpy(float))
    distances = []
    for row in range(len(df)):
        values = [np.linalg.norm(vehicles[a][row] - vehicles[b][row]) for a, b in ((0, 1), (0, 2), (1, 2))]
        distances.append(min(values))
    errors = []
    for row in range(len(df)):
        errors.append(math.sqrt(sum(np.linalg.norm(vehicles[i][row] - desired[i][row]) ** 2 for i in range(3)) / 3.0))
    time = df["time"].to_numpy(float)
    dt = float(np.median(np.diff(time)))
    return {
        "df": df,
        "time": time,
        "vehicles": vehicles,
        "desired": desired,
        "distance": np.asarray(distances),
        "formation_error": np.asarray(errors),
        "rmse": float(np.sqrt(np.mean(np.asarray(errors) ** 2))),
        "minimum": float(np.min(distances)),
        "violation_seconds": float(np.sum(np.asarray(distances) < SAFETY_DISTANCE_M) * dt),
    }


def build_formation_figures(paths: Paths, figure_7_1: Path, figure_7_2: Path) -> dict[str, float]:
    scene_b = formation_data(paths.formation_source / "Scene07B.csv")
    scene_off = formation_data(paths.formation_source / "Scene07COff.csv")
    scene_on = formation_data(paths.formation_source / "Scene07COnPredictiveV5C.csv")

    fig, axes = plt.subplots(2, 2, figsize=(12.4, 7.2))
    colors = [BLUE, "#DD6B20", GREEN]
    for i, vehicle in enumerate(scene_b["vehicles"]):
        axes[0, 0].plot(vehicle[:, 0], vehicle[:, 1], color=colors[i], linewidth=1.4, label=f"无人机{i+1}")
    axes[0, 0].set_xlabel("X / m")
    axes[0, 0].set_ylabel("Y / m")
    axes[0, 0].set_aspect("equal", adjustable="box")
    clean_axis(axes[0, 0], grid="both")
    axes[0, 0].legend(frameon=False, ncol=3)
    label_panel(axes[0, 0], "(a) 三机队形变换轨迹")

    axes[0, 1].plot(scene_b["time"], scene_b["formation_error"], color=TEAL, linewidth=1.4)
    axes[0, 1].set_xlabel("时间 / s")
    axes[0, 1].set_ylabel("队形误差 / m")
    clean_axis(axes[0, 1], grid="both")
    label_panel(axes[0, 1], "(b) 相对队形误差")

    axes[1, 0].plot(scene_b["time"], scene_b["distance"], color=TEAL_DARK, linewidth=1.4)
    axes[1, 0].axhline(SAFETY_DISTANCE_M, color=RED, linestyle="--", linewidth=1.0, label="安全距离 0.60 m")
    axes[1, 0].set_xlabel("时间 / s")
    axes[1, 0].set_ylabel("最近机间距 / m")
    clean_axis(axes[1, 0], grid="both")
    axes[1, 0].legend(frameon=False)
    label_panel(axes[1, 0], "(c) 最近机间距")

    member_rmse = []
    for vehicle, desired in zip(scene_b["vehicles"], scene_b["desired"]):
        member_rmse.append(float(np.sqrt(np.mean(np.sum((vehicle - desired) ** 2, axis=1)))))
    axes[1, 1].bar(np.arange(3), member_rmse, color=colors)
    axes[1, 1].set_xticks(np.arange(3), ["无人机1", "无人机2", "无人机3"])
    axes[1, 1].set_ylabel("成员位置RMSE / m")
    clean_axis(axes[1, 1])
    label_panel(axes[1, 1], "(d) 成员响应一致性")
    for bars in axes[1, 1].containers:
        axes[1, 1].bar_label(bars, fmt="%.4f", padding=2, fontsize=8.2)
    fig.subplots_adjust(hspace=0.34, wspace=0.26)
    save_figure(fig, figure_7_1)

    fig, axes = plt.subplots(2, 1, figsize=(12.2, 6.0), gridspec_kw={"height_ratios": [2.0, 1.0]})
    axes[0].plot(scene_off["time"], scene_off["distance"], color=RED, linestyle="--", linewidth=1.3, label=f"PP-CBF关闭  最小{scene_off['minimum']:.3f} m")
    axes[0].plot(scene_on["time"], scene_on["distance"], color=TEAL, linewidth=1.5, label=f"PP-CBF开启  最小{scene_on['minimum']:.3f} m")
    axes[0].axhline(SAFETY_DISTANCE_M, color=CHARCOAL, linestyle=":", linewidth=1.0, label="安全距离 0.60 m")
    axes[0].set_ylabel("最近机间距 / m")
    axes[0].legend(frameon=False, ncol=3)
    clean_axis(axes[0], grid="both")
    label_panel(axes[0], "(a) 近距离交汇的最小机间距")

    axes[1].bar([0, 1], [scene_off["violation_seconds"], scene_on["violation_seconds"]], color=[RED, TEAL], width=0.55)
    axes[1].set_xticks([0, 1], ["PP-CBF关闭", "PP-CBF开启"])
    axes[1].set_xlim(-0.75, 1.75)
    axes[1].set_ylabel("低于0.60 m时间 / s")
    clean_axis(axes[1])
    label_panel(axes[1], "(b) 风险暴露时间")
    for bars in axes[1].containers:
        axes[1].bar_label(bars, fmt="%.2f", padding=3, fontsize=8.4)
    fig.subplots_adjust(hspace=0.24)
    save_figure(fig, figure_7_2)
    return {
        "scene07b_formation_rmse_m": scene_b["rmse"],
        "scene07b_minimum_distance_m": scene_b["minimum"],
        "scene07coff_minimum_distance_m": scene_off["minimum"],
        "scene07con_minimum_distance_m": scene_on["minimum"],
        "scene07coff_violation_seconds": scene_off["violation_seconds"],
        "scene07con_violation_seconds": scene_on["violation_seconds"],
    }


def build_figure_8_1(
    common: pd.DataFrame,
    p11: pd.DataFrame,
    random20: pd.DataFrame,
    angular: dict[str, float],
    scene06b: dict[str, float],
    compound: pd.DataFrame,
    path: Path,
) -> None:
    fig, axes = plt.subplots(2, 2, figsize=(12.4, 7.2))
    scene = common[common["case_id"] == "Scene06b"].copy().sort_values("tracking_rmse_m")
    colors = [TEAL if str(item) == ALGORITHM else CHARCOAL if str(item) == "PID" else GRAY for item in scene["controller"]]
    axes[0, 0].barh(np.arange(len(scene)), scene["tracking_rmse_m"], color=colors)
    controller_labels = [PUBLIC_DISPLAY_NAMES.get(str(item), str(item)) for item in scene["controller"]]
    axes[0, 0].set_yticks(np.arange(len(scene)), controller_labels)
    axes[0, 0].set_xlabel("三事件外力扰动RMSE / m")
    axes[0, 0].invert_yaxis()
    clean_axis(axes[0, 0], grid="x")
    label_panel(axes[0, 0], "(a) 复杂外扰下的算法比较")

    evidence_counts = [
        int((p11["classification_vs_geometric_baseline"] == "improved").sum()),
        int((random20["ardg_vs_pid_reduction_percent"] > 0.0).sum()),
        10,
        int(len(compound)),
    ]
    axes[0, 1].bar([0, 1, 2, 3], evidence_counts, color=[TEAL, GREEN, BLUE, AMBER])
    axes[0, 1].set_xticks(
        [0, 1, 2, 3],
        ["预设参数\n改善", "随机参数\n胜官方PID", "环境退化\n有效相位", "复合应力\n物理检查通过"],
    )
    axes[0, 1].set_ylabel("工况数")
    clean_axis(axes[0, 1])
    label_panel(axes[0, 1], "(b) 鲁棒性与泛化证据")
    for bars in axes[0, 1].containers:
        axes[0, 1].bar_label(bars, padding=2, fontsize=8.3)

    ratios = [
        100.0 * angular["average_ardg_rgpc_event_iae_rad_s"] / angular["average_official_pid_event_iae_rad_s"],
        100.0 * angular["average_ardg_rgpc_motor_tv"] / angular["average_official_pid_motor_tv"],
    ]
    tradeoff_bars = axes[1, 0].bar([0, 1], ratios, color=[RED, TEAL], width=0.58)
    axes[1, 0].axhline(100.0, color=CHARCOAL, linestyle="--", linewidth=1.0, label="官方PID = 100%")
    axes[1, 0].set_xticks([0, 1], ["姿态事件IAE\n越低越好", "电机TV\n越低越好"])
    axes[1, 0].set_ylabel("ARDG-RGPC / 官方PID / %")
    axes[1, 0].set_ylim(0.0, max(430.0, max(ratios) + 35.0))
    clean_axis(axes[1, 0])
    axes[1, 0].legend(frameon=False, loc="upper right")
    label_panel(axes[1, 0], "(c) 角扰动下的客观性能取舍")
    axes[1, 0].bar_label(tradeoff_bars, fmt="%.1f%%", padding=2, fontsize=8.2)

    median = float(random20["ardg_vs_pid_reduction_percent"].median())
    values = [median, scene06b["reduction_percent"]]
    axes[1, 1].bar([0, 1], values, color=[GREEN, TEAL])
    axes[1, 1].set_xticks([0, 1], ["随机参数20组\nRMSE中位降幅", "三事件外扰\nRMSE降幅"])
    axes[1, 1].set_ylabel("相对官方PID降幅 / %")
    clean_axis(axes[1, 1])
    label_panel(axes[1, 1], "(d) 相对官方PID的代表性收益")
    for bars in axes[1, 1].containers:
        axes[1, 1].bar_label(bars, fmt="%.2f%%", padding=2, fontsize=8.3)
    fig.subplots_adjust(hspace=0.36, wspace=0.34)
    save_figure(fig, path)


def build_figure_d1(p11: pd.DataFrame, random20: pd.DataFrame, environment: dict[str, float], path: Path) -> None:
    fig, axes = plt.subplots(1, 3, figsize=(12.8, 4.6), gridspec_kw={"width_ratios": [1.25, 1.0, 1.0]})
    p11_sorted = p11.sort_values("ardg_rgpc_vs_geometric_baseline_reduction_percent")
    values = p11_sorted["ardg_rgpc_vs_geometric_baseline_reduction_percent"].to_numpy(float)
    classifications = p11_sorted["classification_vs_geometric_baseline"].astype(str).to_numpy()
    colors = [TEAL if classification == "improved" else GRAY for classification in classifications]
    bars = axes[0].barh(np.arange(len(p11_sorted)), values, color=colors)
    axes[0].set_yticks(np.arange(len(p11_sorted)), [item.replace("Scene05B_", "") for item in p11_sorted["case_id"]])
    axes[0].set_xlabel("相对几何基线RMSE降幅 / %")
    axes[0].set_xlim(-2.0, max(102.0, float(np.max(values)) + 6.0))
    clean_axis(axes[0], grid="x")
    label_panel(axes[0], "(a) 最终算法预设参数工况")
    for bar, value, classification in zip(bars, values, classifications):
        y = bar.get_y() + bar.get_height() / 2
        if classification == "improved":
            axes[0].text(value + 1.2, y, f"{value:.1f}%", va="center", fontsize=7.6, color=CHARCOAL)
        else:
            axes[0].scatter([0.0], [y], marker="|", s=72, linewidths=1.6, color=GRAY, zorder=4)
            axes[0].text(1.2, y, "等效", va="center", fontsize=7.6, color=GRAY)

    axes[1].boxplot(random20["ardg_vs_pid_reduction_percent"], widths=0.45, patch_artist=True, boxprops={"facecolor": "#D9F0F0", "edgecolor": TEAL_DARK}, medianprops={"color": AMBER, "linewidth": 1.5})
    axes[1].scatter(np.ones(len(random20)), random20["ardg_vs_pid_reduction_percent"], s=15, color=TEAL_DARK)
    axes[1].set_xticks([1], ["20组随机参数"])
    axes[1].set_ylabel("相对官方PID RMSE降幅 / %")
    clean_axis(axes[1])
    label_panel(axes[1], "(b) 统计性鲁棒性")

    means = [environment["wind_mean_rmse_m"], environment["sensor_mean_rmse_m"]]
    errors = [environment["wind_std_rmse_m"], environment["sensor_std_rmse_m"]]
    environment_bars = axes[2].bar([0, 1], means, yerr=errors, capsize=4, color=[BLUE, GREEN])
    axes[2].set_xticks([0, 1], ["五相位风扰", "五相位传感器退化"])
    axes[2].set_ylabel("三维位置RMSE / m")
    clean_axis(axes[2])
    label_panel(axes[2], "(c) 环境退化稳定性")
    axes[2].bar_label(environment_bars, fmt="%.5f", padding=3, fontsize=8.2)
    fig.subplots_adjust(wspace=0.36)
    save_figure(fig, path)


def copy_evidence(paths: Paths) -> list[dict[str, object]]:
    copied: list[dict[str, object]] = []
    regression_target = Path("06_supplementary_evidence/ardg_rgpc_regression18_final")
    regression_records: dict[str, dict[str, object]] = {}
    for source in sorted((paths.final_regression_source / "raw").glob("*.csv")):
        target = staged(paths, regression_target / "raw" / source.name)
        record = copy_public_csv(source, target)
        regression_records[source.name] = record
        copied.append(
            {
                "path": str((regression_target / "raw" / source.name).as_posix()),
                "sha256": record["public_sha256"],
                "source_sha256": record["source_sha256"],
                "size_bytes": target.stat().st_size,
                "removed_internal_identity_columns": record["removed_internal_identity_columns"],
            }
        )
    status_source = paths.final_regression_source / "execution_status.json"
    status_target = staged(paths, regression_target / "execution_status.json")
    source_status = json.loads(status_source.read_text(encoding="utf-8-sig"))
    public_cases = []
    for case in source_status.get("cases", []):
        raw = case.get("raw") or {}
        filename = f"{case['case']}.csv"
        public_record = regression_records[filename]
        public_cases.append(
            {
                "case_id": case["case"],
                "start_time_s": case.get("start_time_s"),
                "stop_time_s": case.get("stop_time_s"),
                "interval_s": case.get("interval_s"),
                "execution_status": case.get("execution_status"),
                "translate": case.get("translate"),
                "simulate": case.get("simulate"),
                "read_result": case.get("read_result"),
                "raw_file": f"raw/{filename}",
                "source_raw_sha256": raw.get("sha256"),
                "public_raw_sha256": public_record["public_sha256"],
                "rows": public_record["rows"],
                "columns": public_record["columns"],
                "max_abs_motor_command": raw.get("max_abs_motor_command"),
                "allocator_limit_min": raw.get("allocator_limit_min"),
                "allocator_limit_max": raw.get("allocator_limit_max"),
            }
        )
    write_public_json(
        status_target,
        {
            "schema_version": "ardg_rgpc_public_regression18_status_v1",
            "algorithm": ALGORITHM,
            "started_utc": source_status.get("started_utc"),
            "finished_utc": source_status.get("finished_utc"),
            "success": source_status.get("success"),
            "status": source_status.get("status"),
            "scene_count": len(public_cases),
            "selected_cases": source_status.get("selected_cases"),
            "cases": public_cases,
            "source_execution_status_sha256": sha256_file(status_source),
        },
    )
    copied.append(
        {
            "path": str((regression_target / "execution_status.json").as_posix()),
            "sha256": sha256_file(status_target),
            "source_sha256": sha256_file(status_source),
            "size_bytes": status_target.stat().st_size,
        }
    )

    formation_target = Path("06_supplementary_evidence/ardg_rgpc_formation_final/raw")
    for source in sorted(paths.formation_source.glob("Scene07*.csv")):
        target = staged(paths, formation_target / source.name)
        record = copy_public_csv(source, target)
        copied.append(
            {
                "path": str((formation_target / source.name).as_posix()),
                "sha256": record["public_sha256"],
                "source_sha256": record["source_sha256"],
                "size_bytes": target.stat().st_size,
                "removed_internal_identity_columns": record["removed_internal_identity_columns"],
            }
        )
    pid_target = Path("04_results/report_evidence/official_pid_scene06b/raw.csv")
    pid_output = staged(paths, pid_target)
    shutil.copy2(paths.pid_scene06b_source, pid_output)
    copied.append({"path": str(pid_target.as_posix()), "sha256": sha256_file(pid_output), "size_bytes": pid_output.stat().st_size})

    angular_target = Path("04_results/report_evidence/official_pid_angular")
    for case_id in ("BODY_ROLL_POS", "BODY_PITCH_NEG"):
        raw_source = paths.pid_angular_source / case_id / "raw.csv"
        raw_target_path = angular_target / case_id / "raw.csv"
        raw_target = staged(paths, raw_target_path)
        raw_record = copy_public_csv(raw_source, raw_target)
        copied.append({"path": str(raw_target_path.as_posix()), "sha256": raw_record["public_sha256"], "source_sha256": raw_record["source_sha256"], "size_bytes": raw_target.stat().st_size})
        source = paths.pid_angular_source / case_id / "execution_status.json"
        source_status = json.loads(source.read_text(encoding="utf-8-sig"))
        target_path = angular_target / case_id / "execution_status.json"
        target = staged(paths, target_path)
        write_public_json(
            target,
            {
                "schema_version": "official_pid_public_angular_status_v1",
                "case_id": case_id,
                "controller": "官方PID",
                "success": True,
                "simulation": source_status.get("simulation"),
                "disturbance": source_status.get("disturbance"),
                "metrics": source_status.get("metrics"),
                "toolchain": source_status.get("toolchain"),
                "evidence": {
                    "raw_file": "raw.csv",
                    "source_raw_sha256": raw_record["source_sha256"],
                    "public_raw_sha256": raw_record["public_sha256"],
                    "source_execution_status_sha256": sha256_file(source),
                },
            },
        )
        copied.append({"path": str(target_path.as_posix()), "sha256": sha256_file(target), "source_sha256": sha256_file(source), "size_bytes": target.stat().st_size})

    compound_target = Path("06_supplementary_evidence/ardg_rgpc_compound_final")
    metrics_source = paths.compound_source / "evaluation" / "compound_metrics.csv"
    metrics_target_path = compound_target / "evaluation" / "compound_metrics.csv"
    metrics_target = staged(paths, metrics_target_path)
    shutil.copy2(metrics_source, metrics_target)
    copied.append({"path": str(metrics_target_path.as_posix()), "sha256": sha256_file(metrics_target), "source_sha256": sha256_file(metrics_source), "size_bytes": metrics_target.stat().st_size})
    compound_table = read_csv(metrics_source).set_index("case_id")
    compound_public_records: dict[str, dict[str, object]] = {}
    for case_id in ("D_C01", "D_C02", "D_C03", "D_C04", "D_C05", "D_C06"):
        raw_source = paths.compound_source / "cases" / case_id / "raw.csv"
        raw_target_path = compound_target / "cases" / case_id / "raw.csv"
        raw_target = staged(paths, raw_target_path)
        raw_record = copy_public_csv(raw_source, raw_target)
        diag_source = paths.compound_source / "cases" / case_id / "ardg_diagnostics.csv"
        diag_target_path = compound_target / "cases" / case_id / "ardg_diagnostics.csv"
        diag_target = staged(paths, diag_target_path)
        diag_record = copy_public_csv(diag_source, diag_target)
        compound_public_records[case_id] = {"raw": raw_record, "diagnostics": diag_record}
        for target_path, target, record in (
            (raw_target_path, raw_target, raw_record),
            (diag_target_path, diag_target, diag_record),
        ):
            copied.append({"path": str(target_path.as_posix()), "sha256": record["public_sha256"], "source_sha256": record["source_sha256"], "size_bytes": target.stat().st_size, "removed_internal_identity_columns": record["removed_internal_identity_columns"]})
        status_source = paths.compound_source / "cases" / case_id / "execution_status.json"
        source_status = json.loads(status_source.read_text(encoding="utf-8-sig"))
        status_target_path = compound_target / "cases" / case_id / "execution_status.json"
        status_target = staged(paths, status_target_path)
        row = compound_table.loc[case_id]
        write_public_json(
            status_target,
            {
                "schema_version": "ardg_rgpc_public_compound_status_v1",
                "algorithm": ALGORITHM,
                "case_id": case_id,
                "success": source_status.get("success"),
                "started_utc": source_status.get("started_utc"),
                "finished_utc": source_status.get("finished_utc"),
                "simulation": source_status.get("simulation"),
                "metrics": {
                    "tracking_rmse_m": float(row["tracking_rmse_m"]),
                    "tracking_peak_m": float(row["tracking_peak_m"]),
                    "disturbance_event_count": int(row["disturbance_event_count"]),
                    "disturbance_recovery_s": float(row["disturbance_recovery_s"]),
                    "ardg_active_fraction": float(row["ardg_active_fraction"]),
                    "all_physical_pass": bool(row["all_physical_pass"]),
                },
                "evidence": {
                    "raw_file": "raw.csv",
                    "raw_source_sha256": raw_record["source_sha256"],
                    "raw_public_sha256": raw_record["public_sha256"],
                    "diagnostics_file": "ardg_diagnostics.csv",
                    "diagnostics_source_sha256": diag_record["source_sha256"],
                    "diagnostics_public_sha256": diag_record["public_sha256"],
                    "source_execution_status_sha256": sha256_file(status_source),
                },
            },
        )
        copied.append({"path": str(status_target_path.as_posix()), "sha256": sha256_file(status_target), "source_sha256": sha256_file(status_source), "size_bytes": status_target.stat().st_size})
    summary_source = paths.compound_source / "evaluation" / "summary.json"
    summary_target_path = compound_target / "evaluation" / "summary.json"
    summary_target = staged(paths, summary_target_path)
    write_public_json(
        summary_target,
        {
            "schema_version": "ardg_rgpc_public_compound_summary_v1",
            "algorithm": ALGORITHM,
            "case_count": int(len(compound_table)),
            "all_physical_pass": bool(compound_table["all_physical_pass"].astype(str).str.lower().eq("true").all()),
            "tracking_rmse_m": {"min": float(compound_table["tracking_rmse_m"].min()), "max": float(compound_table["tracking_rmse_m"].max())},
            "tracking_peak_m": {"min": float(compound_table["tracking_peak_m"].min()), "max": float(compound_table["tracking_peak_m"].max())},
            "disturbance_recovery_s": {"min": float(compound_table["disturbance_recovery_s"].min()), "max": float(compound_table["disturbance_recovery_s"].max())},
            "ardg_active_fraction": {"min": float(compound_table["ardg_active_fraction"].min()), "max": float(compound_table["ardg_active_fraction"].max())},
            "metrics_file": "compound_metrics.csv",
            "metrics_source_sha256": sha256_file(metrics_source),
            "metrics_public_sha256": sha256_file(metrics_target),
            "source_summary_sha256": sha256_file(summary_source),
        },
    )
    copied.append({"path": str(summary_target_path.as_posix()), "sha256": sha256_file(summary_target), "source_sha256": sha256_file(summary_source), "size_bytes": summary_target.stat().st_size})
    return copied


def write_public_evidence(
    paths: Paths,
    common: pd.DataFrame,
    p11: pd.DataFrame,
    random20: pd.DataFrame,
    stats: pd.DataFrame,
    formation_metrics: dict[str, float],
    scene06b_metrics: dict[str, float],
    angular_metrics: dict[str, float],
    compound: pd.DataFrame,
) -> None:
    p11.to_csv(staged(paths, "04_results/report_evidence/parameter11_ardg_rgpc_final/parameter11_final_paired.csv"), index=False, encoding="utf-8-sig")
    random20.to_csv(staged(paths, "04_results/report_evidence/parameter_random20_ardg_rgpc_final/paired_results.csv"), index=False, encoding="utf-8-sig")
    stats.to_csv(staged(paths, "04_results/report_evidence/parameter_random20_ardg_rgpc_final/statistical_summary.csv"), index=False, encoding="utf-8-sig")
    common.to_csv(staged(paths, "05_visuals/assets/report_sources/data/FIG_6-4__figure_6_4_five_controller_common.csv"), index=False, encoding="utf-8-sig")
    pd.DataFrame(
        [
            {"comparison": "ARDG-RGPC_vs_official_PID", **scene06b_metrics},
        ]
    ).to_csv(staged(paths, "05_visuals/assets/report_sources/data/FIG_6-8__scene06b_pid_comparison.csv"), index=False, encoding="utf-8-sig")
    angular_rows = []
    for case_id in ("BODY_ROLL_POS", "BODY_PITCH_NEG"):
        angular_rows.append(
            {
                "case_id": case_id,
                "official_pid_event_iae_rad_s": angular_metrics[f"{case_id}_official_pid_event_iae_rad_s"],
                "ardg_rgpc_event_iae_rad_s": angular_metrics[f"{case_id}_ardg_rgpc_event_iae_rad_s"],
                "official_pid_peak_attitude_error_rad": angular_metrics[f"{case_id}_official_pid_peak_attitude_error_rad"],
                "ardg_rgpc_peak_attitude_error_rad": angular_metrics[f"{case_id}_ardg_rgpc_peak_attitude_error_rad"],
                "official_pid_position_rmse_m": angular_metrics[f"{case_id}_official_pid_position_rmse_m"],
                "ardg_rgpc_position_rmse_m": angular_metrics[f"{case_id}_ardg_rgpc_position_rmse_m"],
                "official_pid_motor_tv": angular_metrics[f"{case_id}_official_pid_motor_tv"],
                "ardg_rgpc_motor_tv": angular_metrics[f"{case_id}_ardg_rgpc_motor_tv"],
                "ardg_rgpc_motor_tv_reduction_percent": angular_metrics[f"{case_id}_motor_tv_reduction_percent"],
            }
        )
    pd.DataFrame(angular_rows).to_csv(staged(paths, "05_visuals/assets/report_sources/data/FIG_6-7__angular_pid_tradeoff.csv"), index=False, encoding="utf-8-sig")
    pd.DataFrame([formation_metrics]).to_csv(staged(paths, "05_visuals/assets/report_sources/data/FIG_7-1_7-2__formation_pp_cbf.csv"), index=False, encoding="utf-8-sig")
    compound.to_csv(staged(paths, "05_visuals/assets/report_sources/data/FIG_D-2__compound_stress_final.csv"), index=False, encoding="utf-8-sig")


def build_static_package(paths: Paths, path: Path) -> None:
    step = downsample(final_raw(paths, "Scene01S_Z"), 900)
    spiral = downsample(final_raw(paths, "Scene02"), 900)
    eight = downsample(final_raw(paths, "Scene03"), 1000)
    fig = plt.figure(figsize=SCREEN_SIZE)
    grid = fig.add_gridspec(1, 3, wspace=0.24)
    axes = [fig.add_subplot(grid[0, 0]), fig.add_subplot(grid[0, 1], projection="3d"), fig.add_subplot(grid[0, 2])]
    axes[0].plot(step["time"], step["referenceVector[3]"], color=CHARCOAL, linestyle="--", linewidth=1.1, label="参考")
    axes[0].plot(step["time"], step["quadChassisTest17_1.body.r_0[3]"], color=TEAL, linewidth=1.6, label=ALGORITHM)
    axes[0].set_xlabel("时间 / s")
    axes[0].set_ylabel("高度 / m")
    clean_axis(axes[0], grid="both")
    axes[0].legend(frameon=False)
    axes[0].set_title("独立高度阶跃", fontsize=11, fontweight="bold", pad=10)

    axes[1].plot(spiral["referenceVector[1]"], spiral["referenceVector[2]"], spiral["referenceVector[3]"], color=CHARCOAL, linestyle="--", linewidth=1.0)
    axes[1].plot(spiral["quadChassisTest17_1.body.r_0[1]"], spiral["quadChassisTest17_1.body.r_0[2]"], spiral["quadChassisTest17_1.body.r_0[3]"], color=TEAL, linewidth=1.5)
    axes[1].set_xlabel("X / m")
    axes[1].set_ylabel("Y / m")
    axes[1].set_zlabel("Z / m")
    axes[1].set_title("螺旋爬升", fontsize=11, fontweight="bold", pad=10)

    axes[2].plot(eight["referenceVector[1]"], eight["referenceVector[2]"], color=CHARCOAL, linestyle="--", linewidth=1.0)
    axes[2].plot(eight["quadChassisTest17_1.body.r_0[1]"], eight["quadChassisTest17_1.body.r_0[2]"], color=TEAL, linewidth=1.5)
    axes[2].set_xlabel("X / m")
    axes[2].set_ylabel("Y / m")
    axes[2].set_aspect("equal", adjustable="box")
    clean_axis(axes[2], grid="both")
    axes[2].set_title("8字轨迹", fontsize=11, fontweight="bold", pad=10)
    fig.suptitle("ARDG-RGPC典型任务表现", fontsize=16, fontweight="bold", x=0.04, ha="left")
    fig.text(0.04, 0.925, "最终算法直接仿真结果", fontsize=9.5, color=CHARCOAL)
    save_figure(fig, path, dpi=SCREEN_DPI)


def build_parameter_package(p11: pd.DataFrame, random20: pd.DataFrame, path: Path) -> None:
    fig, axes = plt.subplots(1, 3, figsize=SCREEN_SIZE)
    values = p11["ardg_rgpc_vs_geometric_baseline_reduction_percent"].to_numpy(float)
    axes[0].barh(np.arange(len(p11)), values, color=[TEAL if value > 0.5 else GRAY for value in values])
    axes[0].set_yticks(np.arange(len(p11)), [item.replace("Scene05B_", "") for item in p11["case_id"]])
    axes[0].set_xlabel("RMSE降幅 / %")
    axes[0].invert_yaxis()
    clean_axis(axes[0], grid="x")
    axes[0].set_title("11项预设参数", fontweight="bold")

    axes[1].scatter(random20["pid_rmse_m"], random20["ardg_rgpc_rmse_m"], color=TEAL, s=28)
    maximum = max(float(random20["pid_rmse_m"].max()), float(random20["ardg_rgpc_rmse_m"].max()))
    axes[1].plot([0, maximum], [0, maximum], color=CHARCOAL, linestyle="--", linewidth=1.0, label="等性能线")
    axes[1].set_xlabel("官方PID RMSE / m")
    axes[1].set_ylabel("ARDG-RGPC RMSE / m")
    clean_axis(axes[1], grid="both")
    axes[1].legend(frameon=False)
    axes[1].set_title("20组随机参数逐组配对", fontweight="bold")

    axes[2].hist(random20["ardg_vs_pid_reduction_percent"], bins=8, color=TEAL, edgecolor="white")
    median = float(random20["ardg_vs_pid_reduction_percent"].median())
    axes[2].axvline(median, color=AMBER, linestyle="--", linewidth=1.5, label=f"中位数 {median:.2f}%")
    axes[2].set_xlabel("相对官方PID RMSE降幅 / %")
    axes[2].set_ylabel("组数")
    clean_axis(axes[2])
    axes[2].legend(frameon=False)
    axes[2].set_title("统计性鲁棒性", fontweight="bold")
    fig.suptitle("ARDG-RGPC参数鲁棒性与统计结果", fontsize=16, fontweight="bold", x=0.04, ha="left")
    fig.text(0.04, 0.925, "11项预设参数与20组登记随机参数均为最终算法直接结果", fontsize=9.5, color=CHARCOAL)
    save_figure(fig, path, dpi=SCREEN_DPI)


def build_formation_package(paths: Paths, path: Path) -> None:
    off = formation_data(paths.formation_source / "Scene07COff.csv")
    on = formation_data(paths.formation_source / "Scene07COnPredictiveV5C.csv")
    fig, axes = plt.subplots(1, 2, figsize=SCREEN_SIZE)
    axes[0].plot(off["time"], off["distance"], color=RED, linestyle="--", linewidth=1.3, label="PP-CBF关闭")
    axes[0].plot(on["time"], on["distance"], color=TEAL, linewidth=1.5, label="PP-CBF开启")
    axes[0].axhline(SAFETY_DISTANCE_M, color=CHARCOAL, linestyle=":", linewidth=1.0, label="安全距离")
    axes[0].set_xlabel("时间 / s")
    axes[0].set_ylabel("最近机间距 / m")
    clean_axis(axes[0], grid="both")
    axes[0].legend(frameon=False)
    axes[0].set_title("近距离交汇安全效果", fontweight="bold")

    axes[1].bar([0, 1], [off["violation_seconds"], on["violation_seconds"]], color=[RED, TEAL], width=0.55)
    axes[1].set_xticks([0, 1], ["关闭", "开启"])
    axes[1].set_ylabel("低于0.60 m时间 / s")
    clean_axis(axes[1])
    axes[1].set_title("风险暴露时间", fontweight="bold")
    for bars in axes[1].containers:
        axes[1].bar_label(bars, fmt="%.2f", padding=3)
    fig.suptitle("ARDG-RGPC低层控制与PP-CBF编队安全", fontsize=16, fontweight="bold", x=0.04, ha="left")
    fig.text(0.04, 0.925, "三套最终低层控制器直接仿真；PP-CBF作为独立上层安全监督器", fontsize=9.5, color=CHARCOAL)
    save_figure(fig, path, dpi=SCREEN_DPI)


def render_frame(fig: plt.Figure) -> Image.Image:
    buffer = io.BytesIO()
    fig.savefig(buffer, format="png", dpi=SCREEN_DPI, facecolor="white")
    plt.close(fig)
    buffer.seek(0)
    return Image.open(buffer).convert("RGB")


def save_gif(frames: list[Image.Image], path: Path, duration_ms: int = 120) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    frames[0].save(path, save_all=True, append_images=frames[1:], duration=duration_ms, loop=0, optimize=False)


def progressive_indices(length: int, frame_count: int = 36) -> np.ndarray:
    return np.linspace(2, max(2, length - 1), frame_count, dtype=int)


def build_gifs(paths: Paths, gif_dir: Path) -> None:
    gif_dir.mkdir(parents=True, exist_ok=True)
    lift = read_csv(paths.root / "06_supplementary_evidence" / "ardg_rgpc_parameter11_final" / "cases" / "Scene05B_LiftMinus10" / "raw.csv")
    lift = downsample(lift, 1400)
    frames_altitude: list[Image.Image] = []
    frames_scale: list[Image.Image] = []
    for end in progressive_indices(len(lift)):
        view = lift.iloc[: end + 1]
        fig, ax = plt.subplots(figsize=SCREEN_SIZE)
        ax.plot(view["time"], view["referenceVector[3]"], color=CHARCOAL, linestyle="--", linewidth=1.2, label="高度参考")
        ax.plot(view["time"], view["quadChassisTest17_1.body.r_0[3]"], color=TEAL, linewidth=1.7, label=ALGORITHM)
        ax.set_xlim(float(lift["time"].min()), float(lift["time"].max()))
        ax.set_ylim(min(-0.05, float(lift["quadChassisTest17_1.body.r_0[3]"].min()) - 0.05), max(float(lift["referenceVector[3]"].max()), float(lift["quadChassisTest17_1.body.r_0[3]"].max())) + 0.12)
        ax.set_xlabel("时间 / s")
        ax.set_ylabel("高度 / m")
        clean_axis(ax, grid="both")
        ax.legend(frameon=False)
        ax.set_title("升力效率降低10%时的高度跟踪", fontsize=15, fontweight="bold", pad=14)
        fig.text(0.98, 0.02, f"t = {float(view['time'].iloc[-1]):.2f} s  ·  帧 {len(frames_altitude)+1}/36", ha="right", fontsize=8.5, color=CHARCOAL)
        frames_altitude.append(render_frame(fig))

        fig, ax = plt.subplots(figsize=SCREEN_SIZE)
        ax.plot(view["time"], view["controllerDiagnostics[11]"], color=BLUE, linewidth=1.2, label="估计尺度")
        ax.plot(view["time"], view["controllerDiagnostics[12]"], color=TEAL, linewidth=1.7, label="应用尺度")
        target = float(view["scenarioDiagnostics[2]"].iloc[0] / view["scenarioDiagnostics[1]"].iloc[0])
        ax.axhline(target, color=CHARCOAL, linestyle="--", linewidth=1.0, label=f"理论补偿尺度 {target:.4f}")
        ax.set_xlim(float(lift["time"].min()), float(lift["time"].max()))
        ax.set_ylim(0.98, 1.13)
        ax.set_xlabel("时间 / s")
        ax.set_ylabel("推力尺度")
        clean_axis(ax, grid="both")
        ax.legend(frameon=False)
        ax.set_title("推力尺度估计与受保护应用", fontsize=15, fontweight="bold", pad=14)
        fig.text(0.98, 0.02, f"t = {float(view['time'].iloc[-1]):.2f} s  ·  帧 {len(frames_scale)+1}/36", ha="right", fontsize=8.5, color=CHARCOAL)
        frames_scale.append(render_frame(fig))
    save_gif(frames_altitude, gif_dir / "01_参数_高度跟踪.gif")
    save_gif(frames_scale, gif_dir / "02_参数_推力尺度.gif")

    scene_b = formation_data(paths.formation_source / "Scene07B.csv")
    off = formation_data(paths.formation_source / "Scene07COff.csv")
    on = formation_data(paths.formation_source / "Scene07COnPredictiveV5C.csv")
    formation_indices = progressive_indices(len(scene_b["time"]))
    cbf_indices = progressive_indices(len(off["time"]))
    traj_frames: list[Image.Image] = []
    dist_frames: list[Image.Image] = []
    geometry_frames: list[Image.Image] = []
    cbf_dist_frames: list[Image.Image] = []
    colors = [BLUE, "#DD6B20", GREEN]
    all_xy = np.vstack(scene_b["vehicles"])
    xlim = (float(all_xy[:, 0].min()) - 0.2, float(all_xy[:, 0].max()) + 0.2)
    ylim = (float(all_xy[:, 1].min()) - 0.2, float(all_xy[:, 1].max()) + 0.2)
    for end in formation_indices:
        fig, ax = plt.subplots(figsize=SCREEN_SIZE)
        for i, vehicle in enumerate(scene_b["vehicles"]):
            ax.plot(vehicle[: end + 1, 0], vehicle[: end + 1, 1], color=colors[i], linewidth=1.5, label=f"无人机{i+1}")
            ax.scatter(vehicle[end, 0], vehicle[end, 1], color=colors[i], s=48)
        ax.set_xlim(*xlim)
        ax.set_ylim(*ylim)
        ax.set_aspect("equal", adjustable="box")
        ax.set_xlabel("X / m")
        ax.set_ylabel("Y / m")
        clean_axis(ax, grid="both")
        ax.legend(frameon=False, ncol=3)
        ax.set_title("三机队形变换轨迹", fontsize=15, fontweight="bold", pad=14)
        fig.text(0.98, 0.02, f"t = {float(scene_b['time'][end]):.2f} s  ·  帧 {len(traj_frames)+1}/36", ha="right", fontsize=8.5, color=CHARCOAL)
        traj_frames.append(render_frame(fig))

        fig, ax = plt.subplots(figsize=SCREEN_SIZE)
        ax.plot(scene_b["time"][: end + 1], scene_b["distance"][: end + 1], color=TEAL, linewidth=1.7)
        ax.axhline(SAFETY_DISTANCE_M, color=RED, linestyle="--", linewidth=1.0, label="安全距离 0.60 m")
        ax.set_xlim(float(scene_b["time"][0]), float(scene_b["time"][-1]))
        ax.set_ylim(0, max(1.0, float(np.max(scene_b["distance"])) * 1.08))
        ax.set_xlabel("时间 / s")
        ax.set_ylabel("最近机间距 / m")
        clean_axis(ax, grid="both")
        ax.legend(frameon=False)
        ax.set_title("队形变换中的最近机间距", fontsize=15, fontweight="bold", pad=14)
        fig.text(0.98, 0.02, f"t = {float(scene_b['time'][end]):.2f} s  ·  帧 {len(dist_frames)+1}/36", ha="right", fontsize=8.5, color=CHARCOAL)
        dist_frames.append(render_frame(fig))
    save_gif(traj_frames, gif_dir / "03_编队_队形变换.gif")
    save_gif(dist_frames, gif_dir / "04_编队_最近机间距.gif")

    all_cbf_xy = np.vstack(off["vehicles"] + on["vehicles"])
    cbf_xlim = (float(all_cbf_xy[:, 0].min()) - 0.2, float(all_cbf_xy[:, 0].max()) + 0.2)
    cbf_ylim = (float(all_cbf_xy[:, 1].min()) - 0.2, float(all_cbf_xy[:, 1].max()) + 0.2)
    for end in cbf_indices:
        fig, axes = plt.subplots(1, 2, figsize=SCREEN_SIZE)
        for ax, data, title in zip(axes, (off, on), ("PP-CBF关闭", "PP-CBF开启")):
            for i, vehicle in enumerate(data["vehicles"]):
                ax.plot(vehicle[: end + 1, 0], vehicle[: end + 1, 1], color=colors[i], linewidth=1.3)
                ax.scatter(vehicle[end, 0], vehicle[end, 1], color=colors[i], s=44)
            ax.set_xlim(*cbf_xlim)
            ax.set_ylim(*cbf_ylim)
            ax.set_aspect("equal", adjustable="box")
            ax.set_xlabel("X / m")
            ax.set_ylabel("Y / m")
            clean_axis(ax, grid="both")
            ax.set_title(title, fontweight="bold")
        fig.suptitle("PP-CBF近距离交汇几何对照", fontsize=15, fontweight="bold")
        fig.text(0.98, 0.02, f"t = {float(off['time'][end]):.2f} s  ·  帧 {len(geometry_frames)+1}/36", ha="right", fontsize=8.5, color=CHARCOAL)
        geometry_frames.append(render_frame(fig))

        fig, ax = plt.subplots(figsize=SCREEN_SIZE)
        ax.plot(off["time"][: end + 1], off["distance"][: end + 1], color=RED, linestyle="--", linewidth=1.4, label="PP-CBF关闭")
        ax.plot(on["time"][: end + 1], on["distance"][: end + 1], color=TEAL, linewidth=1.7, label="PP-CBF开启")
        ax.axhline(SAFETY_DISTANCE_M, color=CHARCOAL, linestyle=":", linewidth=1.0, label="安全距离 0.60 m")
        ax.set_xlim(float(off["time"][0]), float(off["time"][-1]))
        ax.set_ylim(0.25, max(float(np.max(off["distance"])), float(np.max(on["distance"]))) * 1.04)
        ax.set_xlabel("时间 / s")
        ax.set_ylabel("最近机间距 / m")
        clean_axis(ax, grid="both")
        ax.legend(frameon=False)
        ax.set_title("PP-CBF对最近机间距的保护", fontsize=15, fontweight="bold", pad=14)
        fig.text(0.98, 0.02, f"t = {float(off['time'][end]):.2f} s  ·  帧 {len(cbf_dist_frames)+1}/36", ha="right", fontsize=8.5, color=CHARCOAL)
        cbf_dist_frames.append(render_frame(fig))
    save_gif(geometry_frames, gif_dir / "05_PP-CBF_队形安全.gif")
    save_gif(cbf_dist_frames, gif_dir / "06_PP-CBF_距离曲线.gif")


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        Path("C:/Windows/Fonts/msyhbd.ttc" if bold else "C:/Windows/Fonts/msyh.ttc"),
        Path("C:/Windows/Fonts/simhei.ttf"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size=size)
    return ImageFont.load_default()


def contact_sheet(images: list[tuple[str, Image.Image]], columns: int, path: Path, title: str) -> None:
    thumb_w, thumb_h = 520, 300
    rows = math.ceil(len(images) / columns)
    canvas = Image.new("RGB", (columns * thumb_w, 70 + rows * (thumb_h + 42)), "#F1F5F9")
    draw = ImageDraw.Draw(canvas)
    draw.text((18, 14), title, fill="#0F172A", font=font(26, True))
    for index, (label, image) in enumerate(images):
        col = index % columns
        row = index // columns
        x = col * thumb_w + 10
        y = 66 + row * (thumb_h + 42)
        sample = image.copy()
        sample.thumbnail((thumb_w - 20, thumb_h - 12), Image.Resampling.LANCZOS)
        canvas.paste(sample, (x + (thumb_w - sample.width) // 2, y))
        draw.text((x + 8, y + thumb_h + 5), label, fill="#1F2937", font=font(15))
    path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(path)


def build_contact_sheets(paths: Paths) -> None:
    static_dir = paths.stage / "05_visuals" / "assets" / "static"
    gif_dir = paths.stage / "05_visuals" / "assets" / "gif"
    static_items = [(item.stem, Image.open(item).convert("RGB")) for item in sorted(static_dir.glob("*.png"))]
    contact_sheet(static_items, 3, staged(paths, "05_visuals/qa/静态图联系表.png"), "决赛静态图视觉QA联系表")
    gif_items: list[tuple[str, Image.Image]] = []
    for gif in sorted(gif_dir.glob("*.gif")):
        frames = [frame.convert("RGB") for frame in ImageSequence.Iterator(Image.open(gif))]
        for label, index in (("首帧", 0), ("中帧", len(frames) // 2), ("末帧", len(frames) - 1)):
            gif_items.append((f"{gif.stem} · {label}", frames[index]))
    contact_sheet(gif_items, 3, staged(paths, "05_visuals/qa/GIF首中末帧联系表.png"), "六个最终算法GIF首帧 / 中帧 / 末帧视觉QA联系表")
    report_dir = paths.stage / "05_visuals" / "assets" / "report_static"
    report_items = [(item.stem, Image.open(item).convert("RGB")) for item in sorted(report_dir.glob("*.png"))]
    contact_sheet(report_items, 3, staged(paths, "05_visuals/qa/报告图联系表.png"), "决赛仿真报告图视觉QA联系表")


def verify_stage(paths: Paths) -> dict[str, object]:
    required_png = [
        "FIG_3-1.png",
        "FIG_4-1.png",
        "FIG_6-1.png",
        "FIG_6-2.png",
        "FIG_6-3.png",
        "FIG_6-4.png",
        "FIG_6-6.png",
        "FIG_6-7.png",
        "FIG_6-8.png",
        "FIG_6-9.png",
        "FIG_7-1.png",
        "FIG_7-2.png",
        "FIG_8-1.png",
        "FIG_C-1.png",
        "FIG_C-2.png",
        "FIG_C-3.png",
        "FIG_C-4.png",
        "FIG_D-1.png",
        "FIG_D-2.png",
    ]
    report_dir = paths.stage / "05_visuals" / "assets" / "report_static"
    missing = [name for name in required_png if not (report_dir / name).exists()]
    if missing:
        raise RuntimeError(f"Missing report figures: {missing}")
    visual_checks = []
    for path in sorted((paths.stage / "05_visuals" / "assets").rglob("*.png")):
        image = Image.open(path)
        extrema = image.convert("L").getextrema()
        if path.stat().st_size < 10_000 or extrema[0] == extrema[1]:
            raise RuntimeError(f"Blank or undersized PNG: {path}")
        visual_checks.append({"path": str(path.relative_to(paths.stage).as_posix()), "width": image.width, "height": image.height, "size_bytes": path.stat().st_size, "sha256": sha256_file(path)})
    gif_checks = []
    for path in sorted((paths.stage / "05_visuals" / "assets" / "gif").glob("*.gif")):
        image = Image.open(path)
        frames = sum(1 for _ in ImageSequence.Iterator(image))
        if frames != 36 or image.size != (1280, 720):
            raise RuntimeError(f"Unexpected GIF contract: {path} frames={frames} size={image.size}")
        gif_checks.append({"path": str(path.relative_to(paths.stage).as_posix()), "frames": frames, "width": image.width, "height": image.height, "size_bytes": path.stat().st_size, "sha256": sha256_file(path)})
    forbidden = ("v914", "v936", "ardg1", "l06", "97406", "ra-gca-cghte", "初赛", "d:\\users\\admin", "a8决赛阶段升级研发")
    hygiene_files = []
    for path in sorted(paths.stage.rglob("*")):
        if not path.is_file():
            continue
        if path.suffix.lower() in {".json", ".md", ".txt"}:
            text = path.read_text(encoding="utf-8-sig").lower()
            matches = [token for token in forbidden if token in text]
            if matches:
                raise RuntimeError(f"Public hygiene violation in {path}: {matches}")
            hygiene_files.append(str(path.relative_to(paths.stage).as_posix()))
        elif path.suffix.lower() == ".csv":
            with path.open("r", encoding="utf-8-sig", newline="") as handle:
                header = handle.readline().lower()
            matches = [token for token in forbidden if token in header]
            if "controllerdiagnostics[16]" in header or any(
                f"controllerdiagnostics{index}[16]" in header for index in range(1, 10)
            ):
                matches.append("internal_identity_column")
            if matches:
                raise RuntimeError(f"Public CSV hygiene violation in {path}: {matches}")
            hygiene_files.append(str(path.relative_to(paths.stage).as_posix()))
    return {
        "status": "passed",
        "png_count": len(visual_checks),
        "gif_count": len(gif_checks),
        "public_hygiene_file_count": len(hygiene_files),
        "png": visual_checks,
        "gif": gif_checks,
    }


def build(paths: Paths) -> None:
    configure_matplotlib()
    ensure_sources(paths)
    reset_stage(paths)
    copied = copy_evidence(paths)
    report_dir = paths.stage / "05_visuals" / "assets" / "report_static"
    report_dir.mkdir(parents=True, exist_ok=True)

    build_architecture_figure(report_dir / "FIG_3-1.png")
    build_formation_architecture_figure(report_dir / "FIG_4-1.png")
    build_figure_6_1(paths, report_dir / "FIG_6-1.png")
    build_figure_6_2(paths, report_dir / "FIG_6-2.png")
    build_figure_6_3(paths, report_dir / "FIG_6-3.png")
    common = build_common_metrics(paths)
    build_figure_6_4(common, report_dir / "FIG_6-4.png")
    p11, random20, stats = public_parameter_data(paths)
    build_figure_6_6(p11, random20, report_dir / "FIG_6-6.png")
    angular = build_angular_diagnostic(paths, report_dir / "FIG_6-7.png")
    scene06b = build_scene06b(paths, report_dir / "FIG_6-8.png")
    if not (0.26947 <= scene06b["ardg_rgpc_rmse_m"] <= 0.26949):
        raise RuntimeError(f"ARDG-RGPC Scene06b RMSE cross-check failed: {scene06b}")
    if not (0.30676 <= scene06b["official_pid_rmse_m"] <= 0.30678):
        raise RuntimeError(f"Official PID Scene06b RMSE cross-check failed: {scene06b}")
    environment = build_environment(paths, report_dir / "FIG_6-9.png")
    formation_metrics = build_formation_figures(paths, report_dir / "FIG_7-1.png", report_dir / "FIG_7-2.png")
    compound = compound_metrics(paths)
    build_figure_8_1(common, p11, random20, angular, scene06b, compound, report_dir / "FIG_8-1.png")
    build_c1_flow(report_dir / "FIG_C-1.png")
    build_c2_sysblock(report_dir / "FIG_C-2.png")
    build_c3_regions(report_dir / "FIG_C-3.png")
    shutil.copy2(report_dir / "FIG_6-7.png", report_dir / "FIG_C-4.png")
    build_figure_d1(p11, random20, environment, report_dir / "FIG_D-1.png")
    build_figure_d2(compound, report_dir / "FIG_D-2.png")

    build_static_package(paths, staged(paths, "05_visuals/assets/static/01_典型任务.png"))
    build_parameter_package(p11, random20, staged(paths, "05_visuals/assets/static/02_参数鲁棒核心优势.png"))
    build_formation_package(paths, staged(paths, "05_visuals/assets/static/03_编队PP-CBF.png"))
    build_gifs(paths, paths.stage / "05_visuals" / "assets" / "gif")
    build_contact_sheets(paths)
    write_public_evidence(paths, common, p11, random20, stats, formation_metrics, scene06b, angular, compound)

    qa = verify_stage(paths)
    metrics = {
        "angular": angular,
        "scene06b": scene06b,
        "environment": environment,
        "formation": formation_metrics,
        "compound": {
            "case_count": int(len(compound)),
            "all_physical_pass": bool(compound["all_physical_pass"].astype(str).str.lower().eq("true").all()),
            "tracking_rmse_min_m": float(compound["tracking_rmse_m"].min()),
            "tracking_rmse_max_m": float(compound["tracking_rmse_m"].max()),
            "tracking_peak_min_m": float(compound["tracking_peak_m"].min()),
            "tracking_peak_max_m": float(compound["tracking_peak_m"].max()),
            "recovery_min_s": float(compound["disturbance_recovery_s"].min()),
            "recovery_max_s": float(compound["disturbance_recovery_s"].max()),
            "ardg_active_fraction_min": float(compound["ardg_active_fraction"].min()),
            "ardg_active_fraction_max": float(compound["ardg_active_fraction"].max()),
        },
        "random20_median_reduction_percent": float(random20["ardg_vs_pid_reduction_percent"].median()),
        "parameter11_improved": int((p11["classification_vs_geometric_baseline"] == "improved").sum()),
        "parameter11_equivalent": int((p11["classification_vs_geometric_baseline"] == "equivalent").sum()),
    }
    manifest = {
        "schema_version": 1,
        "algorithm": ALGORITHM,
        "status": "validated_stage",
        "source_policy": "final algorithm direct evidence; no prior-main relabeling",
        "copied_evidence": copied,
        "metrics": metrics,
        "qa": qa,
    }
    staged(paths, "05_visuals/FINALS_VISUAL_REVISION_MANIFEST_20260816.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"stage": str(paths.stage), "status": "passed", "metrics": metrics}, ensure_ascii=False, indent=2))


def promote(paths: Paths) -> None:
    manifest_path = paths.stage / "05_visuals" / "FINALS_VISUAL_REVISION_MANIFEST_20260816.json"
    if not manifest_path.exists():
        raise RuntimeError("Build manifest missing; run --mode build first")
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if manifest.get("status") != "validated_stage" or manifest.get("qa", {}).get("status") != "passed":
        raise RuntimeError("Stage did not pass validation")
    promoted = []
    for source in sorted(paths.stage.rglob("*")):
        if not source.is_file():
            continue
        relative = source.relative_to(paths.stage)
        target = paths.root / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        promoted.append(str(relative.as_posix()))
    print(json.dumps({"status": "promoted", "file_count": len(promoted), "files": promoted}, ensure_ascii=False, indent=2))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--research-root", type=Path, required=True)
    parser.add_argument("--mode", choices=("build", "promote"), default="build")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    paths = Paths(args.root.resolve(), args.research_root.resolve())
    if args.mode == "build":
        build(paths)
    else:
        promote(paths)


if __name__ == "__main__":
    main()
