# Harness Pattern

This skill is based on a long-running agent harness pattern for work that spans many context windows.

Core ideas:

- separate the first setup session from later execution sessions
- create durable artifacts that future sessions can read quickly
- convert a vague goal into explicit, testable acceptance criteria
- work incrementally instead of attempting the entire objective at once
- verify before declaring progress complete
- leave the environment clean at the end of every session

Common failure modes this harness is designed to prevent:

1. One-shotting the entire project and leaving half-finished work
2. Declaring the project complete too early
3. Forgetting what happened in earlier sessions
4. Marking tasks done without proper verification
5. Leaving the next session to rediscover how to start the environment

The harness solves these by requiring:

- a structured task map
- progress notes
- a next-step handoff
- blocker tracking
- baseline verification at the start of each session
- incremental, verifiable progress

Use this pattern whenever the user wants uninterrupted progress toward a complex end state and the task is too large or too risky to trust to a single uninterrupted reasoning window.
