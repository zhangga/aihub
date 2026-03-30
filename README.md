# AI Hub 🤖

AI Hub 是一个用于沉淀、管理和复用各种 AI 工具、提示词（Prompts）以及智能体技能（Agent Skills）的综合性知识仓库。

无论你是正在使用各种大模型（如 ChatGPT, Claude, Gemini），还是在本地构建或定制自己的 AI Agent 工作流，本仓库都能为你提供开箱即用的模块化能力。

## 📂 仓库结构

- **[`/external`](./external/)**: 用于存放通过 Git Submodule 引入的第三方仓库源。
- **[`/skills`](./skills/)**: 智能体扩展技能库。包含经过筛选从 `external/` 同步过来的核心技能，能够极大地提升 Agent 的行动能力。
  - *请进入 [skills 目录](./skills/README.md) 查看详细的技能列表与使用指南。*
- **[`/prompts`](./prompts/)**: 高质量提示词模板库。沉淀了经过实际验证的、适用于不同场景的系统提示词。

## 🚀 核心特性

1. **依赖管理**: 通过 Git Submodule 和 `update.sh` 脚本统一管理外部技能依赖，避免手动复制带来的代码陈旧问题。
2. **场景丰富**: 涵盖金融分析（如 A 股股票分析）、安全扫描、文档处理等多个领域。
3. **开箱即用**: 提供 `install.sh` 脚本，将本地管理的技能一键部署到你的 Agent 运行环境中。

## 💡 如何使用

### 1. 更新和同步 Skills 
配置 `external/needed_skills.txt` 文件后，在根目录执行：
```bash
bash skills/update.sh
```
> 详见: [Skills 使用说明](./skills/README.md)

### 2. 使用 Prompts (提示词)
你可以直接浏览 `prompts` 目录，寻找符合你需求的 Markdown 文件，复制其中的内容作为大模型的输入参数。

## 📄 许可证

本项目开源，详细请参考根目录下的 [LICENSE](LICENSE) 文件。
