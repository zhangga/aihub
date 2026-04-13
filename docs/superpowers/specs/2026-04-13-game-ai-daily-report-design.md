# Game AI Daily Report Design

Date: 2026-04-13
Status: Proposed
Owner: Codex

## Summary

This document proposes a new first-party skill named `game-ai-daily-report` for the `aihub` repository.

The skill should help generate a daily deep-dive report about the intersection of games and AI. The report should prioritize formal sources such as company blogs, product announcements, conference updates, media reporting, and official statements, then use X discussion as a high-visibility heat and reaction layer that meaningfully shapes report ordering and analysis.

The skill should support three usage properties from the start:

- manual invocation, such as "give me today's game x AI daily report"
- future automation compatibility, so the same report workflow can run on a schedule without redesigning the output contract
- bilingual file output compatibility, so each run can save matching Chinese and English Markdown reports to predictable relative paths

The scope explicitly includes two sub-domains:

- game companies using AI
- AI companies building game or interactive entertainment products

## Goals

- Create a reusable skill for producing a daily "game x AI" report with a stable structure
- Keep the report focused on high-signal developments rather than generic AI or gaming news
- Prefer formal sources and use X as the main heat-check channel
- Make the output useful for strategic tracking, not just link aggregation
- Keep the skill lightweight enough for manual use while shaping it for later automation
- Fit the repository's existing `local-skills -> skills/update.sh -> skills/` distribution model
- Save each generated report to `docs/game-ai-daily-reports/YYYY-MM-DD-game-ai-report.zh.md` and `docs/game-ai-daily-reports/YYYY-MM-DD-game-ai-report.en.md` relative to the current working directory

## Non-Goals

- Building a full crawler or standalone news aggregation product in v1
- Covering the entire game industry or entire AI industry without an intersection filter
- Treating X chatter as a replacement for formal-source validation
- Solving push delivery, database storage, or analytics dashboards in the first release
- Adding heavy scripts before the report workflow has been proven through repeated real use

## User Intent and Triggering

The skill should trigger when the user wants a recurring or on-demand report about the convergence of games and AI. Typical requests include:

- "Give me today's game x AI daily report"
- "Summarize the latest gaming and AI convergence news"
- "What happened in game AI in the last 3 days?"
- "Track how game companies are using AI this week"
- "Find recent news about AI companies making game products"

The skill should not trigger for:

- generic AI industry news without a game angle
- generic gaming news without an AI angle
- unrelated technical implementation tasks
- broad stock, weather, or code-generation requests

## Recommended Approach

Implement `game-ai-daily-report` as a workflow-first local skill with a concise `SKILL.md` and a small set of focused reference files.

The skill should define:

- what counts as "game x AI"
- which source classes are preferred
- how to collect and filter candidate items
- how to validate heat or relevance with X discussion
- how to render a stable daily report
- how to save the final bilingual reports to disk

The first version should avoid mandatory scripts. It should lean on the agent's browsing and existing repo capabilities, including reuse of `sensight`-style social discovery patterns where helpful, while keeping the workflow explicit enough that later automation can call the same steps with a date parameter and save to a deterministic relative file path.

## Architecture

The skill should use a two-layer design.

### Layer 1: Workflow contract

Defined in `SKILL.md` plus references. Responsible for:

- trigger recognition
- topic boundary enforcement
- source prioritization
- report assembly rules
- quality checks before output
- bilingual file output behavior

### Layer 2: Information gathering

Performed by the agent at runtime. Responsible for:

- finding formal-source candidates
- collecting X heat evidence and supporting social context when needed
- dropping low-signal or weakly sourced items
- composing the final report using the fixed template
- saving the final bilingual reports to disk

This split keeps the skill reusable and avoids prematurely hard-coding a data pipeline.

## Scope Definition

The skill should only include items that sit meaningfully at the overlap of games and AI.

### In scope

