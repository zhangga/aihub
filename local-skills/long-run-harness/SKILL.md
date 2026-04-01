---
name: long-run-harness
description: Use for long-running, complex, multi-step tasks that should continue autonomously until the final goal is fully completed, not merely partially progressed. Trigger when the user wants the agent to self-plan, keep iterating across many work cycles, recover state between sessions, leave structured handoff artifacts, and only stop for true hard blockers such as missing permissions, unavailable external systems, missing required inputs, or high-risk decisions that cannot be made autonomously.
---

# Long Run Harness

Apply this skill only to long-horizon tasks where the user explicitly wants the agent to continue driving toward the final end state without pausing after intermediate milestones.

Do not use this skill for ordinary one-shot tasks, lightweight planning, casual brainstorming, or work that should naturally stop after a single implementation pass.

For ready-to-use user prompt wording, read [`references/prompt-template.md`](references/prompt-template.md).

## Objective

Drive the task to full completion.

Default behavior:

- keep working until the final objective is verified complete
- keep re-planning as new information appears
- keep leaving durable state so a fresh session can continue immediately
- do not stop just because meaningful progress was made

Permitted stop conditions are narrow:

- required permission is missing
- a critical external dependency or environment is unavailable
- a required input is genuinely absent
- a high-risk decision would have non-obvious consequences and cannot be made autonomously
- every acceptance criterion is verified complete

If none of the above is true, continue.

## Operating Model

Use a two-phase harness.

1. Initializer session
2. Execution sessions

Initializer session creates the working structure that future sessions rely on.

Execution sessions repeatedly:

1. restore context
2. verify current state
3. select the single highest-priority unfinished unit of work
4. execute it
5. verify it
6. record state for the next session
7. continue until the final goal is done

Never treat one session as the whole project unless the final objective is actually complete and verified.

## Required Artifacts

At the start of a long-running task, create and maintain these artifacts in the project root or in a task-specific working directory:

- `task-map.json`
- `progress.md`
- `next-step.md`
- `blockers.md`
- `init.sh` when a startup or verification command sequence is needed

Read [`references/state-files.md`](references/state-files.md) before creating or updating these files.

## Initializer Session

On the first session:

1. Understand the user's final objective.
2. Expand the objective into explicit, testable acceptance criteria.
3. Write `task-map.json` with structured work items and completion state.
4. Write `progress.md` with the initial environment summary.
5. Write `next-step.md` with the first concrete work item.
6. Write `blockers.md` with either `none` or active blockers.
7. If applicable, write `init.sh` to start services, load dependencies, or run baseline checks.
8. Leave the environment in a runnable, understandable state.

Do not start by attempting the entire task in one shot.

## Execution Session Start

At the beginning of every subsequent session:

1. Run `pwd`.
2. Read `progress.md`.
3. Read `next-step.md`.
4. Read `task-map.json`.
5. Read `blockers.md`.
6. Review recent git history if git is available.
7. Run `init.sh` if present and relevant.
8. Verify basic baseline functionality before touching new work.

If the environment is broken, fix the breakage before starting the next feature or task unit.

Read [`references/session-checklist.md`](references/session-checklist.md) and execute that checklist in order.

## Work Selection Rules

When choosing what to do next:

- prefer the highest-priority unfinished item in `task-map.json`
- work on one coherent unit at a time
- choose work that reduces uncertainty and unlocks later steps
- do not start multiple half-finished branches of work

Avoid these failure modes:

- trying to complete the entire project in one pass
- declaring completion because the repository looks improved
- marking tasks done without end-to-end verification
- leaving partial, undocumented work behind

## Completion Standard

A task item is complete only when:

- implementation is present
- verification has run
- acceptance criteria pass
- state files are updated

The overall job is complete only when every required item in `task-map.json` is passing and the user's final goal has been achieved in reality, not just in code.

Do not mark items complete based on confidence or intent.

## Session End Rules

Before ending any work cycle:

1. Update `task-map.json`.
2. Append a concise factual entry to `progress.md`.
3. Rewrite `next-step.md` with the next best action.
4. Update `blockers.md`.
5. Commit clean incremental progress if git is in use and the environment is stable.

Leave the workspace in a state where a fresh agent can continue immediately without guessing.

## Non-Stop Execution Policy

Interpret "do not stop until complete" literally.

That means:

- after finishing one subtask, immediately select the next one
- after recovering from a bug, resume forward progress
- after writing plans, continue into execution unless a real blocker exists
- after partial validation, continue until full validation is satisfied

It does not mean running forever without judgment.

Stop only for a permitted stop condition, and when stopping:

- explain the exact blocker
- identify what was verified
- identify what remains
- point to `next-step.md` and `blockers.md`

## Recommended State Discipline

Use structured files as the durable memory layer.

- Keep `task-map.json` structured and machine-readable.
- Keep `progress.md` append-only, factual, and concise.
- Keep `next-step.md` focused on one immediate next action.
- Keep `blockers.md` explicit; write `none` when nothing blocks progress.

Prefer JSON for task state because agents are less likely to casually rewrite it in destructive ways.

## Testing and Verification

Always verify from the outside in when possible.

- prefer end-to-end checks over assumptions
- verify as a user would verify
- use automation tools when available
- do not weaken tests to make progress look complete

If a task cannot be fully validated yet, keep it incomplete.

Read [`references/harness-pattern.md`](references/harness-pattern.md) for the underlying rationale and failure modes this harness is designed to prevent.
