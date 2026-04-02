# Codebase Architecture Overview

This document provides a high-level architecture overview of the `aihub` repository. It is designed to help AI agents, code editors, and developers quickly understand the project's purpose, structure, and synchronization mechanics.

## 1. Project Overview

The `aihub` project is not a traditional software application but a centralized knowledge and asset repository. Its primary purpose is to store, manage, and facilitate the reuse of AI tools, Prompts, and Agent Skills across different LLMs and Agent workflows.

The architecture is organized around five asset domains:
*   **External Submodules (`/external/`)**: Third-party Git repositories managed via `git submodule`, used for the smaller set of upstream skills that are still mirrored into this repo.
*   **Local Skills (`/local-skills/`)**: First-party skills authored in this repository.
*   **Skills (`/skills/`)**: The core distribution folder. It contains generated mirrored skill packages, proxy install registries, bundles, and the remote install scripts used by downstream users.
*   **MCP (`/mcp/`)**: Cross-client MCP server distribution assets, including registries, installers, and docs for Codex, Claude Code, Claude Desktop, and VS Code.
*   **Prompts (`/prompts/`)**: Pure Markdown-based templates, system prompts, and dialog structures meant for direct LLM ingestion.

## 2. Dependency Management & Syncing

Instead of manually copying code, the repository uses a manifest-driven approach that supports three skill source types:
*   **`submodule`**: mirror a skill out of `/external/`
*   **`local`**: mirror a skill out of `/local-skills/`
*   **`proxy`**: keep only an install command and delegate installation directly to the upstream repo

**Developer Workflow (Syncing)**:
1.  **Configure Sources**: Add or update entries in `skills/registry.tsv` for mirrored skills, or in `skills/proxy_registry.tsv` for proxy-installed skills.
2.  **Run Sync Script**: Execute `bash skills/update.sh`. This script will:
    *   Update all `git submodules` to their latest remote commits.
    *   Iterate through `skills/registry.tsv`.
    *   Copy mirrored skill directories from `/external/` or `/local-skills/` into `/skills/`.
    *   Iterate through `skills/proxy_registry.tsv` and include those skills in generated install metadata.
    *   Automatically generate `skills/skills_list.txt` and `skills-lock.json`.

## 3. Remote Installation Mechanics

To facilitate easy distribution to end-users, the repository provides one-click remote installation scripts for multiple platforms.

*   **Linux/Mac/WSL**: `skills/install.sh`
*   **Windows**: `skills/install.ps1`

**How it works**:
These scripts are designed to be executed via `curl` or `Invoke-RestMethod` directly from raw GitHub URLs.
*   **Full install**: Fetches `skills/skills_list.txt` from the `main` branch and installs each skill in order.
*   **Bundle install**: Fetches `skills/bundles.tsv`, resolves the requested bundle into a concrete skill list, and installs only that filtered set.
*   **Install scope**: Supports both project-local installs (default) and global installs.
*   **npm compatibility**: The install scripts sanitize user npm config at runtime to avoid `prefix` conflicts that can otherwise break `npx`.
*   **Proxy-aware install**: If a skill appears in `skills/proxy_registry.tsv`, the installer executes the upstream proxy command instead of installing from `zhangga/aihub`.

## 4. Code Style & Standards

*   **Bash Scripts (`.sh`)**: 
    *   Must include `set -e` to exit immediately on error.
    *   Must be compatible with standard UNIX environments and Windows WSL.
*   **PowerShell Scripts (`.ps1`)**:
    *   Use `$ErrorActionPreference = "Stop"`.
    *   Must be compatible with default Windows PowerShell execution policies via `iex`.
*   **Prompts**:
    *   Written in standard Markdown (`.md`).
    *   Must remain modular and self-contained.

## 5. Security Considerations

*   **Upstream Code Execution**: Mirrored skills copy code from external submodules, and proxy skills execute upstream install commands directly. Maintainers MUST verify the trustworthiness of any third-party repositories or commands added to `.gitmodules`, `skills/registry.tsv`, or `skills/proxy_registry.tsv`.
*   **Data Protection**: Ensure no sensitive data, API keys, or personally identifiable information (PII) are accidentally committed in any prompt templates or local skill configurations.

## 6. Configuration & Environment

*   **Prerequisites for Users**: Users only need `Node.js` (`npx`) to consume the agent skills.
*   **Prerequisites for Devs**: A Unix-like shell (macOS/Linux terminal, WSL, or Git Bash) is required to execute the synchronization script `update.sh`.
*   **Sources of Truth**:
    *   `skills/registry.tsv`: Source of truth for mirrored `submodule` and `local` skills.
    *   `skills/proxy_registry.tsv`: Source of truth for proxy-installed skills.
    *   `skills/bundles.tsv`: User-facing preset bundles for simpler installation choices.
    *   `local-skills/`: The source directory for first-party, locally-authored skills.
    *   `skills/skills_list.txt`: Auto-generated install list for full installs consumed by remote installers.
    *   `skills-lock.json`: Auto-generated lock metadata with source type, path, and commit information.
