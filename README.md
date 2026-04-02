# AI Hub 🤖

AI Hub 是一个用于沉淀、管理和复用各种 AI 工具、提示词（Prompts）以及智能体技能（Agent Skills）的综合性知识仓库。

无论你是正在使用各种大模型（如 ChatGPT, Claude, Gemini），还是在本地构建或定制自己的 AI Agent 工作流，本仓库都能为你提供开箱即用的模块化能力。

## 📂 仓库结构

- **[`/skills`](./skills/)**: 智能体扩展技能分发目录。这里存放最终对外发布和安装的 Agent 技能产物，内容由同步脚本统一生成和维护。
  - *详细技能列表和配置见 [skills 目录](./skills/README.md)。*
- **[`/mcp`](./mcp/)**: MCP Server 分发目录。这里存放跨客户端的一键安装脚本、registry 和 bundles，用于把 MCP server 写入 Codex、Claude Code、Claude Desktop、VS Code 等客户端配置。
- **[`/local-skills`](./local-skills/)**: 自研技能源码目录。用于存放你自己编写并希望纳入统一分发流程的本地 skills。
- **[`/prompts`](./prompts/)**: 高质量提示词模板库。沉淀了经过实际验证的、适用于不同场景的系统提示词，可直接应用于大模型的上下文。
- **[`/external`](./external/)**: 存放通过 Git Submodule 引入、仍需镜像分发的第三方技能仓库源。

当前 skills 分发同时支持三种来源：
- `submodule`：从 `/external` 镜像
- `local`：从 `/local-skills` 镜像
- `proxy`：不镜像代码，只在安装时直接代理执行上游安装命令

架构说明可参考：

- [AGENTS.md](./AGENTS.md)
- [AGENTS.zh.md](./AGENTS.zh.md)

## 🚀 核心特性

1. **开箱即用**: 提供跨平台（Mac/Linux/Windows）的一键远程安装脚本，轻松将仓库当前收录的精选技能一键部署到你的 Agent 运行环境中。
2. **MCP 一键分发**: 除了 skills，本仓库也支持通过 registry + installer 的方式，把 MCP server 一键安装到主流 AI 编程客户端的全局配置中。
3. **场景丰富**: 涵盖股票投资分析、数据抓取、头脑风暴、代码审计、音视频渲染、浏览器调试、本地文件访问等多个实用领域。
4. **灵活分发模型**: 既支持通过 Git Submodule / 本地源码镜像分发，也支持通过 proxy skill 直接代理到上游安装命令，兼顾稳定性与低维护成本。

## 💡 如何使用

### 1. 一键安装全部 Agent Skills
如果你想直接将本仓库中提供的所有精选技能安装到你的 Agent 环境中（需已安装 Node.js 和 npm），请根据你的操作系统在终端中执行以下命令：

**Mac / Linux / Windows WSL**:
```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash
```

**Windows (PowerShell)**:
```powershell
irm https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.ps1 | iex
```

> **注意**: 该操作会自动读取 `skills/skills_list.txt`。镜像 skill 会从 `zhangga/aihub` 安装，proxy skill 会自动切换到对应上游命令。更详细的说明请参考 [Skills 文档](./skills/README.md)。

你也可以按预设包安装，并选择安装到全局目录：

**Bash / WSL 预设包**:
```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash -s -- --bundle core
```

```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash -s -- --bundle creative --global
```

**PowerShell**:
```powershell
$env:AIHUB_BUNDLE="creative"
$env:AIHUB_SCOPE="global"
irm https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.ps1 | iex
```

PowerShell 也支持零参数直接安装：

```powershell
irm https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.ps1 | iex
```

### 2. 使用 Prompts
直接浏览 `prompts` 目录，寻找符合你需求的 Markdown 文件，复制其中的内容作为大模型的 System Prompt 或直接输入。

### 3. 一键安装 MCP Server
如果你希望把仓库里维护的 MCP server 一键安装到客户端全局配置，可以使用 `mcp/` 下的安装脚本。

例如安装 Chrome DevTools MCP 到 Codex：

```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/mcp/install.sh | bash -s -- --client codex --server chrome-devtools
```

例如安装 filesystem MCP，并授权一个目录：

```powershell
irm https://raw.githubusercontent.com/zhangga/aihub/main/mcp/install.ps1 | iex
Install-AihubMcp -Client claude-code -Server filesystem -Arg "C:\work\github"
```

支持的首批客户端包括：
- Codex
- Claude Code
- Claude Desktop
- VS Code

详细说明请参考 [mcp 目录](./mcp/README.md)。

### 4. 在业务项目中复用 Skills
如果你希望在其他项目里复用本仓库维护的 skills，并给团队成员一份可直接复制的接入说明，可以参考：

- [`docs/project-readme-template.zh.md`](./docs/project-readme-template.zh.md)
- [`docs/project-readme-template.en.md`](./docs/project-readme-template.en.md)
- [`docs/project-gitignore-template.txt`](./docs/project-gitignore-template.txt)

这份文档提供了：
- 中英文 README 模板
- 推荐的 `.gitignore` 模板
- 团队协作时的安装与提交建议

### 5. (仅限开发者) 更新与同步上游代码 
如果你 fork 了本仓库并想要更新上游技能：
1. 维护 skill 来源清单：
   - 镜像 skill 写入 `skills/registry.tsv`
   - 代理 skill 写入 `skills/proxy_registry.tsv`
   - 外部镜像 skill 指向 `external/`
   - 自研镜像 skill 指向 `local-skills/`
2. 在根目录执行脚本：
   ```bash
   bash skills/update.sh
   ```
   这会自动更新仍在使用的 submodule、同步镜像 skill，并重新生成 `skills/skills_list.txt` 和 `skills-lock.json`。

## 📄 许可证

本项目开源，详细请参考根目录下的 [LICENSE](LICENSE) 文件。




