# 代码仓库架构概览

本文档提供 `aihub` 仓库的高层架构说明，帮助 AI Agent、代码编辑器和开发者快速理解项目目标、目录结构以及同步机制。

## 1. 项目概览

`aihub` 不是传统的软件应用，而是一个集中式的知识与资产仓库。它的核心目标是存储、管理并促进 AI 工具、Prompts 和 Agent Skills 在不同 LLM 与 Agent 工作流中的复用。

整体架构严格划分为四个模块：

* **外部子模块（`/external/`）**：存放通过 `git submodule` 管理的第三方 Git 仓库，用于跟踪上游依赖而不直接修改原始代码。
* **本地技能源码（`/local-skills/`）**：存放在当前仓库中编写和维护的一方 skill 源码，是自定义能力的来源目录。
* **技能分发目录（`/skills/`）**：核心交付目录，存放生成后的、可供下游用户安装的 skill 分发产物。
* **提示词目录（`/prompts/`）**：存放纯 Markdown 模板、系统提示词以及可直接供 LLM 使用的对话结构。

## 2. 依赖管理与同步

为了避免手动复制代码，仓库使用脚本驱动的方式，从较大的外部子模块中提取需要的能力。

**开发者工作流（同步）**：

1. **配置来源路径**：在 `skills/registry.tsv` 中新增或更新条目。每个条目定义分发 skill 的名称、来源类型和来源路径。
2. **运行同步脚本**：执行 `bash skills/update.sh`。该脚本会：
   * 更新所有 `git submodule` 到最新远端提交；
   * 遍历 `skills/registry.tsv`；
   * 将配置好的 skill 目录从 `/external/` 或 `/local-skills/` 复制到 `/skills/`；
   * 自动生成 `skills/skills_list.txt` 和 `skills-lock.json`。

## 3. 远程安装机制

为了便于分发给终端用户，仓库提供了跨平台的一键远程安装脚本：

* **Linux / Mac / WSL**：`skills/install.sh`
* **Windows**：`skills/install.ps1`

**工作方式**：

这些脚本可以通过 GitHub Raw 链接，配合 `curl` 或 `Invoke-RestMethod` 直接执行。

* **全量安装**：从 `main` 分支拉取 `skills/skills_list.txt`，并依次执行 `npx skills@latest add <repo> --skill <name> -y`。
* **Bundle 安装**：拉取 `skills/bundles.tsv`，将用户请求的 bundle 解析成具体 skill 列表，然后只安装筛选后的集合。
* **安装范围**：同时支持项目本地安装（默认）和全局安装。
* **npm 兼容处理**：安装脚本会在运行时净化用户的 npm 配置，以避免 `prefix` 配置导致 `npx` 失败。

## 4. 代码风格与规范

* **Bash 脚本（`.sh`）**：
  * 必须包含 `set -e`，以便在出错时立即退出；
  * 必须兼容标准 UNIX 环境以及 Windows WSL。
* **PowerShell 脚本（`.ps1`）**：
  * 使用 `$ErrorActionPreference = "Stop"`；
  * 必须兼容默认 Windows PowerShell 执行策略，并能通过 `iex` 执行。
* **Prompts**：
  * 使用标准 Markdown（`.md`）编写；
  * 保持模块化与自包含。

## 5. 安全注意事项

* **上游代码执行风险**：`update.sh` 会复制外部子模块中的代码，`install.sh` / `install.ps1` 会通过 `npx` 执行这些 skill。维护者在把第三方仓库加入 `.gitmodules` 并登记到 `skills/registry.tsv` 前，必须确认其可信度。
* **数据保护**：确保任何提示词模板、本地 skill 配置或其他文件中都不会误提交敏感数据、API Key 或个人隐私信息（PII）。

## 6. 配置与环境

* **用户前置依赖**：终端用户只需要安装 `Node.js`（提供 `npx`）即可使用这些 agent skills。
* **开发者前置依赖**：开发者需要可运行 `update.sh` 的类 UNIX Shell 环境，例如 macOS/Linux 终端、WSL 或 Git Bash。
* **事实来源（Source of Truth）**：
  * `skills/registry.tsv`：分发 skill 及其来源的唯一事实来源；
  * `skills/bundles.tsv`：面向用户的预设 bundle 定义；
  * `local-skills/`：一方本地 skill 源码目录；
  * `skills/skills_list.txt`：自动生成的全量安装清单，供远程安装脚本使用；
  * `skills-lock.json`：自动生成的锁文件，记录来源路径和提交信息。
