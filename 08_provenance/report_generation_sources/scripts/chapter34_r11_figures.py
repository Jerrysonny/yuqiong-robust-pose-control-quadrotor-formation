from __future__ import annotations

import importlib.util
import json
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import Circle


ROOT = Path(__file__).resolve().parents[1]
BASE_SCRIPT = ROOT / "01_scripts" / "generate_chapter34_figures.py"
OUTPUT_DIR = ROOT / "03_figures" / "R11图表细节优化"


def load_base_module():
    spec = importlib.util.spec_from_file_location("chapter34_figure_base", BASE_SCRIPT)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Cannot load {BASE_SCRIPT}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    module.OUT = OUTPUT_DIR
    return module


def build_pp_cbf_layers(base) -> dict[str, str]:
    fig, (ax, ag) = plt.subplots(
        1,
        2,
        figsize=(9.0, 4.15),
        gridspec_kw={"width_ratios": [1.52, 0.70]},
    )
    fig.subplots_adjust(wspace=0.16)
    ax.set_xlim(0, 11.0)
    ax.set_ylim(0, 8.0)
    ax.axis("off")
    ag.set_xlim(-1.2, 1.2)
    ag.set_ylim(-0.65, 1.55)
    ag.axis("off")

    base.label(ax, 0.12, 7.58, "a", size=9.0, color=base.INK, ha="left", weight="bold")
    base.box(ax, 0.35, 6.20, 2.25, 1.00, "领导机参考\n与编队偏置", edge=base.INK, face=base.PANEL,
             bold=True, size=7.8)
    base.box(
        ax,
        3.05,
        5.78,
        3.80,
        1.84,
        "PP-CBF安全监督器\n预测三对约束与逐对投影\n输入9/18/9，输出27/8",
        edge=base.GREEN,
        face=base.GREEN_PALE,
        accent=base.GREEN,
        bold=True,
        size=7.35,
    )
    base.box(ax, 7.55, 6.20, 2.55, 1.00, "三机位置与速度\n18维状态", edge=base.INK,
             face=base.PANEL, bold=True, size=7.7)
    base.arrow(ax, (2.60, 6.70), (3.05, 6.70), color=base.GREEN)
    base.arrow(ax, (7.55, 6.70), (6.85, 6.70), color=base.GREEN)

    ys = [4.20, 2.60, 1.00]
    for i, y in enumerate(ys, start=1):
        base.box(ax, 0.75, y, 3.15, 0.98, f"安全参考 {i}\n位置 · 速度 · 加速度",
                 edge=base.LINE, face="white", size=7.6)
        base.box(ax, 5.00, y, 3.55, 0.98, f"RA-GCA-CGHTE {i}", edge=base.BLUE,
                 face=base.BLUE_PALE, accent=base.BLUE, bold=True, size=7.7)
        base.box(ax, 9.35, y, 1.25, 0.98, f"无人机\n{i}", edge=base.INK, face=base.PANEL,
                 bold=True, size=7.5)
        base.arrow(ax, (3.90, y + 0.49), (5.00, y + 0.49), color=base.BLUE)
        base.arrow(ax, (8.55, y + 0.49), (9.35, y + 0.49), color=base.INK)

    # Route the three safety-reference outputs through a dedicated channel
    # outside all text boxes.
    base.arrow(ax, (3.50, 5.78), (0.45, 5.52), color=base.GREEN, connectionstyle="arc3,rad=0.03")
    ax.plot([0.45, 0.45], [1.49, 5.52], color=base.GREEN, lw=1.05, zorder=1)
    for y in ys:
        base.arrow(ax, (0.45, y + 0.49), (0.75, y + 0.49), color=base.GREEN)

    base.arrow(ax, (9.98, 5.18), (8.85, 6.20), color=base.LINE, connectionstyle="arc3,rad=0.18")
    base.label(ax, 9.30, 5.62, "状态反馈", color=base.MUTED, size=7.0)

    base.label(ag, -1.10, 1.38, "b", size=9.0, color=base.INK, ha="left", weight="bold")
    pi = (-0.66, 0.34)
    pj = (0.68, 0.85)
    ag.add_patch(Circle(pi, 0.12, facecolor=base.BLUE_PALE, edgecolor=base.BLUE, lw=1.2))
    ag.add_patch(Circle(pj, 0.12, facecolor=base.GREEN_PALE, edgecolor=base.GREEN, lw=1.2))
    ag.text(pi[0], pi[1] - 0.26, "无人机 i", ha="center", va="center", fontsize=7.8, color=base.INK)
    ag.text(pj[0], pj[1] + 0.24, "无人机 j", ha="center", va="center", fontsize=7.8, color=base.INK)
    base.arrow(ag, pi, pj, color=base.INK, width=1.1, style="<->")
    ag.text(
        0.18,
        0.24,
        r"$\hat{r}_{ij}=r_{ij}+T_pv_{ij}$",
        ha="center",
        va="center",
        fontsize=8.0,
        color=base.INK,
        bbox={"facecolor": "white", "edgecolor": "none", "pad": 1.2},
    )
    ag.add_patch(Circle(pi, 0.46, fill=False, edgecolor=base.GREEN, lw=1.1, linestyle="--"))
    ag.text(-0.68, 1.12, r"设计距离 $d_0=0.615$ m", ha="center", va="center", fontsize=7.4,
            color=base.GREEN)
    ag.text(0.00, -0.39, "安全距离判定值：0.60 m", ha="center", va="center", fontsize=7.3,
            color=base.MUTED)
    return base.save_all(fig, "图4-1_PP-CBF与三套主控制器的分层结构_R11")


