# Long Run Harness Design

## Summary

Design `long-run-harness` as a semi-automated execution-framework skill for long-running work. The skill should primarily support autonomous progress inside an existing git repository, while still being reusable for non-code tasks such as documentation or research. It should externalize state into durable files, enforce single-task progression, gate advancement through validation and review, and recover cleanly across interrupted sessions.

This design intentionally stops short of a fully scripted runner. The skill should provide a reusable operating protocol plus a small set of helper scripts for the most error-prone structured operations.

## Goals

- Enable Codex or similar agents to keep driving toward a final objective across many work cycles.
- Minimize reliance on ephemeral conversation context by storing durable state in repository files and git history.
- Keep execution predictable by allowing only one active task at a time.
- Require explicit validation and a review gate before a task is considered complete.
- Support session recovery after interruption, compaction, or model/thread changes.
- Work well for code-repository tasks first, while remaining adaptable to document and research tasks.

## Non-Goals

- Replace the coding agent with a fully autonomous shell runner.
- Depend on one model vendor, CLI, or hook system.
- Encode business-domain implementation logic into the harness itself.
- Optimize for parallel multi-task execution.
- Require subagents or independent review on every task.

## User Intent and Triggering

The skill should trigger for requests where the user wants the agent to continue autonomously until the true end state is reached, especially when the work:

- spans multiple implementation or reasoning cycles
- requires durable progress tracking
- benefits from task decomposition and recovery across sessions
- should stop only for real blockers, not after the first successful pass

The skill should not trigger for:

- single-pass implementation tasks
- lightweight planning or brainstorming requests
- one-off edits that do not need durable state
- requests where the user wants synchronous oversight at each step

## Recommended Approach

Use a semi-automated harness composed of:

1. A strong `SKILL.md` protocol that defines when to trigger, how to initialize, how to resume, how to select work, and when to stop.
2. Structured state files that act as the durable memory layer.
3. Small helper scripts that reduce failure rates for initialization, status checking, and progress updates.
4. A review policy that defaults to self-review and escalates to an independent review path when risk or uncertainty is high.

This balances repeatability with flexibility. It avoids the fragility of a pure prose-only skill while avoiding the rigidity and environmental coupling of a full shell-driven executor.

## Alternatives Considered

### 1. Documentation-only skill

Pros:

- fastest to author
- portable across environments
- minimal maintenance burden

Cons:

- too much behavior remains implicit
- inconsistent state files across runs
- agents are more likely to drift from the protocol

### 2. Fully scripted harness

Pros:

- highest consistency
- strongest guardrails
- easiest to automate end-to-end

Cons:

- overfits to a specific runtime model
- turns the skill into a product rather than a reusable knowledge package
- harder to adapt to different repositories and task types

### 3. Semi-automated harness

Pros:

- reliable where structure matters most
- flexible where reasoning and implementation vary
- best match for skill distribution in this repository

Cons:

- still relies on agent judgment for some transitions
- requires careful `SKILL.md` wording to stay effective

Recommendation: choose option 3.

## Architecture

The skill should follow a two-layer model:

### Layer 1: Harness protocol

Defined in `SKILL.md` and references. Responsible for:

- deciding when the skill should be used
- initializing state
- restoring context in later sessions
- selecting the next unit of work
- deciding whether a task is ready for review or blocked
- deciding whether to continue or stop

### Layer 2: Task execution

Performed by the agent in the target repository. Responsible for:

- analyzing the selected task
- making code or content changes
- running validation
- updating progress artifacts
- preparing work for review

The harness does not directly perform business logic. It tells the agent how to operate over time.

## Skill Package Structure

The skill should be implemented under `local-skills/long-run-harness/` with at least:

- `SKILL.md`
- `references/state-files.md`
- `references/workflow.md`
- `references/review-policy.md`
- `references/recovery.md`
- `scripts/init_harness.py` or `scripts/init_harness.ps1`
- `scripts/check_next_task.py`
- `scripts/update_progress.py`

Optional later additions:

- `scripts/mark_review_result.py`
- `scripts/verify_state.py`
- `references/examples.md`

### Rationale for Each File Group

`SKILL.md` should stay concise and procedural. It should contain only the trigger description, main lifecycle, and explicit instructions on when to open references or use scripts.

`references/` should contain details that are important but too bulky for the main skill body, especially state schema, recovery procedure, and review escalation rules.

`scripts/` should cover only deterministic, repeated operations where hand-editing would create avoidable errors.

## State Model

The default durable state should use:

- `task_list.json` for machine-readable structured state
- `progress.md` for human-readable narrative state

