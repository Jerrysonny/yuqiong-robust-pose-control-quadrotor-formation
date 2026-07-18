from __future__ import annotations

import hashlib
import re
import tomllib
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / "config" / "main_controller.toml"
PORTABLE_ACTIVE_FILES = (
    "RUN_ALL.ps1",
    "RUN_QUICK_VERIFY.ps1",
    "RECOMPUTE_REPORT_EVIDENCE.ps1",
    "02_scripts/powershell/A8RuntimeResolver.ps1",
    "05_visuals/generate_visuals.js",
    "05_visuals/visual_generation_helpers.js",
    "00_START_HERE/README_项目总览与使用入口.md",
    "05_visuals/README_生成与独立验收.md",
    "05_visuals/README_可视化说明.md",
)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


class ReleaseStaticTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.config = tomllib.loads(CONFIG.read_text(encoding="utf-8"))
        cls.controller_path = ROOT / cls.config["controller"]["path"]
        cls.controller = cls.controller_path.read_text(encoding="utf-8")
        cls.runner_path = ROOT / "02_scripts" / "sysplorer" / "run_main_controller.py"
        cls.runner = cls.runner_path.read_text(encoding="utf-8")
        cls.campaign = tomllib.loads(
            (ROOT / "config" / "campaign.toml").read_text(encoding="utf-8")
        )
        cls.run_all = (ROOT / "RUN_ALL.ps1").read_text(encoding="utf-8")
        cls.campaign_runner = (
            ROOT / "02_scripts" / "syslab" / "run_campaign_evaluation.jl"
        ).read_text(encoding="utf-8")

    def test_formal_identity(self) -> None:
        algorithm = self.config["algorithm"]
        self.assertEqual(algorithm["short_name"], "RA-GCA-CGHTE")
        self.assertEqual(algorithm["version"], "1.0.0")
        self.assertEqual(self.config["release_status"], "formal_main_controller")

    def test_controller_hash_and_class(self) -> None:
        expected = self.config["controller"]["sha256"]
        self.assertEqual(sha256(self.controller_path), expected)
        class_name = self.config["controller"]["class"]
        self.assertRegex(self.controller, rf"(?m)^model {re.escape(class_name)}$")
        self.assertRegex(self.controller, rf"(?m)^end {re.escape(class_name)};$")

    def test_fixed_parameters_match_source(self) -> None:
        parameters = self.config["fixed_parameters"]
        expected = {
            "activation_covariance_max_param": parameters["activation_covariance_max"],
            "activation_persistence_s_param": parameters["activation_persistence_s"],
            "scale_rate_per_step_param": parameters["scale_rate_per_step"],
        }
        for component, value in expected.items():
            pattern = rf"{component}\(k={re.escape(format(value, '.15g'))}\)"
            self.assertRegex(self.controller, pattern)

    def test_active_models_use_formal_controller(self) -> None:
        model_root = ROOT / "01_models" / "modelica"
        packages = sorted(model_root.glob("*/package.mo"))
        self.assertEqual(len(packages), 4)
        combined = "\n".join(path.read_text(encoding="utf-8") for path in packages)
        self.assertIn("A8FormalRAGCACGHTE_20260715", combined)
        self.assertNotIn("A8FormalSO3V9PX4AllocHTETunable_20260714", combined)
        self.assertNotIn("A8SO3V9HTEPlant20260713", combined)

    def test_runner_is_fixed_and_self_contained(self) -> None:
        self.assertIn('MAIN_CONTROLLER = "A8FormalRAGCACGHTE_20260715"', self.runner)
        self.assertIn('MAIN_PLANT = "A8RAGCACGHTEPlant20260715"', self.runner)
        self.assertNotIn("--activation-covariance-max", self.runner)
        self.assertNotIn("--activation-persistence-s", self.runner)
        self.assertNotIn("--scale-rate-per-s", self.runner)
        self.assertNotIn("正式SO3_v9悬停推力估计攻坚_20260713", self.runner)
        self.assertNotIn("A8比赛工程最终成果包_20260713", self.runner)
        self.assertNotIn('"f0_plant_base"', self.runner)
        self.assertNotIn('"candidate_sec"', self.runner)
        self.assertNotIn('"candidate_plant"', self.runner)

    def test_v8_is_non_default_baseline(self) -> None:
        baseline = self.config["baseline"]
        path = ROOT / baseline["path"]
        self.assertEqual(baseline["role"], "comparison_and_rollback_only")
        self.assertEqual(sha256(path), baseline["sha256"])
        self.assertNotEqual(baseline["class"], self.config["controller"]["class"])

    def test_campaign_contract_uses_formal_identity_and_parameters(self) -> None:
        self.assertEqual(self.campaign["identity"]["formal_id"], "RA-GCA-CGHTE")
        self.assertEqual(self.campaign["identity"]["formal_diagnostic_version"], 914)
        formal = self.campaign["formal_fixed_parameters"]
        self.assertEqual(formal["activation_covariance_max"], 0.00253218969247675)
        self.assertEqual(formal["activation_persistence_s"], 0.10)
        self.assertEqual(formal["scale_rate_limit_per_s"], 0.868)
        self.assertNotIn("tunable", self.campaign)

    def test_orchestration_requires_external_output(self) -> None:
        self.assertIn("Resolve-ExternalOutput", self.run_all)
        self.assertIn("-Output is required for Simulate and All modes", self.run_all)
        self.assertNotIn("work_results/main_regression", self.run_all)
        self.assertIn("--formal-root", self.campaign_runner)
        self.assertIn('"RA-GCA-CGHTE", "hte_version" => 914', self.campaign_runner)
        self.assertIn("--output is required", self.campaign_runner)

    def test_active_entrypoints_are_portable(self) -> None:
        fixed_drive = re.compile(r"(?<![A-Za-z])[A-Za-z]:[\\/]")
        for relative in PORTABLE_ACTIVE_FILES:
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIsNone(fixed_drive.search(text), f"fixed filesystem drive in {relative}")
        for relative in ("RUN_ALL.ps1", "RUN_QUICK_VERIFY.ps1", "RECOMPUTE_REPORT_EVIDENCE.ps1"):
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn("A8RuntimeResolver.ps1", text)
            self.assertIn("Resolve-A8MWorksPython", text)

    def test_runtime_resolution_test_is_packaged(self) -> None:
        self.assertTrue((ROOT / "test/test_runtime_resolution.ps1").is_file())


if __name__ == "__main__":
    unittest.main(verbosity=2)
