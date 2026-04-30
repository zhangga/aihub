# Codebase Architecture Overview

This document gives AI agents, code editors, and developers a concise map of the `aihub` repository: what it stores, which files are authoritative, and how generated distribution assets are refreshed.

## 1. Project Overview

`aihub` is a centralized knowledge and asset repository. It is not a traditional runtime application. Its purpose is to collect, manage, and redistribute AI tools, prompts, MCP installers, and agent skills for reuse across LLM and agent workflows.

The repository is organized around these main domains:

* **External Submodules (`/external/`)**: Third-party Git repositories managed with `git submodule`. These are only used for the smaller set of upstream skills that still need to be mirrored into this repository.
* **Local Skills (`/local-skills/`)**: First-party skills authored and maintained in this repository.
* **Skills (`/skills/`)**: The generated skill distribution folder. It contains mirrored skill packages, proxy install registries, bundles, and the remote installers consumed by downstream users.
* **MCP (`/mcp/`)**: Registry-driven MCP server installers and docs for Codex, Claude Code, Claude Desktop, and VS Code.
* **Prompts (`/prompts/`)**: Markdown prompt templates and agent instruction templates intended for direct LLM ingestion.
* **Docs (`/docs/`)**: Supporting design notes, reusable project templates, and drafts.

## 2. Skill Source Model and Syncing

The skill distribution flow is manifest-driven. Do not manually copy skill code into `/skills/` unless you are intentionally changing generated output.

Supported skill source types:

* **`submodule`**: mirror a skill from a repository under `/external/`
* **`local`**: mirror a skill from `/local-skills/`
* **`proxy`**: keep only an install command and delegate installation directly to the upstream repository

Authoritative files:

* `skills/registry.tsv`: mirrored `submodule` and `local` skills
* `skills/proxy_registry.tsv`: proxy-installed skills
* `skills/bundles.tsv`: user-facing skill bundles
* `skills/skills_list.txt`: generated full install list
* `skills-lock.json`: generated lock metadata for all skills

Developer workflow:

1. Add or update mirrored skills in `skills/registry.tsv`, or proxy skills in `skills/proxy_registry.tsv`.
2. Run `bash skills/check-registry.sh` to validate registry shape, duplicate names, source paths, and bundle references.
3. Run `bash skills/update.sh` to update submodules, mirror skills, remove stale proxy copies, and regenerate `skills/skills_list.txt` plus `skills-lock.json`.
4. If submodules have already been updated, or the environment should avoid network access, run `bash skills/update.sh --skip-submodule-update`.

## 3. Skill Remote Installation

The skill installers are designed for one-command use from raw GitHub URLs.

* **Linux / macOS / WSL**: `skills/install.sh`
* **Windows PowerShell**: `skills/install.ps1`

Install modes:

* **Full install**: fetches `skills/skills_list.txt` from `main` and installs every listed skill.
* **Bundle install**: fetches `skills/bundles.tsv`, resolves one or more bundle names, and installs the resulting skill set.
* **Project or global scope**: defaults to project-local installation; `--global` or `AIHUB_SCOPE=global` switches to global installation.
* **Proxy-aware install**: if a skill exists in `skills/proxy_registry.tsv`, the installer executes the registered upstream command instead of installing from `zhangga/aihub`.
* **npm compatibility**: installers sanitize the user npm config at runtime to avoid `prefix` conflicts that can break `npx`.

Useful installer flags and environment overrides are documented in `skills/README.md`.

## 4. MCP Distribution

The `mcp/` directory distributes runnable MCP servers and writes client configuration.

Authoritative files:

* `mcp/registry.tsv`: server runtime, package source, default args/env, and supported clients
* `mcp/bundles.tsv`: server bundle presets
* `mcp/install.sh`: Bash installer
* `mcp/install.ps1`: PowerShell installer

Current installers support:

* `--client <codex|claude-code|claude-desktop|vscode>`
* `--server <name>` or `--bundle <name>`
* `--arg <value>` for server arguments
* `--env KEY=VALUE` for server environment variables
* `--dry-run`, `--list-servers`, and `--list-bundles`

MCP install scope is currently user-global configuration only. See `mcp/README.md` for examples and client-specific notes.

## 5. Code Style and Standards

* **Bash scripts (`.sh`)**
  * Must include `set -e`.
  * Must remain compatible with standard UNIX environments and Windows WSL.
* **PowerShell scripts (`.ps1`)**
  * Must use `$ErrorActionPreference = "Stop"`.
  * Must support default Windows execution-policy workflows through `iex` or `pwsh -File`.
* **Markdown prompts and docs**
  * Must remain modular and self-contained.
  * Avoid embedding secrets, local-only paths, or assumptions that downstream users cannot reproduce.

## 6. Security Considerations

* **Upstream code execution**: mirrored skills copy code from external submodules, and proxy skills execute upstream install commands directly. Maintainers must verify third-party repositories or commands before adding them to `.gitmodules`, `skills/registry.tsv`, or `skills/proxy_registry.tsv`.
* **MCP server execution**: MCP installers configure local clients to run server commands. Treat every MCP server entry as executable code and review `mcp/registry.tsv` before broad rollout.
* **Data protection**: do not commit API keys, tokens, personal data, or private project context in prompts, skills, docs, registries, or generated lock files.

## 7. Validation

Before submitting changes that touch skills, registries, installers, or generated artifacts:

1. Run `bash skills/check-registry.sh`.
2. Run `bash skills/update.sh --skip-submodule-update` unless you intentionally need to refresh submodules.
3. Run `python -m json.tool skills-lock.json` if Python is available.
4. Confirm `git diff -- skills skills-lock.json` only contains intentional generated changes.

GitHub Actions runs the same registry validation and generated-file drift checks for skill distribution changes.
