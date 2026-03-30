# 这个脚本设计为可以直接通过 PowerShell 一键执行：
# irm https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.ps1 | iex

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🚀 开始安装 AI Hub 技能 (Agent Skills)..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 定义主仓库地址
$REPO_URL = "github.com/zhangga/aihub"
# 定义外部依赖列表配置文件的远程地址
$CONFIG_URL = "https://raw.githubusercontent.com/zhangga/aihub/main/skills/skills_list.txt"

# 检查环境依赖
if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    Write-Host "❌ 错误: 未找到 npx 命令！请先安装 Node.js 和 npm。" -ForegroundColor Red
    exit 1
}

Write-Host "📥 正在从远程获取技能列表..." -ForegroundColor Yellow
$SKILLS = @()
try {
    # 获取并解析 skills_list.txt
    $configContent = Invoke-RestMethod -Uri $CONFIG_URL -UseBasicParsing
    
    # 按行分割
    $lines = $configContent -split "`n"
    
    foreach ($line in $lines) {
        $cleanLine = $line.Trim()
        # 忽略空行和注释
        if (-not [string]::IsNullOrWhiteSpace($cleanLine) -and -not $cleanLine.StartsWith("#")) {
            $SKILLS += $cleanLine
        }
    }
} catch {
    Write-Host "❌ 获取技能列表失败！请检查网络连接。" -ForegroundColor Red
    exit 1
}

if ($SKILLS.Count -eq 0) {
    Write-Host "⚠️ 警告: 未获取到任何需要安装的技能。" -ForegroundColor Yellow
    exit 0
}


Write-Host "📦 即将安装以下技能：" -ForegroundColor Yellow
foreach ($skill in $SKILLS) {
    Write-Host "  - $skill" -ForegroundColor Yellow
}
Write-Host "--------------------------------------------------" -ForegroundColor Cyan

# 逐个安装技能
foreach ($skill in $SKILLS) {
    Write-Host "🔄 正在安装: $skill ..." -ForegroundColor Yellow
    
    # 执行远程安装命令
    # 注意：npx skills 默认会去目标仓库中寻找对应的 --skill <name>
    try {
        npx skills@latest add $REPO_URL --skill $skill -y
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✔️  $skill 安装成功！" -ForegroundColor Green
        } else {
            Write-Host "❌ $skill 安装失败！(退出码: $LASTEXITCODE)" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ $skill 安装时发生异常！" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    
    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
}

Write-Host "🎉 所有技能安装流程执行完毕！" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
