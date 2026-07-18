from __future__ import annotations

import ast
import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FIVE_CONTROLLER = ROOT / "02_scripts" / "syslab" / "build_five_scene_comparison.jl"
VERIFY_RELEASE = ROOT / "02_scripts" / "evaluation" / "verify_release_results.py"
REFERENCE = ROOT / "06_supplementary_evidence" / "ra_gca_cg_hte_32_raw"
CASES = (
    "Scene04",
    "Scene01S_Z",
    "Scene05B_LiftMinus10",
    "Scene08_P0",
    "Scene10_P0",
    "Scene07COnPredictiveV5C",
)


class EvidenceEntrypointTest(unittest.TestCase):
    def test_five_controller_check_and_package_output_rejection(self) -> None:
        julia = shutil.which("julia-ty")
        if julia is None:
            self.skipTest("julia-ty is not available")
        check = subprocess.run(
            [julia, str(FIVE_CONTROLLER), "--check"],
            cwd=ROOT,
            capture_output=True,
            text=True,
            encoding="utf-8",
            check=False,
        )
        self.assertEqual(check.returncode, 0, msg=check.stdout + check.stderr)
        self.assertIn("five_controller_evidence_status=pass", check.stdout)
        forbidden = ROOT / "04_results" / "forbidden_five_controller_export"
        rejected = subprocess.run(
            [julia, str(FIVE_CONTROLLER), "--output", str(forbidden)],
            cwd=ROOT,
            capture_output=True,
            text=True,
            encoding="utf-8",
            check=False,
        )
        self.assertNotEqual(rejected.returncode, 0)
        self.assertIn("outside the source package", rejected.stdout + rejected.stderr)
        self.assertFalse(forbidden.exists())

    def test_release_verifier_uses_packaged_reference_and_external_output(self) -> None:
        ast.parse(VERIFY_RELEASE.read_text(encoding="utf-8"))
        with tempfile.TemporaryDirectory(prefix="a8_release_verifier_") as temporary:
            root = Path(temporary)
            results = root / "results"
            raw = results / "raw"
            raw.mkdir(parents=True)
            for case_id in CASES:
                shutil.copy2(REFERENCE / f"{case_id}.csv", raw / f"{case_id}.csv")
            status = {
                "success": True,
                "algorithm_id": "RA-GCA-CGHTE",
                "selected_cases": list(CASES),
            }
            (results / "execution_status.json").write_text(
                json.dumps(status, ensure_ascii=False) + "\n",
                encoding="utf-8",
            )
            output = root / "release_reproduction.json"
            completed = subprocess.run(
                [
                    sys.executable,
                    "-B",
                    str(VERIFY_RELEASE),
                    "--results",
                    str(results),
                    "--output",
                    str(output),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
                encoding="utf-8",
                check=False,
            )
            self.assertEqual(completed.returncode, 0, msg=completed.stdout + completed.stderr)
            payload = json.loads(output.read_text(encoding="utf-8"))
            self.assertTrue(payload["success"])
            self.assertEqual(payload["byte_identical_count"], 6)

        forbidden = ROOT / "04_results" / "forbidden_release_reproduction.json"
        rejected = subprocess.run(
            [
                sys.executable,
                "-B",
                str(VERIFY_RELEASE),
                "--results",
                str(ROOT),
                "--output",
                str(forbidden),
            ],
            cwd=ROOT,
            capture_output=True,
            text=True,
            encoding="utf-8",
            check=False,
        )
        self.assertEqual(rejected.returncode, 2)
        self.assertIn("outside the source package", rejected.stderr)
        self.assertFalse(forbidden.exists())

    def test_legacy_workspace_paths_are_absent(self) -> None:
        for path in (FIVE_CONTROLLER, VERIFY_RELEASE):
            text = path.read_text(encoding="utf-8")
            for token in ("00_输入快照", "04_结果数据", "00_source_snapshot", "04_analysis"):
                self.assertNotIn(token, text, msg=f"{token} in {path.name}")


if __name__ == "__main__":
    unittest.main(verbosity=2)
