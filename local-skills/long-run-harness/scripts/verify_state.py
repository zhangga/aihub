#!/usr/bin/env python3
"""Verify long-run harness state and report a concise summary."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from harness_lib import ACTIVE_STATES, ValidationError, load_json, validate_state


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate task_list.json for the long-run harness.")
    parser.add_argument("--file", default="task_list.json", help="Path to task_list.json")
    args = parser.parse_args()

    path = Path(args.file).resolve()
    try:
        state = validate_state(load_json(path))
    except (OSError, json.JSONDecodeError, ValidationError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2

    tasks = state["tasks"]
    active = [task["id"] for task in tasks if task.get("status") in ACTIVE_STATES]
    blocked = [task["id"] for task in tasks if task.get("status") == "blocked"]
    done = [task["id"] for task in tasks if task.get("status") == "done"]

    print(
        json.dumps(
            {
                "ok": True,
                "goal": state["goal"],
                "overall_status": state["status"],
                "current_task_id": state["current_task_id"],
                "active_tasks": active,
                "blocked_tasks": blocked,
                "done_tasks": done,
                "task_count": len(tasks),
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
