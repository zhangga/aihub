# State Files

## `task-map.json`

Purpose:

- hold the full decomposed objective
- provide durable completion state across sessions

Recommended shape:

```json
{
  "final_goal": "string",
  "done_criteria": [
    "criterion 1",
    "criterion 2"
  ],
  "items": [
    {
      "id": "T1",
      "title": "Short task title",
      "priority": 1,
      "status": "todo",
      "acceptance_criteria": [
        "observable outcome"
      ],
      "verification": [
        "how this gets checked"
      ],
      "notes": ""
    }
  ]
}
```

Allowed statuses:

- `todo`
- `in_progress`
- `blocked`
- `done`

Rules:

- keep the schema stable
- do not silently delete unfinished items
- only move an item to `done` after verification

## `progress.md`

Purpose:

- append-only operating log for future sessions

Suggested format:

```md
# Progress

## 2026-03-31 14:20
- Verified baseline app startup.
- Completed T3.
- Found blocker on external API auth for T4.
```

Rules:

- append, do not rewrite history
- keep entries factual
- include what changed, what was verified, and what remains

## `next-step.md`

Purpose:

- define the single most important immediate next action

Suggested format:

```md
# Next Step

Work on T4: integrate authenticated API flow and verify end-to-end login.

Why this is next:
- T4 is the highest-priority blocked functional gap.
- T1-T3 are already verified.

Start by:
1. Read blockers.md
2. Re-run init.sh
3. Verify baseline login screen
```

Rules:

- only one next action
- make it executable, not abstract

## `blockers.md`

Purpose:

- explicit blocker register

Suggested format:

```md
# Blockers

none
```

or

```md
# Blockers

- Missing production API token for billing sync
- Need user decision on irreversible data migration strategy
```

Rules:

- write `none` when nothing blocks progress
- do not mix blockers with general notes

## `init.sh`

Purpose:

- provide a reliable startup and baseline verification path

Use when the task involves:

- starting services
- bootstrapping dependencies
- running smoke checks
- recurring environment setup across sessions

Rules:

- make it idempotent where practical
- keep it focused on reproducible environment bring-up
