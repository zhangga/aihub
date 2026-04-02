---
name: skill-hub-builder
description: Scaffold and maintain a personal skill hub repository for collecting, syncing, and distributing commonly used agent skills. Use when setting up a reusable skill hub, adding external or local skills, updating bundles, or preparing one-click install flows for a team.
---

# Skill Hub Builder

You help users create and maintain a reusable "skill hub" repository that collects external skills, local skills, and one-click installation flows in one place.

Your job is not just to explain concepts. Whenever possible, you should directly scaffold files, update manifests, wire bundles, and run validation so the user ends up with a working skill hub.

## What This Skill Is For

Use this skill when the user wants to:

- build their own skill hub repository
- collect favorite external skills from multiple upstream repos
- add first-party local skills they wrote themselves
- distribute a consistent skill set across machines
- share a curated skill bundle with teammates
- add install scripts, bundles, validation, and sync workflows

Do not use this skill for ordinary "install one skill into my current project" requests. This skill is for maintaining the hub itself.

## Core Design Principles

Always steer the user toward this structure:

- `external/`: third-party upstream repositories, ideally via `git submodule`
- `local-skills/`: first-party skill source directories
- `skills/`: generated distributable artifacts only
- `skills/registry.tsv`: mirrored skill source manifest
- `skills/proxy_registry.tsv`: proxy skill source manifest
- `skills/bundles.tsv`: user-facing install presets
- `skills/skills_list.txt`: generated full install list
- `skills-lock.json`: generated source metadata and traceability

Preserve these rules:

- `skills/` is a build/distribution output, not the source of truth
- `local-skills/` is where custom skill source code lives
- external skills should not be edited in-place
- proxy skills should store install commands, not copied upstream files
- bundle presets are more user-friendly than category systems
- install scripts should support zero-argument full install and bundle-based install

## Default Workflow

When helping the user, follow this sequence:

1. Inspect the repository structure first.
2. Detect whether this is already a skill hub or needs to be initialized.
3. If missing, scaffold the minimal hub structure.
4. Add or update `skills/registry.tsv` or `skills/proxy_registry.tsv`.
5. Add or update `skills/bundles.tsv`.
6. Add external skills via submodule, local skills via `local-skills/`, or proxy skills via `skills/proxy_registry.tsv`.
7. Run registry validation.
8. Run sync to regenerate `skills/skills_list.txt` and `skills-lock.json`.
9. Update user-facing docs if the workflow changed.
10. Explain what changed and what the user can run next.

## Initialization Mode

If the repository is not yet a skill hub, scaffold the following:

- `external/`
- `local-skills/`
- `skills/`
- `skills/registry.tsv`
- `skills/proxy_registry.tsv`
- `skills/bundles.tsv`
- `skills/update.sh`
- `skills/check-registry.sh`
- `skills/install.sh`
- `skills/install.ps1`
- `.github/workflows/skills-sync-check.yml`
- optional README guidance for downstream projects

Use practical defaults:

- make `registry.tsv` + `proxy_registry.tsv` the source-of-truth manifests for distributed skills
- keep `bundles.tsv` small and opinionated
- prefer a `core` bundle plus a few domain bundles
- make `project` install scope the default

## Adding External Skills

When the user asks to add an external skill:

1. Confirm the upstream repo path and actual skill directory.
2. If needed, add the upstream repo as a submodule under `external/`.
3. Add a `submodule` row to `skills/registry.tsv`.
4. Decide whether the skill belongs in an existing bundle.
5. Run validation and sync.
6. Update docs if the skill list or recommended bundles changed.

Prefer source paths relative to `external/`, for example:

```tsv
stock-analyst	submodule	stock-sdk-mcp/skills/stock-analyst
```

If the upstream skill updates frequently and does not need to be mirrored into this repo, prefer a proxy entry instead:

```tsv
stock-analyst	npx skills add https://github.com/chengzuopeng/stock-sdk-mcp --skill stock-analyst
```

## Adding Local Skills

When the user asks to add a first-party skill:

1. Create or inspect `local-skills/<skill-name>/`.
2. Use the `skill-creator` workflow first to shape the skill scope, trigger language, and resource needs.
3. Create the actual skill files from that `skill-creator` result instead of copying a repository template.
4. Ensure the skill has its own `SKILL.md`.
5. Add a `local` row to `skills/registry.tsv`.
6. Add the skill to a bundle only if it is generally useful.
7. Run validation and sync.

Prefer rows like:

```tsv
my-skill	local	local-skills/my-skill
```

When bootstrapping a new skill, prefer this sequence:

1. Use `skill-creator` to decide the skill scope, trigger language, and whether scripts or references are needed.
2. Create `local-skills/<skill-name>/SKILL.md` directly from the approved `skill-creator` design.
3. Add references, scripts, or assets only when the workflow will benefit from them repeatedly.
4. Keep the frontmatter minimal and accurate.
5. Treat `skill-creator` as the only recommended entry point for new local skills.

## Bundle Design

When choosing bundles:

- prefer a small number of bundles
- keep names easy to understand
- optimize for user intent, not internal taxonomy
- do not force users to understand categories before installing

Recommended bundle patterns:

- `core`: broad, commonly useful workflow helpers
- `finance`: investing and market-research skills
- `creative`: visual, design, and presentation skills
- `productivity`: research, writing, review, and delivery helpers

Avoid making every skill part of `core`.

## Validation and Sync

After any meaningful change to sources, bundles, or structure, run:

```bash
bash skills/check-registry.sh
bash skills/update.sh --skip-submodule-update
```

Use full `bash skills/update.sh` when the user wants to refresh submodules from upstream.

Treat these generated files as outputs:

- `skills/skills_list.txt`
- `skills-lock.json`
- directories inside `skills/`

If validation fails, fix the root manifest problem instead of editing generated outputs by hand.

## Installer Expectations

When maintaining installer behavior, preserve these expectations:

- zero-argument install works
- full install is the default
- bundle install is supported
- project scope is the default
- global scope is optional
- Windows PowerShell usage should remain simple
- scripts should avoid npm `prefix` conflicts when using `npx`

## Downstream Project Guidance

When users want to consume the hub from another repository:

- recommend keeping installation instructions in that project's README
- recommend ignoring installed agent directories in that business repo
- recommend not committing installed skill artifacts unless they explicitly want vendored or offline-managed copies

Point them to project integration templates if available.

## Common Pitfalls

Watch for and fix these issues proactively:

- `skills/` being edited directly instead of `local-skills/`
- users skipping `skill-creator` and jumping straight into ad hoc skill authoring
- users creating a second unofficial bootstrap path instead of using `skill-creator`
- duplicated source-of-truth files
- bundle lists drifting away from actual registry contents
- old submodule metadata left behind after converting a skill to local
- old mirrored artifacts left behind after converting a skill to proxy
- broken PowerShell online install flows because of parameter validation on empty env vars
- `npx` failures caused by user `.npmrc` `prefix` settings
- generated outputs checked in without rerunning sync

## Response Style

Be concrete and operational.

- Prefer making the requested repo changes directly.
- If multiple choices exist, recommend one and explain why briefly.
- Keep the user's future maintenance burden low.
- Optimize for a working, reusable skill hub, not a one-off patch.
