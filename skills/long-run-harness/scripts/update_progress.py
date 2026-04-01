#!/usr/bin/env python3
"""Update task_list.json and progress.md for the long-run harness."""

from __future__ import annotations

import argparse
from pathlib import Path

from harness_lib import (
    ACTIVE_STATES,
    PASSED_REVIEW_STATUSES,
    REVIEW_STATUSES,
    TASK_STATUSES,
    ValidationError,
    dependencies_satisfied,
    load_json,
    normalize_state,
    parse_items,
    task_by_id,
    utc_now,
    validate_state,
    write_json,
)


ALLOWED_TRANSITIONS = {
    "todo": {"in_progress", "blocked"},
    "in_progress": {"in_progress", "in_review", "blocked", "done"},
    "in_review": {"in_review", "in_progress", "blocked", "done"},
    "blocked": {"blocked", "in_progress"},
    "done": {"done"},
}


def build_progress_content(
    state: dict,
    current_task_line: str,
    recent_progress: list[str],
    blockers: list[str],
    next_action: list[str],
    risks: list[str],
) -> str:
    return "\n".join(
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


def ensure_transition_allowed(previous_status: str, next_status: str, task_id: str) -> None:
    if next_status not in ALLOWED_TRANSITIONS[previous_status]:
        raise ValidationError(f"Illegal status transition for {task_id}: {previous_status} -> {next_status}")


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
    parser.add_argument("--validation-result", action="append", default=[], help="Validation result bullet. Repeat or use pipe separators.")
    parser.add_argument("--evidence", action="append", default=[], help="Evidence bullet. Repeat or use pipe separators.")
    parser.add_argument("--commit", default="", help="Commit hash related to the task")
    args = parser.parse_args()

    target_dir = Path(args.dir).resolve()
    task_file = target_dir / "task_list.json"
    progress_file = target_dir / "progress.md"

    state = validate_state(load_json(task_file))
    normalize_state(state)
    tasks = state.get("tasks", [])
    tasks_by_id = task_by_id(state)

    target_task = tasks_by_id.get(args.task_id)
    if target_task is None:
        raise SystemExit(f"Task {args.task_id} not found in {task_file}")

    previous_status = target_task["status"]
    ensure_transition_allowed(previous_status, args.task_status, args.task_id)

    review_status = args.review_status or target_task.get("review_status", "not_started")
    validation_results = parse_items(args.validation_result)
    evidence = parse_items(args.evidence)
    blockers = parse_items(args.blocker)

    if args.task_status == "blocked" and not blockers:
        raise ValidationError(f"Task {args.task_id} cannot be marked blocked without at least one blocker.")
    if args.task_status != "blocked" and blockers:
        raise ValidationError("Blockers can only be supplied when marking a task as blocked.")

    if args.next_task_id and args.task_status != "done":
        raise ValidationError("next-task-id is only allowed when the current task is being marked done.")

    target_task["status"] = args.task_status
    target_task["review_status"] = review_status
    if args.commit:
        target_task["last_commit"] = args.commit
    if validation_results:
        target_task["validation_results"] = validation_results
    if evidence:
        target_task["evidence"] = evidence
    target_task["blocked_reason"] = blockers[0] if args.task_status == "blocked" else ""

    if args.task_status == "done":
        if review_status not in PASSED_REVIEW_STATUSES:
            raise ValidationError(
                f"Task {args.task_id} cannot be marked done without a passing review_status."
            )
        if not target_task.get("acceptance_criteria"):
            raise ValidationError(f"Task {args.task_id} needs task-level acceptance_criteria before it can be done.")
        if not target_task.get("validation"):
            raise ValidationError(f"Task {args.task_id} needs task-level validation steps before it can be done.")
        if not target_task.get("validation_results"):
            raise ValidationError(f"Task {args.task_id} needs validation_results before it can be done.")

    if args.task_status == "in_review" and review_status == "not_started":
        raise ValidationError(f"Task {args.task_id} must record a review_status before entering in_review.")

    if args.task_status == "in_progress":
        if previous_status == "todo" and not dependencies_satisfied(target_task, tasks_by_id):
            raise ValidationError(f"Task {args.task_id} cannot start before its dependencies are done.")
        state["current_task_id"] = args.task_id
    elif args.task_status == "in_review":
        state["current_task_id"] = args.task_id
    elif args.task_status == "blocked":
        state["current_task_id"] = args.task_id
    elif args.next_task_id:
        next_task = tasks_by_id.get(args.next_task_id)
        if next_task is None:
            raise ValidationError(f"Next task {args.next_task_id} does not exist.")
        if next_task["status"] != "todo":
            raise ValidationError(f"Next task {args.next_task_id} must currently be todo.")
        if not dependencies_satisfied(next_task, tasks_by_id):
            raise ValidationError(f"Next task {args.next_task_id} cannot start before its dependencies are done.")
        next_task["status"] = "in_progress"
        state["current_task_id"] = args.next_task_id
    else:
        state["current_task_id"] = ""

    blocked_tasks = [task for task in tasks if task.get("status") == "blocked"]
    if all(task.get("status") == "done" for task in tasks):
        state["status"] = "done"
        state["current_task_id"] = ""
        state["blockers"] = []
    elif blocked_tasks:
        state["status"] = "blocked"
        state["blockers"] = [task["blocked_reason"] for task in blocked_tasks]
    else:
        state["status"] = "in_progress"
        state["blockers"] = []

    state["last_updated"] = utc_now()
    validate_state(state)
    write_json(task_file, state)

    if args.current_task_line:
        current_task_line = args.current_task_line
    elif state["current_task_id"]:
        current_task = task_by_id(state)[state["current_task_id"]]
        current_task_line = f"{current_task['id']}: {current_task.get('title', '')}"
    else:
        current_task_line = "none"

    recent_progress = parse_items(args.recent_progress) or [f"{utc_now()}: Updated {args.task_id} to {args.task_status}."]
    next_action = parse_items(args.next_action) or ["Select or continue the next task."]
    risks = parse_items(args.risk) or ["none"]
    progress_file.write_text(
        build_progress_content(state, current_task_line, recent_progress, state["blockers"], next_action, risks),
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        raise SystemExit(f"ERROR: {exc}") from exc
