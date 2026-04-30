# Prompts

这个目录用于沉淀可直接复制到 LLM 或 Agent 工具中的 Markdown 提示词模板。

当前内容：

- `AGENTS.md`：通用 Agent 工作规范模板，强调简洁、根因导向、最小影响、计划、执行、验证和复盘。
- `CLAUDE.md`：Claude Code 兼容入口，指向同目录的 `AGENTS.md`。

维护约定：

- 每个 prompt 应保持自包含，避免依赖外部对话上下文。
- 不要写入 API Key、访问令牌、个人隐私信息或私有项目细节。
- 如果 prompt 适合被下游项目直接复用，优先使用 Markdown 文件保存。
