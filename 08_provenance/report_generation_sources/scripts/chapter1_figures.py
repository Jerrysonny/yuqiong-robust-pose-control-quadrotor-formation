from __future__ import annotations

import csv
import importlib.util
from pathlib import Path

import matplotlib.pyplot as plt
import networkx as nx
import numpy as np
from matplotlib.colors import LinearSegmentedColormap
from PIL import Image


ROOT = Path(r"D:\Users\admin\Desktop\A8-四旋翼无人机位姿控制系统设计优化")
LANDSCAPE_ROOT = (
    ROOT
    / "A8赛题核心工作区"
    / "仿真报告规划_20260712"
    / "01_第一章稳定内容试写"
    / "文献计量热点图_20260713"
)
SOURCE_SCRIPT = LANDSCAPE_ROOT / "scripts" / "build_openalex_landscape.py"
CLEAN_DATA = LANDSCAPE_ROOT / "data" / "openalex_control_works_2015_2025.csv"
FIGURE_DIR = Path(__file__).resolve().parent / "figures"
MAIN_STEM = FIGURE_DIR / "figure_1_1_publication_theme"
APPENDIX_STEM = FIGURE_DIR / "appendix_a_1_keyword_density"


def load_landscape_module():
    # 动态加载文献分析模块，避免复制其统计实现。
    spec = importlib.util.spec_from_file_location("a8_openalex_landscape", SOURCE_SCRIPT)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Unable to load plotting module: {SOURCE_SCRIPT}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def load_clean_rows() -> list[dict[str, str]]:
    with CLEAN_DATA.open("r", encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle))


def save_figure(figure: plt.Figure, stem: Path) -> None:
    # 同步输出位图和矢量底稿，保持版式来源一致。
    figure.savefig(stem.with_suffix(".png"), dpi=320, facecolor="white")
    figure.savefig(stem.with_suffix(".pdf"), facecolor="white")
    figure.savefig(stem.with_suffix(".svg"), facecolor="white")
    plt.close(figure)


def plot_main(module, stats: dict) -> None:
    years, theme_keys, matrix = module.theme_matrix(stats)
    counts = [stats["year_counts"][year] for year in years]

    width_inches = 15.2 / 2.54
    height_inches = 10.4 / 2.54
    figure = plt.figure(figsize=(width_inches, height_inches))
    grid = figure.add_gridspec(
        2,
        1,
        height_ratios=(0.88, 1.55),
        left=0.235,
        right=0.915,
        bottom=0.105,
        top=0.965,
        hspace=0.38,
    )
    axis_top = figure.add_subplot(grid[0])
    axis_bottom = figure.add_subplot(grid[1])

    axis_top.bar(
        years,
        counts,
        color="#397C89",
        width=0.68,
        edgecolor="white",
        linewidth=0.45,
    )
    axis_top.plot(
        years,
        counts,
        color="#C6533E",
        linewidth=1.25,
        marker="o",
        markersize=3.1,
    )
    axis_top.set_ylabel("论文数量", fontsize=9)
    axis_top.set_xticks(years)
    axis_top.tick_params(axis="both", labelsize=8)
    axis_top.set_ylim(0, max(counts) * 1.11)
    axis_top.grid(axis="y", color="#D8D8D8", linewidth=0.5, alpha=0.75)
    axis_top.spines[["top", "right"]].set_visible(False)
    axis_top.text(
        -0.185,
        1.02,
        "a",
        transform=axis_top.transAxes,
        fontsize=10,
        fontweight="bold",
    )

    image = axis_bottom.imshow(matrix, aspect="auto", cmap="YlGnBu", vmin=0.0)
    axis_bottom.set_xticks(range(len(years)), years)
    axis_bottom.set_yticks(
        range(len(theme_keys)),
        [module.THEMES[key]["label"] for key in theme_keys],
    )
    axis_bottom.set_xlabel("发表年份", fontsize=9)
    axis_bottom.tick_params(axis="both", labelsize=8)
    for row in range(matrix.shape[0]):
        for column in range(matrix.shape[1]):
            value = matrix[row, column]
            axis_bottom.text(
                column,
                row,
                f"{value:.0f}",
                ha="center",
                va="center",
                fontsize=8,
                color="white" if value > 0.62 * matrix.max() else "#222222",
            )
    colorbar = figure.colorbar(image, ax=axis_bottom, fraction=0.038, pad=0.025)
    colorbar.set_label("当年相关论文占比（%）", fontsize=8.5)
    colorbar.ax.tick_params(labelsize=8)
    axis_bottom.text(
        -0.185,
        1.02,
        "b",
        transform=axis_bottom.transAxes,
        fontsize=10,
        fontweight="bold",
    )
    save_figure(figure, MAIN_STEM)