### `task_list.json`

Purpose:

- represent the final goal and decomposed work items
- expose current workflow state to both the agent and scripts
- make recovery deterministic

Recommended top-level fields:

- `goal`
- `acceptance_criteria`
- `current_task_id`
- `status`
- `tasks`
- `blockers`
- `last_updated`

Recommended per-task fields:

- `id`
- `title`
- `status`
- `depends_on`
- `summary`
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

### `progress.md`

Purpose:

- capture the latest working narrative for humans and fresh sessions
- record what was attempted, what succeeded, what failed, and what comes next

Suggested sections:

- current objective
- current active task
- recent completed work
- current blockers
- next action
- risks and decisions

This file should be concise and updated every cycle. It should complement `task_list.json`, not duplicate every field.

## Workflow

### 1. Initialize

When no harness state exists:

- restate the final objective
- derive concrete acceptance criteria
- decompose work into sequential tasks
- write `task_list.json`
- write `progress.md`
- select the first task

### 2. Restore

At the start of a new work cycle:

- read `task_list.json`
- read `progress.md`
- inspect recent git history when available
- determine the current task and pending blockers
- verify the repository baseline before changing anything

### 3. Execute One Task

For the single selected task:

- refine task-local plan if needed
- implement or perform the task
- run validation appropriate to the task
- gather artifacts and evidence

### 4. Review Gate

After execution:

- perform self-review by default
- escalate to independent review when the task is risky, user-visible, broad in scope, weakly verified, or failed prior attempts
- if review fails, return the same task to `in_progress`
- if review passes, move the task to `done`

### 5. Update State

After review:

- update `task_list.json`
- update `progress.md`
- record the related commit hash when applicable

### 6. Commit and Continue

If the repository is stable and the task is complete:

- create a focused commit for that task
- choose the next highest-priority unblocked task
- continue until all acceptance criteria pass or a hard blocker is reached

## Review Policy

Default policy: self-review first.

Escalate to independent review when:

- the task changes critical flows or shared architecture
- tests are partial or weak
- previous attempts failed review
- the task affects safety, data integrity, or external behavior in non-obvious ways
- the user explicitly requests stricter review

Independent review should be framed as a gate, not as a parallel implementation path. The executing agent remains responsible for integrating review feedback and re-running validation.

## Error Handling and Recovery

The skill should include explicit handling for:

- missing prerequisites
- broken baseline environment
- failed validation
- ambiguous next steps
- review failure
- interrupted sessions

Recovery strategy:

- never silently skip a failed or blocked task
- update state before stopping
- make blockers explicit in `task_list.json` and `progress.md`
- rely on the combination of state files and git log to restore context

## Implementation Guidance for `SKILL.md`

The quality of this skill will depend mostly on the `SKILL.md` body. It should clearly answer:

- when this skill should trigger
- what the first session must do
- what every later session must read first
- how to select exactly one task
- what counts as sufficient validation
- when commit is allowed
- when review escalation is required
- when the agent must continue versus when it may stop

The body should remain concise and push detailed schema and examples into references.

## Testing Strategy

Validation should happen at two levels:

### Skill package validation

- run the repository skill validator on the skill folder
- verify frontmatter and structure

### Behavioral validation

Forward-test the skill on realistic long-running tasks such as:

- implementing a medium-size feature in an existing repository
- carrying a documentation project across multiple sessions
- recovering from an interrupted session with only state files and git history

Success criteria:

- the agent restores context without guesswork
- only one task is active at a time
- tasks are not marked complete before validation and review
- state files stay consistent with git history

## Open Decisions

The initial version should leave these as implementation choices rather than design blockers:

- whether helper scripts are written in Python, PowerShell, or both
- the exact JSON schema versioning strategy
- whether to add optional per-task files later for richer audit history

## Implementation Plan Outline

Recommended build order:

1. Rewrite `SKILL.md` around the new trigger rules and lifecycle.
2. Define `references/state-files.md` with the canonical `task_list.json` schema.
3. Add workflow, review, and recovery references.
4. Add the smallest useful helper scripts.
5. Validate the skill package.
6. Forward-test on at least one code task and one non-code task.

## Acceptance Criteria for This Design

This design is complete when the resulting skill:

- is clearly positioned as a semi-automated harness rather than a pure prompt or a full runner
- defaults to git-repository work while remaining reusable elsewhere
- stores durable state in `task_list.json` plus `progress.md`
- enforces single-task execution with validation and review before advancement
- supports recovery through state files plus git history
- can be implemented within the repository's existing skill packaging model
