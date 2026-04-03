#!/usr/bin/env python3
import argparse
import json
import shutil
from datetime import datetime
from pathlib import Path


def backup_existing(path):
    if not path.exists():
        return None
    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup = path.with_name(f"{path.stem}-backup-{ts}{path.suffix}")
    shutil.move(str(path), str(backup))
    return str(backup)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--downloaded-file", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--filename", required=True)
    args = parser.parse_args()

    downloaded = Path(args.downloaded_file)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    target = output_dir / args.filename

    if not downloaded.exists():
        print(json.dumps({
            "status": "error",
            "message": f"Downloaded file not found: {downloaded}",
        }, ensure_ascii=False, indent=2))
        raise SystemExit(1)

    backup = backup_existing(target)
    shutil.move(str(downloaded), str(target))
    print(json.dumps({
        "status": "saved",
        "saved_path": str(target),
        "backup_path": backup,
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
