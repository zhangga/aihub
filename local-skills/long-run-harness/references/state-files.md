# State Files

Use two durable state files by default:

- `task_list.json` for machine-readable workflow state
- `progress.md` for human-readable session context

Keep them small, explicit, and synchronized.

## `task_list.json`

Purpose:

- capture the final goal and acceptance criteria
- track the single active task and all remaining tasks
- record blockers, review state, and commit linkage
- record validation outcomes and evidence for completed work
- support deterministic recovery across sessions

Recommended shape:

```json
{
  "goal": "Ship feature X with passing tests and docs",
  "acceptance_criteria": [
    "Feature X works end to end",
    "Relevant tests pass",
    "Documentation is updated"
  ],
  "status": "in_progress",
  "current_task_id": "T2",
  "blockers": [],
  "last_updated": "2026-04-01T15:30:00Z",
  "tasks": [
    {
      "id": "T1",
      "title": "Inspect current implementation and constraints",
      "summary": "Establish the baseline and identify the affected files",
      "status": "done",
      "depends_on": [],
      "acceptance_criteria": [
        "Affected areas are identified",
        "Assumptions are recorded"
      ],
      "validation": [
        "Baseline commands run successfully"
      ],
      "artifacts": [
        "progress.md"
      ],
      "validation_results": [
        "Ran baseline startup check successfully"
      ],
      "evidence": [
        "git diff",
        "test output"
      ],
      "review_status": "self_review_passed",
      "last_commit": "abc1234",
      "blocked_reason": ""
    }
  ]
}
```

Required top-level fields:

- `goal`
- `acceptance_criteria`
- `status`
- `current_task_id`
- `blockers`
- `last_updated`
- `tasks`

Required per-task fields:

- `id`
- `title`
- `summary`
- `status`
- `depends_on`
- `acceptance_criteria`
- `validation`
- `artifacts`
- `review_status`
- `last_commit`
- `blocked_reason`

Allowed task statuses:

- `todo`
- `in_progress`
- `in_review`
- `blocked`
- `done`

Allowed review statuses:

- `not_started`
- `self_review_passed`
- `needs_independent_review`
- `independent_review_passed`
- `changes_requested`

Recommended additional per-task fields:

- `validation_results`
- `evidence`

Rules:

- Keep exactly one active task at a time.
- Do not silently delete unfinished tasks.
- Do not move a task to `done` before validation and review.
- If a task is blocked, say why in `blocked_reason`.
- Do not leave task-level `acceptance_criteria` or `validation` empty.
- Do not move a task to `done` until `validation_results` is recorded.
- If git is in use, write the most relevant commit hash into `last_commit` after completion.

## `progress.md`

Purpose:

- help a fresh session recover quickly
- capture what changed, what was verified, and what remains
- explain why the next task was chosen

Suggested structure:

```md
# Progress

## Objective
- Ship feature X with passing tests and docs.

## Current Task
- T2: Implement feature X endpoint and integration wiring.

## Recent Progress
- 2026-04-01 15:30 UTC: Completed T1. Verified baseline app startup and mapped the affected files.

## Blockers
- none

## Next Action
- Run the implementation for T2, then execute the relevant tests.

## Risks And Decisions
- Keep the old endpoint contract unchanged to avoid a client regression.
```

Rules:

- Rewrite it deliberately. It is not an append-only log.
- Keep it concise enough that a fresh agent can read it quickly.
- Reflect the same current task as `task_list.json`.
- Record blockers explicitly. Write `none` when there are none.

## Synchronization Rules

After each completed cycle:

1. Update `task_list.json`.
2. Update `progress.md`.
3. Verify they agree on the current task, blockers, and next action.
4. If git is available, make sure the latest commit is consistent with the recorded state.
