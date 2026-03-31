# Agent Skills 库

这个目录用于统一分发各类 Agent 扩展技能（Skills）。通过安装这里的技能产物，你可以显著增强 AI Agent（如 Cline, Trae, Cursor 等工作流中的 Agent）在特定领域的专业分析、网页浏览或代码执行能力。

为了保持技能的最新状态并避免手动复制带来的代码陈旧问题，我们通过 Git Submodule 管理外部依赖，并使用 `local-skills/` 管理自研源码，再通过一键同步脚本统一生成当前目录下的分发产物。

`skills/registry.tsv` 是唯一的技能清单来源。`skills/skills_list.txt` 和根目录的 `skills-lock.json` 都由 `bash skills/update.sh` 自动生成。

## 🚀 一键安装指南

如果你想直接将本仓库中提供的**所有 18 个精选技能**安装到你的 Agent 运行环境中，只需在你的终端（需已安装 Node.js 和 npm）中执行以下命令：

**Mac / Linux / Windows WSL**:
```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash
```

**Windows (PowerShell)**:
```powershell
irm https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.ps1 | iex
```

> **注意**：上述脚本会读取 `skills_list.txt`，自动从云端下载并静默安装（`-y`）所有支持的核心技能。

推荐优先使用预设包。

支持的预设包如下：

- `core`
- `finance`
- `creative`
- `productivity`

预设包安装示例：

**Mac / Linux / Windows WSL**:
```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash -s -- --bundle core
```

```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash -s -- --bundle creative --global
```

查看可用预设包：

**Mac / Linux / Windows WSL**:
```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash -s -- --list-bundles
```

**Windows (PowerShell)**:
```powershell
$env:AIHUB_BUNDLE="creative"
$env:AIHUB_SCOPE="global"
irm https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.ps1 | iex
```

也支持零参数直接安装：

```powershell
irm https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.ps1 | iex
```

## 📦 现有技能列表 (共 18 款)

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
- **`doc-coauthoring`**: 文档共创与协作写作技能，适合需求文档、提案、技术规格和决策文档整理。
- **`excalidraw-diagram-generator`**: 根据自然语言描述生成 Excalidraw 图表，可用于流程图、关系图、脑图和架构图。
- **`frontend-design`**: 前端设计与 UI 组件生成辅助技能。
- **`humanizer-zh`**: 中文写作润色与去 AI 痕迹技能，适合编辑、审阅和自然化改写中文文本。
- **`remotion`**: 基于 JSON 渲染，支持自动化生成视频/动画的整合技能。
- **`sensight`**: 社媒热点、AI 行业资讯与语义检索技能，适合做舆情观察、热门话题追踪和作者动态检索。
- **`ui-ux-pro-max`**: 面向 Web 和移动端的 UI/UX 设计智能技能，提供设计风格、配色、字体、交互与组件建议。

---

## ⚙️ 仓库维护指南 (仅限开发者)

本目录下的具体技能代码是分发产物，不建议直接在这里手写维护。外部技能来自 `/external/` 目录中的第三方开源仓库子模块，自研技能来自 `/local-skills/`，两者都会通过同一份 registry 纳入分发。

**如何添加新技能或更新现有技能代码：**
1. **配置依赖**: 编辑 `skills/registry.tsv`。每一行格式为 `name<TAB>source_type<TAB>source_path`。其中：
   - `submodule` 表示来源于 `external/` 下的子模块路径，例如 `01coder-agent-skills/skills/china-stock-analysis`
   - `local` 表示来源于当前仓库的自研源码目录，例如 `local-skills/xai-stock-sentiment`
2. **执行同步脚本**: 在根目录运行更新脚本。
   ```bash
   bash skills/update.sh
   ```
   > 脚本会自动：拉取最新的 Git Submodule -> 将 registry 中配置好的技能同步到 `skills/` 下 -> 生成 `skills_list.txt` 和 `skills-lock.json`。

3. **离线校验或仅重建产物**: 如果你已经手动更新过 submodule，或当前环境不方便联网，可以执行：
   ```bash
   bash skills/update.sh --skip-submodule-update
   ```

4. **运行本地校验**: 在提交前可以执行：
   ```bash
   bash skills/check-registry.sh
   ```
   这会检查 `registry.tsv` 的列格式、重复名称和来源路径是否存在。GitHub Actions 也会执行同样的检查。




