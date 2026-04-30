# 代码仓库架构概览

本文档用于帮助 AI Agent、代码编辑器和开发者快速理解 `aihub` 仓库的用途、目录边界、事实来源和同步机制。

## 1. 项目概览

`aihub` 不是传统的软件应用，而是一个集中式知识与资产仓库。它用于沉淀、管理并分发 AI 工具、提示词、MCP 安装器和 Agent Skills，方便在不同 LLM 与 Agent 工作流之间复用。

仓库主要由以下领域组成：

* **外部子模块（`/external/`）**：通过 `git submodule` 管理的第三方 Git 仓库，只用于少量仍需镜像进本仓库分发的上游 skill。
* **本地技能源码（`/local-skills/`）**：当前仓库内自行维护的一方 skill 源码目录。
* **技能分发目录（`/skills/`）**：对外发布的核心目录，包含同步脚本生成的镜像 skill、proxy 安装注册表、bundles 和远程安装脚本。
* **MCP 分发目录（`/mcp/`）**：面向 Codex、Claude Code、Claude Desktop、VS Code 等客户端的 MCP registry、bundles、安装器和说明文档。
* **提示词目录（`/prompts/`）**：可直接供大模型使用的 Markdown 模板、系统提示词和 Agent 指令模板。
* **文档目录（`/docs/`）**：设计说明、业务项目 README 模板、草稿和其他辅助文档。

## 2. Skill 来源模型与同步

仓库的 skill 分发采用 manifest 驱动方式。除非你明确要修改生成产物，否则不要直接把 skill 源码手工复制到 `/skills/`。

当前支持三种 skill 来源：

* **`submodule`**：从 `/external/` 下的上游仓库镜像到 `/skills/`
* **`local`**：从 `/local-skills/` 下的本地源码复制到 `/skills/`
* **`proxy`**：不镜像源码，只在安装时代理执行上游安装命令

事实来源：

* `skills/registry.tsv`：维护 `submodule` 和 `local` 两类镜像 skill
* `skills/proxy_registry.tsv`：维护 proxy skill 及其上游安装命令
* `skills/bundles.tsv`：维护面向用户的 bundle 预设
* `skills/skills_list.txt`：自动生成的全量安装清单
* `skills-lock.json`：自动生成的 skill 锁文件，记录来源类型、路径和提交或内容哈希

开发者同步流程：

1. 在 `skills/registry.tsv` 或 `skills/proxy_registry.tsv` 中新增或更新条目。
2. 运行 `bash skills/check-registry.sh`，校验列格式、重复名称、来源路径和 bundle 引用。
3. 运行 `bash skills/update.sh`，更新子模块、同步镜像 skill、移除已改为 proxy 的旧分发副本，并重新生成 `skills/skills_list.txt` 和 `skills-lock.json`。
4. 如果已经手动更新过子模块，或当前环境不方便联网，可以运行 `bash skills/update.sh --skip-submodule-update`。

## 3. Skill 远程安装机制

仓库提供一键远程安装脚本，供下游用户通过 GitHub Raw URL 直接执行。

* **Linux / macOS / WSL**：`skills/install.sh`
* **Windows PowerShell**：`skills/install.ps1`

安装行为：

* **全量安装**：拉取 `skills/skills_list.txt`，逐个安装所有已登记 skill。
* **Bundle 安装**：拉取 `skills/bundles.tsv`，将一个或多个 bundle 解析成 skill 列表后安装。
* **安装范围**：默认使用项目本地安装；`--global` 或 `AIHUB_SCOPE=global` 会切换到全局安装。
* **镜像 skill**：执行 `npx skills@latest add github.com/zhangga/aihub --skill <name> -y`。
* **proxy skill**：查找 `skills/proxy_registry.tsv` 中的完整命令并直接执行。
* **npm 兼容处理**：安装脚本会在运行时净化用户 `.npmrc` 中可能破坏 `npx` 的 `prefix` 配置。

具体命令、bundle 示例和环境变量覆盖项见 `skills/README.md`。

## 4. MCP 分发机制

`mcp/` 目录用于分发可运行的 MCP server，并把 server 写入目标客户端配置。

事实来源：

* `mcp/registry.tsv`：定义 server 名称、运行时、包来源、默认参数、默认环境变量和支持的客户端
* `mcp/bundles.tsv`：定义 server bundle
* `mcp/install.sh`：Bash 安装器
* `mcp/install.ps1`：PowerShell 安装器

当前安装器支持：

* `--client <codex|claude-code|claude-desktop|vscode>`
* `--server <name>` 或 `--bundle <name>`
* `--arg <value>` 追加 server 参数
* `--env KEY=VALUE` 追加 server 环境变量
* `--dry-run`、`--list-servers`、`--list-bundles`

MCP 目前只支持用户级全局配置。使用示例和客户端差异见 `mcp/README.md`。

## 5. 代码风格与规范

* **Bash 脚本（`.sh`）**
  * 必须包含 `set -e`。
  * 应兼容标准 UNIX 环境和 Windows WSL。
* **PowerShell 脚本（`.ps1`）**
  * 必须使用 `$ErrorActionPreference = "Stop"`。
  * 应支持通过 `iex` 或 `pwsh -File` 在默认 Windows PowerShell 执行策略下运行。
* **Markdown 提示词与文档**
  * 保持模块化、自包含。
  * 不要写入密钥、本机私有路径，或下游用户无法复现的上下文假设。

## 6. 安全注意事项

* **上游代码执行风险**：镜像 skill 会通过 `update.sh` 复制上游代码，proxy skill 会通过安装脚本直接执行上游命令。维护者在把第三方来源加入 `.gitmodules`、`skills/registry.tsv` 或 `skills/proxy_registry.tsv` 前，必须确认其可信度。
* **MCP server 执行风险**：MCP 安装器会配置本地客户端运行 server 命令。每个 `mcp/registry.tsv` 条目都应按可执行代码对待。
* **数据保护**：确保提示词模板、skill 配置、文档、注册表和锁文件中都不包含敏感数据、API Key、令牌、个人隐私信息或私有项目上下文。

## 7. 提交前校验

修改 skills、registries、installers 或生成产物后，提交前建议执行：

1. `bash skills/check-registry.sh`
2. `bash skills/update.sh --skip-submodule-update`，除非你确实需要刷新 submodule
3. `python -m json.tool skills-lock.json`，如果本机有 Python
4. 确认 `git diff -- skills skills-lock.json` 中只有预期的生成产物变化

GitHub Actions 会对 skill 分发相关改动执行同样的 registry 校验和生成产物漂移检查。
