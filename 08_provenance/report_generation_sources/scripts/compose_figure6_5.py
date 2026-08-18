from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def label_font(size: int) -> ImageFont.ImageFont:
    candidates = (
        Path("C:/Windows/Fonts/msyhbd.ttc"),
        Path("C:/Windows/Fonts/msyh.ttc"),
    )
    for path in candidates:
        if path.is_file():
            return ImageFont.truetype(str(path), size)
    return ImageFont.load_default()


def relabel_lower_panels(image: Image.Image) -> Image.Image:
    result = image.convert("RGBA")
    draw = ImageDraw.Draw(result)
    font = label_font(82)

    # 原辅助图使用(a)(b)，合并到图6-5后改为(c)(d)。
    replacements = [
        ((95, 205, 235, 350), (135, 220), "c"),
        ((2110, 195, 2410, 365), (2185, 220), "d"),
    ]
    for rectangle, position, label in replacements:
        draw.rectangle(rectangle, fill="white")
        draw.text(position, label, fill="black", font=font, anchor="la")
    return result


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--primary", type=Path, required=True)
    parser.add_argument("--improvement", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--record", type=Path, required=True)
    args = parser.parse_args()

    if args.output.exists() or args.record.exists():
        raise FileExistsError("refusing to overwrite composite output")

    with Image.open(args.primary) as source:
        upper = source.convert("RGBA")
    with Image.open(args.improvement) as source:
        lower = relabel_lower_panels(source)

    if upper.width != lower.width:
        raise ValueError("source figures must have the same width")

    gap = 36
    canvas = Image.new("RGBA", (upper.width, upper.height + gap + lower.height), "white")
    canvas.alpha_composite(upper, (0, 0))
    canvas.alpha_composite(lower, (0, upper.height + gap))
    canvas.convert("RGB").save(args.output, format="PNG", dpi=(600, 600), optimize=True)

    record = {
        "role": "report-specific Figure 6-5 composite",
        "inputs": [
            {"path": str(args.primary), "sha256": sha256(args.primary)},
            {"path": str(args.improvement), "sha256": sha256(args.improvement)},
        ],
        "output": {
            "path": str(args.output),
            "sha256": sha256(args.output),
            "pixels": [canvas.width, canvas.height],
            "dpi": 600,
        },
        "panel_mapping": {"upper": ["a", "b"], "lower": ["c", "d"]},
    }
    args.record.write_text(
        json.dumps(record, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


if __name__ == "__main__":
    main()