def plot_appendix(module, graph: nx.Graph, positions: dict) -> None:
    positions = module.normalize_positions(positions)
    xx, yy, zz = module.density_grid(graph, positions)
    cmap = LinearSegmentedColormap.from_list(
        "chapter1_report_density",
        ("#F8FAFA", "#D8ECE4", "#73B8A2", "#F1C75B", "#C44E3B"),
    )

    width_inches = 14.8 / 2.54
    height_inches = 11.5 / 2.54
    figure = plt.figure(figsize=(width_inches, height_inches))
    axis = figure.add_axes((0.025, 0.035, 0.865, 0.93))
    image = axis.contourf(xx, yy, zz, levels=24, cmap=cmap)
    counts = nx.get_node_attributes(graph, "count")
    top_nodes = sorted(graph.nodes, key=lambda node: counts[node], reverse=True)[:16]
    for node in top_nodes:
        axis.text(
            positions[node][0],
            positions[node][1],
            graph.nodes[node]["label"],
            fontsize=8.2,
            ha="center",
            va="center",
            bbox={
                "boxstyle": "round,pad=0.11",
                "facecolor": "white",
                "edgecolor": "none",
                "alpha": 0.72,
            },
        )
    axis.set_xlim(-1.25, 1.25)
    axis.set_ylim(-1.15, 1.15)
    axis.set_aspect("equal")
    axis.axis("off")
    colorbar_axis = figure.add_axes((0.915, 0.07, 0.025, 0.86))
    colorbar = figure.colorbar(image, cax=colorbar_axis)
    colorbar.set_label("相对研究密度", fontsize=8.5)
    colorbar.ax.tick_params(labelsize=8)
    save_figure(figure, APPENDIX_STEM)


def main() -> None:
    # 主图与附录图共用同一清洗数据和网络布局。
    if not SOURCE_SCRIPT.exists() or not CLEAN_DATA.exists():
        raise FileNotFoundError("Frozen OpenAlex script or clean corpus is missing")
    outputs = [stem.with_suffix(suffix) for stem in (MAIN_STEM, APPENDIX_STEM) for suffix in (".png", ".pdf", ".svg")]
    if any(path.exists() for path in outputs):
        raise FileExistsError("Second-handoff figure output already exists")
    FIGURE_DIR.mkdir(parents=True)

    module = load_landscape_module()
    module.configure_matplotlib()
    rows = load_clean_rows()
    if len(rows) != 6153:
        raise RuntimeError(f"Expected 6153 frozen works, got {len(rows)}")
    stats = module.build_statistics(rows)
    graph, positions, _ = module.build_graph(stats)

    plot_main(module, stats)
    plot_appendix(module, graph, positions)

    for path in (MAIN_STEM.with_suffix(".png"), APPENDIX_STEM.with_suffix(".png")):
        with Image.open(path) as image:
            print(f"{path.name}: {image.width}x{image.height} px")
    for path in outputs:
        print(f"output={path}")


if __name__ == "__main__":
    main()
