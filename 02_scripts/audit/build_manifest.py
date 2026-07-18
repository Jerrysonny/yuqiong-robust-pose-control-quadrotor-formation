from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path


def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest().upper()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    args = parser.parse_args()
    root = args.root.resolve()
    target = root / "SHA256_MANIFEST.json"
    # 总清单不记录自身，避免清单哈希形成循环依赖。
    files = sorted(
        path for path in root.rglob("*") if path.is_file() and path != target
    )
    entries = [
        {
            "path": path.relative_to(root).as_posix(),
            "size": path.stat().st_size,
            "sha256": digest(path),
        }
        for path in files
    ]
    # 文件路径统一使用POSIX分隔符，便于不同环境稳定比对。
    payload = {
        "schema_version": 1,
        "algorithm": "RA-GCA-CGHTE",
        "generated_utc": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "self_excluded": True,
        "file_count": len(entries),
        "total_bytes": sum(entry["size"] for entry in entries),
        "files": entries,
    }
    target.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"file_count": len(entries), "total_bytes": payload["total_bytes"]}))


if __name__ == "__main__":
    main()
