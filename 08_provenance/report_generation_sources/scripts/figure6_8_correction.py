from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path


BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
sys.path.insert(0, str(BASE / "python_deps"))
sys.stdout.reconfigure(encoding="utf-8")

import matplotlib  # noqa: E402

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import pandas as pd  # noqa: E402


RAW = (
    ROOT
    / "A8赛题核心工作区/A8比赛作品完整源文件_20260715/06_supplementary_evidence"
    / "ra_gca_cg_hte_32_raw/Scene05B_LiftMinus10.csv"
)
EXPECTED_RAW_SHA256 = "1C3C4FA55464E5A1E7C61262893D17D528BF7CB33CEF6449D390FF2647EE4375"
OUT = BASE / "corrected_assets"
STEM = "figure_6_8_cghte_diagnostics_corrected"

COLORS = {
    "main": "#1768AC",
    "adrc": "#2A7F62",
    "pid": "#4B5563",
    "reference": "#111827",
    "grid": "#D8DEE4",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def configure_matplotlib() -> None:
    # 使用统一中英文字体和导出分辨率修正图6-8。
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
    axis.text(
        -0.12,
        1.04,
        label,
        transform=axis.transAxes,
        fontsize=9.2,
        fontweight="bold",
        va="bottom",
    )


def main() -> None:
    # 修正过程只读取冻结数据并重新生成正式图件底稿。
    if sha256(RAW) != EXPECTED_RAW_SHA256:
        raise AssertionError("图6-8原始数据哈希发生变化")
    columns = [
        "time",
        "referenceVector[3]",
        "quadChassisTest17_1.body.r_0[3]",
        "controllerDiagnostics[11]",
        "controllerDiagnostics[12]",
        "controllerDiagnostics[13]",
        "controllerDiagnostics[14]",
        "controllerDiagnostics[15]",
        "scenarioDiagnostics[1]",
        "scenarioDiagnostics[2]",
        *[f"motorCommand[{index}]" for index in range(1, 5)],
    ]
    frame = pd.read_csv(RAW, usecols=columns, encoding="utf-8-sig")
    motor_columns = [f"motorCommand[{index}]" for index in range(1, 5)]
    frame["max_motor_q"] = frame[motor_columns].pow(2).max(axis=1)
    frame["q_domain_usage_percent"] = (
        100.0 * frame["max_motor_q"] / frame["controllerDiagnostics[15]"]
    )
    target_scale = float(
        frame["scenarioDiagnostics[2]"].iloc[0] / frame["scenarioDiagnostics[1]"].iloc[0]
    )
    maximum_usage = float(frame["q_domain_usage_percent"].max())
    if not 6.7321 < maximum_usage < 6.7323:
        raise AssertionError(f"平方转速域使用率复算异常：{maximum_usage}")

    sample = frame.iloc[::5].copy()
    configure_matplotlib()
    figure, axes = plt.subplots(2, 2, figsize=(7.05, 4.45), constrained_layout=True)

    axis = axes[0, 0]
    axis.plot(
        sample.time,
        sample["referenceVector[3]"],
        color=COLORS["reference"],
        linestyle="--",
        label="高度参考",
    )
    axis.plot(
        sample.time,
        sample["quadChassisTest17_1.body.r_0[3]"],
        color=COLORS["main"],
        label="实际高度",
    )
    axis.set_ylabel("高度（m）")
    axis.set_xlabel("时间（s）")
    axis.set_title("升力效能降低10%时的高度跟踪")
    axis.legend(frameon=False)
    style_axis(axis)
    panel_label(axis, "(a)")

    axis = axes[0, 1]
    axis.plot(
        sample.time,
        sample["controllerDiagnostics[11]"],
        color=COLORS["adrc"],
        linestyle="--",
        label="估计尺度",
    )
    axis.plot(
        sample.time,
        sample["controllerDiagnostics[12]"],
        color=COLORS["main"],
        label="应用尺度",
    )
    axis.axhline(
        target_scale,
        color=COLORS["reference"],
        linestyle=":",
        linewidth=1.2,
        label=f"对应尺度 {target_scale:.3f}",
    )
    axis.set_ylabel("推力尺度")
    axis.set_xlabel("时间（s）")
    axis.set_title("尺度估计与平滑应用")
    axis.legend(frameon=False)
    style_axis(axis)
    panel_label(axis, "(b)")

    axis = axes[1, 0]
    axis.step(
        sample.time,
        sample["controllerDiagnostics[13]"],
        where="post",
        color=COLORS["main"],
        label="估计有效状态",
    )
    axis.set_ylim(-0.08, 1.12)
    axis.set_ylabel("状态")
    axis.set_xlabel("时间（s）")
    twin = axis.twinx()
    twin.plot(
        sample.time,
        sample["controllerDiagnostics[14]"],
        color=COLORS["pid"],
        alpha=0.8,
        linewidth=1.0,
        label="归一化创新",
    )
    twin.set_ylabel("归一化创新")
    lines = axis.get_lines() + twin.get_lines()
    axis.legend(lines, [line.get_label() for line in lines], frameon=False, loc="best")
    axis.set_title("估计有效状态与创新量")
    style_axis(axis)
    panel_label(axis, "(c)")

    axis = axes[1, 1]
    axis.plot(sample.time, sample["q_domain_usage_percent"], color=COLORS["adrc"])
    axis.set_ylabel("平方转速域使用率（%）")
    axis.set_xlabel("时间（s）")
    axis.set_title("平方转速域上限使用率")
    style_axis(axis)
    panel_label(axis, "(d)")

    OUT.mkdir(parents=True, exist_ok=True)
    png = OUT / f"{STEM}.png"
    pdf = OUT / f"{STEM}.pdf"
    svg = OUT / f"{STEM}.svg"
    csv = OUT / f"{STEM}.csv"
    figure.savefig(png, dpi=600, bbox_inches="tight", pad_inches=0.04)
    figure.savefig(pdf, bbox_inches="tight", pad_inches=0.04)
    figure.savefig(svg, bbox_inches="tight", pad_inches=0.04)
    plt.close(figure)
    sample[
        [
            "time",
            "referenceVector[3]",
            "quadChassisTest17_1.body.r_0[3]",
            "controllerDiagnostics[11]",
            "controllerDiagnostics[12]",
            "controllerDiagnostics[13]",
            "controllerDiagnostics[14]",
            "controllerDiagnostics[15]",
            "max_motor_q",
            "q_domain_usage_percent",
        ]
    ].to_csv(csv, index=False, encoding="utf-8-sig")

    record = {
        "source": str(RAW),
        "source_sha256": sha256(RAW),
        "formula": "100 * max_i(motorCommand[i]^2) / controllerDiagnostics[15]",
        "q_max": float(frame["controllerDiagnostics[15]"].iloc[0]),
        "maximum_q_domain_usage_percent": maximum_usage,
        "outputs": {
            item.name: sha256(item) for item in (png, pdf, svg, csv)
        },
    }
    record_path = OUT / "figure_6_8_correction_record.json"
    record_path.write_text(json.dumps(record, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(record, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
