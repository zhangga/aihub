# Scoring Rules

Use these rules to rank candidates and decide what to keep.

## Five Core Dimensions

Score each item from 0 to 3 on:

- `relevance`
- `credibility`
- `impact`
- `novelty`
- `x_heat`

## Dimension Definitions

### Relevance

- `3`: directly and clearly about the overlap of games and AI
- `2`: related to game x AI, but one side of the overlap is less central
- `1`: weak or indirect connection
- `0`: not meaningfully in scope

### Credibility

- `3`: official source or strong direct reporting
- `2`: credible second-hand reporting with clear sourcing
- `1`: mostly commentary or low-confidence sourcing
- `0`: rumor or unverifiable claim

### Impact

- `3`: likely to affect product direction, workflows, partnerships, or industry behavior
- `2`: meaningful but narrower in scope
- `1`: interesting but low practical consequence
- `0`: trivial

### Novelty

- `3`: genuinely new development or strong update
- `2`: adds useful new detail to an ongoing story
- `1`: mostly repetition
- `0`: stale or duplicative

### X Heat

- `3`: strong X discussion, fast spread, or clear viewpoint conflict
- `2`: visible and useful X discussion, but not dominant
- `1`: limited or niche X reaction
- `0`: little to no meaningful X signal found

## Keep Or Drop Rules

Drop an item if:

- `relevance < 2`
- `credibility < 2`
- it fails the boundary check in `topic-boundary.md`

Prioritize items with:

- strong `relevance`
- strong `credibility`
- combined score high enough to support a coherent report
- stronger `x_heat` when comparing otherwise similar qualified items

As a practical default:

- `12-15`: strong candidate
- `9-11`: include if it improves coverage balance
- `0-8`: usually drop

## Ranking Logic

Use three layers:

1. Gate on `relevance` and `credibility`.
2. Rank qualified items using `impact + x_heat`.
3. Use `novelty` to break ties.

This means X heat should noticeably shape ordering, but never override weak formal credibility.

## X-Led Observation Items

If X heat is strong but formal confirmation is weak:

- do not promote the topic into the core fact-driven section
- include it only in `X Heat Check`
- mark the confidence level explicitly
