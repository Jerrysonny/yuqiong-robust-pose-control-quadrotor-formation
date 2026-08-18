from __future__ import annotations

import argparse
import csv
import hashlib
import json
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch


TEAL = "#007C83"
TEAL_PALE = "#EAF5F5"
GREEN = "#2F855A"
GREEN_PALE = "#EDF7F0"
BLUE = "#2B6CB0"
BLUE_PALE = "#EEF5FC"
AMBER = "#B7791F"
AMBER_PALE = "#FFF7E8"
RED = "#BE3340"
RED_PALE = "#FFF1F2"
INK = "#374151"
MUTED = "#616975"
LINE = "#9CA3AF"
GRID = "#E5E7EB"
PID_COLOR = "#6B6B6B"


def configure_style() -> None:
    plt.rcParams.update(
        {
            "font.family": "sans-serif",
            "font.sans-serif": ["Microsoft YaHei", "SimHei", "Arial", "DejaVu Sans"],
            "axes.unicode_minus": False,
            "font.size": 9.0,
            "axes.labelsize": 9.0,
            "axes.titlesize": 9.5,
            "xtick.labelsize": 7.8,
            "ytick.labelsize": 7.8,
            "legend.fontsize": 7.8,
            "axes.edgecolor": LINE,
            "axes.linewidth": 0.7,
            "axes.spines.top": False,
            "axes.spines.right": False,
            "grid.color": GRID,
            "grid.linewidth": 0.6,
            "figure.facecolor": "white",
            "axes.facecolor": "white",
            "savefig.facecolor": "white",
            "svg.fonttype": "none",
            "pdf.fonttype": 42,
        }
    )


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def box(
    ax: plt.Axes,
    x: float,
    y: float,
    w: float,
    h: float,
    text: str,
    *,
    edge: str = TEAL,
    face: str = TEAL_PALE,
    size: float = 8.0,
    bold: bool = False,
) -> None:
    patch = FancyBboxPatch(
        (x, y),
        w,
        h,
        boxstyle="round,pad=0.010,rounding_size=0.012",
        linewidth=1.0,
        edgecolor=edge,
        facecolor=face,
    )
    ax.add_patch(patch)
    ax.text(
        x + w / 2,
        y + h / 2,
        text,
        ha="center",
        va="center",
        fontsize=size,
        color=INK,
        fontweight="bold" if bold else "normal",
        linespacing=1.22,
    )


def arrow(
    ax: plt.Axes,
    start: tuple[float, float],
    end: tuple[float, float],
    *,
    color: str = INK,
    linestyle: str = "-",
    connectionstyle: str = "arc3,rad=0",
    width: float = 1.0,
) -> None:
    ax.add_patch(
        FancyArrowPatch(
            start,
            end,
            arrowstyle="-|>",
            mutation_scale=9,
            linewidth=width,
            color=color,
            linestyle=linestyle,
            connectionstyle=connectionstyle,
            shrinkA=0,
            shrinkB=0,
        )
    )


def line_route(
    ax: plt.Axes,
    points: list[tuple[float, float]],
    *,
    color: str,
    linestyle: str = "-",
    width: float = 1.0,
) -> None:
    for start, end in zip(points[:-2], points[1:-1]):
        ax.plot(
            [start[0], end[0]],
            [start[1], end[1]],
            color=color,
            linewidth=width,
            linestyle=linestyle,
            solid_capstyle="round",
            zorder=1,
        )
    arrow(ax, points[-2], points[-1], color=color, linestyle=linestyle, width=width)


def save(fig: plt.Figure, output: Path) -> list[Path]:
    output.parent.mkdir(parents=True, exist_ok=True)
    targets = [output.with_suffix(ext) for ext in (".png", ".pdf", ".svg")]
    for target in targets:
        if target.exists():
            raise FileExistsError(f"refusing to overwrite staged figure: {target}")
    fig.savefig(targets[0], dpi=360, bbox_inches="tight", pad_inches=0.05)
    fig.savefig(targets[1], bbox_inches="tight", pad_inches=0.05)
    fig.savefig(targets[2], bbox_inches="tight", pad_inches=0.05)
    plt.close(fig)
    return targets


