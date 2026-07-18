from __future__ import annotations

import csv
import hashlib
import json
import os
import re
import subprocess
import sys
import unittest
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "05_visuals/assets/report_static"
QA_PATH = ROOT / "05_visuals/qa/final_report_static_qa.json"
CONTACT = ROOT / "05_visuals/qa/最终报告28图联系表.png"
INDEX = ROOT / "08_provenance/FINAL_REPORT_ASSET_INDEX.csv"
VERIFIER = ROOT / "05_visuals/verify_final_report_assets.py"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


class FinalReportVisualsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.qa = json.loads(QA_PATH.read_text(encoding="utf-8"))
        cls.figures = {item["id"]: item for item in cls.qa["figures"]}
        with INDEX.open(encoding="utf-8-sig", newline="") as stream:
            cls.index = list(csv.DictReader(stream))

    def test_complete_final_report_asset_set(self) -> None:
        self.assertEqual(len(self.figures), 28)
        self.assertEqual(len([row for row in self.index if row["type"] == "figure"]), 28)
        self.assertEqual(len([row for row in self.index if row["type"] == "table"]), 26)
        self.assertEqual(len(list(ASSETS.glob("*.png"))), 28)
        self.assertEqual(list(ASSETS.glob("*.svg")), [])
        self.assertFalse(self.qa["candidate_only"])
        self.assertTrue(self.qa["final_report_numbering_assigned"])

    def test_png_dimensions_and_hashes(self) -> None:
        for asset_id, item in self.figures.items():
            path = ROOT / item["png"]
            self.assertEqual(path.name, f"{asset_id}.png")
            self.assertTrue(path.is_file(), msg=path)
            with Image.open(path) as image:
                self.assertEqual(image.format, "PNG", msg=path.name)
                self.assertEqual(image.size, (item["width_px"], item["height_px"]))
                self.assertGreaterEqual(image.width, 900)
                self.assertGreaterEqual(image.height, 240)
            self.assertEqual(sha256(path), item["sha256"], msg=path.name)

    def test_visible_identity_and_numbering(self) -> None:
        visible = QA_PATH.read_text(encoding="utf-8") + INDEX.read_text(encoding="utf-8-sig")
        for token in ("RA-GCA + CG-HTE", "HTE-F0", "V9 HTE", "RA-GCA/V8"):
            self.assertNotIn(token, visible)
        self.assertIsNone(re.search(r"candidate_\d+", visible))
        self.assertEqual(self.qa["algorithm_display_name"], "RA-GCA-CGHTE")

    def test_contact_sheet(self) -> None:
        self.assertTrue(CONTACT.is_file())
        with Image.open(CONTACT) as image:
            self.assertEqual(image.size, (2400, 3640))
            self.assertEqual(image.format, "PNG")

    def test_verifier_is_read_only(self) -> None:
        tracked = [QA_PATH, CONTACT, INDEX, *sorted(ASSETS.glob("*.png"))]
        before = {path: (path.stat().st_size, path.stat().st_mtime_ns, sha256(path)) for path in tracked}
        environment = os.environ.copy()
        environment["PYTHONIOENCODING"] = "utf-8"
        result = subprocess.run(
            [sys.executable, "-B", str(VERIFIER), "--check"],
            cwd=ROOT,
            capture_output=True,
            text=True,
            encoding="utf-8",
            env=environment,
            check=False,
        )
        self.assertEqual(result.returncode, 0, msg=(result.stdout or "") + (result.stderr or ""))
        after = {path: (path.stat().st_size, path.stat().st_mtime_ns, sha256(path)) for path in tracked}
        self.assertEqual(after, before)


if __name__ == "__main__":
    unittest.main(verbosity=2)
