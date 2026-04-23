# Article Template

Use this structure for the final article package.

## Choose A Mode

Default to `daily_news`.

Use `wechat_longform` only when the user explicitly wants a long public-account essay, deep analysis, or title-driven article draft.

## Metadata

```markdown
# <main title>

时间范围：YYYY-MM-DD 至 YYYY-MM-DD
写作定位：<daily_news / wechat_longform / topic_selection>
覆盖渠道：<source families used>
一句话判断：<one sentence editorial judgment>
```

## Daily News Mode

Match this compact information-flow style:

```markdown
# AI Daily News

☀️ 说明
- 全文由 Codex 生成，更新时间：<time>，周期：<last 24h / weekend / date range>
- 新闻源：<source count or source families>，如需新增来源可继续补充

AI Daily News
Spring Product Insight：每日推送 AI 行业最重要的新闻 + 值得关注的产品

<YYYY-MM-DD or 一周重点新闻 |（MM.DD-MM.DD）>

## AI行业动态

[image placeholder or image prompt reference]

1. <headline>

<110-180 Chinese chars. Start with the source or actor. Explain what happened, why it matters, and any uncertainty. End with a source link label such as 更多.>

2. <headline>

...

## 今天值得关注的产品

🚀 Product Hunt Top 5

| 排名 | 产品 | 介绍 |
|---:|---|---|
| 1 | <product> | <short Chinese description> |

🔥 GitHub Trending Top 5

| 排名 | 项目 | 星级 | 介绍 |
|---:|---|---:|---|
| 1 | <repo> | 🌟+<stars> | <short Chinese description> |
```

Daily news item rules:

- Use 5-8 `AI行业动态` items for a daily digest.
- Use 8-12 items for a weekly digest.
- Each headline should be concrete and contain the key actor plus action.
- Each paragraph should be one compact paragraph, not bullets.
- Mention the source name at the beginning when useful: `OpenAI官方称`, `TechCrunch报道称`, `The Information称`.
- End each item with `更多` when a URL is available.
- Keep uncertainty visible: `据称`, `被曝`, `仍在谈判`, `尚未确认`.
- Do not add a separate analysis block under every item in daily mode.

## Title Options

Use this section only in `wechat_longform` or `topic_selection` mode.

Provide 6 to 10 title options.

Mix styles:

- news-summary title
- trend-judgment title
- question title
- conflict title
- practical-reader title

Avoid clickbait that overstates facts.

## AI速览

Use this section only in `wechat_longform`, or as an optional executive summary when the user asks for it.

Write 5 to 7 bullets.

Each bullet should combine:

- the event
- the bigger implication
- the source confidence when needed

Example shape:

```markdown
- OpenAI/Anthropic/Google continue moving from "chatbot" to "always-on agent platform"; the real competition is shifting toward workflow ownership.
```

## Main Article Structure

Use this section only in `wechat_longform` mode.

Use this article flow:

```markdown
## 开场：这几天 AI 圈真正变化的是什么

<2-4 paragraphs. Do not list everything. Set the main thesis.>

## 1. <Lead hotspot title>

发生了什么：
为什么热：
对普通读者/创作者/企业意味着什么：
我怎么看：
来源：

## 2. <Second hotspot title>

...

## 产品雷达：今天/本周值得关注的 AI 产品

| 排名 | 产品/项目 | 来源 | 一句话介绍 | 为什么值得看 |
|---|---|---|---|---|

## 本周期趋势判断

1. <trend>
2. <trend>
3. <trend>

## 结尾：下一步该关注什么

<Give a grounded forward-looking closing.>
```

## Source And Heat Table

Include a compact table after the article draft when the user asks for sources, scoring, or topic-selection evidence. For pure `daily_news`, source links embedded as `更多` are enough unless confidence is low.

```markdown
## 来源与热度表

| 热点 | 优先级 | 热度 | 可信度 | 核心来源 | 备注 |
|---|---:|---:|---|---|---|
```

Rules:

- Use source names plus links when possible.
- Mark `Low` confidence items clearly.
- Do not hide uncertainty in prose.

## WeChat Tone

Write like a sharp editor, not a database. For `daily_news`, keep it even more compressed and factual.

Use:

- clear topic sentences
- short paragraphs
- concrete company/product names
- "这说明什么" transitions
- direct but cautious judgments

Avoid:

- "重塑未来", "颠覆一切", "时代洪流" unless directly supported
- stacked jargon
- unexplained acronyms
- pretending social heat equals truth

## Short Chat Summary

When also replying in chat, keep it short:

```markdown
已整理 <date range> 的 AI 热点，核心判断是：<judgment>。

最值得写的 3 个方向：
1. ...
2. ...
3. ...

文件：
- <article path>
- <prompt path>
```
