"""Encode staged PNG frames as conservative, broadly compatible GIF files."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image


def encode_one(frame_paths: list[Path], output: Path, delay_ms: int) -> dict:
    if not frame_paths:
        raise ValueError(f"no frames for {output.name}")
    frames = []
    expected_size = None
    for frame_path in frame_paths:
        with Image.open(frame_path) as source:
            image = source.convert("RGB")
        if expected_size is None:
            expected_size = image.size
        if image.size != expected_size:
            raise ValueError(f"frame size mismatch: {frame_path}")
        # 每帧独立量化调色板，避免高密度曲线出现明显色阶截断。
        frames.append(image.quantize(colors=256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE))

    output.parent.mkdir(parents=True, exist_ok=True)
    frames[0].save(
        output,
        format="GIF",
        save_all=True,
        append_images=frames[1:],
        duration=delay_ms,
        loop=0,
        disposal=2,
        optimize=False,
        interlace=False,
    )

    # 编码完成后重新读取，核对帧数、尺寸和播放间隔。
    with Image.open(output) as check:
        count = getattr(check, "n_frames", 1)
        delays = []
        for frame_index in range(count):
            check.seek(frame_index)
            delays.append(int(check.info.get("duration", 0)))
        if check.size != expected_size:
            raise ValueError(f"encoded size mismatch: {output}")
        if count != len(frame_paths):
            raise ValueError(f"encoded frame count mismatch: {output}: {count} != {len(frame_paths)}")
        if any(delay != delay_ms for delay in delays):
            raise ValueError(f"encoded delay mismatch: {output}: {sorted(set(delays))}")

    return {
        "width": expected_size[0],
        "height": expected_size[1],
        "frame_count": len(frame_paths),
        "frame_delay_ms": delay_ms,
        "duration_s": len(frame_paths) * delay_ms / 1000.0,
        "encoder": "Pillow 9.5.0 adaptive palette, disposal=2, optimize=false",
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--frames-root", type=Path, required=True)
    parser.add_argument("--output-root", type=Path, required=True)
    parser.add_argument("--jobs", type=Path, required=True, help="JSON mapping of output file to frame directory")
    parser.add_argument("--delay-ms", type=int, default=120)
    parser.add_argument("--report", type=Path, required=True)
    args = parser.parse_args()

    jobs = json.loads(args.jobs.read_text(encoding="utf-8"))
    results = {}
    for relative_output, relative_frames in jobs.items():
        frame_dir = args.frames_root / relative_frames
        frame_paths = sorted(frame_dir.glob("frame_*.png"))
        output = args.output_root / relative_output
        results[relative_output] = encode_one(frame_paths, output, args.delay_ms)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps({"status": "passed", "outputs": results}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
