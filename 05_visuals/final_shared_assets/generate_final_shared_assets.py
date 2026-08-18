from __future__ import annotations

import csv
import hashlib
import json
import math
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from matplotlib import font_manager
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch
from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parent
DATA = ROOT / "data"
PNG = ROOT / "png"
PDF = ROOT / "pdf"
QA = ROOT / "qa"

TEAL = "#187B80"
TEAL_DARK = "#245643"
TEAL_LIGHT = "#DCEAEC"
GREEN_LIGHT = "#E5EEE8"
GOLD = "#BE8B22"
GOLD_LIGHT = "#F5EEDC"
GRAY = "#687072"
GRAY_LIGHT = "#EEF0F0"
INK = "#25292A"
WHITE = "#FFFFFF"

SOURCE_ORIGINS = {
    "BODY_ROLL_POS_baseline.csv": r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化\A8决赛阶段升级研发\60_v936_ardg1_fast_qualification\03_results\fixed_l1_20260813\BODY_ROLL_POS\v914\output\raw.csv",
    "BODY_ROLL_POS_ARDG-RGPC.csv": r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化\A8决赛阶段升级研发\74_v936_ardg1_final_local_search\03_results\local8_retry_20260814T113552Z\v936-ARDG1-L06\BODY_ROLL_POS\output\raw.csv",
    "BODY_ROLL_POS_ARDG-RGPC_diagnostics.csv": r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化\A8决赛阶段升级研发\74_v936_ardg1_final_local_search\03_results\local8_retry_20260814T113552Z\v936-ARDG1-L06\BODY_ROLL_POS\output\ardg1_diagnostics.csv",
    "BODY_PITCH_NEG_baseline.csv": r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化\A8决赛阶段升级研发\60_v936_ardg1_fast_qualification\03_results\fixed_l1_20260813\BODY_PITCH_NEG\v914\output\raw.csv",
    "BODY_PITCH_NEG_ARDG-RGPC.csv": r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化\A8决赛阶段升级研发\74_v936_ardg1_final_local_search\03_results\local8_retry_20260814T113552Z\v936-ARDG1-L06\BODY_PITCH_NEG\output\raw.csv",
    "BODY_PITCH_NEG_ARDG-RGPC_diagnostics.csv": r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化\A8决赛阶段升级研发\74_v936_ardg1_final_local_search\03_results\local8_retry_20260814T113552Z\v936-ARDG1-L06\BODY_PITCH_NEG\output\ardg1_diagnostics.csv",
    "Scene06b_baseline.csv": r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化\A8赛题核心工作区\驭穹稳控-基于MWORKS的四旋翼鲁棒位姿控制与编队安全仿真1\06_supplementary_evidence\ra_gca_cg_hte_32_raw\Scene06b.csv",
    "Scene06b_ARDG-RGPC.csv": r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化\A8决赛阶段升级研发\74_v936_ardg1_final_local_search\03_results\l06_regression18_20260814T115638Z\candidate\raw\Scene06b.csv",
    "regression18_analysis.json": r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化\A8决赛阶段升级研发\74_v936_ardg1_final_local_search\03_results\l06_regression18_20260814T115638Z\regression18_analysis.json",
    "screen_analysis.json": r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化\A8决赛阶段升级研发\74_v936_ardg1_final_local_search\03_results\local8_retry_20260814T113552Z\v936-ARDG1-L06\screen_analysis.json",
    "screen_summary.json": r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化\A8决赛阶段升级研发\74_v936_ardg1_final_local_search\03_results\local8_retry_20260814T113552Z\screen_summary.json",
    "stage_a_campaign_summary.json": r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化\A8决赛阶段升级研发\73_v936_ardg1_joint_parameter_optimization\03_results\stage_a_campaign_summary.json",
    "formal_wcet_adjudication.json": r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化\A8决赛阶段升级研发\74_v936_ardg1_final_local_search\03_results\t109_l06_qpc_adjudication_20260814\formal_wcet_adjudication.json",
    "static_integration_adjudication.json": r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化\A8决赛阶段升级研发\74_v936_ardg1_final_local_search\03_results\t112_l06_static_adjudication_20260814\static_integration_adjudication.json",
    "codegen_completion.json": r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化\A8决赛阶段升级研发\74_v936_ardg1_final_local_search\00_protocol\T107_l06_codegen_completion_20260814.json",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def load_json(name: str):
    return json.loads((DATA / name).read_text(encoding="utf-8"))


def load_csv_columns(name: str, columns: list[str]) -> dict[str, np.ndarray]:
    values = {column: [] for column in columns}
    with (DATA / name).open(encoding="utf-8-sig", newline="") as stream:
        reader = csv.DictReader(stream)
        missing = [column for column in columns if column not in (reader.fieldnames or [])]
        if missing:
            raise RuntimeError(f"{name} missing columns: {missing}")
        for row in reader:
            for column in columns:
                values[column].append(float(row[column]))
    return {key: np.asarray(items, dtype=float) for key, items in values.items()}


def setup_style() -> None:
    candidates = [
        Path(r"C:\Windows\Fonts\msyh.ttc"),
        Path(r"C:\Windows\Fonts\msyhbd.ttc"),
        Path(r"C:\Windows\Fonts\simhei.ttf"),
    ]
    family = "DejaVu Sans"
    for path in candidates:
        if path.is_file():
            font_manager.fontManager.addfont(path)
            family = font_manager.FontProperties(fname=path).get_name()
            break
    plt.rcParams.update(
        {
            "font.family": family,
            "font.size": 11,
            "axes.labelsize": 11,
            "xtick.labelsize": 10,
            "ytick.labelsize": 10,
            "legend.fontsize": 10,
            "axes.unicode_minus": False,
            "figure.dpi": 150,
            "savefig.dpi": 300,
            "savefig.bbox": "tight",
            "savefig.pad_inches": 0.08,
            "pdf.fonttype": 42,
            "ps.fonttype": 42,
        }
    )


def clean_axes(ax) -> None:
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#9AA0A1")
    ax.spines["bottom"].set_color("#9AA0A1")
    ax.tick_params(colors="#555C5E", width=0.8)
    ax.grid(axis="y", color="#D9DEDF", linewidth=0.7, alpha=0.8)


def save_figure(fig, stem: str) -> list[Path]:
    PNG.mkdir(parents=True, exist_ok=True)
    PDF.mkdir(parents=True, exist_ok=True)
    png = PNG / f"{stem}.png"
    pdf = PDF / f"{stem}.pdf"
    fig.savefig(png, facecolor=WHITE)
    fig.savefig(pdf, facecolor=WHITE)
    plt.close(fig)
    return [png, pdf]


def draw_box(ax, xy, wh, title, lines, edge=TEAL, fill=TEAL_LIGHT, title_size=13):
    x, y = xy
    w, h = wh
    patch = FancyBboxPatch(
        (x, y),
        w,
        h,
        boxstyle="round,pad=0.012,rounding_size=0.012",
        linewidth=1.4,
        edgecolor=edge,
        facecolor=fill,
    )
    ax.add_patch(patch)
    ax.text(x + 0.04 * w, y + h - 0.13 * h, title, fontsize=title_size, weight="bold", color=INK, va="top")
    ax.text(x + 0.04 * w, y + h - 0.34 * h, "\n".join(lines), fontsize=10.2, color=GRAY, va="top", linespacing=1.45)


def arrow(ax, start, end, color=TEAL_DARK, width=1.6):
    ax.add_patch(
        FancyArrowPatch(
            start,
            end,
            arrowstyle="-|>",
            mutation_scale=14,
            linewidth=width,
            color=color,
            connectionstyle="arc3,rad=0",
        )
    )


def figure_a() -> tuple[list[Path], dict]:
    fig, ax = plt.subplots(figsize=(13.2, 5.6))
    ax.set_xlim(0, 1.05)
    ax.set_ylim(0, 1)
    ax.axis("off")

    draw_box(ax, (0.015, 0.38), (0.14, 0.30), "基础几何控制", ["生成期望推力", "滚转/俯仰力矩"], edge=TEAL)
    draw_box(ax, (0.19, 0.55), (0.16, 0.30), "转速力矩重构", ["由四路转子转速", "重构实际滚转/俯仰力矩"], edge=TEAL_DARK, fill=GREEN_LIGHT)
    draw_box(ax, (0.19, 0.12), (0.16, 0.27), "状态证据", ["角速度与角加速度", "平移残差、时间有效性"], edge=TEAL_DARK, fill=GREEN_LIGHT)
    draw_box(ax, (0.39, 0.38), (0.17, 0.30), "角残差判别", ["区分角向扰动与平移扰动", "选择滚转/俯仰补偿通道"], edge=TEAL)
    draw_box(ax, (0.60, 0.38), (0.15, 0.30), "滞回守卫", ["进入/退出阈值", "持续时间与渐变融合"], edge=GOLD, fill=GOLD_LIGHT)
    draw_box(ax, (0.79, 0.55), (0.14, 0.30), "受限补偿", ["补偿幅值上限", "单步变化率上限"], edge=GOLD, fill=GOLD_LIGHT)
    draw_box(ax, (0.79, 0.12), (0.14, 0.27), "安全旁路", ["非有限值、时间异常", "剪裁或不可行时置零"], edge=GRAY, fill=GRAY_LIGHT)
    draw_box(ax, (0.945, 0.38), (0.095, 0.30), "约束分配", ["四路电机命令"], edge=TEAL, title_size=12)

    arrow(ax, (0.155, 0.53), (0.19, 0.70), color=TEAL)
    arrow(ax, (0.35, 0.70), (0.39, 0.53), color=TEAL)
    arrow(ax, (0.35, 0.25), (0.39, 0.43), color=TEAL_DARK)
    arrow(ax, (0.56, 0.53), (0.60, 0.53), color=GOLD)
    arrow(ax, (0.75, 0.53), (0.79, 0.70), color=GOLD)
    arrow(ax, (0.75, 0.50), (0.79, 0.25), color=GRAY)
    arrow(ax, (0.93, 0.70), (0.945, 0.53), color=TEAL)
    arrow(ax, (0.93, 0.25), (0.945, 0.47), color=GRAY)

    ax.text(
        0.02,
        0.03,
        "补偿仅在角扰动证据充分且安全状态有效时介入；其他情况下保持基础控制输出。",
        fontsize=11.5,
        weight="bold",
        color=TEAL_DARK,
    )
    return save_figure(fig, "FIG_A_ARDG_RGPC_architecture"), {
        "claim": "角残差判别、滞回守卫、受限补偿和安全旁路构成结构增量。"
    }


def body_case(case: str) -> dict:
    base = load_csv_columns(
        f"{case}_baseline.csv",
        ["time_s", "angle_roll_rad", "angle_pitch_rad"],
    )
    candidate = load_csv_columns(
        f"{case}_ARDG-RGPC.csv",
        ["time_s", "angle_roll_rad", "angle_pitch_rad"],
    )
    diagnostics = load_csv_columns(
        f"{case}_ARDG-RGPC_diagnostics.csv",
        ["time_s", "ardg_blend", "ardg_correction_x_nm", "ardg_correction_y_nm"],
    )
    mask_base = (base["time_s"] >= 8.0) & (base["time_s"] <= 12.25)
    mask_candidate = (candidate["time_s"] >= 8.0) & (candidate["time_s"] <= 12.25)
    base_mag = np.sqrt(base["angle_roll_rad"] ** 2 + base["angle_pitch_rad"] ** 2)
    candidate_mag = np.sqrt(candidate["angle_roll_rad"] ** 2 + candidate["angle_pitch_rad"] ** 2)
    iae_base = float(np.trapz(base_mag[mask_base], base["time_s"][mask_base]))
    iae_candidate = float(np.trapz(candidate_mag[mask_candidate], candidate["time_s"][mask_candidate]))
    improvement = 100.0 * (iae_base - iae_candidate) / iae_base
    return {
        "base": base,
        "candidate": candidate,
        "diagnostics": diagnostics,
        "iae_base": iae_base,
        "iae_candidate": iae_candidate,
        "improvement": improvement,
    }


def figure_b() -> tuple[list[Path], dict]:
    roll = body_case("BODY_ROLL_POS")
    pitch = body_case("BODY_PITCH_NEG")
    cases = [
        (roll, "angle_roll_rad", "(a) 正滚转机体系力矩脉冲扰动"),
        (pitch, "angle_pitch_rad", "(b) 负俯仰机体系力矩脉冲扰动"),
    ]
    fig, axes = plt.subplots(
        2,
        2,
        figsize=(12.2, 7.0),
        sharex="col",
        gridspec_kw={"height_ratios": [4.4, 0.75], "hspace": 0.10, "wspace": 0.18},
    )
    for column, (result, angle_key, panel) in enumerate(cases):
        ax = axes[0, column]
        band = axes[1, column]
        for dataset, label, color, style, width in [
            (result["base"], "升级前主算法", GRAY, "--", 1.8),
            (result["candidate"], "ARDG-RGPC", TEAL, "-", 2.2),
        ]:
            mask = (dataset["time_s"] >= 8.0) & (dataset["time_s"] <= 12.25)
            ax.plot(
                dataset["time_s"][mask],
                np.degrees(dataset[angle_key][mask]),
                label=label,
                color=color,
                linestyle=style,
                linewidth=width,
            )
        ax.axvspan(8.0, 8.25, color=GOLD, alpha=0.18, linewidth=0)
        ax.axhline(0.0, color="#A4AAAB", linewidth=0.7)
        ax.set_ylabel("受扰轴角度 (°)")
        ax.set_xlim(8.0, 12.25)
        max_abs = max(
            np.abs(np.asarray(line.get_ydata(), dtype=float)).max()
            for line in ax.lines
            if len(line.get_ydata())
        )
        ax.set_ylim(-1.18 * max_abs, 1.18 * max_abs)
        ax.text(0.02, 0.95, panel, transform=ax.transAxes, va="top", weight="bold", color=INK)
        ax.text(
            0.98,
            0.95,
            f"事件IAE改善 {result['improvement']:.2f}%",
            transform=ax.transAxes,
            va="top",
            ha="right",
            color=TEAL_DARK,
            weight="bold",
            bbox={"boxstyle": "round,pad=0.25", "facecolor": WHITE, "edgecolor": TEAL_LIGHT},
        )
        clean_axes(ax)

        diag = result["diagnostics"]
        mask = (diag["time_s"] >= 8.0) & (diag["time_s"] <= 12.25)
        band.fill_between(diag["time_s"][mask], 0.0, diag["ardg_blend"][mask], color=TEAL, alpha=0.75)
        band.axvspan(8.0, 8.25, color=GOLD, alpha=0.18, linewidth=0)
        band.set_ylim(0.0, 1.05)
        band.set_yticks([0, 1])
        band.set_ylabel("介入", labelpad=3)
        band.set_xlabel("时间 (s)")
        band.grid(False)
        band.spines["top"].set_visible(False)
        band.spines["right"].set_visible(False)
        band.spines["left"].set_color("#9AA0A1")
        band.spines["bottom"].set_color("#9AA0A1")
    axes[0, 0].legend(frameon=False, loc="lower right", ncol=2)
    average = float(np.mean([roll["improvement"], pitch["improvement"]]))
    fig.text(
        0.5,
        0.985,
        f"两个新增场景的姿态事件IAE平均降低 {average:.2f}%",
        ha="center",
        va="top",
        fontsize=13,
        weight="bold",
        color=TEAL_DARK,
    )
    return save_figure(fig, "FIG_B_angular_disturbance_comparison"), {
        "window_s": [8.0, 12.25],
        "disturbance_window_s": [8.0, 8.25],
        "roll_iae_baseline_rad_s": roll["iae_base"],
        "roll_iae_ardg_rgpc_rad_s": roll["iae_candidate"],
        "roll_improvement_percent": roll["improvement"],
        "pitch_iae_baseline_rad_s": pitch["iae_base"],
        "pitch_iae_ardg_rgpc_rad_s": pitch["iae_candidate"],
        "pitch_improvement_percent": pitch["improvement"],
        "average_improvement_percent": average,
    }


def scene06b_series(name: str, modern: bool | None = None) -> dict:
    if modern is None:
        with (DATA / name).open(encoding="utf-8-sig", newline="") as stream:
            fields = csv.DictReader(stream).fieldnames or []
        modern = "time" in fields and "time_s" not in fields

    if modern:
        columns = [
            "time",
            "referenceVector[1]",
            "referenceVector[2]",
            "referenceVector[3]",
            "quadChassisTest17_1.body.r_0[1]",
            "quadChassisTest17_1.body.r_0[2]",
            "quadChassisTest17_1.body.r_0[3]",
        ]
        raw = load_csv_columns(name, columns)
        time = raw["time"]
        reference = np.column_stack([raw[f"referenceVector[{i}]"] for i in range(1, 4)])
        position = np.column_stack([raw[f"quadChassisTest17_1.body.r_0[{i}]"] for i in range(1, 4)])
    else:
        columns = [
            "time_s",
            "reference_1",
            "reference_2",
            "reference_3",
            "position_x_m",
            "position_y_m",
            "position_z_m",
        ]
        raw = load_csv_columns(name, columns)
        time = raw["time_s"]
        reference = np.column_stack([raw[f"reference_{i}"] for i in range(1, 4)])
        position = np.column_stack([raw[axis] for axis in ("position_x_m", "position_y_m", "position_z_m")])
    error = np.linalg.norm(reference - position, axis=1)
    rmse = float(np.sqrt(np.mean(error**2)))
    return {"time": time, "error": error, "rmse": rmse}


def figure_c() -> tuple[list[Path], dict]:
    baseline = scene06b_series("Scene06b_baseline.csv")
    candidate = scene06b_series("Scene06b_ARDG-RGPC.csv")
    improvement = 100.0 * (baseline["rmse"] - candidate["rmse"]) / baseline["rmse"]
    fig, ax = plt.subplots(figsize=(11.6, 5.6))
    ax.plot(baseline["time"], baseline["error"], color=GRAY, linestyle="--", linewidth=1.7, label="升级前主算法")
    ax.plot(candidate["time"], candidate["error"], color=TEAL, linewidth=2.1, label="ARDG-RGPC")
    for index, (start, end) in enumerate([(8.0, 8.5), (14.0, 15.0), (20.0, 22.0)], start=1):
        ax.axvspan(start, end, color=GOLD, alpha=0.14, linewidth=0)
        ax.text((start + end) / 2.0, 0.98, f"外扰{index}", transform=ax.get_xaxis_transform(), ha="center", va="top", color=GOLD, fontsize=9)
    ax.set_xlim(0.0, 30.0)
    ax.set_xlabel("时间 (s)")
    ax.set_ylabel("三维位置误差 (m)")
    clean_axes(ax)
    ax.legend(
        frameon=False,
        loc="lower left",
        bbox_to_anchor=(0.0, 1.01),
        borderaxespad=0.0,
        ncol=2,
    )
    ax.text(
        0.98,
        0.95,
        f"全程位置RMSE\n{baseline['rmse']:.5f} m → {candidate['rmse']:.5f} m\n改善 {improvement:.2f}%",
        transform=ax.transAxes,
        ha="right",
        va="top",
        color=TEAL_DARK,
        weight="bold",
        bbox={"boxstyle": "round,pad=0.45", "facecolor": WHITE, "edgecolor": TEAL_LIGHT},
    )
    return save_figure(fig, "FIG_C_scene06b_position_recovery"), {
        "window_s": [0.0, 30.0],
        "disturbance_windows_s": [[8.0, 8.5], [14.0, 15.0], [20.0, 22.0]],
        "baseline_rmse_m": baseline["rmse"],
        "ardg_rgpc_rmse_m": candidate["rmse"],
        "improvement_percent": improvement,
    }


def figure_d() -> tuple[list[Path], dict]:
    result = load_json("regression18_analysis.json")
    comparison = result["comparison_vs_v914"]
    wins = int(comparison["candidate_wins"])
    losses = int(comparison["baseline_wins"])
    equivalent = int(comparison["equivalent_votes"])
    activity = float(result["aggregate_control_activity"]["v914"]["direct_improvement_percent"])
    fig, ax = plt.subplots(figsize=(11.5, 4.7))
    ax.set_xlim(0, 18)
    ax.set_ylim(-0.65, 0.75)
    ax.axis("off")
    left = 0
    segments = [(equivalent, "17项等效", GREEN_LIGHT, TEAL_DARK), (wins, "1项改善", TEAL_LIGHT, TEAL), (losses, "0项退化", GRAY_LIGHT, GRAY)]
    for value, label, fill, color in segments:
        if value:
            ax.barh(0.18, value, left=left, height=0.36, color=fill, edgecolor=WHITE)
            ax.text(left + value / 2, 0.18, label, ha="center", va="center", color=color, weight="bold", fontsize=13)
            left += value
    ax.text(0, -0.20, "18项代表性回归：1项改善、0项退化、17项等效", color=INK, weight="bold", fontsize=13)
    ax.text(0, -0.43, f"共同安全硬门全部通过；18场景四电机总变差汇总降低 {activity:.4f}%", color=GRAY, fontsize=11)
    return save_figure(fig, "FIG_D_regression18_summary"), {
        "improved": wins,
        "degraded": losses,
        "equivalent": equivalent,
        "aggregate_motor_tv_improvement_percent": activity,
        "hard_gates_passed": bool(result["hard_gates_passed"]),
    }


def figure_e() -> tuple[list[Path], dict]:
    stage_a = load_json("stage_a_campaign_summary.json")
    local = load_json("screen_summary.json")
    final = load_json("screen_analysis.json")
    stage_points = [record["objectives"] for record in stage_a["candidate_records"].values()]
    local_observations = local["observations"]
    local_points = [record["objectives"] for record in local_observations]
    final_record = next(record for record in local_observations if record["candidate_id"].endswith("L06"))
    final_objectives = final_record["objectives"]
    params = final["parameters"]

    fig, ax = plt.subplots(figsize=(10.6, 6.0))
    ax.scatter(
        [item["motor_tv_full"] for item in stage_points],
        [item["attitude_iae"] for item in stage_points],
        s=46,
        color="#A7B0B1",
        alpha=0.85,
        label="联合搜索候选（14组）",
    )
    ax.scatter(
        [item["motor_tv_full"] for item in local_points],
        [item["attitude_iae"] for item in local_points],
        s=58,
        marker="D",
        color=TEAL,
        alpha=0.78,
        label="局部搜索候选（8组）",
    )
    ax.scatter(
        [final_objectives["motor_tv_full"]],
        [final_objectives["attitude_iae"]],
        s=260,
        marker="*",
        color=GOLD,
        edgecolor=INK,
        linewidth=0.8,
        zorder=5,
        label="ARDG-RGPC最终定型",
    )
    ax.annotate(
        "最终定型",
        (final_objectives["motor_tv_full"], final_objectives["attitude_iae"]),
        xytext=(-18, 36),
        textcoords="offset points",
        arrowprops={"arrowstyle": "->", "color": GOLD, "linewidth": 1.2},
        color=TEAL_DARK,
        weight="bold",
        ha="right",
        va="bottom",
    )
    ax.set_xlabel("两个核心场景四电机总变差")
    ax.set_ylabel("两个核心场景姿态事件IAE (rad·s)")
    clean_axes(ax)
    ax.legend(frameon=False, loc="upper right")
    ax.text(
        0.02,
        0.04,
        "物理约束、多目标、分阶段局部优化\n"
        f"Kc={params['Kc']:.5f}，Cmax={params['Cmax_nm']:.7f} N·m\n"
        f"Rmax={params['Rmax_nm_per_sample']:.8f} N·m/采样",
        transform=ax.transAxes,
        va="bottom",
        color=GRAY,
        bbox={"boxstyle": "round,pad=0.35", "facecolor": WHITE, "edgecolor": TEAL_LIGHT},
    )
    return save_figure(fig, "FIG_E_parameter_optimization"), {
        "joint_candidates": len(stage_points),
        "local_candidates": len(local_points),
        "core_screening_runs": 44,
        "final_parameters": {
            "Kc": params["Kc"],
            "Cmax_nm": params["Cmax_nm"],
            "Rmax_nm_per_sample": params["Rmax_nm_per_sample"],
        },
        "weighted_sum_used": False,
        "global_optimum_claimed": False,
    }


def figure_f() -> tuple[list[Path], dict]:
    wcet = load_json("formal_wcet_adjudication.json")
    safety = load_json("static_integration_adjudication.json")
    codegen = load_json("codegen_completion.json")
    stats = wcet["statistics"]

    fig, ax = plt.subplots(figsize=(12.5, 5.1))
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    boxes = [
        (
            (0.02, 0.23),
            (0.22, 0.62),
            "双精度生成代码",
            [
                f"{codegen['execution']['generated_file_count']}项冻结工件",
                f"{codegen['execution']['generated_source_file_count']}个源文件",
                f"{codegen['execution']['generated_header_file_count']}个头文件",
                "正式模型保持不变",
            ],
            TEAL,
            TEAL_LIGHT,
        ),
        (
            (0.27, 0.23),
            (0.22, 0.62),
            "QPC高分辨率计时",
            [
                f"预热 {wcet['warmup_iterations']:,} 次",
                f"测量 {wcet['measured_iterations']:,} 次",
                f"P99 {stats['p99_ms']:.4f} ms",
                f"最大 {stats['maximum_ms']:.4f} ms",
            ],
            TEAL_DARK,
            GREEN_LIGHT,
        ),
        (
            (0.52, 0.23),
            (0.22, 0.62),
            "运行时资源",
            [
                f"动态分配 {wcet['dynamic_allocation_count']}",
                f"非正计时样本 {wcet['nonpositive_sample_count']}",
                "输出校验一致",
                "被测对象为生成代码Step函数",
            ],
            GOLD,
            GOLD_LIGHT,
        ),
        (
            (0.77, 0.23),
            (0.21, 0.62),
            "安全集成",
            [
                "剪裁安全旁路通过",
                "不可行分配旁路通过",
                "补偿幅值与变化率受限",
                "最终力矩保持物理边界",
            ],
            GRAY,
            GRAY_LIGHT,
        ),
    ]
    for xy, wh, title, lines, edge, fill in boxes:
        draw_box(ax, xy, wh, title, lines, edge=edge, fill=fill, title_size=13)
    ax.text(
        0.02,
        0.07,
        "正式计时采用 QueryPerformanceCounter；较早的 steady_clock 记录继续保留为未完成证据。",
        fontsize=11.2,
        weight="bold",
        color=TEAL_DARK,
    )
    return save_figure(fig, "FIG_F_engineering_validation"), {
        "generated_files": codegen["execution"]["generated_file_count"],
        "warmup_iterations": wcet["warmup_iterations"],
        "measured_iterations": wcet["measured_iterations"],
        "p99_ms": stats["p99_ms"],
        "maximum_ms": stats["maximum_ms"],
        "dynamic_allocation_count": wcet["dynamic_allocation_count"],
        "safety_cases_passed": all(case["passed"] for case in safety["cases"].values()),
    }


def contact_sheet(png_paths: list[Path]) -> Path:
    QA.mkdir(parents=True, exist_ok=True)
    thumbs = []
    for path in png_paths:
        image = Image.open(path).convert("RGB")
        image.thumbnail((900, 500))
        thumbs.append((path.name, image.copy()))
    width = 1840
    row_height = 570
    canvas = Image.new("RGB", (width, row_height * 3), WHITE)
    draw = ImageDraw.Draw(canvas)
    for index, (name, image) in enumerate(thumbs):
        column = index % 2
        row = index // 2
        x = 20 + column * 910
        y = 40 + row * row_height
        canvas.paste(image, (x, y + 35))
        draw.text((x, y), name, fill=INK)
    output = QA / "FIG_A_F_contact_sheet.png"
    canvas.save(output, dpi=(180, 180))
    return output


def main() -> None:
    setup_style()
    for name in SOURCE_ORIGINS:
        path = DATA / name
        if not path.is_file():
            raise RuntimeError(f"missing frozen source copy: {path}")

    figures = []
    for figure_id, builder in [
        ("A", figure_a),
        ("B", figure_b),
        ("C", figure_c),
        ("D", figure_d),
        ("E", figure_e),
        ("F", figure_f),
    ]:
        outputs, metrics = builder()
        figures.append(
            {
                "figure_id": figure_id,
                "outputs": [path.relative_to(ROOT).as_posix() for path in outputs],
                "metrics": metrics,
            }
        )

    png_paths = [ROOT / item["outputs"][0] for item in figures]
    sheet = contact_sheet(png_paths)
    sources = []
    for name in SOURCE_ORIGINS:
        copy = DATA / name
        sources.append(
            {
                "copy": copy.relative_to(ROOT).as_posix(),
                "bytes": copy.stat().st_size,
                "sha256": sha256(copy),
            }
        )
    outputs = []
    for item in figures:
        for relative in item["outputs"]:
            path = ROOT / relative
            outputs.append(
                {
                    "figure_id": item["figure_id"],
                    "path": relative,
                    "bytes": path.stat().st_size,
                    "sha256": sha256(path),
                }
            )
    outputs.append(
        {
            "figure_id": "QA",
            "path": sheet.relative_to(ROOT).as_posix(),
            "bytes": sheet.stat().st_size,
            "sha256": sha256(sheet),
        }
    )
    index = {
        "schema_version": "ardg_rgpc_final_shared_assets_v1",
        "public_algorithm_name": "ARDG-RGPC",
        "figures": figures,
        "sources": sources,
        "outputs": outputs,
        "usage_rule": "Reports, developer documentation, slides and videos must reuse these outputs and must not recalculate public metrics independently.",
    }
    (ROOT / "FINAL_ASSET_INDEX.json").write_text(
        json.dumps(index, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    qa = {
        "schema_version": "ardg_rgpc_final_shared_assets_qa_v1",
        "figure_count": len(figures),
        "png_count": len(list(PNG.glob("*.png"))),
        "pdf_count": len(list(PDF.glob("*.pdf"))),
        "contact_sheet": sheet.relative_to(ROOT).as_posix(),
        "claims": {
            "angular_iae_average_improvement_percent": figures[1]["metrics"]["average_improvement_percent"],
            "scene06b_position_rmse_improvement_percent": figures[2]["metrics"]["improvement_percent"],
            "regression18": {
                "improved": figures[3]["metrics"]["improved"],
                "degraded": figures[3]["metrics"]["degraded"],
                "equivalent": figures[3]["metrics"]["equivalent"],
            },
        },
        "checks": {
            "all_source_copies_present": all((DATA / name).is_file() for name in SOURCE_ORIGINS),
            "six_png_present": len(list(PNG.glob("*.png"))) == 6,
            "six_pdf_present": len(list(PDF.glob("*.pdf"))) == 6,
            "angular_claim_matches_43_30": abs(figures[1]["metrics"]["average_improvement_percent"] - 43.30) < 0.02,
            "scene06b_claim_matches_8_62": abs(figures[2]["metrics"]["improvement_percent"] - 8.62) < 0.02,
            "regression_claim_matches": figures[3]["metrics"]["improved"] == 1
            and figures[3]["metrics"]["degraded"] == 0
            and figures[3]["metrics"]["equivalent"] == 17,
        },
    }
    qa["pass"] = all(qa["checks"].values())
    (QA / "FINAL_ASSET_QA.json").write_text(
        json.dumps(qa, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(qa, ensure_ascii=False, indent=2))
    if not qa["pass"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
