# Prompt Template

Use these templates when you want the agent to keep driving a long-running task until the real end goal is complete.

## General Template

```text
Use $long-run-harness at /absolute/path/to/long-run-harness.

Final objective:
<describe the real end goal, not the first milestone>

Constraints:
- Work autonomously until the final objective is actually complete and verified.
- Do not stop after partial progress, planning, or one milestone.
- Only stop if you hit a true hard blocker: missing permission, missing required input, unavailable external dependency, or a high-risk decision that cannot be made autonomously.
- Maintain durable state files so a fresh session can continue immediately.
- Prefer incremental, verifiable progress over broad speculative changes.
- Keep the environment clean after each work cycle.

Required working artifacts:
- task-map.json
- progress.md
- next-step.md
- blockers.md
- init.sh if startup or baseline verification is needed

Completion rule:
- The task is done only when the final objective is achieved in reality and all required acceptance criteria pass.
```

## Coding / Delivery Template

```text
Use $long-run-harness at /absolute/path/to/long-run-harness.

Build and finish this task end-to-end:
<describe the deliverable>

Execution policy:
- Expand the goal into a structured task map.
- Work on the highest-priority unfinished item at each step.
- Verify baseline functionality before starting new work.
- After each change, run relevant validation and update the state files.
- Continue immediately to the next unfinished item.
- Do not declare success because the code looks mostly done.
- Do not stop until the final deliverable is complete and verified.

Allowed stop conditions:
- missing permission
- missing required input
- unavailable external system or dependency
- high-risk decision requiring user choice

If you stop, explain the blocker precisely and leave next-step.md ready for the next session.
```

## Research / Operations Template

```text
Use $long-run-harness at /absolute/path/to/long-run-harness.

Carry this objective to completion:
<describe the research, analysis, migration, investigation, or operations goal>

Requirements:
- Break the objective into explicit acceptance criteria.
- Keep working until the final decision, deliverable, or output is complete.
- Record progress and blockers in durable files.
- Re-plan whenever new findings change the priority order.
- Do not stop at an outline, preliminary findings, or partial analysis.
- Stop only for a true hard blocker or when the final objective is fully complete and verified.
```

## Short Trigger Phrases

Use phrases like these to trigger the skill naturally:

- "Treat this as a long-running task and keep going until the final goal is complete."
- "Do not stop at partial progress. Keep iterating until the real end state is done."
- "Create a durable task map and keep executing until everything required is verified."
- "Work this like a multi-session autonomous project, not a one-shot task."
