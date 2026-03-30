# Skills

这个目录用于沉淀和管理各类 Agent 技能（Skills），通过这些扩展技能，可以显著增强 AI Agent 在特定领域的专业分析或执行能力。

为了保持技能的最新状态，我们通过 Git Submodule 管理外部依赖，并提供了一键同步的脚本。

## ⚙️ 技能的同步与更新

本目录下的技能是从 `external/` 目录中的子模块自动拷贝过来的。

1. **配置依赖**: 在根目录的 `external/needed_skills.txt` 文件中按行写入你需要的技能路径（例如 `01coder-agent-skills/skills/china-stock-analysis`）。
2. **执行更新**: 运行以下脚本。该脚本会自动拉取子模块的最新代码，并将 `needed_skills.txt` 中列出的技能拷贝到本目录下。
   ```bash
   bash skills/update.sh
   ```

## 📦 现有技能列表

当前已同步并支持的技能包括：

- **`china-stock-analysis`**: A股价值投资分析工具，基于价值投资理论，提供股票筛选、个股深度分析和估值计算功能。
- **`finviz-screener`**: 基于 FinViz 的股票筛选工具技能。
- **`institutional-flow-tracker`**: 机构资金流向跟踪分析技能。
- **`news-sentiment`**: 市场新闻情绪分析技能。
- **`stock-analyst`**: 专业的股票数据分析辅助工具。
- **`stock-metrics`**: 核心股票指标抓取与计算技能。

## 🚀 安装指南

如果你需要将本目录下的技能安装到你的 Agent 环境中（部分技能可能需要 Node.js），可以使用：

```bash
# 赋予执行权限并运行安装脚本
chmod +x skills/install.sh
./skills/install.sh
```