def build_cghte_flow(base) -> dict[str, str]:
    fig, ax = plt.subplots(figsize=(9.0, 4.8))
    ax.set_xlim(0, 18.0)
    ax.set_ylim(0, 8.5)
    ax.axis("off")

    base.label(ax, 0.40, 7.85, "估计过程", size=8.3, color=base.INK, ha="left", weight="bold")
    base.box(ax, 0.45, 5.55, 2.35, 1.45, "垂向加速度\n差分限幅 ±15\n0.2/0.8离散滤波",
             edge=base.LINE, face=base.PANEL, bold=True, size=7.8)
    base.box(ax, 3.35, 5.55, 2.50, 1.45, "测量模型\nâ = T/(m ŝ) - g", edge=base.LINE,
             face="white", bold=True, size=8.0)
    base.box(ax, 6.40, 5.55, 2.50, 1.45, "创新与协方差\nν = ā - â\nη = ν/(3√S)",
             edge=base.LINE, face="white", bold=True, size=7.8)
    base.box(ax, 9.45, 5.55, 2.60, 1.45, "估计有效条件\n启动、姿态、未裁剪\n参考与推力条件",
             edge=base.GREEN, face=base.GREEN_PALE, accent=base.GREEN, bold=True, size=7.6)
    base.box(ax, 12.65, 5.55, 2.35, 1.45, "尺度估计更新\n0.75 ≤ ŝ ≤ 1.35", edge=base.BLUE,
             face=base.BLUE_PALE, bold=True, size=7.8)
    base.box(ax, 15.55, 5.55, 1.85, 1.45, "估计尺度\n诊断11", edge=base.BLUE, face="white",
             bold=True, size=7.7)
    for x1, x2, color in ((2.80, 3.35, base.LINE), (5.85, 6.40, base.LINE),
                          (8.90, 9.45, base.GREEN), (12.05, 12.65, base.BLUE),
                          (15.00, 15.55, base.BLUE)):
        base.arrow(ax, (x1, 6.28), (x2, 6.28), color=color)

    base.label(ax, 0.40, 4.25, "启用判断与尺度应用", size=8.3, color=base.INK, ha="left", weight="bold")
    base.box(ax, 0.45, 1.85, 2.75, 1.60, "估计结果可信\n协方差不超过阈值\n|ŝ-1| ≥ 0.04",
             edge=base.GREEN, face=base.GREEN_PALE, bold=True, size=7.6)
    base.box(ax, 3.75, 1.85, 2.40, 1.60, "持续激活\n条件连续满足\n0.10 s", edge=base.GREEN,
             face="white", bold=True, size=7.7)
    base.box(ax, 6.70, 1.85, 2.65, 1.60, "尺度应用限速\n0.00868/步\n等效0.868 s^-1",
             edge=base.BLUE, face=base.BLUE_PALE, accent=base.BLUE, bold=True, size=7.7)
    base.box(ax, 9.90, 1.85, 2.55, 1.60, "保持条件\n电机裁剪、姿态不可信\n或估计无效",
             edge=base.RED, face="#F7EEEE", bold=True, size=7.4)
    base.box(ax, 13.00, 1.85, 2.45, 1.60, "回归条件\n|ŝ-1| ≤ 0.02\n持续1.0 s后回到1",
             edge=base.LINE, face="white", bold=True, size=7.5)
    base.box(ax, 16.00, 1.85, 1.40, 1.60, "应用尺度\n诊断12", edge=base.BLUE, face="white",
             bold=True, size=7.3)
    for x1, x2, color in ((3.20, 3.75, base.GREEN), (6.15, 6.70, base.BLUE),
                          (9.35, 9.90, base.RED), (12.45, 13.00, base.LINE),
                          (15.45, 16.00, base.BLUE)):
        base.arrow(ax, (x1, 2.65), (x2, 2.65), color=color)

    base.arrow(ax, (13.82, 5.55), (8.03, 3.45), color=base.BLUE, connectionstyle="arc3,rad=0.16")
    base.box(
        ax,
        4.65,
        0.18,
        8.10,
        1.02,
        "诊断13-16\n估计有效状态 · 归一化创新 · 分配器上限 · 算法标识码914",
        edge=base.LINE,
        face=base.PANEL,
        size=7.25,
    )
    base.arrow(ax, (10.72, 1.85), (10.72, 1.20), color=base.LINE)
    return base.save_all(fig, "图A-1_CGHTE推力尺度估计与应用流程_R11")


def main() -> None:
    base = load_base_module()
    base.configure_fonts()
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    outputs = {
        "figure_4_1": build_pp_cbf_layers(base),
        "figure_a_1": build_cghte_flow(base),
    }
    manifest = OUTPUT_DIR / "R11方法图输出清单.json"
    manifest.write_text(json.dumps(outputs, ensure_ascii=False, indent=2), encoding="utf-8")
    print(manifest)


if __name__ == "__main__":
    main()