- game companies adopting AI in development, content pipelines, live ops, localization, testing, voice, NPC behavior, or UGC tooling
- AI companies launching game, simulation, interactive media, or player-facing entertainment products
- partnerships between AI firms and game platforms or studios
- regulatory, platform, labor, or creator-economy developments that materially affect game x AI adoption
- funding, acquisitions, or product launches when the game x AI link is explicit

### Out of scope

- generic model launches with no gaming angle
- generic game releases with no AI angle
- low-credibility rumor threads with no formal source support
- fan speculation that does not change market or product reality

## Report Structure

The default report should use the following sections in order:

1. `Today in Brief`
2. `Formal Signal`
3. `X Heat Check`
4. `Game Companies Using AI`
5. `AI Companies Building Game Products`
6. `What To Watch Next`
7. `Saved Report`

Section rules:

- `Today in Brief` should summarize the most important changes in 3 to 5 bullets
- `Formal Signal` should contain only formally supported facts
- `X Heat Check` should be a major analytical section that explains whether the market is paying attention, who is driving the conversation, and where the disagreement sits
- the two domain sections should group items by sub-domain rather than by source
- `What To Watch Next` should list 2 to 4 forward-looking observations or follow-up questions
- `Saved Report` should state the file path or a save failure

## Candidate Selection Workflow

Each report run should follow the same sequence:

1. Resolve report window, defaulting to the last 3 days for daily mode
2. Search formal sources first
3. Build a candidate list of possible items
4. Filter candidates using the game x AI boundary
5. Score each remaining item
6. Use X discussion to validate heat, controversy, and reaction, and to elevate the relative priority of qualified items
7. Keep the top items that produce a coherent report
8. Render the report in the fixed section order
9. Save the Chinese and English reports to deterministic relative file paths

## Scoring Model

Each candidate item should be scored on five dimensions:

- `relevance`: how directly it sits at the game x AI intersection
- `credibility`: how strong and formal the sourcing is
- `impact`: how important it appears for industry behavior, product direction, or platform strategy
- `novelty`: whether it adds genuinely new information versus repeating ongoing chatter
- `x_heat`: how much meaningful X discussion, spread, or disagreement the item is generating

Recommended interpretation:

- include only items with strong relevance and acceptable credibility
- use impact and X heat to rank items inside the report
- use novelty as a tie-breaker
- allow X-led weakly confirmed topics only inside `X Heat Check`

## Source Strategy

The source strategy should be intentionally asymmetric.

### Primary sources

- official company blogs
- product announcements
- conference talks or event posts
- developer platform updates
- press releases
- executive statements in credible publications
- established gaming and AI trade media

### Heat and secondary sources

- X or Twitter discussion
- Reddit
- Weibo
- YouTube creator commentary
- other public discussion venues where practitioner reaction is visible

X should be the default heat lens. Secondary social sources should answer questions like:

- Is this item attracting unusual attention?
- Are developers, creators, or players reacting positively or negatively?
- Is there disagreement between official positioning and market reaction?

## Skill Package Structure

The skill should live under:

`local-skills/game-ai-daily-report/`

Initial package contents:

- `SKILL.md`
- `scripts/save_reports.py`
- `references/topic-boundary.md`
- `references/source-map.md`
- `references/report-template.md`
- `references/scoring-rules.md`
- `agents/openai.yaml`

### File responsibilities

`SKILL.md`

- keep concise
- define triggers, workflow order, and output expectations
- tell the agent which reference file to open for specific decisions
- define the save-to-file behavior

`scripts/save_reports.py`

- save the Chinese and English Markdown reports to deterministic relative paths
- create the target directory when missing
- overwrite the same day's files cleanly
- return machine-readable success output for automation

`references/topic-boundary.md`

- define in-scope and out-of-scope patterns
- include borderline examples so filtering stays consistent

`references/source-map.md`

- list source categories and representative source types to check first
- separate formal sources from X and supporting social validation sources

