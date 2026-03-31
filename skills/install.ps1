param(
    [string]$Bundle = $env:AIHUB_BUNDLE,
    [ValidateSet("project", "global")]
    [string]$Scope = $env:AIHUB_SCOPE,
    [switch]$ListBundles
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Scope)) {
    $Scope = "project"
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🚀 开始安装 AI Hub 技能 (Agent Skills)..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$REPO_URL = "github.com/zhangga/aihub"
$SKILLS_LIST_URL = "https://raw.githubusercontent.com/zhangga/aihub/main/skills/skills_list.txt"
$BUNDLES_URL = "https://raw.githubusercontent.com/zhangga/aihub/main/skills/bundles.tsv"

if (-not (Get-Command npx.cmd -ErrorAction SilentlyContinue)) {
    Write-Host "❌ 错误: 未找到 npx 命令！请先安装 Node.js 和 npm。" -ForegroundColor Red
    exit 1
}

$SKILLS = @()
$ALL_BUNDLES = @()

if ($ListBundles) {
    try {
        $bundleContent = Invoke-RestMethod -Uri $BUNDLES_URL -UseBasicParsing
        $bundleLines = $bundleContent -split "`n"
        foreach ($line in $bundleLines) {
            $cleanLine = $line.Trim()
            if ([string]::IsNullOrWhiteSpace($cleanLine) -or $cleanLine.StartsWith("#")) {
                continue
            }

            $parts = $cleanLine -split "`t"
            if ($parts.Count -lt 2) {
                continue
            }

            Write-Host ("{0} - {1}" -f $parts[0].Trim(), $parts[1].Trim())
        }
    } catch {
        Write-Host "❌ 获取 bundle 列表失败！请检查网络连接。" -ForegroundColor Red
        exit 1
    }

    exit 0
}

if (-not [string]::IsNullOrWhiteSpace($Bundle)) {
    $requestedBundles = $Bundle.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    $foundBundle = $false

    try {
        $bundleContent = Invoke-RestMethod -Uri $BUNDLES_URL -UseBasicParsing
        $bundleLines = $bundleContent -split "`n"
        foreach ($line in $bundleLines) {
            $cleanLine = $line.Trim()
            if ([string]::IsNullOrWhiteSpace($cleanLine) -or $cleanLine.StartsWith("#")) {
                continue
            }

            $parts = $cleanLine -split "`t"
            if ($parts.Count -lt 3) {
                continue
            }

            $bundleName = $parts[0].Trim()
            $bundleSkills = $parts[2].Trim()
            $ALL_BUNDLES += $bundleName

            if ($requestedBundles -contains $bundleName) {
                $foundBundle = $true
                $bundleSkills.Split(",") | ForEach-Object {
                    $skillName = $_.Trim()
                    if (-not [string]::IsNullOrWhiteSpace($skillName)) {
                        $SKILLS += $skillName
                    }
                }
            }
        }
    } catch {
        Write-Host "❌ 获取 bundle 列表失败！请检查网络连接。" -ForegroundColor Red
        exit 1
    }

    if (-not $foundBundle) {
        Write-Host "⚠️ 警告: 未找到符合条件的 bundle。" -ForegroundColor Yellow
        Write-Host "可用 bundle：" -ForegroundColor Yellow
        $ALL_BUNDLES | Sort-Object -Unique | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
        exit 0
    }

    $SKILLS = $SKILLS | Select-Object -Unique
} else {
    try {
        $skillsContent = Invoke-RestMethod -Uri $SKILLS_LIST_URL -UseBasicParsing
        $skillLines = $skillsContent -split "`n"
        foreach ($line in $skillLines) {
            $cleanLine = $line.Trim()
            if ([string]::IsNullOrWhiteSpace($cleanLine) -or $cleanLine.StartsWith("#")) {
                continue
            }

            $SKILLS += $cleanLine
        }
    } catch {
        Write-Host "❌ 获取技能列表失败！请检查网络连接。" -ForegroundColor Red
        exit 1
    }
}

if ($SKILLS.Count -eq 0) {
    Write-Host "⚠️ 警告: 未找到符合条件的技能。" -ForegroundColor Yellow
    exit 0
}

Write-Host "📦 即将安装以下技能：" -ForegroundColor Yellow
if (-not [string]::IsNullOrWhiteSpace($Bundle)) {
    Write-Host "  预设包: $Bundle" -ForegroundColor Yellow
} else {
    Write-Host "  模式: full" -ForegroundColor Yellow
}
Write-Host "  位置: $Scope" -ForegroundColor Yellow
foreach ($skill in $SKILLS) {
    Write-Host "  - $skill" -ForegroundColor Yellow
}
Write-Host "--------------------------------------------------" -ForegroundColor Cyan

foreach ($skill in $SKILLS) {
    Write-Host "🔄 正在安装: $skill ..." -ForegroundColor Yellow

    try {
        $cmdArgs = @("skills@latest", "add", $REPO_URL, "--skill", $skill, "-y")
        if ($Scope -eq "global") {
            $cmdArgs += "--global"
        }

        & npx.cmd @cmdArgs

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
