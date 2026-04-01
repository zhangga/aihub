#!/usr/bin/env python3
"""Initialize durable state files for the long-run harness."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from harness_lib import parse_pipe_list, utc_now, validate_state, write_json

def build_task(
    task_id: str,
    title: str,
    summary: str,
    acceptance_criteria: list[str] | None = None,
    validation: list[str] | None = None,
    artifacts: list[str] | None = None,
    depends_on: list[str] | None = None,
) -> dict:
    acceptance = acceptance_criteria or [f"{title} is completed with the intended outcome."]
    validation_steps = validation or [f"Run the validation needed to confirm {title} is complete."]
    return {
        "id": task_id,
        "title": title,
        "summary": summary,
        "status": "todo",
        "depends_on": depends_on or [],
        "acceptance_criteria": acceptance,
        "validation": validation_steps,
        "artifacts": artifacts or [],
        "validation_results": [],
        "evidence": [],
        "review_status": "not_started",
        "last_commit": "",
        "blocked_reason": "",
    }


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
        help="Legacy task in the format TITLE or TITLE::SUMMARY. Repeat for multiple tasks.",
    )
    parser.add_argument(
        "--task-json",
        action="append",
        default=[],
        help=(
            "Structured task JSON. Repeat for multiple tasks. "
            "Fields: title, summary, acceptance_criteria, validation, artifacts, depends_on."
        ),
    )
    args = parser.parse_args()

    target_dir = Path(args.dir).resolve()
    target_dir.mkdir(parents=True, exist_ok=True)

    tasks_json = []
    for raw in args.task_json:
        try:
            item = json.loads(raw)
        except json.JSONDecodeError as exc:
            raise SystemExit(f"Invalid JSON passed to --task-json: {exc}") from exc
        if not isinstance(item, dict):
            raise SystemExit("--task-json values must decode to JSON objects.")
        if not item.get("title"):
            raise SystemExit("Each --task-json object must include a non-empty title.")
        tasks_json.append(item)

    tasks_raw = args.task or []
    if not tasks_json and not tasks_raw:
        tasks_raw = ["Inspect current state::Establish the baseline and capture constraints"]

    tasks = []
    for index, item in enumerate(tasks_json, start=1):
        tasks.append(
            build_task(
                task_id=f"T{index}",
                title=item["title"].strip(),
                summary=item.get("summary", "").strip() or "Complete this task and record validation.",
                acceptance_criteria=item.get("acceptance_criteria") or [],
                validation=item.get("validation") or [],
                artifacts=item.get("artifacts") or [],
                depends_on=item.get("depends_on") or [],
            )
        )
    start_index = len(tasks) + 1
    for offset, item in enumerate(tasks_raw, start=start_index):
        if "::" in item:
            title, summary = item.split("::", 1)
        else:
            title, summary = item, "Complete this task and record validation."
        title = title.strip()
        summary = summary.strip()
        tasks.append(
            build_task(
                f"T{offset}",
                title,
                summary,
                acceptance_criteria=[f"{title} is completed and assumptions are recorded."],
                validation=[f"Run the baseline or task-specific checks that prove {title} is complete."],
            )
        )

    tasks[0]["status"] = "in_progress"
    for index in range(1, len(tasks)):
        if not tasks[index]["depends_on"]:
            tasks[index]["depends_on"] = [tasks[index - 1]["id"]]

    acceptance = []
    for value in args.acceptance:
        acceptance.extend(parse_pipe_list(value))
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

    validate_state(task_list)
    write_json(target_dir / "task_list.json", task_list)
    write_progress(target_dir / "progress.md", args.goal.strip(), tasks[0]["id"], tasks[0]["title"])
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        raise SystemExit(str(exc)) from exc
