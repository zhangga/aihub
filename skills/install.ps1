param(
    [string]$Bundle = $env:AIHUB_BUNDLE,
    [string]$Scope = $env:AIHUB_SCOPE,
    [switch]$ListBundles
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Scope)) {
    $Scope = "project"
}

if ($Scope -notin @("project", "global")) {
    Write-Host "Error: scope must be 'project' or 'global'." -ForegroundColor Red
    exit 1
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Starting AI Hub skill installation..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$RepoUrl = if (-not [string]::IsNullOrWhiteSpace($env:AIHUB_REPO_URL)) { $env:AIHUB_REPO_URL } else { "github.com/zhangga/aihub" }
$SkillsListUrl = if (-not [string]::IsNullOrWhiteSpace($env:AIHUB_SKILLS_LIST_URL)) { $env:AIHUB_SKILLS_LIST_URL } else { "https://raw.githubusercontent.com/zhangga/aihub/main/skills/skills_list.txt" }
$BundlesUrl = if (-not [string]::IsNullOrWhiteSpace($env:AIHUB_BUNDLES_URL)) { $env:AIHUB_BUNDLES_URL } else { "https://raw.githubusercontent.com/zhangga/aihub/main/skills/bundles.tsv" }
$NpxCommand = if (-not [string]::IsNullOrWhiteSpace($env:AIHUB_NPX_CMD)) { $env:AIHUB_NPX_CMD } else { "npx.cmd" }

function New-SanitizedNpmUserConfig {
    $sourcePath = $null

    if (-not [string]::IsNullOrWhiteSpace($env:NPM_CONFIG_USERCONFIG) -and (Test-Path $env:NPM_CONFIG_USERCONFIG)) {
        $sourcePath = $env:NPM_CONFIG_USERCONFIG
    } elseif (-not [string]::IsNullOrWhiteSpace($HOME)) {
        $defaultUserConfig = Join-Path $HOME ".npmrc"
        if (Test-Path $defaultUserConfig) {
            $sourcePath = $defaultUserConfig
        }
    }

    $tempPath = Join-Path ([System.IO.Path]::GetTempPath()) ("aihub-npmrc-{0}.tmp" -f ([System.Guid]::NewGuid().ToString("N")))

    if ($sourcePath) {
        Get-Content $sourcePath | Where-Object { $_ -notmatch '^\s*prefix\s*=' } | Set-Content $tempPath
    } else {
        Set-Content $tempPath ''
    }

    return $tempPath
}

function Invoke-SkillsNpx {
    param(
        [string[]]$Arguments
    )

    $previousUserConfig = $env:NPM_CONFIG_USERCONFIG
    $tempUserConfig = New-SanitizedNpmUserConfig

    try {
        $env:NPM_CONFIG_USERCONFIG = $tempUserConfig
        & $NpxCommand "skills@latest" @Arguments
        return $LASTEXITCODE
    } finally {
        if ([string]::IsNullOrWhiteSpace($previousUserConfig)) {
            Remove-Item Env:NPM_CONFIG_USERCONFIG -ErrorAction SilentlyContinue
        } else {
            $env:NPM_CONFIG_USERCONFIG = $previousUserConfig
        }

        Remove-Item $tempUserConfig -Force -ErrorAction SilentlyContinue
    }
}

function Get-RemoteLines {
    param(
        [string]$Url
    )

    $content = Invoke-RestMethod -Uri $Url -UseBasicParsing
    return $content -split "`n"
}

$skills = @()
$allBundles = @()
$failedSkills = @()

if ($ListBundles) {
    try {
        foreach ($line in Get-RemoteLines -Url $BundlesUrl) {
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
        Write-Host "Error: failed to fetch bundle list." -ForegroundColor Red
        exit 1
    }

    exit 0
}

if (-not (Get-Command $NpxCommand -ErrorAction SilentlyContinue)) {
    Write-Host "Error: $NpxCommand was not found. Please install Node.js and npm first." -ForegroundColor Red
    exit 1
}

if (-not [string]::IsNullOrWhiteSpace($Bundle)) {
    $requestedBundles = $Bundle.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    $foundBundle = $false

    try {
        foreach ($line in Get-RemoteLines -Url $BundlesUrl) {
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
            $allBundles += $bundleName

            if ($requestedBundles -contains $bundleName) {
                $foundBundle = $true
                $bundleSkills.Split(",") | ForEach-Object {
                    $skillName = $_.Trim()
                    if (-not [string]::IsNullOrWhiteSpace($skillName)) {
                        $skills += $skillName
                    }
                }
            }
        }
    } catch {
        Write-Host "Error: failed to fetch bundle list." -ForegroundColor Red
        exit 1
    }

    if (-not $foundBundle) {
        Write-Host "Warning: no matching bundle was found." -ForegroundColor Yellow
        Write-Host "Available bundles:" -ForegroundColor Yellow
        $allBundles | Sort-Object -Unique | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
        exit 0
    }

    $skills = $skills | Select-Object -Unique
} else {
    try {
        foreach ($line in Get-RemoteLines -Url $SkillsListUrl) {
            $cleanLine = $line.Trim()
            if ([string]::IsNullOrWhiteSpace($cleanLine) -or $cleanLine.StartsWith("#")) {
                continue
            }

            $skills += $cleanLine
        }
    } catch {
        Write-Host "Error: failed to fetch skill list." -ForegroundColor Red
        exit 1
    }
}

if ($skills.Count -eq 0) {
    Write-Host "Warning: no skills matched the requested install target." -ForegroundColor Yellow
    exit 0
}

Write-Host "The following skills will be installed:" -ForegroundColor Yellow
if (-not [string]::IsNullOrWhiteSpace($Bundle)) {
    Write-Host "  Bundle: $Bundle" -ForegroundColor Yellow
} else {
    Write-Host "  Mode: full" -ForegroundColor Yellow
}
Write-Host "  Scope: $Scope" -ForegroundColor Yellow
foreach ($skill in $skills) {
    Write-Host "  - $skill" -ForegroundColor Yellow
}
Write-Host "--------------------------------------------------" -ForegroundColor Cyan

foreach ($skill in $skills) {
    Write-Host "Installing: $skill" -ForegroundColor Yellow

    try {
        $cmdArgs = @("add", $RepoUrl, "--skill", $skill, "-y")
        if ($Scope -eq "global") {
            $cmdArgs += "--global"
        }

        $exitCode = Invoke-SkillsNpx -Arguments $cmdArgs

        if ($exitCode -eq 0) {
            Write-Host "Success: $skill installed." -ForegroundColor Green
        } else {
            Write-Host "Error: $skill failed with exit code $exitCode." -ForegroundColor Red
            $failedSkills += $skill
        }
    } catch {
        Write-Host "Error: failed while installing $skill." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        $failedSkills += $skill
    }

    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
}

if ($failedSkills.Count -gt 0) {
    Write-Host "The following skills failed to install:" -ForegroundColor Red
    foreach ($failedSkill in ($failedSkills | Select-Object -Unique)) {
        Write-Host "  - $failedSkill" -ForegroundColor Red
    }
    exit 1
}

Write-Host "Skill installation finished." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
