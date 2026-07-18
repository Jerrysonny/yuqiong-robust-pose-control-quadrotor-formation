from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
ASSET_INDEX = ROOT / "08_provenance/FINAL_REPORT_ASSET_INDEX.csv"
ADMISSION = ROOT / "08_provenance/FINAL_MATERIAL_ADMISSION.csv"
FREEZE = ROOT / "08_provenance/FINAL_REPORT_FREEZE.json"
QA = ROOT / "05_visuals/qa/final_report_static_qa.json"
CONTACT = ROOT / "05_visuals/qa/最终报告28图联系表.png"
STATIC = ROOT / "05_visuals/assets/report_static"
VECTORS = ROOT / "05_visuals/assets/report_sources/vectors"

FORBIDDEN_VISIBLE = re.compile(
    r"RA-GCA/V8|candidate_\d+|HTE-F0|V9 HTE|RA-GCA\s*\+\s*CG-HTE"
)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))


def require_reference(reference: str) -> None:
    if not reference:
        return
    target = ROOT / reference
    if not target.exists():
        raise RuntimeError(f"missing report asset reference: {reference}")


def check() -> dict:
    # 资产索引和准入表必须覆盖全部最终编号图表。
    assets = read_csv(ASSET_INDEX)
    admission = read_csv(ADMISSION)
    figures = {row["asset_id"]: row for row in assets if row["type"] == "figure"}
    tables = {row["asset_id"]: row for row in assets if row["type"] == "table"}
    if len(assets) != 54 or len(figures) != 28 or len(tables) != 26:
        raise RuntimeError("final report asset count mismatch")
    if len(admission) != 54 or any(row["decision"] != "采用" for row in admission):
        raise RuntimeError("material admission decision mismatch")

    freeze = json.loads(FREEZE.read_text(encoding="utf-8-sig"))
    if (
        freeze.get("status") != "frozen"
        or freeze.get("numbered_figures") != 28
        or freeze.get("numbered_tables") != 26
        or freeze.get("pdf_pages") != 53
    ):
        raise RuntimeError("final report freeze mismatch")

    qa = json.loads(QA.read_text(encoding="utf-8"))
    qa_figures = {row["id"]: row for row in qa.get("figures", [])}
    if (
        qa.get("status") != "passed"
        or qa.get("candidate_only") is not False
        or qa.get("final_report_numbering_assigned") is not True
        or set(qa_figures) != set(figures)
    ):
        raise RuntimeError("final report visual QA contract mismatch")

    physical_png = sorted(STATIC.glob("*.png"))
    if len(physical_png) != 28 or any(path.suffix.lower() != ".png" for path in STATIC.iterdir()):
        raise RuntimeError("report_static must contain exactly 28 PNG files")

    for asset_id, row in figures.items():
        # 每幅图同时核对文件名、哈希、像素尺寸和数据来源。
        target = ROOT / row["package_file"]
        item = qa_figures[asset_id]
        if target.name != f"{asset_id}.png" or not target.is_file():
            raise RuntimeError(f"missing final report PNG: {asset_id}")
        if sha256(target) != row["output_sha256"] or sha256(target) != item["sha256"]:
            raise RuntimeError(f"final report PNG hash mismatch: {asset_id}")
        with Image.open(target) as image:
            if image.format != "PNG" or image.width < 900 or image.height < 240:
                raise RuntimeError(f"final report PNG quality mismatch: {asset_id}")
            if image.width != item["width_px"] or image.height != item["height_px"]:
                raise RuntimeError(f"final report PNG dimension mismatch: {asset_id}")
        for reference in filter(None, row["source_data"].split(";")):
            require_reference(reference)
        for generator in filter(None, row["generator_or_model"].split(";")):
            if "/" in generator:
                require_reference(generator)

    for row in tables.values():
        for reference in filter(None, row["source_data"].split(";")):
            require_reference(reference)

    # 矢量底稿数量固定，避免候选版本混入最终发布目录。
    vectors = list(VECTORS.glob("*"))
    if sum(path.suffix.lower() == ".svg" for path in vectors) != 24:
        raise RuntimeError("expected 24 admitted SVG files")
    if sum(path.suffix.lower() == ".pdf" for path in vectors) != 23:
        raise RuntimeError("expected 23 admitted PDF files")

    with Image.open(CONTACT) as image:
        if image.format != "PNG" or image.size != (2400, 3640):
            raise RuntimeError("final report contact sheet mismatch")

    # 读者可见索引中不得出现研发阶段名称。
    visible = QA.read_text(encoding="utf-8") + ASSET_INDEX.read_text(encoding="utf-8-sig")
    if FORBIDDEN_VISIBLE.search(visible):
        raise RuntimeError("forbidden historical label in final report visual index")

    return {
        "status": "passed",
        "figures": len(figures),
        "tables": len(tables),
        "svg": 24,
        "pdf": 23,
        "contact_sheet": CONTACT.relative_to(ROOT).as_posix(),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if not args.check:
        parser.error("only the read-only --check mode is supported")
    print(json.dumps(check(), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
