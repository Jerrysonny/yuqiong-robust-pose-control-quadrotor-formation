from __future__ import annotations

import csv
import hashlib
import json
import re
import subprocess
import sys
import tempfile
import unittest
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "04_results" / "report_evidence"
GENERATOR = ROOT / "02_scripts" / "evaluation" / "build_report_evidence.py"
MANIFEST = EVIDENCE / "REPORT_EVIDENCE_MANIFEST.json"
FORMAL = "RA-GCA-CGHTE"
EXPECTED_FILES = {
    "README_报告证据使用边界.md",
    "01_five_controller_scene_coverage.csv",
    "02_standard_step_pid_vs_main.csv",
    "03_five_controller_common_scenes.csv",
    "04_algorithm_evolution_ablation.csv",
    "05_parameter_11_paired.csv",
    "06_project_regression_32_summary.json",
    "07_disturbance_tradeoff.csv",
    "08_compound_stress_tradeoff.csv",
    "09_formation_pp_cbf.csv",
    "10_claim_evidence_index.csv",
    "source_snapshots/chapter6_metrics_normalized.json",
    "source_snapshots/compound_stress_formal_algorithm.csv",
    "REPORT_EVIDENCE_MANIFEST.json",
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def read_csv(name: str, root: Path = EVIDENCE) -> list[dict[str, str]]:
    with (root / name).open("r", encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))


def evidence_state() -> dict[str, tuple[int, int, str]]:
    return {
        path.relative_to(EVIDENCE).as_posix(): (path.stat().st_size, path.stat().st_mtime_ns, sha256(path))
        for path in EVIDENCE.rglob("*")
        if path.is_file()
    }


