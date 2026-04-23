# Scoring Rules

Score each candidate topic before choosing the article shortlist.

## Score Dimensions

Use a 0-5 score for each dimension.

### Heat

Measure visible attention.

- 5: cross-platform discussion, strong repost/comment velocity, or top ranking
- 4: visible attention in one major platform plus media follow-up
- 3: niche but active discussion among AI builders or creators
- 2: mentioned by a few sources but no clear debate
- 1: single source, little visible reaction
- 0: no current attention

### Credibility

Measure factual reliability.

- 5: official source or primary document
- 4: credible media with named source or clear documentation
- 3: multiple secondary sources but no primary confirmation
- 2: single secondary source
- 1: rumor, leak, or social screenshot
- 0: unverifiable

### Freshness

Measure recency inside the chosen window.

- 5: within the last 24 hours
- 4: within 2-3 days
- 3: within 4-7 days
- 2: within 8-14 days
- 1: older but newly resurfaced
- 0: outside the requested window with no new reason

### WeChat Writing Value

Measure whether the topic can become an article section.

- 5: has a clear reader-facing question, conflict, implication, or decision
- 4: strong trend signal that can support analysis
- 3: useful context but needs framing work
- 2: list-worthy but thin
- 1: too technical or too minor for general readers
- 0: not worth writing

### Visual Potential

Measure whether it can become a useful long-image panel.

- 5: can be turned into a clear visual metaphor, timeline, map, or comparison
- 4: has enough named actors and changes for an infographic
- 3: can become one simple card
- 2: mostly text, weak visual hook
- 1: abstract or legalistic
- 0: no visual value

## Total Score

Recommended weighted score:

```text
total = heat * 0.30 + credibility * 0.25 + freshness * 0.15 + writing_value * 0.20 + visual_potential * 0.10
```

Use the total score to rank, but do not let a hot rumor outrank a confirmed major launch unless it is clearly labeled as unconfirmed.

## Priority Labels

- `P0`: lead topic, use in title or opening
- `P1`: core article section
- `P2`: brief mention or product radar item
- `Watch`: interesting but not confirmed enough
- `Drop`: omit

## Veto Rules

Drop or downgrade when:

- no source can be verified
- the item is outside the requested time range
- the story is only a recycled version of an older item
- the item is too narrow for a WeChat reader
- the claim sounds like financial, medical, or legal advice without reliable support

## Source Confidence Labels

Use these labels in the source table:

- `High`: primary source or multiple credible sources
- `Medium`: credible secondary source, limited confirmation
- `Low`: social-only, leak-only, or unclear source chain

## Selection Targets

Daily article:

- 5 to 8 core items
- 3 to 5 product radar items
- 1 to 3 visual prompt candidates

Daily news digest:

- 5 to 8 `AI行业动态` items
- exactly 5 `Product Hunt Top 5` items when data is available
- exactly 5 `GitHub Trending Top 5` items when data is available
- no long per-item analysis blocks
- one optional image slot after `AI行业动态`

Weekly article:

- 8 to 12 core items
- 5 to 10 product radar items
- 3 to 7 visual prompt candidates

Topic-selection brief:

- 3 to 5 best topics
- 2 to 3 backup topics
- explicit "not worth writing" list
