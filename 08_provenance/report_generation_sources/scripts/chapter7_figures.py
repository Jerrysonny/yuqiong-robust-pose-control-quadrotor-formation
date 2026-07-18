from __future__ import annotations

import argparse
import csv
import hashlib
import json
from pathlib import Path

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.lines import Line2D


COLORS = {
    "uav1": "#0072B2",
    "uav2": "#D55E00",
    "uav3": "#009E73",
    "off": "#C73E1D",
    "on": "#0072B2",
    "reference": "#555555",
    "centroid": "#202020",
    "accent": "#CC79A7",
}


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def configure_style() -> None:
    mpl.rcParams.update(
        {
            "font.family": "sans-serif",
            "font.sans-serif": [
                "Microsoft YaHei",
                "SimHei",
                "Noto Sans CJK SC",
                "Arial Unicode MS",
                "DejaVu Sans",
            ],
            "font.size": 8.4,
            "axes.labelsize": 8.8,
            "axes.titlesize": 9.0,
            "axes.linewidth": 0.7,
            "axes.unicode_minus": False,
            "xtick.labelsize": 7.8,
            "ytick.labelsize": 7.8,
            "xtick.direction": "out",
            "ytick.direction": "out",
            "xtick.major.width": 0.6,
            "ytick.major.width": 0.6,
            "legend.fontsize": 7.5,
            "legend.frameon": False,
            "grid.color": "#D9D9D9",
            "grid.linewidth": 0.45,
            "grid.alpha": 0.7,
            "savefig.dpi": 360,
            "savefig.bbox": "tight",
            "savefig.pad_inches": 0.04,
            "svg.fonttype": "none",
            "pdf.fonttype": 42,
            "ps.fonttype": 42,
        }
    )


def finish_axis(ax: mpl.axes.Axes, panel: str) -> None:
    # 坐标轴、网格和分图标记使用统一样式。
    ax.grid(True, which="major", axis="both")
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.text(
        -0.12,
        1.04,
        panel,
        transform=ax.transAxes,
        fontsize=9.3,
        fontweight="bold",
        va="bottom",
    )


def save_figure(fig: mpl.figure.Figure, output_dir: Path, stem: str) -> list[Path]:
    outputs: list[Path] = []
    for extension in ("png", "pdf", "svg"):
        output = output_dir / f"{stem}.{extension}"
        fig.savefig(output)
        outputs.append(output)
    plt.close(fig)
    return outputs


def figure_7_1(source: pd.DataFrame, output_dir: Path) -> list[Path]:
    # 队形变换图同时展示参考轨迹、实际轨迹和关键时刻。
    fig, axes = plt.subplots(2, 2, figsize=(7.25, 5.65), constrained_layout=True)
    ax = axes[0, 0]
    colors = [COLORS["uav1"], COLORS["uav2"], COLORS["uav3"]]
    for vehicle, color in zip(range(1, 4), colors):
        ax.plot(
            source[f"uav{vehicle}_commanded_x_m"],
            source[f"uav{vehicle}_commanded_y_m"],
            color=color,
            linewidth=1.0,
            linestyle=(0, (3, 2)),
            alpha=0.85,
        )
        ax.plot(
            source[f"uav{vehicle}_actual_x_m"],
            source[f"uav{vehicle}_actual_y_m"],
            color=color,
            linewidth=1.45,
        )
        ax.scatter(
            source[f"uav{vehicle}_actual_x_m"].iloc[-1],
            source[f"uav{vehicle}_actual_y_m"].iloc[-1],
            s=16,
            color=color,
            edgecolor="white",
            linewidth=0.5,
            zorder=4,
        )
    handles = [
        Line2D([0], [0], color=color, lw=1.6, label=f"无人机{vehicle}")
        for vehicle, color in zip(range(1, 4), colors)
    ]
    handles.extend(
        [
            Line2D([0], [0], color="#444444", lw=1.5, label="实际轨迹"),
            Line2D(
                [0],
                [0],
                color="#444444",
                lw=1.0,
                linestyle=(0, (3, 2)),
                label="位置指令",
            ),
        ]
    )
    ax.legend(
        handles=handles,
        ncol=3,
        loc="lower center",
        bbox_to_anchor=(0.5, 1.01),
        columnspacing=0.9,
        handlelength=2.0,
    )
    ax.set_xlabel("x位置 / m")
    ax.set_ylabel("y位置 / m")
    ax.set_aspect("equal", adjustable="datalim")
    finish_axis(ax, "(a)")

    ax = axes[0, 1]
    ax.plot(
        source["time_s"],
        source["formation_error_follower2_m"],
        color=COLORS["uav2"],
        linewidth=1.15,
        label="跟随机2",
    )
    ax.plot(
        source["time_s"],
        source["formation_error_follower3_m"],
        color=COLORS["uav3"],
        linewidth=1.15,
        linestyle=(0, (4, 2)),
        label="跟随机3",
    )
    ax.fill_between(
        source["time_s"],
        0,
        source["formation_error_max_m"],
        color="#8F8F8F",
        alpha=0.10,
        linewidth=0,
    )
    ax.set_xlabel("时间 / s")
    ax.set_ylabel("相对队形误差 / m")
    ax.legend(loc="upper right", ncol=2)
    ax.set_ylim(bottom=0)
    finish_axis(ax, "(b)")

    ax = axes[1, 0]
    ax.plot(
        source["time_s"],
        source["minimum_pairwise_distance_m"],
        color=COLORS["on"],
        linewidth=1.35,
        label="最小两机中心间距",
    )
    ax.set_xlabel("时间 / s")
    ax.set_ylabel("最小两机中心间距 / m")
    ax.set_ylim(bottom=0)
    ax.legend(loc="lower right")
    finish_axis(ax, "(c)")

    ax = axes[1, 1]
    for vehicle, color in zip(range(1, 4), colors):
        ax.plot(
            source["time_s"],
            source[f"member{vehicle}_commanded_error_m"],
            color=color,
            linewidth=0.85,
            alpha=0.82,
            label=f"无人机{vehicle}",
        )
    ax.plot(
        source["time_s"],
        source["centroid_commanded_error_m"],
        color=COLORS["centroid"],
        linewidth=1.55,
        label="编队质心",
    )
    ax.set_xlabel("时间 / s")
    ax.set_ylabel("位置指令跟踪误差 / m")
    ax.set_ylim(bottom=0)
    ax.legend(loc="upper right", ncol=2)
    finish_axis(ax, "(d)")
    return save_figure(fig, output_dir, "figure_7_1_formation_coordination")


