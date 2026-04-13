#!/usr/bin/env python3
"""Save bilingual game-ai reports to deterministic relative paths."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Save Chinese and English game-ai reports to docs/game-ai-daily-reports/"
    )
    parser.add_argument("--date", required=True, help="Report date in YYYY-MM-DD format")
    parser.add_argument("--zh-file", required=True, help="Path to the Chinese markdown input file")
    parser.add_argument("--en-file", required=True, help="Path to the English markdown input file")
    parser.add_argument(
        "--output-root",
        default=".",
        help="Root directory under which docs/game-ai-daily-reports/ will be created",
    )
    return parser.parse_args()


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8", newline="\n")


def main() -> int:
    args = parse_args()

    zh_input = Path(args.zh_file).resolve()
    en_input = Path(args.en_file).resolve()
    output_root = Path(args.output_root).resolve()
    output_dir = output_root / "docs" / "game-ai-daily-reports"

    if not zh_input.is_file():
        raise FileNotFoundError(f"Chinese input file not found: {zh_input}")
    if not en_input.is_file():
        raise FileNotFoundError(f"English input file not found: {en_input}")

    zh_output = output_dir / f"{args.date}-game-ai-report.zh.md"
    en_output = output_dir / f"{args.date}-game-ai-report.en.md"

    zh_content = read_text(zh_input)
    en_content = read_text(en_input)

    write_text(zh_output, zh_content)
    write_text(en_output, en_content)

    result = {
        "status": "saved",
        "zh_path": str(zh_output),
        "en_path": str(en_output),
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
