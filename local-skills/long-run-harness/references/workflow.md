# Workflow

Use this lifecycle for long-running execution.

## 1. Initialize

When no state exists yet:

1. Restate the final objective.
2. Convert it into explicit acceptance criteria.
3. Decompose the work into sequential tasks.
4. Initialize `task_list.json` and `progress.md`.
5. Select one starting task.

Prefer tasks that are:

- independently finishable
- easy to validate
- likely to unblock later work

Avoid tasks that are too broad to review cleanly.

## 2. Restore

At the beginning of each later cycle:

1. Read `task_list.json`.
2. Read `progress.md`.
3. Inspect recent git history if available.
4. Confirm the active task or choose the next unblocked task.
5. Re-establish the baseline before editing anything new.

If the baseline is broken, fix that first.

## 3. Execute One Task

Once a task is active:

1. Refine the plan only for that task.
2. Implement or perform the task.
3. Run the task's validation.
4. Gather evidence.

Do not start a second task while the first one is still unresolved.

## 4. Review

After execution:

1. Perform self-review.
2. Decide whether escalation to independent review is required.
3. If review requests changes, keep the same task active.
4. If review passes, mark the task complete.

## 5. Update Durable State

After review:

1. Update task status, review status, blockers, and commit linkage in `task_list.json`.
2. Rewrite `progress.md` so a fresh session can continue immediately.

Use the helper scripts whenever possible so state transitions stay consistent.

## 6. Commit And Continue

If the workspace is stable:

1. Create a focused commit for the completed task.
2. Select the next unblocked task.
3. Repeat the cycle.

Only stop when:

- all acceptance criteria are complete, or
- a real blocker prevents safe continuation

## Task Granularity Guidance

Prefer tasks that can be finished in one coherent cycle. Split work further when a task:

- touches too many unrelated areas
- needs more than one review boundary
- has vague validation criteria
- would likely produce a noisy or oversized commit

## Non-Code Tasks

For documentation or research work, keep the same lifecycle:

- decompose into single-focus tasks
- validate outputs against explicit criteria
- review before marking done
- update durable state

Git commits are still useful, but the main product may be documents or reports rather than code.
