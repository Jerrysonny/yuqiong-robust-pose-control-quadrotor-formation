"""Read-only verification for the concise ARDG-RGPC finals package."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import zipfile
from pathlib import Path


FORBIDDEN_PUBLIC = re.compile(
    r"初赛|v914|v936|ARDG1|\bL06\b|\b97406\b|RA-GCA-CGHTE",
    re.IGNORECASE,
)
ABSOLUTE_USER_PATH = re.compile(r"(?i)[A-Z]:[\\/]Users[\\/]")
EXTERNAL_SHAPE = re.compile(
    r'shapeType\s*=\s*"([^"\r\n]+\.(?:stl|hsf|obj|dxf))"',
    re.IGNORECASE,
)
FORBIDDEN_DIRS = {
    "tmp",
    "__pycache__",
    "ra_gca_cg_hte_32_raw",
    "ra_gca_v8_32_raw",
    "report_final_20260815",
    "report_static",
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def load_json(path: Path) -> dict:
    require(path.is_file(), f"missing JSON: {path}")
    return json.loads(path.read_text(encoding="utf-8-sig"))


def public_docx_text(path: Path) -> str:
    with zipfile.ZipFile(path) as archive:
        parts = []
        for name in archive.namelist():
            if name.startswith("word/") and name.endswith(".xml"):
                parts.append(archive.read(name).decode("utf-8", errors="ignore"))
        return "\n".join(parts)


def check_manifest(root: Path) -> int:
    manifest_path = root / "SHA256_MANIFEST.json"
    manifest = load_json(manifest_path)
    entries = manifest.get("files", [])
    expected_paths = {
        path.relative_to(root).as_posix()
        for path in root.rglob("*")
        if path.is_file() and path != manifest_path
    }
    recorded_paths = {entry["path"] for entry in entries}
    require(recorded_paths == expected_paths, "SHA256 manifest file set mismatch")
    for entry in entries:
        path = root / entry["path"]
        require(path.stat().st_size == entry["size_bytes"], f"size mismatch: {entry['path']}")
        require(sha256(path) == entry["sha256"], f"hash mismatch: {entry['path']}")
    return len(entries)


def check_report(root: Path) -> dict:
    freeze = load_json(root / "08_provenance/FINAL_REPORT_FREEZE.json")
    docx = root / freeze["report_docx"]
    pdf = root / freeze["report_pdf"]
    require(sha256(docx) == freeze["report_docx_sha256"], "report DOCX hash mismatch")
    require(sha256(pdf) == freeze["report_pdf_sha256"], "report PDF hash mismatch")
    require(freeze["pdf_pages"] == 58, "unexpected report page count")
    require(freeze["numbered_figures"] == 30, "unexpected report figure count")
    require(freeze["numbered_tables"] == 28, "unexpected report table count")
    text = public_docx_text(docx)
    require(FORBIDDEN_PUBLIC.search(text) is None, "forbidden internal identity in report")
    require(ABSOLUTE_USER_PATH.search(text) is None, "absolute user path in report")
    return {"pages": 58, "figures": 30, "tables": 28}


def check_scene_index(root: Path) -> dict:
    path = root / "00_START_HERE/SCENE_INDEX.csv"
    with path.open(newline="", encoding="utf-8-sig") as stream:
        rows = list(csv.DictReader(stream))
    require(len(rows) == 34, "registered scene count must be 34")
    counts: dict[str, int] = {}
    for row in rows:
        counts[row["suite"]] = counts.get(row["suite"], 0) + 1
    require(counts == {"finals_core": 20, "supplementary": 14}, f"scene suite mismatch: {counts}")
    required = {"BODY_ROLL_POS", "BODY_PITCH_NEG", "Scene06b", "Scene07B", "Scene07COff", "Scene07COnPredictiveV5C"}
    require(required <= {row["case_id"] for row in rows}, "required scene entry missing")
    return counts


def check_visual_resources(root: Path) -> dict:
    package_root = root / "01_models/official/QuadrotorModel"
    model_path = package_root / "package.mo"
    references = EXTERNAL_SHAPE.findall(model_path.read_text(encoding="utf-8"))
    require(references, "official model has no registered external visualization resources")
    prefix = "modelica://QuadrotorModel/"
    resolved_files: set[str] = set()
    for reference in references:
        require(
            reference.startswith(prefix),
            f"non-portable visualization resource reference: {reference}",
        )
        relative = reference[len(prefix):]
        resource = package_root / relative
        require(resource.is_file(), f"missing visualization resource: {reference}")
        resolved_files.add(relative)
    return {"references": len(references), "files": len(resolved_files)}


def check_gui_scene_experiments(root: Path) -> dict:
    model_path = root / "01_models/modelica/A8ARDGRGPCFinalScenarios20260815/package.mo"
    source = model_path.read_text(encoding="utf-8")
    checked: list[str] = []
    for model_name in ("BodyRollPos", "BodyPitchNeg"):
        match = re.search(
            rf"\bmodel\s+{model_name}\b(?P<body>.*?)\bend\s+{model_name}\s*;",
            source,
            re.DOTALL,
        )
        require(match is not None, f"missing angular GUI scene: {model_name}")
        body = match.group("body")
        experiment = re.search(r"experiment\s*\((?P<settings>.*?)\)", body, re.DOTALL)
        require(experiment is not None, f"missing direct experiment annotation: {model_name}")
        settings = re.sub(r"\s+", "", experiment.group("settings"))
        require("StartTime=0" in settings, f"invalid GUI start time: {model_name}")
        require("StopTime=50" in settings, f"invalid GUI stop time: {model_name}")
        require("NumberOfIntervals=5000" in settings, f"invalid GUI output intervals: {model_name}")
        checked.append(model_name)
    return {"scenes": checked, "stop_time_s": 50, "interval_s": 0.01}


def check_assets(root: Path) -> dict:
    index_path = root / "08_provenance/FINAL_REPORT_ASSET_INDEX.csv"
    with index_path.open(newline="", encoding="utf-8-sig") as stream:
        rows = list(csv.DictReader(stream))
    figures = [row for row in rows if row["type"] == "figure"]
    tables = [row for row in rows if row["type"] == "table"]
    require(len(figures) == 30, "asset index must contain 30 numbered figures")
    require(len(tables) == 28, "asset index must contain 28 numbered tables")
    for row in figures:
        path = root / row["package_file"]
        require(path.is_file(), f"missing report figure: {row['package_file']}")
        require(sha256(path) == row["output_sha256"], f"report figure hash mismatch: {row['asset_id']}")

    static_files = sorted((root / "05_visuals/assets/static").glob("*.png"))
    gif_files = sorted((root / "05_visuals/assets/gif").glob("*.gif"))
    require(len(static_files) == 3, "release static figure count must be 3")
    require(len(gif_files) == 6, "release GIF count must be 6")
    public_assets = load_json(root / "08_provenance/PUBLIC_ASSET_MANIFEST.json")
    for entry in public_assets["files"]:
        path = root / entry["path"]
        require(path.is_file(), f"missing public asset: {entry['path']}")
        require(sha256(path) == entry["sha256"], f"public asset hash mismatch: {entry['path']}")
    return {"report_figures": 30, "static_png": 3, "gif": 6}


def first_csv_header(path: Path) -> list[str]:
    with path.open(newline="", encoding="utf-8-sig") as stream:
        return next(csv.reader(stream))


def check_evidence(root: Path) -> dict:
    bases = {
        "regression18": root / "06_supplementary_evidence/ardg_rgpc_regression18_final/raw",
        "parameter11": root / "06_supplementary_evidence/ardg_rgpc_parameter11_final/cases",
        "random20": root / "06_supplementary_evidence/ardg_rgpc_random20_final/cases",
        "formation": root / "06_supplementary_evidence/ardg_rgpc_formation_final/raw",
        "compound": root / "06_supplementary_evidence/ardg_rgpc_compound_final/cases",
        "pid_random20": root / "06_supplementary_evidence/official_pid_random20_raw",
    }
    counts = {
        "regression18": len(list(bases["regression18"].glob("*.csv"))),
        "parameter11": len(list(bases["parameter11"].glob("*/raw.csv"))),
        "random20": len(list(bases["random20"].glob("*/raw.csv"))),
        "formation": len(list(bases["formation"].glob("*.csv"))),
        "compound": len(list(bases["compound"].glob("*/raw.csv"))),
        "pid_random20": len(list(bases["pid_random20"].glob("*.csv"))),
    }
    require(counts == {
        "regression18": 18,
        "parameter11": 11,
        "random20": 20,
        "formation": 3,
        "compound": 6,
        "pid_random20": 20,
    }, f"direct evidence count mismatch: {counts}")
    for path in (root / "06_supplementary_evidence").rglob("*.csv"):
        header = first_csv_header(path)
        forbidden_columns = [
            name for name in header
            if name == "controller_identity" or re.fullmatch(r"controllerDiagnostics\d*\[16\]", name)
        ]
        require(not forbidden_columns, f"internal identity column in public evidence: {path}")
    return counts


def check_public_hygiene(root: Path) -> int:
    files = [root / "README.md"]
    files.extend(path for path in (root / "00_START_HERE").rglob("*") if path.is_file())
    files.extend([
        root / "MAIN_ALGORITHM.json",
        root / "08_provenance/PACKAGE_BUILD_INFO.json",
        root / "08_provenance/SOURCE_PROVENANCE.csv",
    ])
    checked = 0
    for path in files:
        text = path.read_text(encoding="utf-8-sig", errors="ignore")
        require(FORBIDDEN_PUBLIC.search(text) is None, f"forbidden internal identity in {path.relative_to(root)}")
        require(ABSOLUTE_USER_PATH.search(text) is None, f"absolute user path in {path.relative_to(root)}")
        checked += 1
    return checked


def check_required_files(root: Path) -> None:
    required = [
        "RUN_ALL.ps1",
        "RUN_QUICK_VERIFY.ps1",
        "01_models/official/QuadrotorModel/package.mo",
        "01_models/sysblock/A8FormalRAGCACGHTE_20260715.mo",
        "01_models/modelica/A8ARDGRGPCFinalScenarios20260815/package.mo",
        "01_models/modelica/A8RAGCACGHTEPlant20260715/package.mo",
        "01_models/modelica/A8RAGCACGHTEFormationValidationPlant20260715/package.mo",
        "02_scripts/sysplorer/run_main_controller.py",
        "04_results/report_evidence/REPORT_EVIDENCE_MANIFEST.json",
    ]
    for relative in required:
        require((root / relative).is_file(), f"missing required file: {relative}")
    for path in root.rglob("*"):
        if path.is_dir():
            require(path.name not in FORBIDDEN_DIRS, f"forbidden directory in package: {path.relative_to(root)}")


def check(root: Path) -> dict:
    root = root.resolve()
    require(root.is_dir(), f"package root does not exist: {root}")
    check_required_files(root)
    identity = load_json(root / "MAIN_ALGORITHM.json")
    require(identity["algorithm"]["short_name"] == "ARDG-RGPC", "formal algorithm mismatch")
    result = {
        "status": "passed",
        "algorithm": "ARDG-RGPC",
        "report": check_report(root),
        "scenes": check_scene_index(root),
        "visual_resources": check_visual_resources(root),
        "gui_scene_experiments": check_gui_scene_experiments(root),
        "assets": check_assets(root),
        "evidence": check_evidence(root),
        "public_hygiene_files": check_public_hygiene(root),
        "manifest_files": check_manifest(root),
    }
    return result


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(check(args.root), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
