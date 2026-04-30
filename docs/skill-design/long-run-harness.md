# Long Run Harness 设计说明

`long-run-harness` 是一个用于长周期任务的半自动执行协议。它的目标不是替代 coding agent，也不是把任务完全交给 shell runner，而是让 Agent 在多轮会话、上下文压缩或中断后，仍能通过持久化状态继续朝最终目标推进。

更完整的英文设计文档见：

- `docs/superpowers/specs/2026-04-01-long-run-harness-design.md`

当前实现位置：

- 源码：`local-skills/long-run-harness/`
- 分发产物：`skills/long-run-harness/`
- bundle：`skills/bundles.tsv` 中的 `core` 和 `productivity`

## 目标

- 支持 Codex 或类似 Agent 在长任务中持续推进，而不是完成一个局部步骤后停止。
- 将进度、任务状态和恢复信息写入持久文件，减少对对话上下文的依赖。
- 一次只推进一个明确任务，避免并发修改导致状态混乱。
- 在任务完成前要求验证和复盘，降低误判完成的风险。
- 支持代码、文档、研究等需要多轮推进的任务。

## 非目标

- 不实现完整的无人值守 shell runner。
- 不绑定某一家模型、CLI 或 hook 系统。
- 不在 skill 内编码业务领域逻辑。
- 不默认使用多 subagent 并发实现同一个任务。

## 推荐工作方式

`long-run-harness` 采用两层模型：

1. **Harness 协议层**：由 `SKILL.md` 和 `references/` 定义触发条件、初始化、恢复、任务选择、验证和停止规则。
2. **任务执行层**：由 Agent 在目标仓库中完成实际分析、修改、验证和状态更新。

协议层负责“怎么持续工作”，执行层负责“当前任务具体怎么做”。

## 状态文件

默认使用两个持久化文件：

- `task_list.json`：机器可读的任务列表、当前任务、状态、验收标准、验证结果和阻塞信息。
- `progress.md`：面向人和新会话的简明叙述，记录当前目标、已完成工作、阻塞、风险和下一步。

状态文件应保持简洁。`task_list.json` 提供结构化事实，`progress.md` 提供恢复上下文，两者不要重复堆砌。

## 生命周期

1. **初始化**：明确最终目标和验收标准，拆解任务，创建状态文件，选择第一个任务。
2. **恢复**：新会话开始时先读状态文件和近期 git 历史，再判断当前任务。
3. **执行**：只处理当前任务，完成必要的代码或文档变更。
4. **验证**：运行与风险匹配的测试、构建、脚本校验或人工检查。
5. **复盘**：确认结果是否满足验收标准；高风险任务需要更严格的 review。
6. **更新状态**：记录结果、证据、下一步和阻塞。
7. **继续或停止**：所有验收标准完成则停止；存在硬阻塞则说明原因；否则继续下一个任务。

## 维护约定

- 修改 skill 源码时，应先改 `local-skills/long-run-harness/`，再运行 `bash skills/update.sh --skip-submodule-update` 同步到 `skills/`。
- 如果调整触发条件、状态字段或恢复流程，应同步更新 `references/` 中的说明。
- 如果 bundle 中移除或新增该 skill，应同时更新 `skills/README.md` 和相关项目模板。