def build_figure_3_1(output: Path) -> list[Path]:
    fig, ax = plt.subplots(figsize=(13.8, 6.3))
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")

    xs = [0.04, 0.235, 0.43, 0.625, 0.82]
    w, h = 0.14, 0.14
    top, middle = 0.69, 0.40

    ax.text(0.04, 0.88, "基础控制主链", color=TEAL, fontsize=10.5, fontweight="bold")
    main = [
        "参考与状态\n输入",
        "几何位置/姿态\n控制",
        "基础力矩 +\n受限补偿",
        "约束电机分配\n限幅与可行性检查",
        "四旋翼模型\n电机与传感器",
    ]
    for index, text in enumerate(main):
        edge, face = (TEAL, TEAL_PALE)
        if index == 2:
            edge, face = GREEN, GREEN_PALE
        elif index == 3:
            edge, face = AMBER, AMBER_PALE
        elif index == 4:
            edge, face = INK, "#F3F4F6"
        box(ax, xs[index], top, w, h, text, edge=edge, face=face, size=8.2)
        if index:
            arrow(ax, (xs[index - 1] + w, top + h / 2), (xs[index], top + h / 2))

    line_route(
        ax,
        [(xs[-1] + w / 2, top), (xs[-1] + w / 2, 0.31), (xs[0] + w / 2, 0.31), (xs[0] + w / 2, middle + h)],
        color=BLUE,
        linestyle="--",
        width=0.85,
    )
    ax.text(0.50, 0.32, "模型反馈：转速与角速度", ha="center", va="bottom", color=BLUE, fontsize=7.6)

    ax.text(0.04, 0.59, "角残差补偿支链", color=GREEN, fontsize=10.5, fontweight="bold")
    branch_xs = [0.04, 0.25, 0.46]
    branch_w = 0.16
    branch = [
        "转速与角速度\n输入",
        "实际滚转/俯仰\n力矩重构",
        "角残差判别与\n受限补偿",
    ]
    for index, text in enumerate(branch):
        edge, face = (GREEN, GREEN_PALE)
        if index == 2:
            edge, face = BLUE, BLUE_PALE
        box(ax, branch_xs[index], middle, branch_w, h, text, edge=edge, face=face, size=8.2)
        if index:
            arrow(ax, (branch_xs[index - 1] + branch_w, middle + h / 2), (branch_xs[index], middle + h / 2), color=GREEN if index < 2 else BLUE)
    arrow(ax, (branch_xs[2] + branch_w / 2, middle + h), (xs[2] + w / 2, top), color=GREEN)

    ax.text(0.04, 0.265, "安全旁路", color=RED, fontsize=10.5, fontweight="bold")
    sx = [0.05, 0.27, 0.49, 0.71]
    sw, sy, sh = 0.17, 0.08, 0.125
    safety = [
        "数值、时间和\n输入范围检查",
        "电机剪裁与\n分配可行性检查",
        "异常时补偿\n立即归零",
        "保留基础控制\n并给出状态",
    ]
    for index, text in enumerate(safety):
        edge, face = (RED, RED_PALE) if index < 3 else (BLUE, BLUE_PALE)
        box(ax, sx[index], sy, sw, sh, text, edge=edge, face=face, size=8.0)
        if index:
            arrow(ax, (sx[index - 1] + sw, sy + sh / 2), (sx[index], sy + sh / 2), color=RED if index < 3 else BLUE)
    arrow(ax, (sx[2] + sw / 2, sy + sh), (branch_xs[2] + branch_w / 2, middle), color=RED, linestyle="--")
    ax.text(0.50, 0.015, "安全检查通过才允许补偿介入；异常时只旁路补偿，不切断基础控制。", ha="center", color=INK, fontsize=8.2)
    return save(fig, output)


