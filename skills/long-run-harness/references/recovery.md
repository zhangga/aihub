# Recovery

Use this reference when a session starts after interruption, context compaction, or an unclear handoff.

## Recovery Order

1. Read `task_list.json`.
2. Read `progress.md`.
3. Inspect recent git history when available.
4. Determine whether there is an active task.
5. Re-run the baseline validation or startup checks.
6. Continue the active task or select the next unblocked task.
7. Run `verify_state.py` before changing task status if the state was manually edited or looks inconsistent.

Do not guess from repository shape alone when state files exist.

## What To Trust

Trust these sources in this order:

1. explicit state in `task_list.json`
2. narrative context in `progress.md`
3. recent git history
4. current workspace contents

If these disagree, reconcile them before starting new work.
Prefer fixing the state file explicitly over guessing which task should be active.

## Common Recovery Cases

### Active task already exists

If `current_task_id` points to a task that is `in_progress` or `in_review`, resume that task first.

### No active task but unfinished work remains

Choose the highest-priority unblocked task whose dependencies are complete, then update both state files.

### Baseline is broken

Treat environment repair as part of the current cycle before starting new feature work.

### Review was pending

Do not begin a new task until the current task's review outcome is explicit.

## Hard Blockers

Stop only after recording the blocker when:

- required permissions are missing
- required inputs cannot be safely inferred
- external systems are unavailable
- a high-risk product or operational decision needs user input

If you stop, make the next action obvious in `progress.md`.
