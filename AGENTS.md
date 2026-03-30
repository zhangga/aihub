# Codebase Architecture Overview

This document provides a high-level architecture overview of the `aihub` repository. It is intended to help other AI agents, tools, and developers quickly understand the project's purpose, structure, and operational requirements.

## 1. Project Overview

The `aihub` project is a centralized knowledge repository designed to store, manage, and facilitate the reuse of AI tools, Prompts, and Agent Skills.

The architecture is divided into three primary domains:
*   **External Submodules (`/external/`)**: Contains third-party Git repositories managed via `git submodule`. This allows the project to track upstream dependencies.
*   **Skills (`/skills/`)**: Contains executable scripts and tooling extensions that augment an AI Agent's capabilities. Specific skills from the `/external/` directory are selectively copied here for local use.
*   **Prompts (`/prompts/`)**: Contains Markdown-based templates, system prompts, and dialog structures meant to be directly injected into LLM context windows or application code.

## 2. Build & Commands

**Syncing & Updating Skills**:
Instead of manual copying, the repository uses a configuration file and a bash script to fetch and sync specific skills from external submodules.
1.  **Configure Needs**: Add the relative path of the desired skill (from the `external` root) to `external/needed_skills.txt` (e.g., `01coder-agent-skills/skills/china-stock-analysis`).
2.  **Run Sync**: Execute the update script. This script updates the `git submodule` to the latest remote commit and copies the directories listed in `needed_skills.txt` into the `/skills/` directory.
    ```bash
    bash skills/update.sh
    ```

**Installing Agent Skills**:
Some skills may require environment-specific installation.
```bash
bash skills/install.sh
```

## 3. Code Style

*   **Bash Scripts**: 
    *   Must include `set -e` to ensure the script exits immediately upon encountering an error.
    *   Use clear `echo` statements to indicate progress.
*   **Prompts**:
    *   Written in standard Markdown (`.md`).
    *   Keep it modular with clear instructions for the AI model.

## 4. Testing

There is no global automated testing framework configured.
*   **Prompts**: Verified manually through direct testing with target LLMs.
*   **Skills & Scripts**: Tested locally by executing the shell scripts (`update.sh`, `install.sh`) to ensure file operations and submodules behave as expected.

## 5. Security

*   **Submodule Security**: `skills/update.sh` pulls the latest code from third-party repositories via `git submodule update --remote`. Ensure you trust the upstream repositories registered in `.gitmodules`.
*   **Data Protection**: Ensure no sensitive data (PII or secrets) are hardcoded in prompts or accidentally pushed via external skills.

## 6. Configuration

*   **Prerequisites**: A Unix-like shell (macOS/Linux terminal, Windows WSL, or Git Bash) is required to execute the `.sh` setup scripts. Node.js may be required depending on the specific skills being executed by `install.sh`.
*   **Dependency Management File**: `external/needed_skills.txt` is the sole source of truth for which external skills are synced to the local `/skills/` folder.