def build_figure_4_1(output: Path) -> list[Path]:
    fig, ax = plt.subplots(figsize=(13.8, 7.1))
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")

    ax.text(0.025, 0.935, "上层安全修正", color=GREEN, fontsize=11.0, fontweight="bold")
    box(ax, 0.025, 0.775, 0.18, 0.12, "领导机参考\n与三机编队偏置", size=8.2)
    box(ax, 0.30, 0.755, 0.40, 0.16, "PP-CBF安全监督器\n预测机间距离，只在需要时小幅修正参考", edge=GREEN, face=GREEN_PALE, size=8.5, bold=True)
    box(ax, 0.795, 0.775, 0.18, 0.12, "三机位置与速度\n状态反馈", edge=BLUE, face=BLUE_PALE, size=8.2)
    arrow(ax, (0.205, 0.835), (0.30, 0.835), color=GREEN)
    arrow(ax, (0.795, 0.835), (0.70, 0.835), color=GREEN)

    ax.text(0.31, 0.675, "三套独立低层闭环", color=TEAL, fontsize=11.0, fontweight="bold")
    ys = [0.505, 0.315, 0.125]
    for index, y in enumerate(ys, start=1):
        box(ax, 0.06, y, 0.18, 0.12, f"安全参考 {index}\n位置、速度、加速度", edge=GREEN, face=GREEN_PALE, size=7.8)
        box(ax, 0.31, y, 0.22, 0.12, f"ARDG-RGPC {index}\n几何控制与受限补偿", size=7.9, bold=True)
        box(ax, 0.61, y, 0.16, 0.12, f"四旋翼 {index}\n电机与机体", edge=INK, face="#F3F4F6", size=7.8)
        box(ax, 0.84, y, 0.135, 0.12, f"状态 {index}\n位置与速度", edge=BLUE, face=BLUE_PALE, size=7.8)
        arrow(ax, (0.24, y + 0.06), (0.31, y + 0.06), color=TEAL)
        arrow(ax, (0.53, y + 0.06), (0.61, y + 0.06))
        arrow(ax, (0.77, y + 0.06), (0.84, y + 0.06), color=BLUE)

    line_route(ax, [(0.50, 0.755), (0.50, 0.705), (0.035, 0.705), (0.035, ys[-1] + 0.06)], color=GREEN)
    ax.plot([0.035, 0.035], [ys[-1] + 0.06, ys[0] + 0.06], color=GREEN, lw=1.0)
    for y in ys:
        arrow(ax, (0.035, y + 0.06), (0.06, y + 0.06), color=GREEN)

    ax.plot([0.992, 0.992], [ys[-1] + 0.06, ys[0] + 0.06], color=BLUE, lw=0.95, linestyle="--")
    for y in ys:
        ax.plot([0.975, 0.992], [y + 0.06, y + 0.06], color=BLUE, lw=0.95, linestyle="--")
    line_route(ax, [(0.992, ys[0] + 0.06), (0.992, 0.735), (0.885, 0.735), (0.885, 0.775)], color=BLUE, linestyle="--", width=0.95)
    ax.text(0.50, 0.025, "设计距离0.615 m，安全判定值0.60 m。PP-CBF只修正参考，不替代低层控制器。", ha="center", color=INK, fontsize=8.1)
    return save(fig, output)


def position_peak(path: Path) -> float:
    frame = pd.read_csv(path, low_memory=False)
    reference = frame[["reference_x_m", "reference_y_m", "reference_z_m"]].to_numpy(float)
    actual = frame[["position_x_m", "position_y_m", "position_z_m"]].to_numpy(float)
    return float(np.linalg.norm(actual - reference, axis=1).max())


def parameter_label(case_id: str) -> str:
    labels = {
        "Scene05B_Nominal": "名义（1.00 / 1.00 / 1.00）",
        "Scene05B_LiftMinus10": "仅升力降低（0.90 / 1.00 / 1.00）",
        "Scene05B_PayloadPlus10": "质量/惯量增加（1.00 / 1.10 / 1.10）",
        "Scene05B_C000": "组合（0.90 / 0.90 / 0.90）",
        "Scene05B_C001": "组合（0.90 / 0.90 / 1.10）",
        "Scene05B_C010": "组合（0.90 / 1.10 / 0.90）",
        "Scene05B_C011": "组合（0.90 / 1.10 / 1.10）",
        "Scene05B_C100": "组合（1.10 / 0.90 / 0.90）",
        "Scene05B_C101": "组合（1.10 / 0.90 / 1.10）",
        "Scene05B_C110": "组合（1.10 / 1.10 / 0.90）",
        "Scene05B_C111": "组合（1.10 / 1.10 / 1.10）",
    }
    return labels[case_id]


