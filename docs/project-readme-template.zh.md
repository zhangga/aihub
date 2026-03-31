# Project README Template (中文)

````md
## AI Skills

本项目使用 `zhangga/aihub` 分发的共享 agent skills。

### 安装推荐技能

Mac / Linux / WSL：
```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash -s -- --bundle core
```

Windows PowerShell：
```powershell
irm https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.ps1 | iex
```

### 如需安装到全局目录

Mac / Linux / WSL：
```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash -s -- --bundle core --global
```

Windows PowerShell：
```powershell
$env:AIHUB_BUNDLE="core"
$env:AIHUB_SCOPE="global"
irm https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.ps1 | iex
```

### 说明

- 默认使用 `project` 安装方式，适合项目内协作和项目专属工作流。
- 如果希望多个项目共用一套 skills，可以使用 `global` 安装。
- 除非你明确希望把 skills 当作 vendored 依赖或离线依赖管理，否则通常不要把安装产物直接提交进业务仓库。
````
