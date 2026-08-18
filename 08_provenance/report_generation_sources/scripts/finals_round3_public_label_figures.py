from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


ALGORITHM = "ARDG-RGPC"
GEOMETRIC_BASELINE_KEY = "RA-GCA/Base"
DISPLAY_NAMES = {
    "PID": "官方PID",
    GEOMETRIC_BASELINE_KEY: "几何控制基线",
    ALGORITHM: ALGORITHM,
}
TEAL = "#007C83"
CHARCOAL = "#374151"
GRAY = "#9CA3AF"
GREEN = "#2F855A"
BLUE = "#2B6CB0"
PURPLE = "#6B46C1"
GRID = "#E5E7EB"


def configure_style() -> None:
    plt.rcParams.update(
        {
            "font.family": "sans-serif",
            "font.sans-serif": ["Microsoft YaHei", "SimHei", "Arial", "DejaVu Sans"],
            "axes.unicode_minus": False,
            "font.size": 9.5,
            "axes.labelsize": 9.5,
            "axes.titlesize": 9.5,
            "xtick.labelsize": 8.5,
            "ytick.labelsize": 8.5,
            "legend.fontsize": 8.2,
            "axes.edgecolor": "#6B7280",
            "axes.linewidth": 0.7,
            "axes.spines.top": False,
            "axes.spines.right": False,
            "grid.color": GRID,
            "grid.linewidth": 0.6,
            "savefig.facecolor": "white",
            "figure.facecolor": "white",
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


def clean_axis(axis: plt.Axes, *, grid: str = "y") -> None:
    if grid == "x":
        axis.grid(axis="x")
    elif grid == "both":
        axis.grid(axis="both")
    else:
        axis.grid(axis="y")
    axis.set_axisbelow(True)


def label_panel(axis: plt.Axes, label: str) -> None:
    axis.text(-0.10, 1.05, label, transform=axis.transAxes, ha="left", va="bottom", fontsize=10.3, fontweight="bold")


def save_all(figure: plt.Figure, stem: Path) -> list[Path]:
    outputs = [stem.with_suffix(suffix) for suffix in (".png", ".pdf", ".svg")]
    for output in outputs:
        if output.exists():
            raise FileExistsError(f"Refusing to overwrite staged figure: {output}")
    figure.savefig(outputs[0], dpi=240, bbox_inches="tight", pad_inches=0.05)
    figure.savefig(outputs[1], bbox_inches="tight", pad_inches=0.05)
    figure.savefig(outputs[2], bbox_inches="tight", pad_inches=0.05)
    plt.close(figure)
    return outputs


def load_common(root: Path) -> pd.DataFrame:
    path = root / "05_visuals" / "assets" / "report_sources" / "data" / "FIG_6-4__figure_6_4_five_controller_common.csv"
    data = pd.read_csv(path)
    expected = {"PID", GEOMETRIC_BASELINE_KEY, ALGORITHM, "CAP-ADRC", "CP-INDI"}
    if set(data["controller"].astype(str)) != expected or len(data) != 20:
        raise RuntimeError("Five-controller common-scene source contract changed")
    return data


def build_figure_6_4(common: pd.DataFrame, stem: Path) -> list[Path]:
    cases = [("Scene01", "分段爬升"), ("Scene04", "定点悬停"), ("Scene03", "8字轨迹"), ("Scene06b", "三事件外力扰动")]
    order = ["PID", GEOMETRIC_BASELINE_KEY, ALGORITHM, "CAP-ADRC", "CP-INDI"]
    palette = {"PID": CHARCOAL, GEOMETRIC_BASELINE_KEY: GRAY, ALGORITHM: TEAL, "CAP-ADRC": GREEN, "CP-INDI": PURPLE}
    markers = {"PID": "o", GEOMETRIC_BASELINE_KEY: "s", ALGORITHM: "o", "CAP-ADRC": "^", "CP-INDI": "P"}
    figure, axes = plt.subplots(2, 2, figsize=(12.4, 7.2))
    for index, (axis, (case_id, scene_name)) in enumerate(zip(axes.flat, cases)):
        subset = common[common["case_id"] == case_id].copy()
        subset["controller"] = pd.Categorical(subset["controller"], order, ordered=True)
        subset = subset.sort_values("controller")
        y = np.arange(len(subset))
        for row, y_position in zip(subset.itertuples(), y):
            controller = str(row.controller)
            axis.scatter(
                row.tracking_rmse_m,
                y_position,
                s=44 if controller == ALGORITHM else 34,
                color=palette[controller],
                marker=markers[controller],
                zorder=3,
            )
            axis.text(row.tracking_rmse_m, y_position, f"  {row.tracking_rmse_m:.4f}", va="center", fontsize=8)
        axis.set_yticks(y, [DISPLAY_NAMES.get(str(item), str(item)) for item in subset["controller"]])
        axis.set_xlabel("三维位置RMSE / m")
        clean_axis(axis, grid="x")
        label_panel(axis, f"({chr(97 + index)}) {scene_name}")
        axis.invert_yaxis()
    figure.subplots_adjust(hspace=0.36, wspace=0.42)
    return save_all(figure, stem)


def load_parameter_evidence(root: Path) -> tuple[pd.DataFrame, pd.DataFrame, dict[str, object]]:
    parameter11 = pd.read_csv(root / "04_results" / "report_evidence" / "parameter11_ardg_rgpc_final" / "parameter11_final_paired.csv")
    random20 = pd.read_csv(root / "04_results" / "report_evidence" / "parameter_random20_ardg_rgpc_final" / "paired_results.csv")
    manifest = json.loads((root / "05_visuals" / "FINALS_VISUAL_REVISION_MANIFEST_20260816.json").read_text(encoding="utf-8"))
    if len(parameter11) != 11 or len(random20) != 20:
        raise RuntimeError("Parameter evidence sample count changed")
    if "classification_vs_geometric_baseline" not in parameter11.columns:
        parameter11 = parameter11.rename(columns={"classification_vs_reference_baseline": "classification_vs_geometric_baseline"})
    return parameter11, random20, manifest


def build_figure_8_1(
    common: pd.DataFrame,
    parameter11: pd.DataFrame,
    random20: pd.DataFrame,
    manifest: dict[str, object],
    stem: Path,
) -> list[Path]:
    metrics = manifest["metrics"]
    angular = metrics["angular"]
    scene06b = metrics["scene06b"]
    figure, axes = plt.subplots(2, 2, figsize=(12.4, 7.2))

    scene = common[common["case_id"] == "Scene06b"].copy().sort_values("tracking_rmse_m")
    colors = [TEAL if str(item) == ALGORITHM else CHARCOAL if str(item) == "PID" else GRAY for item in scene["controller"]]
    axes[0, 0].barh(np.arange(len(scene)), scene["tracking_rmse_m"], color=colors)
    axes[0, 0].set_yticks(np.arange(len(scene)), [DISPLAY_NAMES.get(str(item), str(item)) for item in scene["controller"]])
    axes[0, 0].set_xlabel("三事件外力扰动RMSE / m")
    axes[0, 0].invert_yaxis()
    clean_axis(axes[0, 0], grid="x")
    label_panel(axes[0, 0], "(a) 复杂外扰下的算法比较")

    improved = int((parameter11["classification_vs_geometric_baseline"].astype(str) == "improved").sum())
    random_wins = int((random20["ardg_vs_pid_reduction_percent"].astype(float) > 0.0).sum())
    evidence_counts = [improved, random_wins, 10]
    axes[0, 1].bar([0, 1, 2], evidence_counts, color=[TEAL, GREEN, BLUE])
    axes[0, 1].set_xticks([0, 1, 2], ["预设参数\n改善", "随机参数\n胜官方PID", "风扰/传感器\n有效相位"])
    axes[0, 1].set_ylabel("工况数")
    clean_axis(axes[0, 1])
    label_panel(axes[0, 1], "(b) 鲁棒性与泛化证据")
    for bars in axes[0, 1].containers:
        axes[0, 1].bar_label(bars, padding=2, fontsize=8.3)

    attitude_iae = [
        float(angular["BODY_ROLL_POS_ardg_rgpc_event_iae_rad_s"]),
        float(angular["BODY_PITCH_NEG_ardg_rgpc_event_iae_rad_s"]),
    ]
    axes[1, 0].bar([0, 1], attitude_iae, color=[TEAL, GREEN])
    axes[1, 0].set_xticks([0, 1], ["正滚转冲击", "负俯仰冲击"])
    axes[1, 0].set_ylabel("姿态事件IAE / rad·s")
    clean_axis(axes[1, 0])
    label_panel(axes[1, 0], "(c) 机体系角扰动响应")
    for bars in axes[1, 0].containers:
        axes[1, 0].bar_label(bars, fmt="%.5f", padding=2, fontsize=8.2)

    median_reduction = float(random20["ardg_vs_pid_reduction_percent"].median())
    gains = [median_reduction, float(scene06b["reduction_percent"])]
    axes[1, 1].bar([0, 1], gains, color=[GREEN, TEAL])
    axes[1, 1].set_xticks([0, 1], ["随机参数20组\nRMSE中位降幅", "三事件外扰\nRMSE降幅"])
    axes[1, 1].set_ylabel("相对官方PID降幅 / %")
    clean_axis(axes[1, 1])
    label_panel(axes[1, 1], "(d) 相对官方PID的代表性收益")
    for bars in axes[1, 1].containers:
        axes[1, 1].bar_label(bars, fmt="%.2f%%", padding=2, fontsize=8.3)
    figure.subplots_adjust(hspace=0.36, wspace=0.40)
    return save_all(figure, stem)


def build(root: Path, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    configure_style()
    common = load_common(root)
    parameter11, random20, manifest = load_parameter_evidence(root)
    outputs = []
    outputs.extend(build_figure_6_4(common, output_dir / "FIG_6-4"))
    outputs.extend(build_figure_8_1(common, parameter11, random20, manifest, output_dir / "FIG_8-1"))
    forbidden_visible = ["RA-GCA/Base", "RA-GCA-CGHTE", "v914", "v936", "L06", "97406"]
    for svg in output_dir.glob("*.svg"):
        text = svg.read_text(encoding="utf-8")
        found = [token for token in forbidden_visible if token in text]
        if found:
            raise RuntimeError(f"Internal label remains in {svg.name}: {found}")
    record = {
        "schema_version": 1,
        "role": "round-3 public comparator label repair",
        "public_algorithm": ALGORITHM,
        "source_files": [
            "05_visuals/assets/report_sources/data/FIG_6-4__figure_6_4_five_controller_common.csv",
            "04_results/report_evidence/parameter11_ardg_rgpc_final/parameter11_final_paired.csv",
            "04_results/report_evidence/parameter_random20_ardg_rgpc_final/paired_results.csv",
            "05_visuals/FINALS_VISUAL_REVISION_MANIFEST_20260816.json",
        ],
        "outputs": [
            {"path": path.name, "bytes": path.stat().st_size, "sha256": sha256(path)}
            for path in outputs
        ],
    }
    (output_dir / "PUBLIC_LABEL_BUILD_RECORD.json").write_text(json.dumps(record, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(record, ensure_ascii=False, indent=2))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()
    build(args.root.resolve(), args.output_dir.resolve())


if __name__ == "__main__":
    main()
