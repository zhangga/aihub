# Agent Skills 库

这个目录是 `aihub` 的 Agent Skills 分发目录。下游用户通过这里的安装脚本安装 skill；维护者通过 registry 和同步脚本生成这里的分发产物。

`skills/` 下的具体 skill 目录通常不是手写源码，而是由 `bash skills/update.sh` 从以下来源生成：

- `submodule`：从 `external/` 下的第三方仓库镜像
- `local`：从 `local-skills/` 下的一方源码复制
- `proxy`：不保留源码目录，只在安装时执行 `skills/proxy_registry.tsv` 中登记的上游安装命令

事实来源：

- `skills/registry.tsv`：镜像 skill 的来源清单
- `skills/proxy_registry.tsv`：proxy skill 的安装命令清单
- `skills/bundles.tsv`：预设包定义
- `skills/skills_list.txt`：自动生成的全量安装列表
- `../skills-lock.json`：自动生成的来源锁文件

## 一键安装

安装全部已登记 skill：

**Mac / Linux / Windows WSL**

```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash
```

**Windows PowerShell**

```powershell
irm https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.ps1 | iex
```

安装预设包：

```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash -s -- --bundle core
```

安装到全局范围：

```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash -s -- --bundle creative --global
```

PowerShell 远程安装时可用环境变量指定 bundle 和 scope：

```powershell
$env:AIHUB_BUNDLE="creative"
$env:AIHUB_SCOPE="global"
irm https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.ps1 | iex
```

查看可用预设包：

```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash -s -- --list-bundles
```

## 预设包

当前 `skills/bundles.tsv` 定义了以下 bundle：

- `core`：日常 Agent 工作流基础包
- `finance`：市场研究与投资分析包
- `creative`：创意、视觉和演示工作流包
- `productivity`：研究、写作和交付工作流包
- `engineering`：软件工程规划、诊断、测试、架构和交付工作流包

## 当前技能列表

以下列表应与 `skills/skills_list.txt` 保持一致。

### 研发与 Agent 工作流

- **`agent-browser`**：浏览器自动化与网页调试技能。
- **`brainstorming`**：需求澄清、发散构思和方案探索技能。
- **`codex-review`**：代码审查和架构风险识别技能。
- **`doc-coauthoring`**：文档共创与协作写作技能，适合需求文档、提案、技术规格和决策文档。
- **`excalidraw-diagram-generator`**：根据自然语言生成 Excalidraw 图表。
- **`frontend-design`**：前端设计和 UI 组件生成辅助技能。
- **`long-run-harness`**：仓库级长周期任务执行 harness，用持久化状态、验证和恢复流程补充 Codex goal 模式。
- **`playwright-cli`**：基于 Playwright 的浏览器测试和自动化技能。
- **`remotion`**：基于 JSON 渲染的视频和动画生成技能。
- **`remotion-best-practices`**：Remotion 视频项目的最佳实践规则集。
- **`skill-hub-builder`**：个人 skill hub 搭建、同步和分发维护技能。
- **`ui-ux-pro-max`**：Web 与移动端 UI/UX 设计建议技能。
- **`writing-plans`**：面向多步骤实现任务的计划写作和执行拆解技能。

### 软件工程规划、诊断与交付

- **`setup-matt-pocock-skills`**：为 Matt Pocock 工程类技能写入项目级 agent 配置和上下文约定。
- **`grill-me`**：通过连续追问压力测试计划、设计或需求理解。
- **`grill-with-docs`**：结合项目领域语言和文档决策来压力测试方案。
- **`zoom-out`**：在不熟悉代码区域时拉高视角，理解上下文和系统位置。
- **`to-prd`**：把当前需求上下文整理成 PRD 并发布到项目议题系统。
- **`to-issues`**：把计划、规格或 PRD 拆成可独立领取的实现议题。
- **`triage`**：按状态机和标签规则梳理 bug、需求和待处理议题。
- **`diagnose`**：用复现、最小化、假设、观测、修复和回归测试流程诊断问题。
- **`tdd`**：按 red-green-refactor 循环做测试先行开发。
- **`improve-codebase-architecture`**：发现架构摩擦和模块加深机会，提出可测试性重构方向。
- **`prototype`**：构建一次性原型来验证状态模型、交互或 UI 方向。
- **`handoff`**：把当前上下文压缩成交接文档，方便另一个 agent 接手。
- **`write-a-skill`**：创建结构化、可复用的 agent skill。
- **`caveman`**：启用极简表达模式，减少 token 消耗。

### 投资与金融分析

- **`china-stock-analysis`**：A 股价值投资分析工具。
- **`finviz-screener`**：基于 FinViz 的股票筛选技能。
- **`institutional-flow-tracker`**：机构持仓与资金流向分析技能。
- **`news-sentiment`**：市场新闻和情绪分析技能。
- **`stock-analyst`**：股票技术面和指标分析技能。
- **`stock-metrics`**：核心股票指标与财报数据抓取技能。
- **`xai-stock-sentiment`**：基于 X/Twitter 数据的股票情绪分析技能。
- **`yahoo-data-fetcher`**：Yahoo Finance 实时行情数据获取技能。

### 写作、研究与内容整理

- **`ai-wechat-hotspot-writer`**：AI 热点收集、筛选和微信公众号文章写作技能。
- **`humanizer-zh`**：中文写作润色和去 AI 痕迹技能。
- **`sensight`**：社媒热点、AI 行业资讯、作者动态和语义检索技能。

### 视觉、图片与发布

- **`baoyu-article-illustrator`**：为文章结构生成插图建议和图像提示词。
- **`baoyu-cover-image`**：生成文章封面图提示词和视觉方案。
- **`baoyu-imagine`**：多模型图片生成工作流技能。
- **`baoyu-infographic`**：信息图生成技能。
- **`baoyu-post-to-wechat`**：微信公众号文章或图文发布技能。
- **`baoyu-post-to-x`**：X/Twitter 内容发布技能。
- **`baoyu-xhs-images`**：小红书图文卡片生成技能。
- **`chatgpt-images-fallback`**：主图像 API 失败时回退到 ChatGPT Images 的图片生成技能。
- **`nano-banana-2`**：基于 Gemini 3.1 Flash Image Preview 的图片生成和编辑技能。

## 维护流程

不要直接维护 `skills/<name>/` 下的镜像产物。修改来源后重新同步。

1. 修改来源清单：
   - 镜像 skill：编辑 `skills/registry.tsv`
   - proxy skill：编辑 `skills/proxy_registry.tsv`
   - bundle：编辑 `skills/bundles.tsv`
2. 运行本地校验：

   ```bash
   bash skills/check-registry.sh
   ```

3. 重新生成分发产物：

   ```bash
   bash skills/update.sh
   ```

   如果已经手动更新过 submodule，或当前环境不方便联网：

   ```bash
   bash skills/update.sh --skip-submodule-update
   ```

4. 在仓库根目录检查生成结果：

   ```bash
   python -m json.tool skills-lock.json > /dev/null
   git diff -- skills skills-lock.json
   ```

GitHub Actions 会执行 registry 校验、重新生成产物并检查 drift。