`references/report-template.md`

- define the final Markdown structure
- standardize tone, section order, and per-item formatting
- define the bilingual saved-report footer and language-alignment rules

`references/scoring-rules.md`

- define the five scoring dimensions
- give practical keep-or-drop guidance

## Distribution Plan

The skill should be added as a local first-party source in:

`skills/registry.tsv`

Expected row:

```tsv
game-ai-daily-report	local	local-skills/game-ai-daily-report
```

After creation, the normal sync flow should be:

```bash
bash skills/update.sh --skip-submodule-update
```

This matches the repository's existing mirror-and-distribute model.

## Output Contract

The report output should be Markdown-first and automation-friendly.

Required properties:

- deterministic section order
- concise headline plus supporting explanation per item
- explicit source attribution in prose or link form
- date window included near the top
- stable formatting that can later be reused by scheduled automations
- deterministic bilingual save paths relative to the current working directory

Recommended per-item format:

- headline
- why it matters
- source summary
- optional X reaction note when relevant

## Error Handling

The skill should fail gracefully when signal is weak.

Expected cases:

- not enough high-quality items in the selected time window
- strong X heat but weak formal confirmation
- formal-source item exists but has weak or no visible market reaction
- duplicate stories from multiple publications

Behavior:

- prefer a shorter, high-confidence report over a long noisy one
- explicitly note when an X trend lacks formal confirmation
- collapse duplicates into one entry with the strongest source
- if the window is too sparse, widen slightly and say so clearly
- if save-to-file fails, still return the short Chinese summary and state the language-specific error

## Testing Strategy

Validation should happen at two levels.

### Skill package validation

- run the skill validator on the folder
- confirm frontmatter, naming, and required files are valid

### Behavioral validation

Use the skill on real prompts such as:

- today's game x AI report
- game companies using AI this week
- AI companies entering gaming in the last 7 days

Success criteria:

- output stays within the game x AI boundary
- formal sources clearly lead the report
- X heat meaningfully shapes ordering and analysis without overriding formal-source gating
- the structure is stable across repeated runs
- the report remains useful for both manual reading and future automation
- the Chinese and English reports are saved to the expected relative paths

## Implementation Phases

### Phase 1: Workflow skeleton

- create the skill folder
- write `SKILL.md`
- add the four reference files
- add `agents/openai.yaml`
- register the skill in `skills/registry.tsv`

### Phase 2: Validation and trial use

- run package validation
- test with several realistic prompts
- tighten boundary and scoring rules based on observed drift

### Phase 3: Optional hardening

- add helper scripts only if repeated manual use exposes real repetition
- optionally connect the skill to a scheduled automation using the same output contract

## Open Decisions Already Resolved

- report shape: deep daily report
- source policy: formal sources first, X as the default heat lens
- topic coverage: both "game companies using AI" and "AI companies building game products"
- usage model: support manual invocation now, preserve automation compatibility
- file output: save to `docs/game-ai-daily-reports/YYYY-MM-DD-game-ai-report.zh.md` and `.en.md` relative to cwd
- v1 implementation: workflow-first, not script-heavy

## Residual Risks

- the game x AI boundary may still drift without enough examples in `topic-boundary.md`
- over-reliance on X reaction could sneak back in if the workflow wording is weak
- some days may have too little signal for a dense daily report, requiring explicit sparse-day behavior
- future automation will still need scheduling and destination choices outside the skill itself

## Acceptance Criteria For This Design

This design is complete when the resulting skill:

- is implemented as a local first-party skill under `local-skills/`
- produces a structured daily deep-dive report about game x AI developments
- prioritizes formal sources and uses X as the primary heat and reaction layer
- covers both major sub-domains in separate sections
- is usable manually today and shaped for scheduled automation later
- saves Chinese and English reports to the expected relative paths
- fits the repository's existing sync and distribution workflow
