目标：设计一个Skill，让Agent可以在无人值守的情况下自主达成最终目标。
主要功能：
- 分析需求，验证可行性，并生成报告
- 充分理解需求，拆解成可独立实现的任务，定义任务边界条件、规划任务执行过程、约束产出格式
- 每个任务完成后，更新进度，commit到git仓库，通过commit hook触发，任务的review工作，确保代码质量和功能实现
- 一个任务通过review后，再开始下一个任务，任务间可通过git log或任务进度文件进行协调
- 自动处理错误和异常情况


参考文章：https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
参考skill1：https://github.com/affaan-m/everything-claude-code/blob/main/skills/autonomous-loops/SKILL.md
参考skill2：
```
#AutonomousExecutor(自主执行器)
让Claude Code在无人值守的情况下自主实现整个项目。你睡觉,它干活。
##设计理念
基于 Anthropic工程博客【Effective Harnesses for Long-Running Agentsឬ (https://www.anthropic.com/engineering/effective-harnesses-for-loong-running-agents)的核心思路
**状态外化**-所有进度写入文件(task_list.json'+ 'progress.md`+gi),不依赖Agent记忆
**单任务聚焦**-Worker-次只做一个任务,做完 commit,再做下一个
**Git作为记忆层**-每个任务一个commit,新session通过 'git log'恢复上下文
**结构化启动协议**-每次session开始执行固定4步,快速恢复工作状态
##架构
run.sh(外层安全网,bash循环)
-claude-p
--settingshooks.json(Worker Agent,直接写代码)
一Stop Hook → 还有 pending任务? block,继续干
CompactHook→上下文压缩了?注入状态,恢复记忆
只有两层。没有Subagent嵌套,Worker自己动手实现代码、运行验证E、git commit
###为什么是两层?
Anthropic博客验证了bashharness+coding agent的两层架林为足够且最高效
Worker直接干活,上下文利用率最高,不浪费 token在调度层
没有Subagent嵌套,Worker能完整感知代码实现细节
bash只做安全网(循环+错误处理),不参与业务逻辑)
##前置条件
[Claude Code CLI] (https://docs.anthropic.com/en/docs/claude-code/overviewclaude'命令可用
[jq](https://jqlang.github.io/jq/) (`brew install jq` / `apt iinstall jq`)
- Git(项目必须是git仓库)
##使用教程
## 方式一:通过技能触发(推荐)
在项目目录中对Claude Code说:
帮我自动实现这个项目
或者直接用斜杠命令:
```