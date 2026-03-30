# Agent Skills 库

这个目录用于沉淀和管理各类 Agent 扩展技能（Skills）。通过安装这些技能，你可以显著增强 AI Agent（如 Cline, Trae, Cursor 等工作流中的 Agent）在特定领域的专业分析、网页浏览或代码执行能力。

为了保持技能的最新状态并避免手动复制带来的代码陈旧问题，我们通过 Git Submodule 统一管理外部依赖，并提供了一键同步脚本。

## 🚀 一键安装指南

如果你想直接将本仓库中提供的**所有 13 个精选技能**安装到你的 Agent 运行环境中，只需在你的终端（需已安装 Node.js 和 npm）中执行以下命令：

**Mac / Linux / Windows WSL**:
```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash
```

**Windows (PowerShell)**:
```powershell
irm https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.ps1 | iex
```

> **注意**：上述脚本会读取 `skills_list.txt`，自动从云端下载并静默安装（`-y`）所有支持的核心技能。

---

## 📦 现有技能列表 (共 13 款)

当前已同步并支持一键安装的技能包括：

### 📈 投资与金融分析
- **`china-stock-analysis`**: A股价值投资分析工具，基于价值投资理论，提供股票筛选、个股深度分析和估值计算功能。
- **`finviz-screener`**: 基于 FinViz 的强大股票筛选工具技能。
- **`institutional-flow-tracker`**: 机构资金流向跟踪分析技能。
- **`news-sentiment`**: 市场新闻与情绪分析技能。
- **`stock-analyst`**: 专业的股票数据技术面与基本面分析辅助工具。
- **`stock-metrics`**: 核心股票指标与财报数据抓取、计算技能。
- **`xai-stock-sentiment`**: 结合 xAI 模型的股票市场情绪追踪工具。
- **`yahoo-data-fetcher`**: 雅虎财经（Yahoo Finance）实时数据获取与分析工具。

### 💻 研发与生产力
- **`agent-browser`**: 能够让 Agent 自主浏览、检索和阅读网页内容的强大技能。
- **`brainstorming`**: 头脑风暴辅助工具，扩展 Agent 的创意构思与发散能力。
- **`codex-review`**: 提供智能代码审查（Code Review）与架构分析能力。
- **`frontend-design`**: 前端设计与 UI 组件生成辅助技能。
- **`remotion`**: 基于 JSON 渲染，支持自动化生成视频/动画的整合技能。

---

## ⚙️ 仓库维护指南 (仅限开发者)

本目录下的具体技能代码并非手写，而是从 `/external/` 目录中的第三方开源仓库子模块自动抽取过来的。

**如何添加新技能或更新现有技能代码：**
1. **配置依赖**: 编辑项目根目录的 `external/needed_skills.txt`，按行追加或修改你需要引入的子模块路径（例如 `01coder-agent-skills/skills/china-stock-analysis`）。
2. **执行同步脚本**: 在根目录运行更新脚本。
   ```bash
   bash skills/update.sh
   ```
   > 脚本会自动：拉取最新的 Git Submodule -> 将配置好的技能夹拷贝到 `skills/` 下 -> 动态扫描并重新生成 `skills_list.txt` 文件。
