# 代码仓库架构概览

本文档用于帮助 AI Agent、代码编辑器和开发者快速理解 `aihub` 仓库的目标、目录结构以及同步机制。

## 1. 项目概览

`aihub` 不是传统的软件应用，而是一个集中式的知识与资产仓库。它的核心目标是沉淀、管理并复用 AI 工具、Prompts 和 Agent Skills，在不同 LLM 与 Agent 工作流之间共享能力。

当前仓库围绕五类资产组织：

* **外部子模块（`/external/`）**：通过 `git submodule` 管理的第三方 Git 仓库，用于保留少量仍需镜像分发的上游源码。
* **本地技能源码（`/local-skills/`）**：当前仓库内自行维护的一方 skill 源码目录。
* **技能分发目录（`/skills/`）**：对外发布的核心目录。这里既包含由同步脚本生成的镜像 skill，也包含代理安装 registry、bundles 和远程安装脚本。
* **MCP 分发目录（`/mcp/`）**：面向 Codex、Claude Code、Claude Desktop、VS Code 等客户端的 MCP 安装器、registry 与说明文档。
* **提示词目录（`/prompts/`）**：可直接供大模型使用的 Markdown 模板、系统提示词和对话结构。

## 2. Skill 来源模型与同步

仓库目前同时支持三种 skill 来源：

1. **`submodule`**：从 `/external/` 中的上游仓库镜像到 `/skills/`
2. **`local`**：从 `/local-skills/` 中的本地源码复制到 `/skills/`
3. **`proxy`**：不镜像源码，只在安装时代理执行上游安装命令

其中：

* `skills/registry.tsv` 维护 `submodule` 与 `local` 两类来源
* `skills/proxy_registry.tsv` 维护 `proxy` 技能

**开发者工作流（同步）**：

1. 在 `skills/registry.tsv` 或 `skills/proxy_registry.tsv` 中新增或更新条目。
2. 运行 `bash skills/check-registry.sh` 做本地校验。
3. 运行 `bash skills/update.sh` 或 `bash skills/update.sh --skip-submodule-update`。

`skills/update.sh` 会：

* 按需更新仍在使用的 `git submodule`
* 遍历 `skills/registry.tsv`
* 将配置好的镜像 skill 从 `/external/` 或 `/local-skills/` 复制到 `/skills/`
* 遍历 `skills/proxy_registry.tsv`
* 将代理 skill 纳入 `skills/skills_list.txt` 与 `skills-lock.json`
* 自动移除已改为 proxy 的旧分发副本

## 3. 远程安装机制

为了方便下游用户使用，仓库提供了一键远程安装脚本：

* **Linux / Mac / WSL**：`skills/install.sh`
* **Windows**：`skills/install.ps1`

这些脚本可通过 GitHub Raw 链接配合 `curl` 或 `Invoke-RestMethod` 直接执行。

安装行为如下：

* **全量安装**：拉取 `skills/skills_list.txt`，逐个安装 skill
* **Bundle 安装**：拉取 `skills/bundles.tsv`，将 bundle 解析为 skill 列表后安装
* **镜像 skill**：执行 `npx skills@latest add <repo> --skill <name> -y`
* **代理 skill**：查找 `skills/proxy_registry.tsv` 中的完整命令并直接执行
* **安装范围**：支持项目本地安装（默认）与全局安装
* **npm 兼容处理**：运行时净化用户 `.npmrc` 中可能破坏 `npx` 的 `prefix` 配置

## 4. 代码风格与规范

* **Bash 脚本（`.sh`）**
  * 必须包含 `set -e`
  * 应兼容标准 UNIX 环境与 Windows WSL
* **PowerShell 脚本（`.ps1`）**
  * 使用 `$ErrorActionPreference = "Stop"`
  * 应兼容默认 Windows PowerShell 执行策略，并支持通过 `iex` 加载
* **Prompts**
  * 使用标准 Markdown（`.md`）
  * 保持模块化和自包含

## 5. 安全注意事项

* **上游代码执行风险**：镜像 skill 会通过 `update.sh` 复制上游代码，代理 skill 会通过安装脚本直接执行上游命令。维护者在把第三方来源加入 `.gitmodules`、`skills/registry.tsv` 或 `skills/proxy_registry.tsv` 前，必须确认其可信度。
* **数据保护**：确保任何提示词模板、本地 skill 配置或其他文档中都不会误提交敏感数据、API Key 或个人隐私信息。

## 6. 配置与环境

* **用户前置依赖**：用户只需安装 `Node.js`（提供 `npx`）即可消费本仓库维护的大多数 skills。
* **开发者前置依赖**：开发者需要能运行 `bash skills/update.sh` 的类 UNIX Shell 环境，例如 macOS/Linux 终端、WSL 或 Git Bash。
* **事实来源（Source of Truth）**
  * `skills/registry.tsv`：镜像 skill 的来源定义
  * `skills/proxy_registry.tsv`：代理 skill 的来源定义
  * `skills/bundles.tsv`：面向用户的 bundle 预设
  * `local-skills/`：一方本地 skill 源码目录
  * `skills/skills_list.txt`：自动生成的全量安装清单
  * `skills-lock.json`：自动生成的锁文件，记录每个 skill 的来源类型、路径与提交信息
