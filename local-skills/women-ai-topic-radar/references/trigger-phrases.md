# Trigger Phrases

Use this file as a reference for the kinds of user requests that should trigger this skill.

These are examples, not exact-match rules. Trigger when the user intent matches the pattern.

## Core Trigger Pattern

The user wants:

- recent AI热点
- social-platform heat
- translation into content opportunities
- an audience lens around women, family, parenting, education, self-growth, or lifestyle creators

## Strong Trigger Examples

- `整理最近 3 天最热的 AI 话题，给女性成长号做选题会材料`
- `帮我看这几天 AI 热点，哪些适合公众号写`
- `做一版适合小红书的 AI 选题会速览`
- `从微博、小红书、公众号和 X 找最近最火的 AI 讨论，转成内容选题`
- `给泛女性成长类创作者做一份 AI 热点分析`
- `帮我判断最近 AI 话题里哪些值得写，哪些不值得跟`
- `做一个女性向内容团队能直接开会用的 AI 热点 briefing`
- `整理最近几天 AI 社交平台热议，重点看内容创作角度`

## Family And Parenting Variants

- `帮我整理最近 3 天适合亲子教育号写的 AI 热点`
- `最近家长圈和 AI 有什么值得做的选题`
- `做一份家庭教育方向的 AI 热点选题分析`
- `从 AI 热点里筛和孩子、教育、家庭有关的内容机会`

## Platform-Specific Variants

### Public Account

- `做一版公众号选题会材料`
- `按公众号深写思路拆一下最近 AI 热点`
- `哪些 AI 话题适合做成公众号长文`

### Xiaohongshu

- `做一版小红书 AI 选题会速览`
- `最近哪些 AI 热点适合发小红书`
- `帮我把这几天的 AI 热点拆成小红书能发的内容`

## Signals That Strengthen Triggering

Trigger even more confidently when the request mentions:

- `最近 3 天`
- `热度最高`
- `社交平台热议`
- `选题会`
- `内容团队`
- `公众号`
- `小红书`
- `女性成长`
- `家庭`
- `亲子教育`

## Near Misses

Do not trigger by default for:

- generic AI news summaries with no creator lens
- pure stock, finance, or investment requests
- general-purpose AI explainers with no trend or topic-planning intent
- requests that are only about building prompts or writing code

## Disambiguation Guidance

If the user only asks for `最近 AI 热点`, but their surrounding context is clearly about content planning, creators, women, parenting, or platform strategy, go ahead and trigger this skill.

If the user asks for `AI 热点` but clearly wants pure news aggregation, use a more general news or research workflow instead.
