---
name: women-ai-topic-radar
description: Turn the hottest AI discussions from the last 3 days into a topic-meeting brief for women-focused growth creators. Use when Codex needs to scan Xiaohongshu, Weibo, WeChat official accounts, and X/Twitter for AI-related social buzz, then filter, rank, and translate it into practical content opportunities for creators covering women's growth, family life, parenting, self-improvement, work, emotional wellbeing, or lifestyle change.
---

# Women AI Topic Radar

## Overview

Use this skill to turn social-first AI trend discovery into a usable topic-meeting brief for creators who write for women, family, parenting, and personal growth audiences.

Prefer a concise, decision-ready report over a noisy pile of links. The output should help a creator decide what to write now, what to watch, and what to ignore.

## Workflow

1. Resolve the time window and creator lens.
2. Gather social signals across the four default platforms.
3. Filter candidates through [references/audience-lens.md](references/audience-lens.md).
4. Score them with [references/scoring-rules.md](references/scoring-rules.md).
5. Expand each surviving topic with [references/topic-angles.md](references/topic-angles.md).
6. Write the final brief with [references/report-template.md](references/report-template.md).
7. Save the final report under the current working directory in `docs/women-ai-topic-radar/`.

## Resolve The Brief

Default to the last 3 calendar days.

If the user says "today," "recent," or "latest" without a range, still use the last 3 days unless they clearly want a single-day snapshot.

Default audience lens:

- women-focused growth creators
- adjacent family and parenting relevance when it naturally appears
- practical consumer-facing implications over technical novelty

Default deliverable:

- Simplified Chinese
- formatted like a topic-meeting handout for public-account and Xiaohongshu planning

## Gather Social Signals First

Use [references/source-playbook.md](references/source-playbook.md) to cover:

- Xiaohongshu for life, productivity, and identity-level conversation
- Weibo for breakout events, controversy, and mass attention
- WeChat official accounts for explainers, opinionated essays, and creator framing
- X or Twitter for upstream product launches and early practitioner reaction

If `sensight` is available in the environment, use it as the main accelerator:

- run `daily_social` for each of the last 3 dates to build the candidate pool
- run `social_search` when you need platform-specific follow-up inside the last 2 days
- run `search_events` or `retrieve_summarize` only to confirm context around a major AI topic

If `sensight` is not available, browse manually and keep attribution explicit.

## Filter For Creator Relevance

Do not keep a topic just because it is popular in AI circles.

Before finalizing the shortlist, read [references/audience-lens.md](references/audience-lens.md) and keep only topics that can be translated into at least one of these outcomes:

- a strong content angle for women-focused growth creators
- a useful personal, family, parenting, education, or career implication
- a visible tension, anxiety, or aspiration that creators can interpret for their audience

Drop:

- purely technical model benchmarks with no lifestyle or audience consequence
- funding or hiring news with no clear creator-side hook
- repetitive commentary that only restates a launch without fresh reaction

## Score And Rank

Read [references/scoring-rules.md](references/scoring-rules.md) before trimming the list.

Score each candidate for:

- social heat
- audience fit
- content yield
- platform fit
- freshness

Treat risk as a veto or downgrade, not a popularity boost.

Prefer:

- 5 to 8 strong topics in the total brief
- 3 high-priority topics for immediate follow-up
- cross-platform resonance over single-platform noise

## Expand Into Topic Angles

For each shortlisted topic, use [references/topic-angles.md](references/topic-angles.md) to convert the raw story into creator-ready framing.

Per topic, usually include:

- what happened
- why it is getting attention
- why women-focused growth audiences would care
- 2 to 4 writing angles
- one public-account direction
- one Xiaohongshu direction
- risk notes and overclaim warnings

Do not force every topic into parenting or motherhood. Only use that lens when the fit is real.

## Write The Final Brief

Always render the report using [references/report-template.md](references/report-template.md).

If the user wants something that reads like an internal planning deck, editorial handout, or topic-meeting memo, switch to [references/editorial-meeting-template.md](references/editorial-meeting-template.md).

If you want a concrete tone and structure reference before drafting, read [references/example-editorial-output.md](references/example-editorial-output.md).

If the user wants a standard analysis brief, read [references/example-standard-output.md](references/example-standard-output.md) for tone and structure.

If the user wants a faster, Xiaohongshu-first planning memo, switch to [references/xiaohongshu-meeting-template.md](references/xiaohongshu-meeting-template.md).

If you need help deciding whether the request should trigger this skill, read [references/trigger-phrases.md](references/trigger-phrases.md).

## Save The Report

Always save the final deliverable to a relative path under the current working directory:

- `docs/women-ai-topic-radar/`

Do not save to an absolute path unless the user explicitly overrides the location.

If the directory does not exist, create it.

Use a filename that reflects the report style and date window, for example:

- `docs/women-ai-topic-radar/2026-04-13-standard-report.md`
- `docs/women-ai-topic-radar/2026-04-13-editorial-meeting.md`
- `docs/women-ai-topic-radar/2026-04-13-xiaohongshu-meeting.md`

After writing the file, tell the user which relative path was created.

The final brief should help the user decide:

- what to write immediately
- what to keep watching
- what to skip

Use direct language, visible judgments, and concrete angle suggestions. Avoid generic summaries like "AI is changing life."

## Example Requests

- "整理最近 3 天 AI 热点，给泛女性成长号做选题会材料。"
- "做一份适合公众号和小红书的 AI 选题雷达，重点看最近三天社交平台热议。"
- "从小红书、微博、公众号、X 上找最热的 AI 话题，帮我判断哪些值得写。"
- "给女性成长类内容团队出一版 AI 热点选题分析。"
