from __future__ import annotations

import hashlib
import json
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib import font_manager
from matplotlib.patches import Circle, FancyArrowPatch, FancyBboxPatch, Rectangle


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "03_figures"

INK = "#20252B"
MUTED = "#69737A"
LINE = "#7B858C"
PANEL = "#F5F6F6"
GRID = "#D9DEE1"
BLUE = "#2F6F9F"
BLUE_PALE = "#E9F1F7"
GREEN = "#4E7A62"
GREEN_PALE = "#EDF3EF"
PURPLE = "#75658A"
PURPLE_PALE = "#F1EEF4"
ORANGE = "#B56E32"
ORANGE_PALE = "#F8F0E9"
RED = "#A65757"


def configure_fonts() -> None:
    installed = {f.name for f in font_manager.fontManager.ttflist}
    for name in ("Microsoft YaHei", "Noto Sans CJK SC", "SimHei", "SimSun"):
        if name in installed:
            plt.rcParams["font.sans-serif"] = [name]
            break
    plt.rcParams["font.family"] = "sans-serif"
    plt.rcParams["axes.unicode_minus"] = False
    plt.rcParams["svg.fonttype"] = "none"
    plt.rcParams["pdf.fonttype"] = 42


def box(ax, x, y, w, h, text, *, edge=LINE, face="white", accent=None,
        size=8.3, bold=False, radius=0.025, align="center"):
    patch = FancyBboxPatch(
        (x, y), w, h,
        boxstyle=f"round,pad=0.015,rounding_size={radius}",
        linewidth=1.05,
        edgecolor=edge,
        facecolor=face,
        zorder=2,
    )
    ax.add_patch(patch)
    if accent:
        ax.add_patch(Rectangle((x, y), 0.07, h, facecolor=accent, edgecolor="none", zorder=3))
    tx = x + w / 2 if align == "center" else x + 0.18
    ax.text(
        tx, y + h / 2, text,
        ha=align, va="center", fontsize=size, color=INK,
        fontweight="bold" if bold else "normal", linespacing=1.25, zorder=4,
    )
    return patch


def arrow(ax, start, end, *, color=LINE, width=1.0, style="-|>", connectionstyle=None):
    ax.add_patch(FancyArrowPatch(
        start, end, arrowstyle=style, mutation_scale=9.5, linewidth=width,
        color=color, connectionstyle=connectionstyle, shrinkA=1.5, shrinkB=1.5, zorder=5,
    ))


def label(ax, x, y, text, *, size=7.3, color=MUTED, ha="center", weight="normal"):
    ax.text(x, y, text, fontsize=size, color=color, ha=ha, va="center", fontweight=weight)


def save_all(fig, stem: str) -> dict[str, str]:
    # 每幅方法图同时保存PNG、SVG和PDF版本。
    OUT.mkdir(parents=True, exist_ok=True)
    outputs = {}
    for suffix in ("png", "svg", "pdf"):
        path = OUT / f"{stem}.{suffix}"
        kwargs = {"bbox_inches": "tight", "pad_inches": 0.04, "facecolor": "white"}
        if suffix == "png":
            kwargs["dpi"] = 500
        fig.savefig(path, **kwargs)
        outputs[suffix] = str(path)
    plt.close(fig)
    return outputs


