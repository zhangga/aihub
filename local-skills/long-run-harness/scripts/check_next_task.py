#!/usr/bin/env python3
"""Validate harness state and report the current or next task."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from harness_lib import ACTIVE_STATES, dependencies_satisfied, load_json, task_by_id, validate_state, ValidationError


def main() -> int:
    parser = argparse.ArgumentParser(description="Inspect task_list.json and report the active or next task.")
    parser.add_argument("--file", default="task_list.json", help="Path to task_list.json")
    args = parser.parse_args()

    path = Path(args.file).resolve()
    try:
        state = validate_state(load_json(path))
    except ValidationError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2
    tasks = state.get("tasks", [])
    tasks_by_id = task_by_id(state)

    active = [task for task in tasks if task.get("status") in ACTIVE_STATES]
    if len(active) == 1:
        task = active[0]
        print(json.dumps({"mode": "active", "task": task}, indent=2))
        return 0

    blocked = [task for task in tasks if task.get("status") == "blocked"]
    if blocked:
        print(json.dumps({"mode": "blocked", "tasks": blocked}, indent=2))
        return 0

    for task in tasks:
        if task.get("status") != "todo":
            continue
        if dependencies_satisfied(task, tasks_by_id):
            print(json.dumps({"mode": "next", "task": task}, indent=2))
            return 0

    if all(task.get("status") == "done" for task in tasks):
        print(json.dumps({"mode": "complete", "goal": state.get("goal", "")}, indent=2))
        return 0

    print("ERROR: no active or eligible next task found", file=sys.stderr)
    return 3


if __name__ == "__main__":
    raise SystemExit(main())