def build_figure_6_5(root: Path, output: Path, data_output: Path) -> tuple[list[Path], Path]:
    deterministic = pd.read_csv(root / "04_results/report_evidence/parameter11_ardg_rgpc_final/parameter11_final_paired.csv")
    paired = pd.read_csv(root / "04_results/report_evidence/parameter_random20_ardg_rgpc_final/paired_results.csv")
    summary = json.loads((root / "04_results/report_evidence/parameter_random20_ardg_rgpc_final/statistical_summary.json").read_text(encoding="utf-8"))
    if len(deterministic) != 11 or len(paired) != 20:
        raise RuntimeError("Figure 6-5 requires 11 deterministic and 20 paired random cases")

    order = [
        "Scene05B_Nominal",
        "Scene05B_LiftMinus10",
        "Scene05B_PayloadPlus10",
        "Scene05B_C000",
        "Scene05B_C001",
        "Scene05B_C010",
        "Scene05B_C011",
        "Scene05B_C100",
        "Scene05B_C101",
        "Scene05B_C110",
        "Scene05B_C111",
    ]
    deterministic = deterministic.set_index("case_id").loc[order].reset_index()

    peak_rows: list[dict[str, float | str]] = []
    for case_id in paired["case_id"]:
        pid_peak = position_peak(root / "06_supplementary_evidence/official_pid_random20_raw" / f"{case_id}.csv")
        main_peak = position_peak(root / "06_supplementary_evidence/ardg_rgpc_random20_final/cases" / case_id / "raw.csv")
        peak_rows.append(
            {
                "case_id": case_id,
                "pid_peak_m": pid_peak,
                "ardg_rgpc_peak_m": main_peak,
                "peak_reduction_percent": 100.0 * (1.0 - main_peak / pid_peak),
            }
        )
    peak = pd.DataFrame(peak_rows)
    merged = paired.merge(peak, on="case_id", validate="one_to_one")
    data_output.parent.mkdir(parents=True, exist_ok=True)
    if data_output.exists():
        raise FileExistsError(f"refusing to overwrite staged data: {data_output}")
    merged.to_csv(data_output, index=False, encoding="utf-8-sig")

    fig = plt.figure(figsize=(9.2, 6.75))
    grid = fig.add_gridspec(2, 2, height_ratios=[1.05, 0.90], width_ratios=[1.08, 1.0], hspace=0.46, wspace=0.38)
    axes = [fig.add_subplot(grid[0, 0]), fig.add_subplot(grid[0, 1]), fig.add_subplot(grid[1, 0]), fig.add_subplot(grid[1, 1])]

    ax = axes[0]
    y = np.arange(11)
    values = deterministic["ardg_rgpc_position_rmse_m"].to_numpy(float)
    ax.hlines(y, 0, values, color="#C9DDE9", linewidth=2.0, zorder=1)
    ax.scatter(values, y, s=27, color=BLUE, edgecolor="white", linewidth=0.5, zorder=2)
    median = float(np.median(values))
    ax.axvline(median, color=GREEN, linewidth=1.0, linestyle=(0, (4, 2)))
    ax.text(0.98, 0.02, f"中位数 = {median:.4f} m", transform=ax.transAxes, ha="right", va="bottom", fontsize=7.0, color=GREEN)
    ax.set_yticks(y)
    ax.set_yticklabels([parameter_label(case_id) for case_id in deterministic["case_id"]], fontsize=6.2)
    ax.invert_yaxis()
    ax.set_xlim(0, max(0.037, values.max() * 1.10))
    ax.set_xlabel("三维位置RMSE / m")
    ax.set_title("11项预设参数工况下的主算法结果", pad=17)
    ax.text(0.0, 1.01, "括号内依次为：升力效能 / 质量 / 转动惯量比例", transform=ax.transAxes, ha="left", va="bottom", fontsize=6.3, color=MUTED)
    ax.grid(axis="x")
    ax.text(0.01, 1.04, "a", transform=ax.transAxes, fontsize=9.5, fontweight="bold")

    ax = axes[1]
    pid = paired["pid_rmse_m"].to_numpy(float)
    main = paired["ardg_rgpc_rmse_m"].to_numpy(float)
    bp = ax.boxplot([pid, main], positions=[1, 2], widths=0.46, patch_artist=True, showfliers=False, medianprops={"color": "black", "linewidth": 1.1}, whiskerprops={"color": LINE}, capprops={"color": LINE})
    for patch, color in zip(bp["boxes"], (PID_COLOR, BLUE)):
        patch.set_facecolor(color)
        patch.set_alpha(0.22)
    ax.scatter(np.ones(len(pid)), pid, s=16, color=PID_COLOR, edgecolor="white", linewidth=0.35, zorder=3)
    ax.scatter(np.full(len(main), 2), main, s=16, color=BLUE, edgecolor="white", linewidth=0.35, zorder=3)
    ax.set_xticks([1, 2])
    ax.set_xticklabels(["官方PID", "ARDG-RGPC"])
    ax.set_xlim(0.55, 2.45)
    ax.set_ylim(0, 0.19)
    ax.set_ylabel("三维位置RMSE / m")
    ax.set_title("20组随机参数下的RMSE分布", pad=17)
    median_reduction = float(summary["comparisons"]["ardg_vs_pid"]["median_reduction_percent"])
    ax.text(0.5, 1.01, f"20/20组更优；中位RMSE降低 {median_reduction:.1f}%", transform=ax.transAxes, ha="center", va="bottom", fontsize=6.3, color=MUTED)
    ax.grid(axis="y")
    ax.text(0.01, 1.04, "b", transform=ax.transAxes, fontsize=9.5, fontweight="bold")

    panels = [
        (merged["ardg_vs_pid_reduction_percent"].to_numpy(float), "三维位置RMSE逐组降幅"),
        (merged["peak_reduction_percent"].to_numpy(float), "峰值位置误差逐组降幅"),
    ]
    for offset, (ax, (metric, title)) in enumerate(zip(axes[2:], panels)):
        ordered = np.sort(metric)
        x = np.arange(1, len(ordered) + 1)
        ax.bar(x, ordered, width=0.72, color="#2389B8", alpha=0.92)
        med = float(np.median(ordered))
        ax.axhline(med, color=GREEN, linewidth=1.0, linestyle=(0, (4, 2)))
        ax.set_xlim(0.25, 20.75)
        ax.set_ylim(0, 100)
        ax.set_xticks([1, 5, 10, 15, 20])
        ax.set_xlabel("随机参数样本（按降幅由低到高排序）")
        ax.set_title(title, pad=17)
        ax.text(0.5, 1.01, f"20/20组均改善；中位降幅 {med:.1f}%，最小 {ordered.min():.1f}%", transform=ax.transAxes, ha="center", va="bottom", fontsize=6.2, color=MUTED)
        ax.grid(axis="y")
        ax.text(0.01, 1.04, chr(ord("c") + offset), transform=ax.transAxes, fontsize=9.5, fontweight="bold")
    axes[2].set_ylabel("相对官方PID降低 / %")
    fig.subplots_adjust(left=0.24, right=0.985, bottom=0.105, top=0.92)
    return save(fig, output), data_output