class ReportEvidenceTest(unittest.TestCase):
    def test_expected_file_set_and_manifest_hashes(self) -> None:
        actual = {
            path.relative_to(EVIDENCE).as_posix()
            for path in EVIDENCE.rglob("*")
            if path.is_file()
        }
        self.assertEqual(actual, EXPECTED_FILES)
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        self.assertEqual(manifest["formal_algorithm"], FORMAL)
        self.assertEqual(manifest["verified_raw_sha256_count"], 64)
        self.assertFalse(manifest["manifest_self_hash_included"])
        self.assertEqual(manifest["generated_file_count_excluding_manifest"], 13)
        for item in manifest["files"]:
            path = EVIDENCE / item["path"]
            self.assertEqual(path.stat().st_size, item["size"])
            self.assertEqual(sha256(path), item["sha256"])
        for item in manifest["inputs"] + manifest["files"]:
            self.assertNotRegex(item["path"], r"^[A-Za-z]:[\\/]")
            self.assertNotIn("\\", item["path"])

    def test_visible_identity_and_path_hygiene(self) -> None:
        forbidden = ("RA-GCA + CG-HTE", "HTE-F0", "candi" + "date_", "V9 HTE")
        visible = [name for name in EXPECTED_FILES if not name.startswith("source_snapshots/")]
        for name in visible:
            text = (EVIDENCE / name).read_text(encoding="utf-8-sig")
            for token in forbidden:
                self.assertNotIn(token, text, msg=f"{token!r} leaked into {name}")
            self.assertNotRegex(text, r"[A-Za-z]:[\\/]Users[\\/]")
        snapshot = read_csv("source_snapshots/compound_stress_formal_algorithm.csv")
        self.assertEqual({row["formal_algorithm"] for row in snapshot}, {FORMAL})
        self.assertNotIn("internal_source_alias", snapshot[0])

    def test_coverage_and_common_scene_contract(self) -> None:
        coverage = read_csv("01_five_controller_scene_coverage.csv")
        self.assertEqual(
            [row["controller"] for row in coverage],
            ["PID", "RA-GCA/Base", FORMAL, "CAP-ADRC", "CP-INDI"],
        )
        common = read_csv("03_five_controller_common_scenes.csv")
        self.assertEqual(len(common), 20)
        self.assertEqual(Counter(row["case_id"] for row in common), Counter({
            "Scene01": 5,
            "Scene04": 5,
            "Scene03": 5,
            "Scene06b": 5,
        }))
        self.assertEqual(
            {row["controller"] for row in common},
            {"PID", "RA-GCA/Base", FORMAL, "CAP-ADRC", "CP-INDI"},
        )

    def test_standard_steps_and_evolution(self) -> None:
        steps = read_csv("02_standard_step_pid_vs_main.csv")
        self.assertEqual(len(steps), 6)
        self.assertEqual(Counter(row["controller"] for row in steps), Counter({"PID": 3, FORMAL: 3}))
        formal = {row["axis"]: row for row in steps if row["controller"] == FORMAL}
        self.assertAlmostEqual(float(formal["X"]["overshoot_percent"]), 0.0, places=12)
        self.assertAlmostEqual(float(formal["Y"]["overshoot_percent"]), 0.0, places=12)
        self.assertAlmostEqual(float(formal["Z"]["overshoot_percent"]), 1.9829264447, places=8)
        evolution = read_csv("04_algorithm_evolution_ablation.csv")
        self.assertEqual(len(evolution), 12)
        self.assertEqual(
            {row["controller"] for row in evolution},
            {"RA-GCA/Base", "RA-GCA/V8", FORMAL},
        )

    def test_parameter_pairs_and_project_boundary(self) -> None:
        rows = read_csv("05_parameter_11_paired.csv")
        self.assertEqual(len(rows), 11)
        self.assertEqual(Counter(row["classification"] for row in rows), Counter({"improved": 6, "equivalent": 5}))
        self.assertTrue(all(row["pair_gate_pass"] == "true" for row in rows))
        ratio_median = sorted(float(row["formal_v8_rmse_ratio"]) for row in rows)[5]
        self.assertAlmostEqual(ratio_median, 0.0667451469771363, places=15)
        summary = json.loads((EVIDENCE / "06_project_regression_32_summary.json").read_text(encoding="utf-8"))
        self.assertEqual(summary["project_regression_case_count"], 32)
        self.assertEqual(summary["pair_gate_pass_count"], 32)
        self.assertTrue(summary["required_parameter_mismatch_improvement"])
        self.assertFalse(summary["required_parameter_retention"])
        self.assertFalse(summary["overall_selection_gate_pass"])
        self.assertIn("not_an_official", summary["scope"])
        self.assertEqual(
            summary["validation_boundaries"],
            {
                "v30_completed": False,
                "h60_completed": False,
                "wilson_lower_bound_computed": False,
                "paired_bootstrap_completed": False,
                "formal_replacement_decision_source": "engineering decision plus completed project evidence; unfinished statistical tests are not claimed",
            },
        )

    def test_disturbance_and_compound_tradeoffs(self) -> None:
        disturbance = {row["controller"]: row for row in read_csv("07_disturbance_tradeoff.csv")}
        self.assertAlmostEqual(float(disturbance["CP-INDI"]["tracking_rmse_m"]), 0.0621232821298252, places=15)
        self.assertAlmostEqual(float(disturbance[FORMAL]["tracking_rmse_m"]), 0.294903761473424, places=15)
        self.assertLess(
            float(disturbance["CP-INDI"]["tracking_rmse_m"]),
            float(disturbance[FORMAL]["tracking_rmse_m"]),
        )
        compound = read_csv("08_compound_stress_tradeoff.csv")
        self.assertEqual(len(compound), 6)
        self.assertTrue(all(row["paired_physical_pass"] == "true" for row in compound))
        self.assertTrue(any(row["recovery_time_tradeoff"] == "true" for row in compound))
        self.assertTrue(all(row["formal_algorithm"] == FORMAL for row in compound))
        self.assertNotIn(
            "candi" + "date_" + "011",
            (EVIDENCE / "08_compound_stress_tradeoff.csv").read_text(encoding="utf-8"),
        )

    def test_formation_metrics_are_not_conflated(self) -> None:
        rows = {row["case_id"]: row for row in read_csv("09_formation_pp_cbf.csv")}
        scene07b = rows["Scene07B"]
        self.assertAlmostEqual(float(scene07b["formation_rmse_m"]), 0.03827874208128883, places=15)
        self.assertAlmostEqual(
            float(scene07b["three_uav_global_position_tracking_rmse_m"]),
            0.028713635176544905,
            places=15,
        )
        self.assertNotAlmostEqual(
            float(scene07b["formation_rmse_m"]),
            float(scene07b["three_uav_global_position_tracking_rmse_m"]),
            places=6,
        )
        self.assertAlmostEqual(float(rows["Scene07COff"]["minimum_pairwise_distance_m"]), 0.3831758291349347, places=12)
        self.assertAlmostEqual(float(rows["Scene07COnPredictiveV5C"]["minimum_pairwise_distance_m"]), 0.6113274026131267, places=12)
        self.assertAlmostEqual(float(rows["Scene07COff"]["risk_exposure_below_0_60_m_s"]), 2.04, places=12)
        self.assertAlmostEqual(float(rows["Scene07COnPredictiveV5C"]["risk_exposure_below_0_60_m_s"]), 0.0, places=12)

    def test_claim_index_has_raw_script_and_hash_links(self) -> None:
        rows = read_csv("10_claim_evidence_index.csv")
        self.assertEqual(len(rows), 8)
        for row in rows:
            self.assertTrue(row["report_evidence"])
            self.assertTrue(row["raw_or_snapshot_evidence"])
            self.assertTrue(row["metric_script"])
            self.assertTrue(row["hash_evidence"])
            for field in ("report_evidence", "raw_or_snapshot_evidence", "metric_script", "hash_evidence"):
                self.assertNotRegex(row[field], r"^[A-Za-z]:[\\/]")
                self.assertNotIn("\\", row[field])

    def test_check_mode_is_read_only(self) -> None:
        before = evidence_state()
        result = subprocess.run(
            [sys.executable, "-B", str(GENERATOR), "--check"],
            cwd=ROOT,
            capture_output=True,
            text=True,
            encoding="utf-8",
            check=False,
        )
        self.assertEqual(result.returncode, 0, msg=result.stdout + result.stderr)
        self.assertEqual(evidence_state(), before)

    def test_external_rebuild_and_package_output_rejection(self) -> None:
        with tempfile.TemporaryDirectory(prefix="a8_report_evidence_") as temporary:
            output = Path(temporary) / "rebuilt"
            result = subprocess.run(
                [sys.executable, "-B", str(GENERATOR), "--output-dir", str(output)],
                cwd=ROOT,
                capture_output=True,
                text=True,
                encoding="utf-8",
                check=False,
            )
            self.assertEqual(result.returncode, 0, msg=result.stdout + result.stderr)
            rebuilt = {
                path.relative_to(output).as_posix()
                for path in output.rglob("*")
                if path.is_file()
            }
            self.assertEqual(rebuilt, EXPECTED_FILES)
            for name in EXPECTED_FILES:
                self.assertEqual((output / name).read_bytes(), (EVIDENCE / name).read_bytes(), msg=name)

        forbidden = ROOT / "04_results" / "report_evidence_forbidden_output"
        result = subprocess.run(
            [sys.executable, "-B", str(GENERATOR), "--output-dir", str(forbidden)],
            cwd=ROOT,
            capture_output=True,
            text=True,
            encoding="utf-8",
            check=False,
        )
        self.assertEqual(result.returncode, 2)
        self.assertIn("outside the source package", result.stderr)
        self.assertFalse(forbidden.exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
