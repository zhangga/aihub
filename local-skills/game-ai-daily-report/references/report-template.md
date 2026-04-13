# Report Template

Use this Markdown structure for the final reports.

## Header

Start with:

```md
# Game x AI Daily Report

Window: <absolute date/time window>
```

If the window was widened because signal was sparse, say so immediately below the window line.

## Section Order

Always use this order:

1. `## Today in Brief`
2. `## Formal Signal`
3. `## X Heat Check`
4. `## Game Companies Using AI`
5. `## AI Companies Building Game Products`
6. `## What To Watch Next`
7. `## Saved Report`

## Today In Brief

Write 3 to 5 bullets.

Each bullet should answer:

- what happened
- why it matters

Keep this section fast to scan.

## Formal Signal

Use this section for formally supported facts only.

For each item, use:

```md
### <short headline>

Why it matters: <1-2 sentences>

Source: <strongest formal source and what it confirms>

X signal: <short note on whether the story is hot, quiet, or divided on X>
```

## X Heat Check

This is a major section, not a throwaway appendix.

Use it to explain:

- which stories are clearly breaking out on X
- which accounts or communities are driving the discussion
- where the conversation is supportive, skeptical, or polarized
- where X is ahead of formal confirmation

For an item driven by X discussion but lacking strong formal confirmation, use:

```md
### <short headline>

Observed on X: <what is being discussed>

Why it matters: <why this conversation is worth watching>

Confidence: <state clearly whether formal confirmation is weak or missing>
```

## Domain Sections

For the two domain sections, use this item format:

```md
### <short headline>

Why it matters: <1-2 sentences>

Source: <strongest formal source and what it confirms>

Heat check: <optional short note about reaction or lack of reaction>
```

Rules:

- lead with the strongest formal source
- add `Heat check` only when it adds something beyond the main `X Heat Check` section
- collapse duplicate coverage into one item

## What To Watch Next

List 2 to 4 follow-up items, such as:

- likely next announcements
- unresolved questions
- signals worth checking tomorrow

## Saved Report

Always end with:

```md
Saved to:
- docs/game-ai-daily-reports/YYYY-MM-DD-game-ai-report.zh.md
- docs/game-ai-daily-reports/YYYY-MM-DD-game-ai-report.en.md
```

If one or both file outputs fail, replace the affected line with:

```md
Save failed: <language>: <reason>
```

## Sparse-Day Variant

If there are too few high-confidence items:

- keep the same section order
- shorten the middle sections
- explicitly say the window was light rather than filling the report with weak items

## Language Rules

- Render one full Chinese report and one full English report.
- Keep facts, ordering, and conclusions aligned across both languages.
- Use Chinese only for the short chat summary outside the saved files.