def build_figure_6_6(root: Path, output: Path, data_output: Path) -> tuple[list[Path], Path]:
    summary_path = root / "05_visuals/final_shared_assets/data/screen_summary.json"
    final_path = root / "05_visuals/final_shared_assets/data/screen_analysis.json"
    summary = json.loads(summary_path.read_text(encoding="utf-8"))
    final = json.loads(final_path.read_text(encoding="utf-8"))
    observations = sorted(summary["observations"], key=lambda item: item["candidate_id"])
    if len(observations) != 8 or not all(item.get("hard_passed") is True for item in observations):
        raise RuntimeError("Figure 6-6 requires eight hard-passed local candidates")

    final_id = final["candidate_id"]
    final_index = next(index for index, item in enumerate(observations) if item["candidate_id"] == final_id)
    rows = []
    for index, item in enumerate(observations, start=1):
        rows.append(
            {
                "candidate_label": f"候选{index}",
                "selected": item["candidate_id"] == final_id,
                "Kc": item["parameters"]["Kc"],
                "Cmax_nm": item["parameters"]["Cmax_nm"],
                "Rmax_nm_per_sample": item["parameters"]["Rmax_nm_per_sample"],
                "attitude_iae_rad_s": item["objectives"]["attitude_iae"],
                "motor_tv_full": item["objectives"]["motor_tv_full"],
                "motor_tv_event": item["objectives"]["motor_tv_event"],
                "hard_passed": item["hard_passed"],
            }
        )
    frame = pd.DataFrame(rows)
    data_output.parent.mkdir(parents=True, exist_ok=True)
    if data_output.exists():
        raise FileExistsError(f"refusing to overwrite staged data: {data_output}")
    frame.to_csv(data_output, index=False, encoding="utf-8-sig")

    x = np.arange(1, len(frame) + 1)
    selected_x = final_index + 1
    start = final["champion_objectives"]
    fig, axes = plt.subplots(1, 3, figsize=(9.4, 3.55), gridspec_kw={"width_ratios": [1.05, 1.0, 1.0]})

    ax = axes[0]
    scatter = ax.scatter(
        frame["Kc"],
        frame["Cmax_nm"] * 1e4,
        c=frame["Rmax_nm_per_sample"] * 1e5,
        cmap="viridis",
        s=42,
        edgecolor="white",
        linewidth=0.6,
        zorder=2,
    )
    chosen = frame.iloc[final_index]
    ax.scatter(chosen["Kc"], chosen["Cmax_nm"] * 1e4, marker="*", s=150, color=RED, edgecolor="white", linewidth=0.8, zorder=3)
    ax.annotate("定型候选", (chosen["Kc"], chosen["Cmax_nm"] * 1e4), xytext=(8, 7), textcoords="offset points", fontsize=7.0, color=RED)
    colorbar = fig.colorbar(scatter, ax=ax, fraction=0.052, pad=0.035)
    colorbar.ax.set_title("Rmax\n(10^-5 N·m/采样)", fontsize=6.0, pad=4)
    colorbar.ax.tick_params(labelsize=6.5)
    ax.set_xlabel("补偿增益 Kc")
    ax.set_ylabel("Cmax / 10^-4 N·m")
    ax.set_title("局部候选的参数分布", pad=14)
    ax.grid(True)
    ax.text(0.01, 1.04, "a", transform=ax.transAxes, fontsize=9.5, fontweight="bold")

    ax = axes[1]
    attitude = frame["attitude_iae_rad_s"].to_numpy(float)
    ax.plot(x, attitude, color=GREEN, marker="o", markersize=4.2, linewidth=1.2)
    ax.axhline(float(start["attitude_iae"]), color=PID_COLOR, linestyle="--", linewidth=1.0, label="局部搜索起点")
    ax.scatter([selected_x], [attitude[final_index]], marker="*", s=120, color=RED, edgecolor="white", linewidth=0.7, zorder=3, label="定型候选")
    ax.set_xticks(x)
    ax.set_xticklabels([str(index) for index in x])
    ax.set_xlabel("局部候选序号")
    ax.set_ylabel("姿态IAE / rad·s", fontsize=7.2, labelpad=4)
    ax.set_title("姿态误差目标", pad=14)
    ax.grid(axis="y")
    ax.legend(frameon=False, loc="best", fontsize=6.7)
    ax.text(0.01, 1.04, "b", transform=ax.transAxes, fontsize=9.5, fontweight="bold")

    ax = axes[2]
    motor = frame["motor_tv_full"].to_numpy(float)
    ax.plot(x, motor, color=BLUE, marker="o", markersize=4.2, linewidth=1.2)
    ax.axhline(float(start["motor_tv_full"]), color=PID_COLOR, linestyle="--", linewidth=1.0, label="局部搜索起点")
    ax.scatter([selected_x], [motor[final_index]], marker="*", s=120, color=RED, edgecolor="white", linewidth=0.7, zorder=3, label="定型候选")
    ax.set_xticks(x)
    ax.set_xticklabels([str(index) for index in x])
    ax.set_xlabel("局部候选序号")
    ax.set_ylabel("四电机总变差", fontsize=7.4, labelpad=1)
    ax.set_title("执行器平滑性目标", pad=14)
    ax.grid(axis="y")
    ax.legend(frameon=False, loc="best", fontsize=6.7)
    ax.text(0.01, 1.04, "c", transform=ax.transAxes, fontsize=9.5, fontweight="bold")

    fig.text(0.50, 0.965, "14组全局候选确定搜索区域；图中展示8组局部候选，定型参数经两个角扰动场景确认。", ha="center", fontsize=7.3, color=MUTED)
    fig.subplots_adjust(left=0.085, right=0.985, bottom=0.19, top=0.82, wspace=0.50)
    return save(fig, output), data_output


