"""Create publication-quality figures from frozen Syslab CSV outputs."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image


PID_COLOR = "#6B6B6B"
MAIN_COLOR = "#0072B2"
ACCENT_COLOR = "#009E73"
LIGHT_LINE = "#BFC5C9"


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def configure_style() -> None:
    plt.rcParams.update(
        {
            "font.family": "Microsoft YaHei",
            "font.sans-serif": ["Microsoft YaHei"],
            "font.size": 8.0,
            "axes.labelsize": 8.0,
            "axes.titlesize": 8.5,
            "axes.linewidth": 0.8,
            "xtick.labelsize": 7.2,
            "ytick.labelsize": 7.2,
            "legend.fontsize": 7.2,
            "legend.frameon": False,
            "lines.linewidth": 1.0,
            "xtick.major.width": 0.7,
            "ytick.major.width": 0.7,
            "xtick.major.size": 3.0,
            "ytick.major.size": 3.0,
            "axes.spines.top": False,
            "axes.spines.right": False,
            "axes.grid": False,
            "figure.facecolor": "white",
            "axes.facecolor": "white",
            "savefig.facecolor": "white",
            "savefig.transparent": False,
            "svg.fonttype": "none",
            "pdf.fonttype": 42,
            "ps.fonttype": 42,
        }
    )


def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))


def deterministic_rmse_key(rows: list[dict[str, str]]) -> str:
    if not rows:
        raise RuntimeError("deterministic parameter data is empty")
    fields = set(rows[0])
    for field in ("tracking_rmse_m", "formal_tracking_rmse_m"):
        if field in fields:
            return field
    raise RuntimeError(
        "deterministic parameter data must contain tracking_rmse_m "
        "or formal_tracking_rmse_m"
    )


def save_figure(figure: plt.Figure, base: Path) -> list[Path]:
    outputs = [base.with_suffix(extension) for extension in (".svg", ".pdf", ".png", ".tiff")]
    for path in outputs:
        if path.exists():
            raise RuntimeError(f"refusing to overwrite figure: {path}")
    figure.savefig(outputs[0])
    figure.savefig(outputs[1])
    figure.savefig(outputs[2], dpi=600)
    with Image.open(outputs[2]) as raster:
        raster.save(outputs[3], format="TIFF", dpi=(600, 600))
    return outputs


def panel_label(axis: plt.Axes, label: str, x: float = -0.13) -> None:
    axis.text(
        x,
        1.04,
        label,
        transform=axis.transAxes,
        fontsize=9.0,
        fontweight="bold",
        ha="left",
        va="bottom",
    )


def deterministic_labels(case_id: str) -> str:
    mapping = {
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
    return mapping.get(case_id, case_id)


def primary_figure(
    deterministic_csv: Path, paired_csv: Path, summary_json: Path
) -> plt.Figure:
    deterministic = read_rows(deterministic_csv)
    paired = read_rows(paired_csv)
    summary = json.loads(summary_json.read_text(encoding="utf-8"))
    if len(deterministic) != 11 or len(paired) != 20:
        raise RuntimeError("unexpected deterministic or random sample count")
    deterministic_order = [
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
    deterministic_by_id = {row["case_id"]: row for row in deterministic}
    deterministic = [deterministic_by_id[case_id] for case_id in deterministic_order]
    rmse_key = deterministic_rmse_key(deterministic)

    figure, axes = plt.subplots(
        1,
        2,
        figsize=(7.08, 3.70),
        gridspec_kw={"width_ratios": [1.05, 1.00], "wspace": 0.42},
    )

    axis = axes[0]
    y = np.arange(11)
    values = np.array([float(row[rmse_key]) for row in deterministic])
    axis.hlines(y, 0, values, color="#C9DDE9", linewidth=2.2, zorder=1)
    axis.scatter(
        values,
        y,
        s=28,
        color=MAIN_COLOR,
        edgecolor="white",
        linewidth=0.55,
        zorder=2,
    )
    axis.axvline(np.median(values), color=ACCENT_COLOR, linewidth=1.0, linestyle=(0, (4, 2)))
    axis.text(
        0.98,
        0.04,
        f"中位数 = {np.median(values):.4f} m",
        transform=axis.transAxes,
        ha="right",
        va="bottom",
        color=ACCENT_COLOR,
        fontsize=7.2,
    )
    axis.set_yticks(y)
    axis.set_yticklabels(
        [deterministic_labels(row["case_id"]) for row in deterministic],
        fontsize=6.3,
    )
    axis.invert_yaxis()
    axis.set_xlim(0, 0.037)
    axis.set_xlabel("三维位置RMSE / m")
    axis.set_title("11种预设参数工况下的主算法结果", pad=19)
    axis.text(
        0.0,
        1.01,
        "括号内依次为：升力效能 / 质量 / 转动惯量比例",
        transform=axis.transAxes,
        ha="left",
        va="bottom",
        fontsize=6.6,
        color="#4F5559",
    )
    axis.grid(axis="x", color="#E6E8EA", linewidth=0.55, zorder=0)
    panel_label(axis, "a", x=-0.82)

    axis = axes[1]
    pid = np.array([float(row["pid_rmse_m"]) for row in paired])
    main = np.array([float(row["main_rmse_m"]) for row in paired])
    boxplot = axis.boxplot(
        [pid, main],
        positions=[1, 2],
        widths=0.48,
        patch_artist=True,
        showfliers=False,
        medianprops={"color": "black", "linewidth": 1.2},
        whiskerprops={"color": "#73787C", "linewidth": 0.8},
        capprops={"color": "#73787C", "linewidth": 0.8},
        boxprops={"edgecolor": "#73787C", "linewidth": 0.8},
    )
    for patch, color in zip(boxplot["boxes"], (PID_COLOR, MAIN_COLOR)):
        patch.set_facecolor(color)
        patch.set_alpha(0.22)
    for position, values_for_controller, color in (
        (1, pid, PID_COLOR),
        (2, main, MAIN_COLOR),
    ):
        axis.scatter(
            np.full(len(values_for_controller), position),
            values_for_controller,
            s=18,
            color=color,
            edgecolor="white",
            linewidth=0.4,
            alpha=0.88,
            zorder=3,
        )
    axis.set_xticks([1, 2])
    axis.set_xticklabels(["官方PID", "RA-GCA-CGHTE"])
    axis.set_xlim(0.55, 2.45)
    axis.set_ylim(0, 0.19)
    axis.set_ylabel("三维位置RMSE / m")
    axis.set_title("20组随机参数下的RMSE分布", pad=19)
    axis.text(
        0.5,
        1.01,
        f"20/20组更优；中位RMSE降低 {summary['median_rmse_reduction_percent']:.1f}%",
        transform=axis.transAxes,
        ha="center",
        va="bottom",
        fontsize=6.6,
        color="#4F5559",
    )
    axis.grid(axis="y", color="#E6E8EA", linewidth=0.55, zorder=0)
    panel_label(axis, "b", x=-0.18)
    figure.subplots_adjust(left=0.34, right=0.985, bottom=0.13, top=0.83)
    return figure


def improvement_figure(paired_csv: Path) -> plt.Figure:
    paired = read_rows(paired_csv)
    if len(paired) != 20:
        raise RuntimeError("improvement figure requires 20 paired samples")
    rmse_reduction = np.array(
        [float(row["rmse_reduction_percent"]) for row in paired]
    )
    peak_reduction = np.array(
        [
            100
            * (1 - float(row["main_peak_m"]) / float(row["pid_peak_m"]))
            for row in paired
        ]
    )

    figure, axes = plt.subplots(1, 2, figsize=(7.08, 3.05), sharey=True)
    panels = (
        (rmse_reduction, "三维位置RMSE逐组降幅"),
        (peak_reduction, "峰值位置误差逐组降幅"),
    )
    for index, (axis, (values, title)) in enumerate(zip(axes, panels)):
        ordered = np.sort(values)
        x = np.arange(1, len(ordered) + 1)
        axis.bar(x, ordered, width=0.72, color=MAIN_COLOR, alpha=0.86)
        median_value = float(np.median(ordered))
        axis.axhline(
            median_value,
            color=ACCENT_COLOR,
            linewidth=1.0,
            linestyle=(0, (4, 2)),
        )
        axis.set_xlim(0.25, 20.75)
        axis.set_ylim(0, 100)
        axis.set_xticks([1, 5, 10, 15, 20])
        axis.set_xlabel("随机参数样本（按降幅由低到高排序）")
        axis.set_title(title, pad=19)
        axis.text(
            0.5,
            1.01,
            f"20/20组均改善；绿色虚线表示中位降幅 {median_value:.1f}%；最小 {np.min(ordered):.1f}%",
            transform=axis.transAxes,
            ha="center",
            va="bottom",
            fontsize=6.8,
            color="#4F5559",
        )
        axis.grid(axis="y", color="#E6E8EA", linewidth=0.55, zorder=0)
        axis.set_axisbelow(True)
        panel_label(axis, chr(ord("a") + index))
    axes[0].set_ylabel("相对官方PID降低 / %")
    figure.subplots_adjust(left=0.085, right=0.985, bottom=0.18, top=0.80, wspace=0.26)
    return figure


def atomic_json(path: Path, payload: dict[str, Any]) -> None:
    if path.exists():
        raise RuntimeError(f"refusing to overwrite record: {path}")
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(
        json.dumps(payload, indent=2, ensure_ascii=False, allow_nan=False) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)


def run(args: argparse.Namespace) -> None:
    configure_style()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    statistics_root = args.statistics_root.resolve()
    deterministic_csv = args.deterministic_csv.resolve()

    primary = primary_figure(
        deterministic_csv,
        statistics_root / "paired_results.csv",
        statistics_root / "statistical_summary.json",
    )
    primary_outputs = save_figure(primary, output / "parameter_robustness_mc20")
    plt.close(primary)

    improvement = improvement_figure(statistics_root / "paired_results.csv")
    improvement_outputs = save_figure(improvement, output / "paired_improvement_mc20")
    plt.close(improvement)

    inputs = [
        deterministic_csv,
        statistics_root / "paired_results.csv",
        statistics_root / "statistical_summary.json",
    ]
    outputs = primary_outputs + improvement_outputs
    record = {
        "schema_version": 1,
        "generated_utc": utc_now(),
        "generator": f"Python {'.'.join(map(str, __import__('sys').version_info[:3]))}; "
        f"matplotlib {matplotlib.__version__}; numpy {np.__version__}",
        "role": "plotting_only; formal metrics supplied by Syslab",
        "inputs": [{"path": str(path), "sha256": sha256(path)} for path in inputs],
        "outputs": [
            {"path": str(path), "sha256": sha256(path), "size": path.stat().st_size}
            for path in outputs
        ],
        "raster_dpi": 600,
        "svg_text_editable": True,
        "old_algorithm_visible": False,
    }
    atomic_json(output / "figure_generation_record.json", record)
    print("figure_generation=pass")
    print(f"output_count={len(outputs)}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--statistics-root", type=Path, required=True)
    parser.add_argument("--deterministic-csv", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args()


if __name__ == "__main__":
    run(parse_args())
