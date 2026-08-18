"""Validate final figure formats, pixels, SVG text and generation hashes."""

from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops


STEMS = ("parameter_robustness_mc20", "paired_improvement_mc20")
EXTENSIONS = (".svg", ".pdf", ".png", ".tiff")


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def atomic_json(path: Path, value: dict[str, Any]) -> None:
    if path.exists():
        raise RuntimeError(f"refusing to overwrite QA result: {path}")
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(
        json.dumps(value, indent=2, ensure_ascii=False, allow_nan=False) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)


def validate(visual_root: Path) -> dict[str, Any]:
    failures: list[str] = []
    raster_records: list[dict[str, Any]] = []
    svg_records: list[dict[str, Any]] = []

    expected = [visual_root / f"{stem}{extension}" for stem in STEMS for extension in EXTENSIONS]
    actual = sorted(
        path
        for path in visual_root.iterdir()
        if path.is_file() and path.name != "figure_generation_record.json"
    )
    if set(actual) != set(expected):
        failures.append("final visual file set is not exactly two figures in four formats")
    for path in expected:
        if not path.is_file() or path.stat().st_size <= 0:
            failures.append(f"missing or empty output: {path.name}")

    for stem in STEMS:
        png_path = visual_root / f"{stem}.png"
        tiff_path = visual_root / f"{stem}.tiff"
        if not png_path.is_file() or not tiff_path.is_file():
            continue
        with Image.open(png_path) as source:
            png = source.convert("RGB")
            png_dpi = source.info.get("dpi")
        with Image.open(tiff_path) as source:
            tiff = source.convert("RGB")
            tiff_dpi = source.info.get("dpi")
        if png.size != tiff.size:
            failures.append(f"PNG/TIFF dimensions differ: {stem}")
        if ImageChops.difference(png, tiff).getbbox() is not None:
            failures.append(f"PNG/TIFF pixels differ: {stem}")
        extrema = png.convert("L").getextrema()
        if extrema[0] == extrema[1]:
            failures.append(f"blank raster: {stem}")
        if min(png.size) < 1500:
            failures.append(f"raster resolution too small: {stem}")
        raster_records.append(
            {
                "stem": stem,
                "dimensions": list(png.size),
                "png_dpi": [float(value) for value in png_dpi] if png_dpi else None,
                "tiff_dpi": [float(value) for value in tiff_dpi] if tiff_dpi else None,
                "grayscale_extrema": list(extrema),
                "pixel_identical": True,
            }
        )

    for path in sorted(visual_root.glob("*.svg")):
        content = path.read_text(encoding="utf-8")
        record = {
            "file": path.name,
            "text_elements": content.count("<text"),
            "replacement_characters": content.count("\ufffd"),
            "old_algorithm_mentions": content.count("RA-GCA/V8"),
            "has_official_pid": "官方PID" in content,
            "has_main_algorithm": "RA-GCA-CGHTE" in content,
        }
        if record["text_elements"] == 0:
            failures.append(f"SVG text is not editable: {path.name}")
        if record["replacement_characters"] or record["old_algorithm_mentions"]:
            failures.append(f"SVG contains forbidden text: {path.name}")
        svg_records.append(record)

    generation_path = visual_root / "figure_generation_record.json"
    if not generation_path.is_file():
        failures.append("missing figure generation record")
        generation = {}
    else:
        generation = json.loads(generation_path.read_text(encoding="utf-8"))
        outputs = generation.get("outputs", [])
        if len(outputs) != 8:
            failures.append("generation record does not contain eight outputs")
        for item in outputs:
            path = Path(item["path"])
            if not path.is_file() or sha256(path) != item["sha256"]:
                failures.append(f"generation hash mismatch: {path.name}")

    return {
        "schema_version": 1,
        "verified_utc": utc_now(),
        "success": not failures,
        "visual_root": str(visual_root),
        "expected_output_count": 8,
        "raster": raster_records,
        "svg": svg_records,
        "generation_record_sha256": sha256(generation_path) if generation_path.is_file() else None,
        "failures": failures,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--visual-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    result = validate(args.visual_root.resolve())
    atomic_json(args.output.resolve(), result)
    print(f"figure_validation={'pass' if result['success'] else 'fail'}")
    print(f"failures={len(result['failures'])}")
    raise SystemExit(0 if result["success"] else 1)
