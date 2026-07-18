from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
REFERENCE = ROOT / "06_supplementary_evidence" / "ra_gca_cg_hte_32_raw"
CASES = (
    "Scene04",
    "Scene01S_Z",
    "Scene05B_LiftMinus10",
    "Scene08_P0",
    "Scene10_P0",
    "Scene07COnPredictiveV5C",
)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def write_json(path: Path, value: dict) -> None:
    # 临时文件写完后再替换目标，避免中断时留下不完整JSON。
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temporary.replace(path)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--results", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    results = args.results.resolve()
    output = args.output.resolve()
    try:
        output.relative_to(ROOT.resolve())
    except ValueError:
        pass
    else:
        parser.error("--output must be outside the source package")
    # 代表场景覆盖名义、阶跃、参数、风扰、传感器和编队安全任务。
    status_path = results / "execution_status.json"
    status = json.loads(status_path.read_text(encoding="utf-8"))
    rows = []
    success = bool(status.get("success"))
    success = success and status.get("algorithm_id") == "RA-GCA-CGHTE"
    selected = set(status.get("selected_cases", []))
    for case_id in CASES:
        reference = REFERENCE / f"{case_id}.csv"
        actual = results / "raw" / f"{case_id}.csv"
        row = {
            "case_id": case_id,
            "selected": case_id in selected,
            "reference_exists": reference.is_file(),
            "actual_exists": actual.is_file(),
            "reference_sha256": sha256(reference) if reference.is_file() else None,
            "actual_sha256": sha256(actual) if actual.is_file() else None,
        }
        # 发布复现采用逐字节一致作为最严格的结果判据。
        row["byte_identical"] = (
            row["reference_sha256"] is not None
            and row["reference_sha256"] == row["actual_sha256"]
        )
        rows.append(row)
        success = success and row["selected"] and row["byte_identical"]
    payload = {
        "schema_version": 1,
        "algorithm_id": "RA-GCA-CGHTE",
        "release_version": "1.0.0",
        "generated_utc": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "results": str(results),
        "status_sha256": sha256(status_path),
        "case_count": len(rows),
        "byte_identical_count": sum(row["byte_identical"] for row in rows),
        "success": success,
        "cases": rows,
    }
    write_json(output, payload)
    print(json.dumps(payload, ensure_ascii=False))
    return 0 if success else 1


if __name__ == "__main__":
    raise SystemExit(main())
