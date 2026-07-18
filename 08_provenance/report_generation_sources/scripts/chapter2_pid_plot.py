import csv
import hashlib
import json
import math
import sys
import warnings
from pathlib import Path

import matplotlib
import matplotlib.pyplot as plt
from matplotlib.font_manager import FontProperties
from matplotlib.ticker import MultipleLocator


SCRIPT = Path(__file__).resolve()
CHAPTER_ROOT = SCRIPT.parents[2]
ANALYSIS_DIR = CHAPTER_ROOT / "02_analysis"
FIGURE_DIR = CHAPTER_ROOT / "03_figures"
PLOT_DATA = ANALYSIS_DIR / "chapter2_pid_plot_data.csv"
METRICS_DATA = ANALYSIS_DIR / "chapter2_pid_baseline_metrics.csv"
PNG = FIGURE_DIR / "图2-3_官方PID三轴独立阶跃响应.png"
PDF = FIGURE_DIR / "图2-3_官方PID三轴独立阶跃响应.pdf"
SVG = FIGURE_DIR / "图2-3_官方PID三轴独立阶跃响应.svg"
MANIFEST = FIGURE_DIR / "图2-3_生成清单.json"
SIMSUN = Path("C:/Windows/Fonts/simsun.ttc")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def read_csv(path: Path):
    # 原始PID结果按表头读取，并将数值列转换为浮点数组。
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))


plot_rows = read_csv(PLOT_DATA)
metric_rows = read_csv(METRICS_DATA)
if not SIMSUN.is_file():
    raise FileNotFoundError(f"required Chinese font not found: {SIMSUN}")
required = {"axis", "time_s", "reference_m", "response_m", "raw_sha256"}
if not plot_rows or not required <= set(plot_rows[0]):
    raise AssertionError(f"invalid plot data columns: {PLOT_DATA}")

metrics_by_axis = {row["axis"]: row for row in metric_rows}
series = {}
for axis in ("X", "Y", "Z"):
    rows = [row for row in plot_rows if row["axis"] == axis]
    if len(rows) != 1201:
        raise AssertionError(f"{axis}: expected 1201 samples, got {len(rows)}")
    time = [float(row["time_s"]) for row in rows]
    reference = [float(row["reference_m"]) for row in rows]
    response = [float(row["response_m"]) for row in rows]
    if not all(math.isfinite(value) for values in (time, reference, response) for value in values):
        raise AssertionError(f"{axis}: non-finite plot value")
    if not all(right > left for left, right in zip(time, time[1:])):
        raise AssertionError(f"{axis}: time is not strictly increasing")
    hashes = {row["raw_sha256"] for row in rows}
    if hashes != {metrics_by_axis[axis]["raw_sha256"]}:
        raise AssertionError(f"{axis}: raw hash mismatch between metrics and plot data")
    if abs(time[0] - 8.0) > 1e-12 or abs(time[-1] - 20.0) > 1e-12:
        raise AssertionError(f"{axis}: unexpected plot window {time[0]}-{time[-1]}")
    series[axis] = (time, reference, response)


matplotlib.rcParams.update({
    "font.family": "Times New Roman",
    "font.size": 9.2,
    "axes.labelsize": 10.0,
    "xtick.labelsize": 8.7,
    "ytick.labelsize": 8.7,
    "legend.fontsize": 8.8,
    "axes.unicode_minus": False,
    "svg.fonttype": "none",
    "pdf.fonttype": 42,
    "ps.fonttype": 42,
})
warnings.filterwarnings("error", message=r"Glyph .* missing from font")
cn_label = FontProperties(fname=str(SIMSUN), size=10.0)
cn_panel = FontProperties(fname=str(SIMSUN), size=9.4)
cn_legend = FontProperties(fname=str(SIMSUN), size=8.8)

pid_color = "#4B5563"
reference_color = "#111827"
grid_color = "#D8DDE3"
spine_color = "#6B7280"

figure, axes = plt.subplots(3, 1, figsize=(7.05, 5.65), sharex=True)
panel_labels = {"X": "(a) X轴", "Y": "(b) Y轴", "Z": "(c) Z轴"}
limits = {"X": (-0.05, 1.31), "Y": (-0.05, 1.31), "Z": (0.85, 2.30)}

for index, axis in enumerate(("X", "Y", "Z")):
    current = axes[index]
    time, reference, response = series[axis]
    current.plot(time, reference, color=reference_color, linewidth=1.45,
                 linestyle=(0, (5, 3)), label="参考指令", zorder=2)
    current.plot(time, response, color=pid_color, linewidth=1.65,
                 linestyle="-", label="PID响应", zorder=3)
    current.set_xlim(8.0, 20.0)
    current.set_ylim(*limits[axis])
    current.set_ylabel("位置 / m", fontproperties=cn_label)
    current.text(0.018, 0.89, panel_labels[axis], transform=current.transAxes,
                 ha="left", va="top", fontproperties=cn_panel, color="#20262D")
    current.grid(True, which="major", color=grid_color, linewidth=0.55, alpha=0.9)
    current.set_axisbelow(True)
    current.xaxis.set_major_locator(MultipleLocator(2.0))
    current.tick_params(direction="out", length=3.2, width=0.7, colors="#30363D")
    for spine in current.spines.values():
        spine.set_color(spine_color)
        spine.set_linewidth(0.75)

axes[0].legend(loc="lower right", ncol=2, frameon=False,
               handlelength=2.8, columnspacing=1.5, prop=cn_legend)
axes[-1].set_xlabel("时间 / s", fontproperties=cn_label)
figure.subplots_adjust(left=0.105, right=0.985, top=0.985, bottom=0.09, hspace=0.08)

FIGURE_DIR.mkdir(parents=True, exist_ok=True)
figure.savefig(PNG, dpi=320, facecolor="white")
figure.savefig(PDF, facecolor="white")
figure.savefig(SVG, facecolor="white")
plt.close(figure)

manifest = {
    "schema_version": 1,
    "figure_candidate": "图2-3",
    "purpose": "官方PID三轴独立阶跃基线响应",
    "software": f"Python {sys.version.split()[0]}; Matplotlib {matplotlib.__version__}",
    "metric_source": "Syslab julia-ty audit output; no metric values are hard-coded in the plot script",
    "input_files": {
        str(PLOT_DATA): sha256(PLOT_DATA),
        str(METRICS_DATA): sha256(METRICS_DATA),
    },
    "output_files": {
        str(PNG): sha256(PNG),
        str(PDF): sha256(PDF),
        str(SVG): sha256(SVG),
    },
    "plot_window": "8-20 s, inherited from the existing Chapter 2 presentation",
    "sample_count_per_axis": 1201,
    "style_contract": "PID dark gray solid; reference black dashed; no in-figure title",
    "fonts": {"Chinese": str(SIMSUN), "Latin_and_digits": "Times New Roman"},
}
MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
print(f"PNG={PNG}")
print(f"PNG_SHA256={sha256(PNG)}")
print(f"PDF_SHA256={sha256(PDF)}")
print(f"SVG_SHA256={sha256(SVG)}")