def build_five_object_architecture() -> dict[str, str]:
    # 五对象结构图仅描述接口关系，不承载性能排序。
    fig, ax = plt.subplots(figsize=(8.6, 4.55))
    ax.set_xlim(0, 15.8)
    ax.set_ylim(0, 8.1)
    ax.axis("off")

    box(ax, 0.35, 1.55, 2.35, 5.30,
        "统一输入与条件\n\n11维参考\n18维状态\n2维分配边界\n\n同一场景与初值\n采样周期0.01 s",
        edge=INK, face=PANEL, bold=True, size=8.0)

    rows = [
        ("PID", "级联反馈", MUTED, "#F1F2F2"),
        ("RA-GCA/Base", "几何控制基础构型", ORANGE, ORANGE_PALE),
        ("RA-GCA-CGHTE", "几何控制 + 推力估计增强", BLUE, BLUE_PALE),
        ("CAP-ADRC", "主动扰动抑制", GREEN, GREEN_PALE),
        ("CP-INDI", "增量动态逆", PURPLE, PURPLE_PALE),
    ]
    ys = [6.35, 5.10, 3.85, 2.60, 1.35]
    for (name, role, color, face), y in zip(rows, ys):
        box(ax, 3.65, y, 3.35, 0.88, f"{name}\n{role}", edge=color, face=face,
            accent=color, bold=(name == "RA-GCA-CGHTE"), size=8.0)
        arrow(ax, (7.00, y + 0.44), (8.10, y + 0.44), color=color)

    ax.plot([8.10, 8.10], [1.79, 6.79], color=LINE, lw=1.1)
    label(ax, 8.10, 7.25, "4维电机指令总线", weight="bold", color=INK)
    box(ax, 9.20, 2.45, 2.75, 4.10, "同一四旋翼\n物理模型\n\n电机\n机体\n传感器",
        edge=INK, face=PANEL, bold=True, size=8.5)
    box(ax, 12.85, 4.55, 2.50, 1.25, "统一数据处理\n与指标计算", edge=INK, face="white", bold=True)
    box(ax, 12.85, 2.70, 2.50, 1.05, "各控制器\n独立诊断输出", edge=LINE, face="white", size=8.0)

    arrow(ax, (8.10, 4.50), (9.20, 4.50), color=INK)
    arrow(ax, (11.95, 5.18), (12.85, 5.18), color=INK)
    arrow(ax, (11.95, 3.22), (12.85, 3.22), color=LINE)

    for y in ys:
        arrow(ax, (2.70, y + 0.44), (3.65, y + 0.44), color=LINE)
    ax.plot([10.58, 10.58, 1.52], [2.45, 0.52, 0.52], color=LINE, lw=1.0)
    arrow(ax, (1.52, 0.52), (1.52, 1.55), color=LINE)

    label(ax, 5.33, 7.55, "可替换控制器", weight="bold", color=INK)
    label(ax, 10.58, 7.02, "被控对象与传感链", weight="bold", color=INK)
    label(ax, 14.10, 6.12, "统一评价", weight="bold", color=INK)
    label(ax, 5.80, 0.25, "物理状态反馈", color=MUTED, weight="bold")
    return save_all(fig, "图3-1_五对象统一控制与评价架构")


def build_main_stack() -> dict[str, str]:
    fig, ax = plt.subplots(figsize=(8.6, 4.15))
    ax.set_xlim(0, 16.4)
    ax.set_ylim(0, 7.2)
    ax.axis("off")

    box(ax, 0.35, 4.75, 1.85, 0.95, "11维参考", edge=INK, face=PANEL, bold=True)
    box(ax, 0.35, 2.95, 1.85, 0.95, "18维状态", edge=INK, face=PANEL, bold=True)

    box(ax, 2.85, 3.92, 2.45, 1.55, "平移控制\n期望合力与推力轴", edge=LINE, face="white", bold=True)
    box(ax, 5.95, 3.92, 2.25, 1.55, "约化姿态\n滚转/俯仰反馈", edge=LINE, face="white", bold=True)
    box(ax, 8.85, 3.92, 2.30, 1.55, "CGHTE\n推力尺度应用", edge=BLUE, face=BLUE_PALE, accent=BLUE, bold=True)
    box(ax, 11.80, 3.92, 2.25, 1.55, "约束感知分配\n两阶段去饱和", edge=INK, face=PANEL, bold=True)
    box(ax, 14.70, 3.92, 1.35, 1.55, "4维\n电机指令", edge=INK, face="white", bold=True)

    box(ax, 2.85, 0.55, 4.85, 1.25, "诊断1-10\n基础控制量、分配状态与误差范数",
        edge=LINE, face="white", size=7.5)
    box(ax, 8.10, 0.55, 3.25, 1.25, "诊断11-14\n尺度、融合与创新",
        edge=BLUE, face=BLUE_PALE, size=7.5)
    box(ax, 11.80, 0.55, 2.25, 1.25, "2维分配边界\n诊断15记录上界", edge=INK, face=PANEL, size=7.3)
    box(ax, 14.70, 0.55, 1.35, 1.25, "诊断16\n代码914", edge=BLUE, face="white", bold=True, size=7.2)

    arrow(ax, (2.20, 5.22), (2.85, 4.92), color=INK)
    arrow(ax, (2.20, 3.42), (2.85, 4.46), color=INK)
    arrow(ax, (5.30, 4.69), (5.95, 4.69), color=LINE)
    arrow(ax, (8.20, 4.69), (8.85, 4.69), color=BLUE)
    arrow(ax, (11.15, 4.69), (11.80, 4.69), color=BLUE)
    arrow(ax, (14.05, 4.69), (14.70, 4.69), color=INK)
    arrow(ax, (4.07, 3.92), (4.07, 2.05), color=LINE)
    arrow(ax, (9.99, 3.92), (9.99, 2.05), color=BLUE)
    arrow(ax, (13.25, 3.92), (13.25, 2.05), color=LINE)
    arrow(ax, (7.70, 1.18), (8.10, 1.18), color=LINE)
    arrow(ax, (11.35, 1.18), (11.80, 1.18), color=BLUE)
    arrow(ax, (12.60, 1.80), (12.60, 3.92), color=INK)
    arrow(ax, (14.05, 1.18), (14.70, 1.18), color=BLUE)

    label(ax, 7.50, 6.45, "RA-GCA主干", color=INK, weight="bold")
    ax.plot([2.85, 8.20], [6.18, 6.18], color=INK, lw=1.1)
    label(ax, 9.99, 6.45, "推力效能增强", color=BLUE, weight="bold")
    ax.plot([8.85, 11.15], [6.18, 6.18], color=BLUE, lw=1.1)
    label(ax, 13.95, 6.45, "执行器接口", color=INK, weight="bold")
    ax.plot([11.80, 16.05], [6.18, 6.18], color=INK, lw=1.1)
    return save_all(fig, "图3-3_RA-GCA-CGHTE控制栈与诊断分层")


