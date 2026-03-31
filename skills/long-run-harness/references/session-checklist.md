# Session Checklist

Run this checklist at the start of each execution session.

1. Confirm the working directory with `pwd`.
2. Read `progress.md`.
3. Read `next-step.md`.
4. Read `task-map.json`.
5. Read `blockers.md`.
6. Review recent git history if available.
7. Run `init.sh` if present.
8. Verify the baseline environment before introducing new changes.
9. Select the highest-priority unfinished item.
10. Work only on that item until it is either verified complete or clearly blocked.

Run this checklist at the end of each execution session.

1. Re-run the relevant verification.
2. Update the affected task item state.
3. Append a factual note to `progress.md`.
4. Rewrite `next-step.md`.
5. Update `blockers.md`.
6. Commit clean incremental progress if git is in use and the environment is stable.

If the final goal is complete, explicitly record that all acceptance criteria pass and no remaining unfinished required items exist.
