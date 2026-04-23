# Source Playbook

Use this playbook to gather AI hotspots with enough breadth for an AI Daily News-style digest or a WeChat article.

## Source Families

### 1. Primary AI Sources

Use these to verify facts:

- official company blogs and release notes
- product documentation and changelogs
- model cards, technical reports, benchmark pages
- conference keynotes and launch pages
- official GitHub repositories

Best for:

- product launches
- model releases
- pricing and access changes
- enterprise features
- safety, policy, and governance updates

### 2. Credible Media

Use these to add context:

- established tech and business media
- developer-focused publications
- industry newsletters with visible sourcing
- reputable Chinese AI media and public-account essays

Best for:

- financing and valuation stories
- strategy changes
- company competition
- regulatory context
- Chinese-language framing for public-account readers

### 3. Product And Developer Signals

Use these to identify "worth watching" products:

- Product Hunt
- GitHub Trending
- Hacker News
- Hugging Face trending spaces/models
- arXiv and Papers with Code
- developer community posts

Best for:

- new AI tools
- open-source projects
- model demos
- coding-agent workflows
- prompt, MCP, and automation ecosystems

### 4. Social Heat

Use these to estimate attention and debate:

- X/Twitter
- Weibo
- Xiaohongshu
- WeChat public accounts
- Reddit, Hacker News, Discord, or Telegram when relevant

Best for:

- visible enthusiasm or backlash
- community adoption
- creator packaging angles
- repeated questions and misunderstandings
- early signals before formal media coverage

## Collection Strategy

Start broad:

1. Collect candidate items from each source family.
2. Keep the original source URL or source name for every item.
3. Group duplicates into one topic.
4. Separate confirmed facts from interpretations.
5. Add social heat only after factual grounding.

Then tighten:

1. Remove low-signal minor updates.
2. Keep topics that connect to a larger trend.
3. Prioritize items that can support a WeChat narrative.
4. Preserve one or two product-discovery items if they are useful or surprising.

## Daily News Source Pattern

For `daily_news`, collect in three lanes:

1. `AI行业动态`: company launches, model releases, financing, regulation, security, enterprise AI, developer tools, and major ecosystem moves.
2. `Product Hunt Top 5`: AI or AI-adjacent products with one-line Chinese descriptions.
3. `GitHub Trending Top 5`: AI or developer projects with star delta and one-line Chinese descriptions.

For each `AI行业动态` item, keep:

- headline
- source name
- source URL
- one-paragraph summary
- uncertainty marker, if any
- category tag such as `model`, `agent`, `coding`, `image`, `funding`, `regulation`, `security`, `productivity`

For each product item, keep only enough to fill the table:

- rank
- product or repo name
- short Chinese description
- star delta for GitHub items when available

## Recommended Query Patterns

For a daily window:

- "AI product launch last 24 hours"
- "AI model release today"
- "AI agent workspace enterprise launch"
- "GitHub trending AI today"
- "Product Hunt AI today"

For a weekly window:

- "AI weekly roundup model releases agents coding image generation"
- "AI funding regulation product launches this week"
- "Claude OpenAI Gemini DeepSeek Qwen latest week"

For Chinese public-account framing:

- "最近 AI 行业动态"
- "AI 产品更新 本周"
- "大模型 发布 融资 监管 Agent"
- "AI 编程 Agent 热点"

## If Sensight Is Available

Use `sensight` for speed:

- `daily_social` for AI social pulse by date
- `retrieve_summarize` for deeper AI article summaries
- `social_search` for last-2-day platform-specific follow-up
- `search_events` for broader event discovery
- `model_sentiment` for model reputation and user reaction

Still verify important facts through primary or credible media sources before writing them as fact.

## Source Balance Rules

For each final article, aim for:

- at least 3 primary or official sources
- at least 2 credible media sources when the topic involves financing, strategy, or litigation
- at least 2 social/product trend sources for heat judgment
- no more than 30 percent of core facts based only on social chatter

For daily news digests, every numbered industry item should have a direct source URL whenever possible. Do not replace the `更多` link with a vague source list at the bottom.

## Attribution Format

Use compact source labels in the article:

- `OpenAI 官方博客`
- `Anthropic release notes`
- `The Information`
- `TechCrunch`
- `GitHub Trending`
- `Product Hunt`
- `X 社区讨论`

When a link is available, include it in the source table. When only a source name is available, mark it as `source name only`.
