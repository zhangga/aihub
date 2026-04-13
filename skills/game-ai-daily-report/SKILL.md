---
name: game-ai-daily-report
description: Create a formal-source-first daily report about the intersection of games and AI. Use when Codex needs to summarize the latest game x AI developments, such as game companies adopting AI, AI companies building game or interactive entertainment products, partnerships, tooling shifts, or policy changes affecting game x AI. Prefer official announcements, company blogs, conference updates, and credible trade media, then use X discussion as the main heat and reaction layer. X heat should meaningfully shape report ordering and analysis, but it must not replace formal-source validation.
---

# Game AI Daily Report

## Overview

Use this skill to produce a structured daily or recent-period report about game x AI developments. Lead with formal sources, then use X discussion as the default heat and reaction lens. Favor a shorter, high-confidence report over a noisy roundup.

## Workflow

1. Resolve the report window.
2. Gather candidate items from formal sources first.
3. Filter candidates against [references/topic-boundary.md](references/topic-boundary.md).
4. Rank and trim them with [references/scoring-rules.md](references/scoring-rules.md).
5. Build a strong X-focused heat analysis for the shortlisted items.
6. Render the report with [references/report-template.md](references/report-template.md).
7. Save the final Markdown reports to two files in the current working directory.

## Resolve The Window

Default to the last 3 days for requests like "today" or "daily report."

Use broader windows only when the user asks for them, such as:

- "this week"
- "last 7 days"
- "recent"

If the window is sparse, widen it slightly and say so explicitly in the report.

## Gather Formal Sources First

Start with:

- official company blogs and product pages
- conference or event announcements
- developer platform updates
- press releases
- executive interviews in credible publications
- established game and AI trade media

Use [references/source-map.md](references/source-map.md) when you need source ideas or want to balance coverage across sub-domains.

Do not start with X chatter unless the user explicitly asks for an X-first view.

## Filter For True Game x AI Overlap

Before keeping any item, check whether it meaningfully sits at the overlap of games and AI.

Read [references/topic-boundary.md](references/topic-boundary.md) before finalizing the candidate list.

Drop:

- generic AI launches with no game angle
- generic game news with no AI angle
- rumor threads with no credible supporting source
- repeated stories that add no new information

## Use X As The Main Heat Lens

Use X to answer questions like:

- Is this item attracting unusual attention?
- Are developers, creators, or players reacting strongly on X?
- Is there visible disagreement between official framing and market reaction?
- Which accounts, communities, or audience segments are driving the conversation?

X heat should not replace formal sourcing, but it should meaningfully affect how the report is ordered and discussed.

Use these rules:

- a formally confirmed item with strong X discussion should move up in report priority
- a formally confirmed item with weak X discussion can stay in the report, but usually lower down
- a highly discussed X topic with weak formal confirmation belongs in `X Heat Check`, not in the core fact section

If `sensight` is available in the environment, use it as an accelerator for X and social heat checks. If not, browse manually.

Other social platforms can still be used, but X should be treated as the default heat source unless the user asks for a different platform.

## Write The Report

Always write the report in the section order defined in [references/report-template.md](references/report-template.md):

1. `Today in Brief`
2. `Formal Signal`
3. `X Heat Check`
4. `Game Companies Using AI`
5. `AI Companies Building Game Products`
6. `What To Watch Next`
7. `Saved Report`

Generate:

- one complete Chinese report
- one complete English report
- one short Chinese chat summary

The Chinese and English reports must use the same facts, ranking, and conclusions. They differ only by language.

Per item, explain:

- what happened
- why it matters
- what the strongest source says
- what the X reaction signal looks like, if useful

Keep attribution visible. Do not dump raw links without explanation.

## Save The Report To Disk

Always save the final Markdown reports relative to the current working directory.

Prefer the helper script:

```powershell
python scripts/save_reports.py `
  --date YYYY-MM-DD `
  --zh-file <path-to-chinese-markdown> `
  --en-file <path-to-english-markdown> `
  --output-root .
```

The script writes into `docs/game-ai-daily-reports/` under the provided output root.

Required output targets:

- directory: `docs/game-ai-daily-reports/`
- Chinese filename: `YYYY-MM-DD-game-ai-report.zh.md`
- English filename: `YYYY-MM-DD-game-ai-report.en.md`

Behavior:

- create the directory if it does not exist
- overwrite the same day's files if they already exist
- return only a short Chinese summary in chat, not the full bilingual reports
- add final lines in the response for each file path or failure

If saving fails:

- still return the Chinese summary in chat
- report Chinese and English save results separately

## Quality Bar

Prefer:

- 3 to 6 strong items over 10 weak ones
- direct source support over second-hand summaries
- concise synthesis over link aggregation

Explicitly note uncertainty when:

- formal confirmation is weak
- X reaction is strong but evidence is thin
- multiple publications are recycling the same story

## Example Requests

- "Give me today's game x AI daily report."
- "Summarize the latest week of game companies using AI."
- "What happened in game x AI over the last 7 days?"
- "Track AI companies moving into gaming this week."

## Chat Summary Format

When replying in chat, keep it short and in Chinese.

Include:

- the date window
- 3 to 5 core observations
- one overall judgment sentence
- the saved Chinese and English file paths, or separate save failures
