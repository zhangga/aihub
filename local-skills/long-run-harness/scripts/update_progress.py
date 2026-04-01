#!/usr/bin/env python3
"""Update task_list.json and progress.md for the long-run harness."""

from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path


TASK_STATUSES = {"todo", "in_progress", "in_review", "blocked", "done"}
REVIEW_STATUSES = {
    "not_started",
    "self_review_passed",
    "needs_independent_review",
    "independent_review_passed",
    "changes_requested",
}


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def parse_items(values: list[str] | None) -> list[str]:
    result: list[str] = []
    for value in values or []:
        result.extend(item.strip() for item in value.split("|") if item.strip())
    return result


def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def write_json(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Update harness task state and rewrite progress.md.")
    parser.add_argument("--dir", default=".", help="Workspace directory containing task_list.json and progress.md")
    parser.add_argument("--task-id", required=True, help="Task id to update")
    parser.add_argument("--task-status", choices=sorted(TASK_STATUSES), required=True, help="New task status")
    parser.add_argument("--review-status", choices=sorted(REVIEW_STATUSES), help="New review status")
    parser.add_argument("--next-task-id", help="Current active task after this update")
    parser.add_argument("--current-task-line", help="Human-readable current task line for progress.md")
    parser.add_argument("--recent-progress", action="append", default=[], help="Recent progress bullet. Repeat or use pipe separators.")
    parser.add_argument("--blocker", action="append", default=[], help="Active blocker bullet. Repeat or use pipe separators.")
    parser.add_argument("--next-action", action="append", default=[], help="Next action bullet. Repeat or use pipe separators.")
    parser.add_argument("--risk", action="append", default=[], help="Risk or decision bullet. Repeat or use pipe separators.")
    parser.add_argument("--commit", default="", help="Commit hash related to the task")
    args = parser.parse_args()

    target_dir = Path(args.dir).resolve()
    task_file = target_dir / "task_list.json"
    progress_file = target_dir / "progress.md"

    state = load_json(task_file)
    tasks = state.get("tasks", [])

    target_task = None
    for task in tasks:
        if task.get("id") == args.task_id:
            target_task = task
            break
    if target_task is None:
        raise SystemExit(f"Task {args.task_id} not found in {task_file}")

    target_task["status"] = args.task_status
    if args.review_status:
        target_task["review_status"] = args.review_status
    if args.commit:
        target_task["last_commit"] = args.commit

    blockers = parse_items(args.blocker)
    target_task["blocked_reason"] = blockers[0] if args.task_status == "blocked" and blockers else ""

    if args.task_status in {"in_progress", "in_review"}:
        state["current_task_id"] = args.task_id
    elif args.next_task_id:
        state["current_task_id"] = args.next_task_id
        for task in tasks:
            if task.get("id") == args.next_task_id and task.get("status") == "todo":
                task["status"] = "in_progress"
                break
    elif args.task_status == "done":
        state["current_task_id"] = ""

    if all(task.get("status") == "done" for task in tasks):
        state["status"] = "done"
    elif blockers:
        state["status"] = "blocked"
    else:
        state["status"] = "in_progress"

    state["blockers"] = blockers
    state["last_updated"] = utc_now()
    write_json(task_file, state)

    if args.current_task_line:
        current_task_line = args.current_task_line
    elif args.next_task_id:
        next_task = next((task for task in tasks if task.get("id") == args.next_task_id), None)
        if next_task:
            current_task_line = f"{next_task['id']}: {next_task.get('title', '')}"
        else:
            current_task_line = f"{args.next_task_id}: next task selected"
    else:
        current_task_line = f"{args.task_id}: {target_task.get('title', '')}"
    recent_progress = parse_items(args.recent_progress) or [f"{utc_now()}: Updated {args.task_id} to {args.task_status}."]
    next_action = parse_items(args.next_action) or ["Select or continue the next task."]
    risks = parse_items(args.risk) or ["none"]

    content = "\n".join(
        [
            "# Progress",
            "",
            "## Objective",
            f"- {state.get('goal', '')}",
            "",
            "## Current Task",
            f"- {current_task_line}",
            "",
            "## Recent Progress",
            *[f"- {item}" for item in recent_progress],
            "",
            "## Blockers",
            *(["- none"] if not blockers else [f"- {item}" for item in blockers]),
            "",
            "## Next Action",
            *[f"- {item}" for item in next_action],
            "",
            "## Risks And Decisions",
            *[f"- {item}" for item in risks],
            "",
        ]
    )
    progress_file.write_text(content, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
