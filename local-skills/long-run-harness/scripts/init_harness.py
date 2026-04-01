#!/usr/bin/env python3
"""Initialize durable state files for the long-run harness."""

from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def parse_list(value: str) -> list[str]:
    return [item.strip() for item in value.split("|") if item.strip()]


def build_task(task_id: str, title: str, summary: str) -> dict:
    return {
        "id": task_id,
        "title": title,
        "summary": summary,
        "status": "todo",
        "depends_on": [],
        "acceptance_criteria": [],
        "validation": [],
        "artifacts": [],
        "review_status": "not_started",
        "last_commit": "",
        "blocked_reason": "",
    }


def write_json(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def write_progress(path: Path, goal: str, task_id: str, task_title: str) -> None:
    content = "\n".join(
        [
            "# Progress",
            "",
            "## Objective",
            f"- {goal}",
            "",
            "## Current Task",
            f"- {task_id}: {task_title}",
            "",
            "## Recent Progress",
            f"- {utc_now()}: Initialized long-run harness state.",
            "",
            "## Blockers",
            "- none",
            "",
            "## Next Action",
            f"- Start {task_id}: {task_title}.",
            "",
            "## Risks And Decisions",
            "- none",
            "",
        ]
    )
    path.write_text(content, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Initialize task_list.json and progress.md for long-run work.")
    parser.add_argument("--dir", default=".", help="Target workspace directory.")
    parser.add_argument("--goal", required=True, help="Final objective.")
    parser.add_argument(
        "--acceptance",
        action="append",
        default=[],
        help="Acceptance criteria. Repeat the flag or use pipe separators.",
    )
    parser.add_argument(
        "--task",
        action="append",
        default=[],
        help="Task in the format TITLE or TITLE::SUMMARY. Repeat for multiple tasks.",
    )
    args = parser.parse_args()

    target_dir = Path(args.dir).resolve()
    target_dir.mkdir(parents=True, exist_ok=True)

    tasks_raw = args.task or ["Inspect current state::Establish the baseline and capture constraints"]
    tasks = []
    for index, item in enumerate(tasks_raw, start=1):
        if "::" in item:
            title, summary = item.split("::", 1)
        else:
            title, summary = item, "Complete this task and record validation."
        tasks.append(build_task(f"T{index}", title.strip(), summary.strip()))

    tasks[0]["status"] = "in_progress"
    for index in range(1, len(tasks)):
        tasks[index]["depends_on"] = [tasks[index - 1]["id"]]

    acceptance = []
    for value in args.acceptance:
        acceptance.extend(parse_list(value))
    if not acceptance:
        acceptance = ["Final objective is verified complete."]

    task_list = {
        "goal": args.goal.strip(),
        "acceptance_criteria": acceptance,
        "status": "in_progress",
        "current_task_id": tasks[0]["id"],
        "blockers": [],
        "last_updated": utc_now(),
        "tasks": tasks,
    }

    write_json(target_dir / "task_list.json", task_list)
    write_progress(target_dir / "progress.md", args.goal.strip(), tasks[0]["id"], tasks[0]["title"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
