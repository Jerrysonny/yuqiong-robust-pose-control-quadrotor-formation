from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import sys
import tomllib
from pathlib import Path


FORBIDDEN_PARTS = {
    "99_backup",
    "99_rollback",
    "99_备份",
    "__pycache__",
    "quarantine",
    "reproduction_probe",
}
TEXT_SUFFIXES = {".md", ".py", ".jl", ".js", ".toml", ".json", ".csv", ".ps1", ".mo", ".txt"}
REQUIRED = {
    "MAIN_ALGORITHM.json",
    "00_START_HERE/README_项目总览与使用入口.md",
    "00_START_HERE/ALGORITHM_REGISTRY.csv",
    "00_START_HERE/SCENE_INDEX.csv",
    "01_models/official/QuadrotorModel/package.mo",
    "01_models/sysblock/A8FormalRAGCACGHTE_20260715.mo",
    "01_models/baseline/A8FormalSO3V8PX4AllocV1A_20260712.mo",
    "02_scripts/sysplorer/run_main_controller.py",
    "02_scripts/powershell/A8RuntimeResolver.ps1",
    "test/test_runtime_resolution.ps1",
    "RECOMPUTE_REPORT_EVIDENCE.ps1",
    "04_results/report_evidence/REPORT_EVIDENCE_MANIFEST.json",
    "05_visuals/verify_final_report_assets.py",
    "05_visuals/qa/final_report_static_qa.json",
    "config/main_controller.toml",
    "06_supplementary_evidence/RAW_MANIFEST.json",
    "08_provenance/版权与许可证状态.md",
    "08_provenance/第三方依赖与来源说明.md",
    "08_provenance/FINAL_REPORT_ASSET_INDEX.csv",
    "08_provenance/FINAL_MATERIAL_ADMISSION.csv",
    "08_provenance/FINAL_REPORT_FREEZE.json",
}
PORTABLE_ACTIVE_FILES = {
    "RUN_ALL.ps1",
    "RUN_QUICK_VERIFY.ps1",
    "RECOMPUTE_REPORT_EVIDENCE.ps1",
    "02_scripts/powershell/A8RuntimeResolver.ps1",
    "05_visuals/generate_visuals.js",
    "05_visuals/visual_generation_helpers.js",
    "00_START_HERE/README_项目总览与使用入口.md",
    "05_visuals/README_生成与独立验收.md",
    "05_visuals/README_可视化说明.md",
}


