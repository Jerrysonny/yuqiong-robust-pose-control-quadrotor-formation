from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "03_figures" / "R9语言与Sysblock附录优化" / "RA-GCA-CGHTE_Sysblock内部实现_6000x4000.png"
OUTPUT_DIR = ROOT / "03_figures" / "R12完整图与分页优化"
OUTPUT = OUTPUT_DIR / "图A-3_Sysblock完整实现重点区域标注_R12.png"

BLUE = "#2F6F9F"
GREEN = "#4E7A62"
WHITE = "#FFFFFF"


def load_font(size: int):
    for path in (
        Path("C:/Windows/Fonts/timesbd.ttf"),
        Path("C:/Windows/Fonts/arialbd.ttf"),
        Path("C:/Windows/Fonts/arial.ttf"),
    ):
        if path.is_file():
            return ImageFont.truetype(str(path), size=size)
    return ImageFont.load_default()


def draw_focus(draw: ImageDraw.ImageDraw, bounds, label: str, color: str, font) -> None:
    x1, y1, x2, y2 = bounds
    draw.rounded_rectangle(bounds, radius=34, outline=WHITE, width=40)
    draw.rounded_rectangle(bounds, radius=34, outline=color, width=20)

    label_box = (x1 + 28, y1 + 28, x1 + 235, y1 + 165)
    draw.rounded_rectangle(label_box, radius=24, fill=WHITE, outline=color, width=12)
    text_box = draw.textbbox((0, 0), label, font=font)
    text_width = text_box[2] - text_box[0]
    text_height = text_box[3] - text_box[1]
    tx = (label_box[0] + label_box[2] - text_width) / 2
    ty = (label_box[1] + label_box[3] - text_height) / 2 - text_box[1]
    draw.text((tx, ty), label, fill=color, font=font)


def main() -> None:
    if not SOURCE.is_file():
        raise FileNotFoundError(SOURCE)
    if OUTPUT.exists():
        raise FileExistsError(OUTPUT)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    with Image.open(SOURCE) as source:
        image = source.convert("RGB")
        if image.size != (6000, 4000):
            raise RuntimeError(f"Unexpected source size: {image.size}")
        draw = ImageDraw.Draw(image)
        font = load_font(92)

        # The complete 6000 x 4000 export remains visible. The rectangles only
        # identify the two regions discussed in the caption.
        draw_focus(draw, (1030, 110, 5420, 2250), "(a)", BLUE, font)
        draw_focus(draw, (2380, 1320, 5950, 3950), "(b)", GREEN, font)
        image.save(OUTPUT, dpi=(600, 600), optimize=True)

    if not OUTPUT.is_file() or OUTPUT.stat().st_size == 0:
        raise RuntimeError(f"Failed to create {OUTPUT}")


if __name__ == "__main__":
    main()