def build_pp_cbf_layers() -> dict[str, str]:
    fig, (ax, ag) = plt.subplots(1, 2, figsize=(9.0, 4.15), gridspec_kw={"width_ratios": [1.45, 0.75]})
    ax.set_xlim(0, 10.4)
    ax.set_ylim(0, 8.0)
    ax.axis("off")
    ag.set_xlim(-1.2, 1.2)
    ag.set_ylim(-0.65, 1.55)
    ag.axis("off")

    label(ax, 0.20, 7.55, "a", size=9.0, color=INK, ha="left", weight="bold")
    box(ax, 0.50, 6.10, 2.20, 1.05, "领导机参考\n与编队偏置", edge=INK, face=PANEL, bold=True)
    box(ax, 3.45, 5.78, 3.05, 1.70, "PP-CBF上层安全监督\n预测三对约束 · 顺序投影\n9/18/9 → 27/8",
        edge=GREEN, face=GREEN_PALE, accent=GREEN, bold=True, size=8.0)
    box(ax, 7.25, 6.10, 2.15, 1.05, "三机位置/速度\n18维状态", edge=INK, face=PANEL, bold=True)

    ys = [4.15, 2.55, 0.95]
    for i, y in enumerate(ys, start=1):
        box(ax, 1.45, y, 3.10, 0.98, f"安全参考 {i}\n位置 · 速度 · 加速度", edge=LINE, face="white", size=7.8)
        box(ax, 5.20, y, 3.30, 0.98, f"RA-GCA-CGHTE {i}", edge=BLUE, face=BLUE_PALE,
            accent=BLUE, bold=True, size=8.0)
        box(ax, 9.05, y, 1.05, 0.98, f"无人机\n{i}", edge=INK, face=PANEL, bold=True, size=7.8)
        arrow(ax, (4.55, y + 0.49), (5.20, y + 0.49), color=BLUE)
        arrow(ax, (8.50, y + 0.49), (9.05, y + 0.49), color=INK)
        arrow(ax, (5.00, 5.78), (3.00, y + 0.98), color=GREEN, connectionstyle="arc3,rad=0.07")

    arrow(ax, (2.70, 6.62), (3.45, 6.62), color=GREEN)
    arrow(ax, (7.25, 6.62), (6.50, 6.62), color=GREEN)
    arrow(ax, (9.58, 4.15), (8.32, 6.10), color=LINE, connectionstyle="arc3,rad=0.18")
    label(ax, 7.25, 5.45, "状态反馈", color=MUTED)

    label(ag, -1.10, 1.38, "b", size=9.0, color=INK, ha="left", weight="bold")
    pi = (-0.72, 0.32)
    pj = (0.74, 0.76)
    ag.add_patch(Circle(pi, 0.12, facecolor=BLUE_PALE, edgecolor=BLUE, lw=1.2))
    ag.add_patch(Circle(pj, 0.12, facecolor=GREEN_PALE, edgecolor=GREEN, lw=1.2))
    ag.text(pi[0], pi[1] - 0.25, "无人机 i", ha="center", va="center", fontsize=8.0, color=INK)
    ag.text(pj[0], pj[1] + 0.24, "无人机 j", ha="center", va="center", fontsize=8.0, color=INK)
    arrow(ag, pi, pj, color=INK, width=1.1, style="<->")
    ag.text(0.10, 0.16, r"$\hat{r}_{ij}=r_{ij}+T_pv_{ij}$", ha="center", va="center", fontsize=8.4,
            color=INK, bbox={"facecolor": "white", "edgecolor": "none", "pad": 1.2})
    safe = Circle(pi, 0.47, fill=False, edgecolor=GREEN, lw=1.1, linestyle="--")
    ag.add_patch(safe)
    ag.text(-0.73, 1.02, r"设计距离 $d_0=0.615$ m", ha="center", va="center", fontsize=7.6, color=GREEN)
    ag.text(0.00, -0.35, "项目评价阈值：0.60 m", ha="center", va="center", fontsize=7.6, color=MUTED)
    return save_all(fig, "图4-1_PP-CBF与三套主控制器的分层结构")