def sha256(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest().upper()


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def audit_tree(root: Path, errors: list[str]) -> list[Path]:
    # 先排除链接、备份和失败产物，保证提交树边界清晰。
    files = []
    for path in root.rglob("*"):
        relative = path.relative_to(root)
        lowered = [part.lower() for part in relative.parts]
        if path.is_symlink():
            fail(errors, f"symlink forbidden: {relative.as_posix()}")
        if any(part in FORBIDDEN_PARTS or part.startswith("99_failed") for part in lowered):
            fail(errors, f"forbidden path: {relative.as_posix()}")
        if path.is_file():
            if path.suffix.lower() in {".pyc", ".pyo"} or ".bak" in path.name.lower():
                fail(errors, f"forbidden file: {relative.as_posix()}")
            files.append(path)
    for required in REQUIRED:
        if not (root / required).is_file():
            fail(errors, f"missing required file: {required}")
    return files


def audit_parsing(root: Path, files: list[Path], errors: list[str]) -> None:
    raw_root = root / "06_supplementary_evidence"
    source_alias = "candidate" + "_011"
    controller_provenance_file = "01_models/sysblock/A8FormalRAGCACGHTE_20260715.mo"
    for path in files:
        relative = path.relative_to(root).as_posix()
        suffix = path.suffix.lower()
        if suffix in TEXT_SUFFIXES:
            try:
                text = path.read_text(encoding="utf-8-sig")
            except UnicodeError as exc:
                fail(errors, f"UTF-8 decode failed: {relative}: {exc}")
                continue
            if "\ufffd" in text:
                fail(errors, f"replacement character found: {relative}")
            # 文本扫描同时检查编码、明文密钥和活动入口中的绝对用户路径。
            if re.search(r"(?i)(api[_-]?key|token|password)\s*[:=]\s*['\"][^'\"]+", text):
                fail(errors, f"possible plaintext secret: {relative}")
            if relative.startswith(("00_START_HERE/", "config/", "02_scripts/sysplorer/", "test/")):
                if re.search(r"[A-Z]:[\\/]+Users[\\/]", text, flags=re.IGNORECASE):
                    fail(errors, f"user-profile absolute path in active file: {relative}")
            if relative in PORTABLE_ACTIVE_FILES:
                if re.search(r"(?<![A-Za-z])[A-Za-z]:[\\/]", text):
                    fail(errors, f"fixed filesystem drive in portable active file: {relative}")
            if source_alias in text and not (
                relative.startswith(("06_supplementary_evidence/", "08_provenance/"))
                or relative == controller_provenance_file
            ):
                fail(errors, f"internal source alias in visible/core file: {relative}")
        try:
            if suffix == ".json":
                json.loads(path.read_text(encoding="utf-8-sig"))
            elif suffix == ".toml":
                tomllib.loads(path.read_text(encoding="utf-8-sig"))
            elif suffix == ".csv" and not path.is_relative_to(raw_root):
                with path.open(encoding="utf-8-sig", newline="") as stream:
                    list(csv.reader(stream))
        except Exception as exc:
            fail(errors, f"parse failed: {relative}: {exc}")


def audit_identity(root: Path, errors: list[str]) -> None:
    # 主算法登记、运行器、控制器和场景索引必须指向同一发布状态。
    identity = json.loads((root / "MAIN_ALGORITHM.json").read_text(encoding="utf-8"))
    algorithm = identity["algorithm"]
    if algorithm.get("short_name") != "RA-GCA-CGHTE" or algorithm.get("version") != "1.0.0":
        fail(errors, "formal main algorithm identity mismatch")
    if identity["controller"].get("class") != "A8FormalRAGCACGHTE_20260715":
        fail(errors, "formal controller class mismatch")
    if identity["baseline"].get("role") != "comparison_and_rollback_only":
        fail(errors, "V8 role mismatch")
    runner = root / identity["runner"]["path"]
    if not runner.is_file() or sha256(runner) != identity["runner"].get("sha256"):
        fail(errors, "formal runner hash mismatch")
    reproduction = identity["release_verification"]
    reproduction_path = root / reproduction.get("package_reproduction_path", "")
    if (
        not reproduction_path.is_file()
        or sha256(reproduction_path)
        != reproduction.get("package_reproduction_sha256")
    ):
        fail(errors, "package reproduction report hash mismatch")
    config = tomllib.loads((root / "config/main_controller.toml").read_text(encoding="utf-8"))
    controller = root / config["controller"]["path"]
    if sha256(controller) != config["controller"]["sha256"]:
        fail(errors, "formal controller hash mismatch")
    scenes = list(csv.DictReader((root / "00_START_HERE/SCENE_INDEX.csv").open(encoding="utf-8-sig", newline="")))
    if len(scenes) != 32 or len({row["case_id"] for row in scenes}) != 32:
        fail(errors, "scene index must contain 32 unique cases")


def audit_raw(root: Path, errors: list[str]) -> None:
    # 每个回归工况同时核对正式算法与历史基线的原始数据。
    manifest_path = root / "06_supplementary_evidence/RAW_MANIFEST.json"
    payload = json.loads(manifest_path.read_text(encoding="utf-8"))
    if payload.get("evidence_tier") != "supplementary":
        fail(errors, "raw evidence tier must be supplementary")
    if payload.get("official_required_case_count") is not None:
        fail(errors, "raw manifest must not claim an official 32-case requirement")
    entries = payload.get("entries", [])
    if len(entries) != 32:
        fail(errors, f"raw manifest expected 32 pairs, got {len(entries)}")
    for entry in entries:
        for side in ("formal_algorithm", "v8_baseline"):
            item = entry[side]
            path = root / item["path"]
            if not path.is_file():
                fail(errors, f"missing raw file: {item['path']}")
                continue
            if path.stat().st_size != item["size"] or sha256(path) != item["sha256"]:
                fail(errors, f"raw integrity mismatch: {item['path']}")
    pairs = list(csv.DictReader((root / "06_supplementary_evidence/campaign_pairs.csv").open(encoding="utf-8-sig", newline="")))
    if len(pairs) != 32 or any(row.get("all_pair_pass", "").lower() != "true" for row in pairs):
        fail(errors, "campaign pair matrix is not 32/32 passing")
    if payload.get("overall_selection_gate_pass") is not False:
        fail(errors, "selection-gate boundary was lost")


def audit_source_copy_manifest(root: Path, errors: list[str]) -> None:
    # 包内文件允许做说明性注释，但当前包哈希必须与复制映射一致。
    path = root / "08_provenance/SOURCE_COPY_MANIFEST.csv"
    if not path.is_file():
        fail(errors, "missing source copy manifest")
        return
    rows = list(csv.DictReader(path.open(encoding="utf-8-sig", newline="")))
    package_paths = [row.get("path", "") for row in rows]
    if len(package_paths) != len(set(package_paths)):
        fail(errors, "duplicate package path in source copy manifest")
    for row in rows:
        relative = row.get("path", "")
        target = root / relative
        if not relative or not target.is_file():
            fail(errors, f"source copy target missing: {relative}")
            continue
        if sha256(target) != row.get("package_sha256", "").upper():
            fail(errors, f"source copy hash mismatch: {relative}")


def audit_report_outputs(root: Path, errors: list[str]) -> None:
    # 报告证据、图件索引和准入表按最终编号进行交叉核对。
    evidence = json.loads(
        (root / "04_results/report_evidence/REPORT_EVIDENCE_MANIFEST.json").read_text(
            encoding="utf-8"
        )
    )
    if evidence.get("formal_algorithm") != "RA-GCA-CGHTE":
        fail(errors, "report evidence formal identity mismatch")
    if evidence.get("verified_raw_sha256_count") != 64:
        fail(errors, "report evidence raw verification count mismatch")
    qa = json.loads(
        (root / "05_visuals/qa/final_report_static_qa.json").read_text(encoding="utf-8")
    )
    if (
        qa.get("status") != "passed"
        or qa.get("summary", {}).get("generated") != 28
        or qa.get("candidate_only") is not False
        or qa.get("final_report_numbering_assigned") is not True
    ):
        fail(errors, "final report visual QA mismatch")
    figures = qa.get("figures", [])
    if len(figures) != 28:
        fail(errors, "final report visual count mismatch")
    for item in figures:
        target = root / item.get("png", "")
        if not target.is_file() or sha256(target) != item.get("sha256"):
            fail(errors, f"final report visual integrity mismatch: {item.get('png')}")
    asset_rows = list(
        csv.DictReader(
            (root / "08_provenance/FINAL_REPORT_ASSET_INDEX.csv").open(
                encoding="utf-8-sig", newline=""
            )
        )
    )
    admission_rows = list(
        csv.DictReader(
            (root / "08_provenance/FINAL_MATERIAL_ADMISSION.csv").open(
                encoding="utf-8-sig", newline=""
            )
        )
    )
    if (
        len(asset_rows) != 54
        or sum(row.get("type") == "figure" for row in asset_rows) != 28
        or sum(row.get("type") == "table" for row in asset_rows) != 26
        or len(admission_rows) != 54
    ):
        fail(errors, "final report asset index count mismatch")
    build_info = json.loads(
        (root / "08_provenance/PACKAGE_BUILD_INFO.json").read_text(encoding="utf-8")
    )
    manifest_hash = sha256(root / "04_results/report_evidence/REPORT_EVIDENCE_MANIFEST.json")
    if build_info.get("report_evidence", {}).get("manifest_sha256") != manifest_hash:
        fail(errors, "package build info report-evidence manifest hash mismatch")


def audit_manifest(root: Path, errors: list[str]) -> None:
    # 总清单自排除，其他物理文件必须逐项匹配大小和SHA256。
    target = root / "SHA256_MANIFEST.json"
    if not target.is_file():
        fail(errors, "missing SHA256_MANIFEST.json")
        return
    payload = json.loads(target.read_text(encoding="utf-8"))
    actual = sorted(path for path in root.rglob("*") if path.is_file() and path != target)
    records = {entry["path"]: entry for entry in payload.get("files", [])}
    names = {path.relative_to(root).as_posix() for path in actual}
    if names != set(records):
        fail(errors, "manifest file set differs from physical file set")
        return
    if payload.get("file_count") != len(actual) or payload.get("self_excluded") is not True:
        fail(errors, "manifest count or self-exclusion contract mismatch")
    for path in actual:
        relative = path.relative_to(root).as_posix()
        record = records[relative]
        if record["size"] != path.stat().st_size or record["sha256"] != sha256(path):
            fail(errors, f"manifest integrity mismatch: {relative}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--verify-manifest", action="store_true")
    parser.add_argument("--write-report", type=Path)
    args = parser.parse_args()
    root = args.root.resolve()
    errors: list[str] = []
    files = audit_tree(root, errors)
    audit_parsing(root, files, errors)
    audit_identity(root, errors)
    audit_raw(root, errors)
    audit_source_copy_manifest(root, errors)
    audit_report_outputs(root, errors)
    if args.verify_manifest:
        audit_manifest(root, errors)
    result = {
        "schema_version": 1,
        "root_name": root.name,
        "formal_algorithm": "RA-GCA-CGHTE",
        "file_count_observed": len(files),
        "manifest_verified": args.verify_manifest,
        "pass": not errors,
        "errors": errors,
    }
    if args.write_report:
        args.write_report.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, ensure_ascii=False, indent=2))
    if errors:
        sys.exit(1)


if __name__ == "__main__":
    main()
