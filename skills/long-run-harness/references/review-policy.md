# Review Policy

Every task needs a review gate before the harness advances.

## Default Mode

Default to self-review. The executing agent should check:

- whether the task's acceptance criteria are actually met
- whether validation ran and passed
- whether the change introduced regressions or contradictions
- whether the state files match reality

Only mark `review_status` as `self_review_passed` when these checks are complete.

## Escalation To Independent Review

Escalate when any of these are true:

- the change touches shared architecture or critical flows
- validation is weak, partial, or indirect
- the task has already failed review once
- the change is large enough that self-review is likely insufficient
- the task affects safety, data integrity, external behavior, or user trust
- the user explicitly asks for stricter review

When escalating:

- set `review_status` to `needs_independent_review`
- keep the task active until the review passes
- treat the review as a quality gate, not a second implementation thread

## Review Outcomes

Use these outcomes:

- `self_review_passed`
- `independent_review_passed`
- `changes_requested`

If review requests changes:

- keep the task out of `done`
- preserve the task id
- update `progress.md` with what failed and what must change next

## Commit Timing

Preferred sequence for a normal task:

1. implement
2. validate
3. review
4. update state
5. commit

If a checkpoint commit is unavoidable before final review, record that clearly in `progress.md` and keep the task active.