def build_cghte_flow() -> dict[str, str]:
    # 估计、置信判定和尺度应用按实际控制顺序绘制。
    fig, ax = plt.subplots(figsize=(9.0, 4.8))
    ax.set_xlim(0, 17.5)
    ax.set_ylim(0, 8.5)
    ax.axis("off")

    label(ax, 0.40, 7.85, "估计支路", size=8.3, color=INK, ha="left", weight="bold")
    box(ax, 0.45, 5.55, 2.35, 1.45, "垂向加速度\n差分限幅 ±15\n0.2/0.8离散滤波", edge=LINE, face=PANEL, bold=True, size=7.8)
    box(ax, 3.35, 5.55, 2.50, 1.45, "测量模型\nâ = T/(m ŝ) - g", edge=LINE, face="white", bold=True, size=8.0)
    box(ax, 6.40, 5.55, 2.50, 1.45, "创新与协方差\nν = ā - â\nη = ν/(3√S)", edge=LINE, face="white", bold=True, size=7.8)
    box(ax, 9.45, 5.55, 2.55, 1.45, "融合可信门\n启动、姿态、未裁剪\n参考与推力条件", edge=GREEN, face=GREEN_PALE, accent=GREEN, bold=True, size=7.7)
    box(ax, 12.55, 5.55, 2.30, 1.45, "尺度估计更新\n0.75 ≤ ŝ ≤ 1.35", edge=BLUE, face=BLUE_PALE, bold=True, size=7.9)
    box(ax, 15.40, 5.55, 1.65, 1.45, "估计尺度\n诊断11", edge=BLUE, face="white", bold=True, size=7.8)
    for x1, x2, color in ((2.80, 3.35, LINE), (5.85, 6.40, LINE), (8.90, 9.45, GREEN),
                          (12.00, 12.55, BLUE), (14.85, 15.40, BLUE)):
        arrow(ax, (x1, 6.28), (x2, 6.28), color=color)

    label(ax, 0.40, 4.25, "门控与应用支路", size=8.3, color=INK, ha="left", weight="bold")
    box(ax, 0.45, 1.85, 2.75, 1.60, "可信估计\n协方差不超过门限\n|ŝ-1| ≥ 0.04", edge=GREEN, face=GREEN_PALE, bold=True, size=7.6)
    box(ax, 3.75, 1.85, 2.40, 1.60, "持续激活\n条件连续满足\n0.10 s", edge=GREEN, face="white", bold=True, size=7.7)
    box(ax, 6.70, 1.85, 2.65, 1.60, "尺度应用限速\n0.00868/步\n等效0.868 s^-1", edge=BLUE, face=BLUE_PALE, accent=BLUE, bold=True, size=7.7)
    box(ax, 9.90, 1.85, 2.55, 1.60, "保持条件\n电机裁剪、姿态不可信\n或融合无效", edge=RED, face="#F7EEEE", bold=True, size=7.4)
    box(ax, 13.00, 1.85, 2.45, 1.60, "回归条件\n|ŝ-1| ≤ 0.02\n持续1.0 s后回到1", edge=LINE, face="white", bold=True, size=7.5)
    box(ax, 15.95, 1.85, 1.10, 1.60, "应用尺度\n诊断12", edge=BLUE, face="white", bold=True, size=7.4)
    for x1, x2, color in ((3.20, 3.75, GREEN), (6.15, 6.70, BLUE), (9.35, 9.90, RED),
                          (12.45, 13.00, LINE), (15.45, 15.95, BLUE)):
        arrow(ax, (x1, 2.65), (x2, 2.65), color=color)

    arrow(ax, (13.70, 5.55), (8.03, 3.45), color=BLUE, connectionstyle="arc3,rad=0.16")
    box(ax, 6.15, 0.35, 5.25, 0.75, "诊断13-16：融合有效性 · 归一化创新 · 分配上界 · 诊断码914",
        edge=LINE, face=PANEL, size=7.8)
    arrow(ax, (10.72, 1.85), (10.72, 1.10), color=LINE)
    return save_all(fig, "图A-1_CGHTE估计门控与尺度应用流程")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def main() -> None:
    # 所有方法图使用统一字体、配色和输出尺寸。
    configure_fonts()
    built = {}
    built["figure_3_1"] = build_five_object_architecture()
    built["figure_3_3"] = build_main_stack()
    built["figure_4_1"] = build_pp_cbf_layers()
    built["figure_A_1"] = build_cghte_flow()
    manifest = {
        key: {
            suffix: {"path": value, "sha256": sha256(Path(value))}
            for suffix, value in outputs.items()
        }
        for key, outputs in built.items()
    }
    path = OUT / "可编辑方法图生成清单.json"
    path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(path)


if __name__ == "__main__":
    main()