def build_figure_c_1(output: Path) -> list[Path]:
    fig, ax = plt.subplots(figsize=(14.0, 6.2))
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    ax.text(0.04, 0.89, "角残差补偿流程", color=GREEN, fontsize=10.5, fontweight="bold")
    xs = [0.06, 0.24, 0.42, 0.60, 0.78]
    w, y, h = 0.14, 0.60, 0.16
    labels = [
        "输入转子转速\n与机体系角速度",
        "重构实际\n滚转/俯仰力矩",
        "计算指令与实际\n力矩的角残差",
        "检查方向、持续时间\n与运动状态",
        "平滑、限幅后\n加入基础力矩",
    ]
    for index, text in enumerate(labels):
        box(ax, xs[index], y, w, h, text, edge=GREEN, face=GREEN_PALE, size=8.2)
        if index:
            arrow(ax, (xs[index - 1] + w, y + h / 2), (xs[index], y + h / 2), color=GREEN)

    ax.text(0.42, 0.43, "安全旁路", color=RED, fontsize=10.0, fontweight="bold")
    sx = [0.42, 0.60, 0.78]
    sw, sy, sh = 0.14, 0.19, 0.14
    safety = [
        "非有限值、时间异常、\n电机剪裁或分配不可行",
        "补偿立即归零\n不改变基础控制输出",
        "记录激活、残差、补偿\n与安全状态",
    ]
    for index, text in enumerate(safety):
        edge, face = (RED, RED_PALE) if index < 2 else (BLUE, BLUE_PALE)
        box(ax, sx[index], sy, sw, sh, text, edge=edge, face=face, size=7.8)
        if index:
            arrow(ax, (sx[index - 1] + sw, sy + sh / 2), (sx[index], sy + sh / 2), color=RED if index == 1 else BLUE)
    arrow(ax, (sx[1] + sw / 2, sy + sh), (xs[3] + w / 2, y), color=RED, linestyle="--")
    ax.text(0.50, 0.06, "安全条件优先；旁路触发后仍保留基础几何控制。", ha="center", color=INK, fontsize=8.3)
    return save(fig, output)


