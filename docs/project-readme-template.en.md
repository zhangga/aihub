# Project README Template (English)

````md
## AI Skills

This project uses shared agent skills distributed from `zhangga/aihub`.

### Install recommended skills

Mac / Linux / WSL:
```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash -s -- --bundle core
```

Windows PowerShell:
```powershell
irm https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.ps1 | iex
```

### Install to global scope instead

Mac / Linux / WSL:
```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash -s -- --bundle core --global
```

Windows PowerShell:
```powershell
$env:AIHUB_BUNDLE="core"
$env:AIHUB_SCOPE="global"
irm https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.ps1 | iex
```

### Notes

- `project` scope is the default and is recommended for project-specific workflows.
- `global` scope is useful if you want the same skills available across multiple projects.
- Do not commit installed skill artifacts into this repository unless you explicitly want vendored, offline-managed copies.
````
