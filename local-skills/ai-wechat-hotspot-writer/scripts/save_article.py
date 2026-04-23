#!/usr/bin/env python3
"""Save AI WeChat hotspot article packages to deterministic paths."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


SLUG_RE = re.compile(r"[^a-zA-Z0-9._-]+")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Save an AI WeChat hotspot article and image prompts."
    )
    parser.add_argument("--date", required=True, help="Package date in YYYY-MM-DD format")
    parser.add_argument("--slug", required=True, help="Filename slug")
    parser.add_argument("--article-file", required=True, help="Path to article Markdown")
    parser.add_argument("--prompts-file", required=True, help="Path to image prompts Markdown")
    parser.add_argument(
        "--brief-file",
        help="Optional path to a separate source brief or ranking Markdown",
    )
    parser.add_argument(
        "--output-root",
        default=".",
        help="Root directory under which docs/ai-wechat-hotspot-writer/ will be created",
    )
    return parser.parse_args()


def read_text(path: Path) -> str:
    if not path.is_file():
        raise FileNotFoundError(f"Input file not found: {path}")
    return path.read_text(encoding="utf-8")


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8", newline="\n")


def safe_slug(value: str) -> str:
    cleaned = SLUG_RE.sub("-", value.strip()).strip("-._")
    return cleaned or "ai-hotspots"


def main() -> int:
    args = parse_args()
    slug = safe_slug(args.slug)
    output_root = Path(args.output_root).resolve()
    output_dir = output_root / "docs" / "ai-wechat-hotspot-writer"

    article = read_text(Path(args.article_file).resolve())
    prompts = read_text(Path(args.prompts_file).resolve())

    article_path = output_dir / f"{args.date}-{slug}.article.md"
    prompts_path = output_dir / f"{args.date}-{slug}.image-prompts.md"

    write_text(article_path, article)
    write_text(prompts_path, prompts)

    result = {
        "status": "saved",
        "article_path": str(article_path),
        "prompts_path": str(prompts_path),
    }

    if args.brief_file:
        brief = read_text(Path(args.brief_file).resolve())
        brief_path = output_dir / f"{args.date}-{slug}.brief.md"
        write_text(brief_path, brief)
        result["brief_path"] = str(brief_path)

    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