def annotate_minimum(
    ax: mpl.axes.Axes,
    time: pd.Series,
    values: pd.Series,
    text: str,
    color: str,
    offset: tuple[float, float],
) -> None:
    index = int(np.nanargmin(values.to_numpy()))
    x_value = float(time.iloc[index])
    y_value = float(values.iloc[index])
    ax.scatter([x_value], [y_value], s=24, color=color, edgecolor="white", linewidth=0.6, zorder=5)
    ax.annotate(
        f"{text}: {y_value:.3f} m",
        xy=(x_value, y_value),
        xytext=offset,
        textcoords="offset points",
        color=color,
        fontsize=7.5,
        ha="right" if offset[0] < 0 else "left",
        arrowprops={"arrowstyle": "-", "color": color, "lw": 0.7},
        bbox={"boxstyle": "round,pad=0.18", "fc": "white", "ec": color, "lw": 0.55, "alpha": 0.92},
    )


def figure_7_2(source: pd.DataFrame, output_dir: Path) -> list[Path]:
    # PP-CBF开关对照使用相同时间轴和安全距离阈值。
    fig, axes = plt.subplots(2, 1, figsize=(7.25, 5.0), sharex=True, constrained_layout=True)
    time = source["time_s"]
    threshold = float(source["project_evaluation_distance_m"].iloc[0])

    ax = axes[0]
    ax.plot(
        time,
        source["pp_cbf_off_minimum_distance_m"],
        color=COLORS["off"],
        linewidth=1.25,
        linestyle=(0, (5, 2)),
        label="PP-CBF关闭",
    )
    ax.plot(
        time,
        source["pp_cbf_on_minimum_distance_m"],
        color=COLORS["on"],
        linewidth=1.45,
        label="PP-CBF开启",
    )
    ax.axhline(
        threshold,
        color=COLORS["reference"],
        linewidth=0.95,
        linestyle=(0, (2, 2)),
        label=f"本文设定安全距离 {threshold:.2f} m",
    )
    annotate_minimum(
        ax,
        time,
        source["pp_cbf_off_minimum_distance_m"],
        "关闭",
        COLORS["off"],
        (-52, -18),
    )
    annotate_minimum(
        ax,
        time,
        source["pp_cbf_on_minimum_distance_m"],
        "开启",
        COLORS["on"],
        (42, 18),
    )
    ax.set_ylabel("最小两机中心间距 / m")
    ax.set_ylim(bottom=0)
    ax.legend(loc="upper right", ncol=3, columnspacing=1.0)
    finish_axis(ax, "(a)")

    ax = axes[1]
    ax.fill_between(
        time,
        0,
        source["pp_cbf_off_cumulative_exposure_s"],
        color=COLORS["off"],
        alpha=0.13,
        linewidth=0,
    )
    ax.plot(
        time,
        source["pp_cbf_off_cumulative_exposure_s"],
        color=COLORS["off"],
        linewidth=1.35,
        linestyle=(0, (5, 2)),
        label="PP-CBF关闭",
    )
    ax.plot(
        time,
        source["pp_cbf_on_cumulative_exposure_s"],
        color=COLORS["on"],
        linewidth=1.45,
        label="PP-CBF开启",
    )
    off_final = float(source["pp_cbf_off_cumulative_exposure_s"].iloc[-1])
    on_final = float(source["pp_cbf_on_cumulative_exposure_s"].iloc[-1])
    ax.text(
        0.985,
        0.82,
        f"累计风险暴露：{off_final:.2f} s → {on_final:.2f} s",
        transform=ax.transAxes,
        ha="right",
        va="top",
        fontsize=8.1,
        bbox={"boxstyle": "round,pad=0.22", "fc": "white", "ec": "#A0A0A0", "lw": 0.55},
    )
    ax.set_xlabel("时间 / s")
    ax.set_ylabel("累计风险暴露时间 / s")
    ax.set_ylim(bottom=0)
    ax.legend(loc="upper left", ncol=2)
    finish_axis(ax, "(b)")
    return save_figure(fig, output_dir, "figure_7_2_pp_cbf_safety_benefit")


