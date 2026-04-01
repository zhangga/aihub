---
name: long-run-harness
description: Use for long-running, multi-step work where the agent should keep driving toward the true final outcome across many cycles instead of stopping after one pass. Trigger when the user wants autonomous progress, durable state, session recovery, single-task execution, validation, and review gates in an existing git repository or a similarly structured workspace.
---

# Long Run Harness

Use this skill when the user wants the agent to keep advancing a complex task until it is actually done, not merely improved.

Default to git-repository work. You may also apply the same operating model to documentation, research, or mixed projects when durable state and autonomous continuation matter.

Do not use this skill for one-shot edits, lightweight planning, or requests where the user wants synchronous oversight at each milestone.

## Core Operating Rules

- Externalize state. Do not rely on conversation memory for long-running work.
- Work one task at a time. Do not keep multiple partial tasks open in parallel.
- Require validation before task completion.
- Require review before advancing to the next task.
- Use git history as a recovery aid when a repository is available.
- Continue automatically unless a real blocker or completion condition exists.

## Required State Files

Create and maintain these files in the project root or an agreed task workspace:

- `task_list.json`
- `progress.md`

Read [`references/state-files.md`](references/state-files.md) before creating or editing them.

## First Session

If harness state does not exist yet:

1. Restate the final objective in concrete terms.
2. Derive explicit acceptance criteria.
3. Decompose the work into sequential tasks with clear boundaries.
4. Initialize `task_list.json` and `progress.md`.
5. Select exactly one starting task.
6. Begin execution only after the state files are coherent.

Use [`scripts/init_harness.py`](scripts/init_harness.py) to create the initial files when possible.

## Every Later Session

At the start of every new cycle:

1. Read `task_list.json`.
2. Read `progress.md`.
3. Review recent git history when available.
4. Confirm the current active task or the next unblocked task.
5. Verify the baseline environment before making new changes.

Read [`references/recovery.md`](references/recovery.md) if the session starts from an interrupted or unclear state.

## Task Execution Loop

For the single active task:

1. Refine the task-local plan only as much as needed.
2. Perform the implementation, writing, or analysis.
3. Run validation that matches the task's acceptance criteria.
4. Gather evidence such as test output, generated artifacts, or diffs.
5. Perform review.
6. Update `task_list.json` and `progress.md`.
7. Commit focused progress when the repository is stable.
8. Select the next unblocked task and continue.

Read [`references/workflow.md`](references/workflow.md) for the complete lifecycle.

## Review Gate

Default to self-review first. Escalate to an independent review pass when the task is risky, user-visible, weakly validated, previously failed review, or changes shared architecture.

Do not move to the next task until the current task has either:

- passed review and been marked complete, or
- been marked blocked with an explicit blocker

Read [`references/review-policy.md`](references/review-policy.md) before deciding whether to advance.

## Stop Conditions

Keep going unless one of these is true:

- every acceptance criterion is verified complete
- a required permission is missing
- a required input is missing and cannot be inferred safely
- the environment or external dependency is unavailable
- a high-risk decision has non-obvious consequences and cannot be made autonomously

If you stop, update the state files first and make the blocker explicit.

## Script Usage

Use the helper scripts when possible instead of hand-editing structured state:

- `python scripts/init_harness.py ...` to initialize `task_list.json` and `progress.md`
- `python scripts/check_next_task.py ...` to validate the state and find the current or next task
- `python scripts/update_progress.py ...` to update task status and append progress entries consistently

If you must edit state files manually, preserve the schema and keep status transitions explicit.
