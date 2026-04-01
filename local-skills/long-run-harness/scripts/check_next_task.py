#!/usr/bin/env python3
"""Validate harness state and report the current or next task."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


DONE_STATES = {"done"}
ACTIVE_STATES = {"in_progress", "in_review"}


def load_state(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def main() -> int:
    parser = argparse.ArgumentParser(description="Inspect task_list.json and report the active or next task.")
    parser.add_argument("--file", default="task_list.json", help="Path to task_list.json")
    args = parser.parse_args()

    path = Path(args.file).resolve()
    state = load_state(path)
    tasks = state.get("tasks", [])
    task_by_id = {task["id"]: task for task in tasks}

    active = [task for task in tasks if task.get("status") in ACTIVE_STATES]
    if len(active) > 1:
        print("ERROR: more than one active task exists", file=sys.stderr)
        return 2
    if len(active) == 1:
        task = active[0]
        print(json.dumps({"mode": "active", "task": task}, indent=2))
        return 0

    for task in tasks:
        if task.get("status") != "todo":
            continue
        depends_on = task.get("depends_on", [])
        if all(task_by_id.get(dep, {}).get("status") in DONE_STATES for dep in depends_on):
            print(json.dumps({"mode": "next", "task": task}, indent=2))
            return 0

    if all(task.get("status") == "done" for task in tasks):
        print(json.dumps({"mode": "complete", "goal": state.get("goal", "")}, indent=2))
        return 0

    blocked = [task for task in tasks if task.get("status") == "blocked"]
    if blocked:
        print(json.dumps({"mode": "blocked", "tasks": blocked}, indent=2))
        return 0

    print("ERROR: no active or eligible next task found", file=sys.stderr)
    return 3


if __name__ == "__main__":
    raise SystemExit(main())
