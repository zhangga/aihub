#!/usr/bin/env python3
"""Shared helpers for long-run harness state management."""

from __future__ import annotations

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
PASSED_REVIEW_STATUSES = {"self_review_passed", "independent_review_passed"}
ACTIVE_STATES = {"in_progress", "in_review"}

REQUIRED_TOP_LEVEL_FIELDS = {
    "goal",
    "acceptance_criteria",
    "status",
    "current_task_id",
    "blockers",
    "last_updated",
    "tasks",
}
REQUIRED_TASK_FIELDS = {
    "id",
    "title",
    "summary",
    "status",
    "depends_on",
    "acceptance_criteria",
    "validation",
    "artifacts",
    "review_status",
    "last_commit",
    "blocked_reason",
}
OPTIONAL_TASK_LIST_FIELDS = {
    "validation_results": [],
    "evidence": [],
}


class ValidationError(ValueError):
    """Raised when harness state is invalid."""


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def parse_items(values: list[str] | None) -> list[str]:
    result: list[str] = []
    for value in values or []:
        result.extend(item.strip() for item in value.split("|") if item.strip())
    return result


def parse_pipe_list(value: str) -> list[str]:
    return [item.strip() for item in value.split("|") if item.strip()]


def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def write_json(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def ensure_task_defaults(task: dict) -> dict:
    for field, default_value in OPTIONAL_TASK_LIST_FIELDS.items():
        task.setdefault(field, list(default_value))
    return task


def is_legacy_done_task(task: dict) -> bool:
    return (
        task.get("status") == "done"
        and task.get("review_status") in PASSED_REVIEW_STATUSES
        and not task.get("validation_results")
    )


def normalize_state(state: dict) -> dict:
    for task in state.get("tasks", []):
        ensure_task_defaults(task)
    return state


def _detect_cycle(task_by_id: dict[str, dict]) -> None:
    seen: set[str] = set()
    active: set[str] = set()

    def visit(task_id: str) -> None:
        if task_id in seen:
            return
        if task_id in active:
            raise ValidationError(f"Dependency cycle detected at task {task_id}.")
        active.add(task_id)
        task = task_by_id[task_id]
        for dep in task.get("depends_on", []):
            visit(dep)
        active.remove(task_id)
        seen.add(task_id)

    for task_id in task_by_id:
        visit(task_id)


def validate_state(state: dict) -> dict:
    missing_top = sorted(field for field in REQUIRED_TOP_LEVEL_FIELDS if field not in state)
    if missing_top:
        raise ValidationError(f"Missing top-level field(s): {', '.join(missing_top)}")
    normalize_state(state)

    tasks = state.get("tasks", [])
    if not isinstance(tasks, list) or not tasks:
        raise ValidationError("State must contain a non-empty tasks list.")

    if not isinstance(state.get("acceptance_criteria"), list) or not state["acceptance_criteria"]:
        raise ValidationError("Top-level acceptance_criteria must be a non-empty list.")
    if not isinstance(state.get("blockers"), list):
        raise ValidationError("Top-level blockers must be a list.")
    if state.get("status") not in {"in_progress", "blocked", "done"}:
        raise ValidationError("Top-level status must be one of: in_progress, blocked, done.")

    task_by_id: dict[str, dict] = {}
    for task in tasks:
        missing_fields = sorted(field for field in REQUIRED_TASK_FIELDS if field not in task)
        if missing_fields:
            raise ValidationError(
                f"Task {task.get('id', '<unknown>')} is missing field(s): {', '.join(missing_fields)}"
            )
        ensure_task_defaults(task)
        task_id = task["id"]
        if task_id in task_by_id:
            raise ValidationError(f"Duplicate task id: {task_id}")
        task_by_id[task_id] = task
        if task.get("status") not in TASK_STATUSES:
            raise ValidationError(f"Task {task_id} has invalid status {task.get('status')!r}.")
        if task.get("review_status") not in REVIEW_STATUSES:
            raise ValidationError(f"Task {task_id} has invalid review_status {task.get('review_status')!r}.")
        if not isinstance(task.get("depends_on"), list):
            raise ValidationError(f"Task {task_id} depends_on must be a list.")
        for field in ("acceptance_criteria", "validation", "artifacts", "validation_results", "evidence"):
            if not isinstance(task.get(field), list):
                raise ValidationError(f"Task {task_id} field {field} must be a list.")
        if task.get("status") == "blocked" and not task.get("blocked_reason"):
            raise ValidationError(f"Task {task_id} is blocked but missing blocked_reason.")
        if task.get("status") != "blocked" and task.get("blocked_reason"):
            raise ValidationError(f"Task {task_id} has blocked_reason set but is not blocked.")
        if task.get("status") == "done":
            if task.get("review_status") not in PASSED_REVIEW_STATUSES:
                raise ValidationError(f"Task {task_id} is done without a passing review_status.")
            if not task.get("acceptance_criteria"):
                raise ValidationError(f"Task {task_id} is done without task-level acceptance_criteria.")
            if not task.get("validation"):
                raise ValidationError(f"Task {task_id} is done without task-level validation steps.")
            if not task.get("validation_results") and not is_legacy_done_task(task):
                raise ValidationError(f"Task {task_id} is done without validation_results.")
        if task.get("status") in ACTIVE_STATES and task.get("review_status") == "changes_requested":
            raise ValidationError(f"Task {task_id} cannot stay active with review_status changes_requested.")

    for task in tasks:
        for dep in task.get("depends_on", []):
            if dep not in task_by_id:
                raise ValidationError(f"Task {task['id']} depends on unknown task {dep}.")
            if dep == task["id"]:
                raise ValidationError(f"Task {task['id']} cannot depend on itself.")
    _detect_cycle(task_by_id)

    active = [task for task in tasks if task.get("status") in ACTIVE_STATES]
    if len(active) > 1:
        raise ValidationError("More than one active task exists.")
    if active:
        active_id = active[0]["id"]
        if state.get("current_task_id") != active_id:
            raise ValidationError(
                f"current_task_id {state.get('current_task_id')!r} does not match active task {active_id!r}."
            )
    else:
        blocked_ids = [task["id"] for task in tasks if task.get("status") == "blocked"]
        if blocked_ids:
            if state.get("current_task_id") and state.get("current_task_id") not in blocked_ids:
                raise ValidationError("current_task_id must reference a blocked task when the state is blocked.")
        elif state.get("status") != "done" and state.get("current_task_id"):
            raise ValidationError("current_task_id must be empty when no task is active.")

    if state.get("status") == "done":
        if state.get("current_task_id"):
            raise ValidationError("current_task_id must be empty when the overall state is done.")
        if state.get("blockers"):
            raise ValidationError("Overall blockers must be empty when the overall state is done.")
        if not all(task.get("status") == "done" for task in tasks):
            raise ValidationError("Overall state cannot be done until every task is done.")

    if state.get("status") == "blocked" and not state.get("blockers"):
        raise ValidationError("Overall state is blocked but blockers is empty.")

    return state


def task_by_id(state: dict) -> dict[str, dict]:
    return {task["id"]: task for task in state.get("tasks", [])}


def dependencies_satisfied(task: dict, tasks_by_id: dict[str, dict]) -> bool:
    return all(tasks_by_id[dep]["status"] == "done" for dep in task.get("depends_on", []))
