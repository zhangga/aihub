# Codebase Architecture Overview

This document provides a high-level architecture overview of the `aihub` repository. It is designed to help AI agents, code editors, and developers quickly understand the project's purpose, structure, and synchronization mechanics.

## 1. Project Overview

The `aihub` project is not a traditional software application but a centralized knowledge and asset repository. Its primary purpose is to store, manage, and facilitate the reuse of AI tools, Prompts, and Agent Skills across different LLMs and Agent workflows.

The architecture is strictly divided into four modular domains:
*   **External Submodules (`/external/`)**: Contains third-party Git repositories managed via `git submodule`. This allows the repository to track upstream dependencies without modifying original source codes.
*   **Local Skills (`/local-skills/`)**: Contains first-party skills authored in this repository. These act as the source directory for custom capabilities you want to distribute.
*   **Skills (`/skills/`)**: The core deliverable folder. Contains the generated, distributable skill packages that are installed by downstream users.
*   **Prompts (`/prompts/`)**: Contains pure Markdown-based templates, system prompts, and dialog structures meant for direct LLM ingestion.

## 2. Dependency Management & Syncing

Instead of manually copying code, the repository uses a script-driven approach to extract specific capabilities from large external submodules.

**Developer Workflow (Syncing)**:
1.  **Configure Source Paths**: Add or update entries in `skills/registry.tsv`. Each entry defines the distributed skill name, source type, and source path.
2.  **Run Sync Script**: Execute `bash skills/update.sh`. This script will:
    *   Update all `git submodules` to their latest remote commits.
    *   Iterate through `skills/registry.tsv`.
    *   Copy the configured skill directories from `/external/` or `/local-skills/` into `/skills/`.
    *   Automatically generate `skills/skills_list.txt` and `skills-lock.json`.

## 3. Remote Installation Mechanics

To facilitate easy distribution to end-users, the repository provides one-click remote installation scripts for multiple platforms.

*   **Linux/Mac/WSL**: `skills/install.sh`
*   **Windows**: `skills/install.ps1`

**How it works**:
These scripts are designed to be executed via `curl` or `Invoke-RestMethod` directly from raw GitHub URLs. When executed, they remotely fetch `skills/skills_list.txt` from the `main` branch to determine which skills to install, and then sequentially execute `npx skills@latest add <repo> --skill <name>` for silent installation.

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

*   **Upstream Code Execution**: The `update.sh` script copies code from external submodules, and the `install.sh` / `install.ps1` scripts execute them via `npx`. Maintainers MUST verify the trustworthiness of any third-party repositories added to `.gitmodules` before adding them to `skills/registry.tsv`.
*   **Data Protection**: Ensure no sensitive data, API keys, or personally identifiable information (PII) are accidentally committed in any prompt templates or local skill configurations.

## 6. Configuration & Environment

*   **Prerequisites for Users**: Users only need `Node.js` (`npx`) to consume the agent skills.
*   **Prerequisites for Devs**: A Unix-like shell (macOS/Linux terminal, WSL, or Git Bash) is required to execute the synchronization script `update.sh`.
*   **Sources of Truth**:
    *   `skills/registry.tsv`: The single source of truth for distributed skills and their origins.
    *   `local-skills/`: The source directory for first-party, locally-authored skills.
    *   `skills/skills_list.txt`: Auto-generated install list consumed by remote installers.
    *   `skills-lock.json`: Auto-generated lock metadata with source path and commit information.
