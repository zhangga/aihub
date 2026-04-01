# Local Skills

这个目录用于存放仓库内自研的 skill 源码。

- 在这里开发和维护你自己编写的 skills
- 通过 `skills/registry.tsv` 里的 `local` 条目将它们纳入分发
- 执行 `bash skills/update.sh` 后，对应 skill 会被复制到 `skills/` 目录作为最终分发产物

推荐约定：

- 一个 skill 一个子目录，例如 `local-skills/my-skill`
- skill 的目录名与 `registry.tsv` 中的 skill 名称保持一致
- 不要直接在 `skills/` 里修改自研 skill，避免源码和分发产物混淆
- 如果某个本地 skill 是“工作流型 skill”，也可以像 `skill-hub-builder` 一样沉淀方法论和维护规范
- 新建本地 skill 时，先通过 `skill-creator` 完成设计与初始化，不要再维护额外的仓库模板入口
