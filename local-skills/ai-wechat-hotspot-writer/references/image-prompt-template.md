# Image Prompt Template

Use this reference to convert AI hotspots into long-image prompts for GPT Image 2 and Nano Banana 2.

## Prompt Package Structure

Produce:

1. `daily_cover_image`: one compact image that can sit below the `AI行业动态` heading.
2. `long_infographic`: one vertical long image summarizing the ranked hotspots.
3. `wechat_cover_or_lead_image`: one article cover or lead image for long-form mode.
4. Optional `single_topic_cards`: one prompt per high-priority hotspot.

## Daily Cover Image Defaults

Use this for `AI Daily News` mode:

- aspect ratio: `1:1` or `16:9`
- topic: the strongest 3-5 industry dynamics of the day
- text: short headline only, no dense paragraphs
- role: visual separator under `AI行业动态`, not a full infographic
- style: clean AI news cover, editorial, technology desk, readable Chinese title

Prompt shape:

```text
Create a clean Chinese AI news cover image for a daily digest.

Headline: <AI Daily News / date-specific title>
Subtext: <YYYY-MM-DD AI行业动态>
Key themes: <3-5 themes from the news list>

Canvas:
- 16:9 or 1:1
- modern editorial technology style
- readable Chinese typography
- no fake company logos
- no dense text

Visual metaphor:
- <model arena / agent control room / product radar / capital map / governance dashboard>

Constraints:
- Use only verified company/product names provided here: <names>
- Avoid exact numeric claims unless listed here: <numbers>
- Keep the image suitable for a public article.
```

## Long Image Defaults

Use these defaults unless the user specifies otherwise:

- aspect ratio: `9:16`
- target size: `1080x1920` or longer if the image tool supports it
- language: Simplified Chinese
- text density: medium, readable on mobile
- style: editorial tech magazine, clean information hierarchy
- avoid: tiny text, fake logos, real UI screenshots unless supplied by user

For WeChat long images, prefer:

- strong top title
- 3 to 7 visual panels
- one central trend map or timeline
- source labels as small footnotes
- clear contrast between "事实" and "判断"

## GPT Image 2 Prompt Shape

```text
Create a vertical Chinese editorial infographic for a WeChat article.

Topic: <article topic>
Time range: <date range>
Core message: <one-sentence judgment>

Canvas:
- 9:16 vertical long image, mobile-first, 1080x1920 or higher
- Chinese typography, large readable headings, no tiny paragraphs
- modern technology magazine design, precise hierarchy, high contrast

Content layout:
1. Hero title: <Chinese title>
2. Subtitle: <time range + short thesis>
3. <3-7 hotspot panels, each with title, one short label, one visual metaphor>
4. Bottom strip: "来源：<source labels>" and "整理：AI热点观察"

Visual direction:
- <color palette>
- <metaphors: network map, timeline, product radar, model arena, agent workflow, etc.>
- <mood>

Constraints:
- Keep all Chinese text legible.
- Do not invent company logos.
- Do not add unsupported numbers.
- Use clean icons instead of realistic brand marks.
- Leave enough whitespace.
```

## Nano Banana 2 Prompt Shape

Nano Banana 2 tends to work well with explicit composition and grounding constraints.

```text
Generate a polished vertical long-form infographic in Simplified Chinese.

Use case: WeChat public-account article illustration.
Aspect ratio: 9:16.

Main headline:
<headline>

Narrative:
<one paragraph describing the article's central trend>

Panel plan:
- Panel 1: <hotspot 1, visual metaphor, short text>
- Panel 2: <hotspot 2, visual metaphor, short text>
- Panel 3: <hotspot 3, visual metaphor, short text>
- Panel 4: <optional>
- Panel 5: <optional>

Design style:
- <specific visual style>
- <palette>
- editorial, premium, information-rich but not crowded
- crisp Chinese typography and clean layout grid

Accuracy constraints:
- Use only the company/product names provided here: <names>
- Do not create fake charts with exact numbers unless listed here: <numbers>
- Do not use real logos unless they are provided as references.
- If sources appear, render them as small text labels, not full URLs.
```

## Visual Directions By Topic Type

### Agent And Workflow Platforms

Use:

- control room
- always-on cloud workers
- workflow conveyor belt
- team of digital agents
- permission gates and approval checkpoints

### Model Releases

Use:

- model arena
- benchmark dashboard
- layered neural architecture
- launch timeline
- capability cards

### Image/Video Generation

Use:

- studio wall
- prompt-to-canvas pipeline
- comparison board
- multimodal creative workstation

### Funding And Company Strategy

Use:

- chessboard
- capital flow map
- company constellation
- strategic territory map

### Regulation And Safety

Use:

- governance dashboard
- traffic-light risk system
- shield and audit trail
- policy map

### Product Radar

Use:

- radar screen
- app shelf
- toolbox
- GitHub/Product Hunt leaderboard

## Prompt Quality Checklist

Before finalizing each prompt, verify:

- It includes the exact article thesis.
- It names only verified companies and products.
- It specifies Chinese text requirements.
- It describes layout, not just mood.
- It contains enough source labels for credibility.
- It avoids unsupported numeric claims.
