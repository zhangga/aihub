# Autonomous Skill Design

这是一份历史入口文档。早期的“autonomous executor”设想已经收敛为当前的 `long-run-harness` skill。

请优先阅读：

- `docs/skill-design/long-run-harness.md`
- `docs/superpowers/specs/2026-04-01-long-run-harness-design.md`
- `local-skills/long-run-harness/SKILL.md`

当前方向不再追求完全脚本化的无人值守执行器，而是采用半自动 harness：通过持久化状态文件、单任务推进、验证门禁和恢复流程，让 Agent 在长任务中稳定推进。