def figure_a_1(source: pd.DataFrame, output_dir: Path) -> list[Path]:
    fig, axes = plt.subplots(3, 1, figsize=(7.25, 5.65), sharex=True, constrained_layout=True)
    time = source["time_s"]
    active = source["pp_cbf_active"].to_numpy() > 0.5

    ax = axes[0]
    ax.plot(
        time,
        source["reference_correction_max_m"],
        color=COLORS["accent"],
        linewidth=1.35,
        label="三机最大参考修正",
    )
    ax.plot(
        time,
        source["reference_correction_rms_m"],
        color=COLORS["centroid"],
        linewidth=0.95,
        linestyle=(0, (4, 2)),
        label="三机参考修正均方根",
    )
    ax.fill_between(
        time,
        0,
        1,
        where=active,
        transform=ax.get_xaxis_transform(),
        color=COLORS["on"],
        alpha=0.08,
        linewidth=0,
        label="PP-CBF介入区间",
    )
    ax.set_ylabel("位置参考修正 / m")
    ax.set_ylim(bottom=0)
    ax.legend(loc="upper right", ncol=3)
    finish_axis(ax, "(a)")

    ax = axes[1]
    ax.plot(
        time,
        source["projection_correction_mps2"],
        color=COLORS["on"],
        linewidth=1.25,
    )
    ax.fill_between(
        time,
        0,
        source["projection_correction_mps2"],
        color=COLORS["on"],
        alpha=0.11,
        linewidth=0,
    )
    ax.set_ylabel("投影修正 / (m/s²)")
    ax.set_ylim(bottom=0)
    finish_axis(ax, "(b)")

    ax = axes[2]
    ax.step(
        time,
        source["pp_cbf_active"],
        where="post",
        color=COLORS["on"],
        linewidth=1.2,
        label="监督器激活",
    )
    ax.step(
        time,
        source["infeasible"],
        where="post",
        color=COLORS["off"],
        linewidth=1.0,
        linestyle=(0, (5, 2)),
        label="求解不可行",
    )
    ax.step(
        time,
        source["output_hold"],
        where="post",
        color=COLORS["accent"],
        linewidth=1.0,
        linestyle=(0, (2, 2)),
        label="输出保持",
    )
    ax.set_xlabel("时间 / s")
    ax.set_ylabel("离散状态")
    ax.set_yticks([0, 1])
    ax.set_ylim(-0.08, 1.15)
    ax.legend(loc="upper right", ncol=3)
    finish_axis(ax, "(c)")
    return save_figure(fig, output_dir, "figure_A_1_pp_cbf_intervention_diagnostics")


def write_manifest(output_dir: Path, source_paths: list[Path], outputs: list[Path]) -> None:
    # 清单记录源数据和全部输出图件的文件哈希。
    rows = []
    for path in source_paths + outputs:
        rows.append(
            {
                "file": str(path.resolve()),
                "kind": "source" if path in source_paths else "figure",
                "bytes": path.stat().st_size,
                "sha256": sha256_file(path),
            }
        )
    manifest_csv = output_dir / "figure_manifest.csv"
    with manifest_csv.open("w", encoding="utf-8-sig", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=["file", "kind", "bytes", "sha256"])
        writer.writeheader()
        writer.writerows(rows)
    manifest_json = output_dir / "figure_manifest.json"
    manifest_json.write_text(
        json.dumps({"files": rows}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("derived_dir", type=Path)
    parser.add_argument("output_dir", type=Path)
    args = parser.parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    source_paths = [
        args.derived_dir / "figure_7_1_source.csv",
        args.derived_dir / "figure_7_2_source.csv",
        args.derived_dir / "figure_A_1_source.csv",
    ]
    for path in source_paths:
        if not path.is_file():
            raise FileNotFoundError(path)

    configure_style()
    outputs: list[Path] = []
    outputs.extend(figure_7_1(pd.read_csv(source_paths[0]), args.output_dir))
    outputs.extend(figure_7_2(pd.read_csv(source_paths[1]), args.output_dir))
    outputs.extend(figure_a_1(pd.read_csv(source_paths[2]), args.output_dir))
    write_manifest(args.output_dir, source_paths, outputs)
    print(f"chapter 7 figures: PASS ({len(outputs)} files)")


if __name__ == "__main__":
    main()