def build_figure_c_2(output: Path) -> list[Path]:
    fig, ax = plt.subplots(figsize=(14.0, 6.5))
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    ax.text(0.04, 0.91, "控制器功能分区与端口关系", color=INK, fontsize=10.5, fontweight="bold")

    main_x = [0.04, 0.25, 0.46, 0.67, 0.86]
    main_w = [0.16, 0.16, 0.16, 0.14, 0.10]
    main = [
        "11维参考 + 18维状态\n位置、速度、姿态、角速度",
        "几何位置与姿态控制\n计算基础推力和力矩",
        "力矩合成\n基础力矩 + 受限补偿",
        "约束电机分配\n限幅与可行性检查",
        "4维\n电机指令",
    ]
    for index, text in enumerate(main):
        edge, face = (TEAL, TEAL_PALE)
        if index == 2:
            edge, face = GREEN, GREEN_PALE
        elif index == 3:
            edge, face = AMBER, AMBER_PALE
        elif index == 4:
            edge, face = INK, "#F3F4F6"
        box(ax, main_x[index], 0.64, main_w[index], 0.16, text, edge=edge, face=face, size=8.0, bold=index == 1)
        if index:
            arrow(ax, (main_x[index - 1] + main_w[index - 1], 0.72), (main_x[index], 0.72))

    aux_x = [0.04, 0.43, 0.64, 0.82]
    aux_w = [0.22, 0.17, 0.15, 0.14]
    aux = [
        "4维转子转速、使能、时间\n与电机分配上下限",
        "角残差判别\n重构实际力矩并判断补偿",
        "安全旁路\n异常时补偿归零",
        "诊断与结果\n控制误差、分配和安全状态",
    ]
    for index, text in enumerate(aux):
        edge, face = (TEAL, TEAL_PALE)
        if index == 1:
            edge, face = GREEN, GREEN_PALE
        elif index == 2:
            edge, face = RED, RED_PALE
        elif index == 3:
            edge, face = BLUE, BLUE_PALE
        box(ax, aux_x[index], 0.28, aux_w[index], 0.16, text, edge=edge, face=face, size=7.9)
        if index:
            arrow(ax, (aux_x[index - 1] + aux_w[index - 1], 0.36), (aux_x[index], 0.36), color=RED if index == 2 else BLUE if index == 3 else INK)

    arrow(ax, (aux_x[1] + aux_w[1] / 2, 0.44), (main_x[2] + main_w[2] / 2, 0.64), color=GREEN)
    arrow(ax, (main_x[3] + main_w[3] / 2, 0.64), (aux_x[2] + aux_w[2] / 2, 0.44), color=RED, linestyle="--")
    ax.text(0.50, 0.10, "上方为主控制链；下方为角残差与安全检查链。两条链通过力矩合成和旁路判定配合。", ha="center", color=INK, fontsize=8.2)
    return save(fig, output)


