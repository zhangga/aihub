---
name: ai-wechat-hotspot-writer
description: Collect recent AI hotspots from multiple channels, rank them by heat and writing value, then turn them into AI Daily News-style Chinese digests, WeChat public-account articles, product radar sections, source-backed topic lists, and image prompts for GPT Image 2 or Nano Banana 2. Use when Codex needs to write or plan AI news digests, AI weekly roundups, AI trend articles, AI product radar posts, WeChat articles, or image-prompt packages based on AI industry developments across the last few days or weeks.
---

# AI WeChat Hotspot Writer

## Overview

Use this skill to turn recent AI news and social heat into a publishable WeChat or Feishu-style article package.

Default output:

- an `AI Daily News`-style digest by default
- a ranked, source-backed AI industry list
- a product radar section for Product Hunt and GitHub Trending
- optional Chinese WeChat long-form expansion
- cover or long-image prompts for GPT Image 2 and Nano Banana 2
- saved Markdown files when working in a repository

## Workflow

1. Resolve the time window and article intent.
2. Choose the output mode: `daily_news` by default, `wechat_longform` only when requested.
3. Gather AI hotspots from multiple source channels.
4. Group duplicates and verify source reliability.
5. Score heat, credibility, writing value, and visual potential.
6. Draft the digest or article using [references/article-template.md](references/article-template.md); for the referenced AI Daily News format, also follow [references/daily-news-style.md](references/daily-news-style.md).
7. Generate image prompts using [references/image-prompt-template.md](references/image-prompt-template.md).
8. Check quality with [references/output-checklist.md](references/output-checklist.md).
9. Save outputs with `scripts/save_article.py` when a workspace is available.

## Resolve The Brief

Default language: Simplified Chinese.

Default article style: `daily_news`, modeled as a compact AI news feed rather than a long essay.

Use `wechat_longform` only when the user asks for a "公众号长文", "深度解读", "文章草稿", or a complete narrative essay.

Use `daily_news` when the user asks to match the referenced AI Daily News style, write a daily or weekly digest, or summarize hotspots quickly.

Default time windows:

- "today", "latest", "daily": last 24 hours
- "recent days", "最近几天": last 3 calendar days
- "this week", "最近一周": last 7 calendar days
- "recent weeks", "最近几周": last 14 calendar days unless the user specifies otherwise
- "monthly" or "last few weeks": last 28 calendar days

Always state the exact date range in the output. If the current date is required, verify it from the environment and use absolute dates.

## Gather Hotspots

Read [references/source-playbook.md](references/source-playbook.md) before collecting.

Cover at least four source families when available:

- official AI company and product announcements
- credible tech and business media
- product and developer trend sources
- social or community discussion sources

If `sensight` is available, use it as the accelerator for AI social pulse, semantic social search, article retrieval, and model sentiment. If it is not available, browse manually.

For OpenAI, Anthropic, Google, Microsoft, Meta, xAI, DeepSeek, Alibaba, Tencent, ByteDance, and other fast-moving AI companies, verify important launch or product claims against primary sources when possible.

## Rank And Select

Read [references/scoring-rules.md](references/scoring-rules.md) before ranking.

Prefer:

- 5 to 8 core hotspots for a normal article
- 8 to 12 items for a weekly roundup
- 3 to 5 "most worth writing" items when the user wants topic selection

Each kept item must have:

- what happened
- why it is hot
- source list with links or source names
- confidence level
- WeChat writing angle
- image-prompt potential

Do not inflate weak rumors. Put unconfirmed but socially hot items into "观察中" rather than the core factual section.

## Write The Article

Use [references/article-template.md](references/article-template.md).

For `daily_news`, required sections:

- title: `AI Daily News`
- optional note block: `☀️ 说明`
- date or weekly range heading
- `AI行业动态`
- optional image slot after the section heading
- numbered news items, each with one title and one compact paragraph ending with a source link label
- `今天值得关注的产品`
- `Product Hunt Top 5`
- `GitHub Trending Top 5`

For `wechat_longform`, also include:

- title options
- AI速览
- main article
- source and heat table
- 可配图热点
- image prompt package

Keep the writing readable:

- explain abbreviations on first use
- avoid empty grand claims
- explain why the reader should care
- distinguish fact, interpretation, and speculation

## Generate Long-Image Prompts

Use [references/image-prompt-template.md](references/image-prompt-template.md).

Create two prompt types:

- `daily_cover_image`: one compact image that can sit below `AI行业动态`
- `long_infographic`: a vertical long image summarizing 3 to 7 hotspots
- `wechat_cover_or_lead_image`: one strong cover for long-form public-account articles

Generate prompts for both GPT Image 2 and Nano Banana 2 unless the user asks for only one model.

Do not generate images unless the user explicitly asks to run an image-generation skill or tool. This skill primarily outputs prompts.

## Save Outputs

When working in a repository, save the final package under:

- `docs/ai-wechat-hotspot-writer/`

Prefer the helper script:

```powershell
python local-skills/ai-wechat-hotspot-writer/scripts/save_article.py `
  --date YYYY-MM-DD `
  --slug ai-weekly-hotspots `
  --article-file <article.md> `
  --prompts-file <image-prompts.md> `
  --output-root .
```

The script writes:

- `docs/ai-wechat-hotspot-writer/YYYY-MM-DD-<slug>.article.md`
- `docs/ai-wechat-hotspot-writer/YYYY-MM-DD-<slug>.image-prompts.md`

If saving is not useful, return the article and prompts directly in chat.

## Example Requests

- "用最近 3 天 AI 热点写一篇公众号文章，并给我长图提示词。"
- "整理最近两周 AI 行业动态，按热度排序，做成公众号选题。"
- "参考 AI Daily News 的形式，写一篇本周 AI 产品和行业热点公众号。"
- "把这些热点变成适合 GPT Image 2 / Nano Banana 2 的长配图提示词。"
- "给我一篇 AI 周报公众号，附来源和配图 prompt。"
- "按 AI Daily News 的样式生成今天的 AI 行业动态和产品榜。"
