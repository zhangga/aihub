# AI Hub 🤖

AI Hub 是一个用于沉淀、管理和复用各种 AI 工具、提示词（Prompts）以及智能体技能（Agent Skills）的综合性知识仓库。

无论你是正在使用各种大模型（如 ChatGPT, Claude, Gemini），还是在本地构建或定制自己的 AI Agent 工作流，本仓库都能为你提供开箱即用的模块化能力。

## 📂 仓库结构

- **[`/skills`](./skills/)**: 智能体扩展技能分发目录。这里存放最终对外发布和安装的 Agent 技能产物，内容由同步脚本统一生成和维护。
  - *详细技能列表和配置见 [skills 目录](./skills/README.md)。*
- **[`/local-skills`](./local-skills/)**: 自研技能源码目录。用于存放你自己编写并希望纳入统一分发流程的本地 skills。
- **[`/prompts`](./prompts/)**: 高质量提示词模板库。沉淀了经过实际验证的、适用于不同场景的系统提示词，可直接应用于大模型的上下文。
- **[`/external`](./external/)**: 存放通过 Git Submodule 引入的第三方开源技能仓库源。我们通过自动化脚本将其中的精华部分抽取至 `/skills` 中。

架构说明可参考：

- [AGENTS.md](./AGENTS.md)
- [AGENTS.zh.md](./AGENTS.zh.md)

## 🚀 核心特性

1. **开箱即用**: 提供跨平台（Mac/Linux/Windows）的一键远程安装脚本，轻松将十余种精选技能一键部署到你的 Agent 运行环境中。
2. **场景丰富**: 涵盖股票投资分析、数据抓取、头脑风暴、代码审计、音视频渲染等多个实用领域。
3. **自动化依赖管理**: 通过 Git Submodule 和内置的 `update.sh` 脚本统一管理上游外部技能更新，确保本地沉淀的技能代码永远保持最新。

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

> **注意**: 该操作会自动读取 `skills/skills_list.txt`，批量静默安装所有的核心技能。更详细的技能说明请参考 [Skills 文档](./skills/README.md)。

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

### 3. 在业务项目中复用 Skills
如果你希望在其他项目里复用本仓库维护的 skills，并给团队成员一份可直接复制的接入说明，可以参考：

- [`docs/project-readme-template.zh.md`](./docs/project-readme-template.zh.md)
- [`docs/project-readme-template.en.md`](./docs/project-readme-template.en.md)
- [`docs/project-gitignore-template.txt`](./docs/project-gitignore-template.txt)

这份文档提供了：
- 中英文 README 模板
- 推荐的 `.gitignore` 模板
- 团队协作时的安装与提交建议

### 4. (仅限开发者) 更新与同步上游代码 
如果你 fork 了本仓库并想要更新上游技能：
1. 编辑 `skills/registry.tsv`，维护需要分发的技能、来源类型和来源路径。外部 skill 指向 `external/`，自研 skill 指向 `local-skills/`。
2. 在根目录执行脚本：
   ```bash
   bash skills/update.sh
   ```
   这会自动拉取 submodule，将指定技能目录提取到 `skills/` 下，并重新生成 `skills/skills_list.txt` 和 `skills-lock.json`。

## 📄 许可证

本项目开源，详细请参考根目录下的 [LICENSE](LICENSE) 文件。