def write_record(output_dir: Path, root: Path, outputs: dict[str, list[Path] | Path]) -> None:
    flat: list[Path] = []
    for value in outputs.values():
        if isinstance(value, list):
            flat.extend(value)
        else:
            flat.append(value)
    payload = {
        "schema_version": 1,
        "role": "finals report round-3 figure revision",
        "public_algorithm": "ARDG-RGPC",
        "source_root": root.name,
        "outputs": [
            {
                "path": path.relative_to(output_dir).as_posix(),
                "sha256": sha256(path),
                "bytes": path.stat().st_size,
            }
            for path in flat
        ],
    }
    record = output_dir / "FIGURE_BUILD_RECORD.json"
    record.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    root = args.root.resolve()
    output = args.output.resolve()
    if output.exists() and any(output.iterdir()):
        raise RuntimeError(f"staging output must be empty: {output}")
    output.mkdir(parents=True, exist_ok=True)
    configure_style()

    results: dict[str, list[Path] | Path] = {}
    results["FIG_3-1"] = build_figure_3_1(output / "FIG_3-1")
    results["FIG_4-1"] = build_figure_4_1(output / "FIG_4-1")
    figure_6_5, figure_6_5_data = build_figure_6_5(root, output / "FIG_6-5", output / "FIG_6-5__paired_peak_results.csv")
    results["FIG_6-5"] = figure_6_5
    results["FIG_6-5-data"] = figure_6_5_data
    figure_6_6, figure_6_6_data = build_figure_6_6(root, output / "FIG_6-6", output / "FIG_6-6__parameter_optimization.csv")
    results["FIG_6-6"] = figure_6_6
    results["FIG_6-6-data"] = figure_6_6_data
    results["FIG_C-1"] = build_figure_c_1(output / "FIG_C-1")
    results["FIG_C-2"] = build_figure_c_2(output / "FIG_C-2")
    write_record(output, root, results)
    print(json.dumps({"status": "built", "figures": 6, "output": str(output)}, ensure_ascii=False))


if __name__ == "__main__":
    main()
