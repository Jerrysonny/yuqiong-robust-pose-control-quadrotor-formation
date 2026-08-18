"""Build or check deterministic manifests for the 20-case parameter dataset."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
from pathlib import Path
from typing import Any


CONTROLLERS = ("PID", "RA-GCA-CGHTE")
CASE_IDS = tuple(f"MC20_{index:02d}" for index in range(1, 21))
EVIDENCE_FILES = (
    "README_20组随机参数配对验证.md",
    "experiment_settings.json",
    "sample_manifest.csv",
    "sample_manifest.sha256",
    "controller_metrics.csv",
    "paired_results.csv",
    "controller_summary.csv",
    "statistical_summary.csv",
    "statistical_summary.json",
    "independent_verification.json",
)
SCRIPT_PATHS = (
    "02_scripts/sysplorer/run_parameter_random20.py",
    "02_scripts/syslab/generate_parameter_random20_samples.jl",
    "02_scripts/syslab/analyze_parameter_random20.jl",
    "02_scripts/evaluation/verify_parameter_random20.py",
    "02_scripts/evaluation/build_parameter_random20_manifest.py",
    "08_provenance/report_generation_sources/scripts/plot_parameter_random20.py",
    "RUN_PARAMETER_RANDOM20.ps1",
    "RECOMPUTE_PARAMETER_RANDOM20.ps1",
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def file_record(root: Path, path: Path) -> dict[str, Any]:
    return {
        "path": path.relative_to(root).as_posix(),
        "size": path.stat().st_size,
        "sha256": sha256(path),
    }


def load_samples(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8", newline="") as stream:
        rows = list(csv.DictReader(stream))
    if [row["case_id"] for row in rows] != list(CASE_IDS):
        raise RuntimeError("sample identifiers or order changed")
    return rows


def build_raw_manifest(root: Path) -> dict[str, Any]:
    evidence = root / "04_results/report_evidence/parameter_random20"
    raw_root = root / "06_supplementary_evidence/parameter_random20_raw"
    samples = {row["case_id"]: row for row in load_samples(evidence / "sample_manifest.csv")}
    entries: list[dict[str, Any]] = []
    for case_id in CASE_IDS:
        files: dict[str, Any] = {}
        for controller in CONTROLLERS:
            path = raw_root / controller / f"{case_id}.csv"
            if not path.is_file():
                raise RuntimeError(f"missing raw file: {path}")
            files[controller] = file_record(root, path)
        sample = samples[case_id]
        entries.append(
            {
                "case_id": case_id,
                "lift_scale": float(sample["lift_scale"]),
                "mass_scale": float(sample["mass_scale"]),
                "inertia_scale": float(sample["inertia_scale"]),
                "files": files,
            }
        )
    return {
        "schema_version": 1,
        "dataset": "20-case matched random-parameter validation",
        "controllers": list(CONTROLLERS),
        "case_count": len(CASE_IDS),
        "raw_file_count": len(CASE_IDS) * len(CONTROLLERS),
        "layout": "controller/case_id.csv",
        "entries": entries,
    }


def build_evidence_manifest(root: Path, raw_manifest: dict[str, Any]) -> dict[str, Any]:
    evidence = root / "04_results/report_evidence/parameter_random20"
    files = []
    for name in EVIDENCE_FILES:
        path = evidence / name
        if not path.is_file():
            raise RuntimeError(f"missing evidence file: {path}")
        files.append(file_record(root, path))
    scripts = []
    for relative in SCRIPT_PATHS:
        path = root / relative
        if not path.is_file():
            raise RuntimeError(f"missing reproduction script: {path}")
        scripts.append(file_record(root, path))
    return {
        "schema_version": 1,
        "scope": "20-case matched random-parameter report evidence",
        "formal_algorithm": "RA-GCA-CGHTE",
        "baseline": "official PID",
        "sample_count": 20,
        "controller_run_count": 40,
        "files": files,
        "scripts": scripts,
        "raw_manifest": {
            "path": "06_supplementary_evidence/parameter_random20_raw/RAW_MANIFEST.json",
            "sha256": hashlib.sha256(
                (json.dumps(raw_manifest, ensure_ascii=False, indent=2) + "\n").encode("utf-8")
            ).hexdigest().upper(),
        },
        "result_summary": {
            "physical_pass_count": 40,
            "main_rmse_win_count": 20,
            "median_rmse_reduction_percent": 87.6344509335469,
            "bootstrap_95_percent": [83.7408486007854, 90.1864564215455],
            "exact_sign_test_p_two_sided": 1.9073486328125e-6,
            "main_engineering_reference_pass_count": 18,
        },
    }


def json_bytes(value: dict[str, Any]) -> bytes:
    return (json.dumps(value, ensure_ascii=False, indent=2) + "\n").encode("utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, required=True)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--write", action="store_true")
    mode.add_argument("--check", action="store_true")
    args = parser.parse_args()

    root = args.root.resolve()
    raw_path = root / "06_supplementary_evidence/parameter_random20_raw/RAW_MANIFEST.json"
    evidence_path = root / "04_results/report_evidence/parameter_random20/EVIDENCE_MANIFEST.json"
    raw = build_raw_manifest(root)
    evidence = build_evidence_manifest(root, raw)
    expected = {raw_path: json_bytes(raw), evidence_path: json_bytes(evidence)}

    if args.write:
        for path, data in expected.items():
            if path.exists():
                raise RuntimeError(f"refusing to overwrite manifest: {path}")
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
    else:
        for path, data in expected.items():
            if not path.is_file() or path.read_bytes() != data:
                raise RuntimeError(f"manifest is missing or stale: {path}")

    print("parameter_random20_manifest=pass")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
