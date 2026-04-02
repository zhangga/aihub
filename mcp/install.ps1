param(
    [string]$Client,
    [string]$Server,
    [string]$Bundle,
    [string]$Scope = "user",
    [string[]]$Arg,
    [string[]]$Env,
    [switch]$DryRun,
    [switch]$ListServers,
    [switch]$ListBundles
)

$ErrorActionPreference = "Stop"

function Install-AihubMcp {
    param(
        [string]$Client,
        [string]$Server,
        [string]$Bundle,
        [string]$Scope = "user",
        [string[]]$Arg,
        [string[]]$Env,
        [switch]$DryRun,
        [switch]$ListServers,
        [switch]$ListBundles
    )

    $repoRootUrl = if ($env:AIHUB_MCP_REPO_URL) { $env:AIHUB_MCP_REPO_URL } else { "https://raw.githubusercontent.com/zhangga/aihub/main/mcp" }
    $registryUrl = if ($env:AIHUB_MCP_REGISTRY_URL) { $env:AIHUB_MCP_REGISTRY_URL } else { "$repoRootUrl/registry.tsv" }
    $bundlesUrl = if ($env:AIHUB_MCP_BUNDLES_URL) { $env:AIHUB_MCP_BUNDLES_URL } else { "$repoRootUrl/bundles.tsv" }
    $codexBin = if ($env:AIHUB_MCP_CODEX_BIN) { $env:AIHUB_MCP_CODEX_BIN } else { "codex" }
    $claudeBin = if ($env:AIHUB_MCP_CLAUDE_BIN) { $env:AIHUB_MCP_CLAUDE_BIN } else { "claude" }
    $vscodeBin = if ($env:AIHUB_MCP_VSCODE_BIN) { $env:AIHUB_MCP_VSCODE_BIN } else { "code" }
    $claudeDesktopConfigOverride = $env:AIHUB_MCP_CLAUDE_DESKTOP_CONFIG
    $nodeBin = if ($env:AIHUB_MCP_NODE_BIN) { $env:AIHUB_MCP_NODE_BIN } else { $null }

    function Fail([string]$Message) {
        throw $Message
    }

    function Get-RemoteLines([string]$Url) {
        if (Test-Path $Url) {
            $content = Get-Content $Url -Raw
            return $content -split "`n"
        }

        $content = Invoke-RestMethod -Uri $Url -UseBasicParsing
        return $content -split "`n"
    }

    function Get-RegistryRow([string]$Name) {
        foreach ($line in Get-RemoteLines $registryUrl) {
            if ([string]::IsNullOrWhiteSpace($line) -or $line.Trim().StartsWith("#")) {
                continue
            }
            $parts = $line.TrimEnd("`r") -split "`t"
            if ($parts[0] -eq $Name) {
                return $parts
            }
        }
        return $null
    }

    function Get-BundleServers([string]$Name) {
        foreach ($line in Get-RemoteLines $bundlesUrl) {
            if ([string]::IsNullOrWhiteSpace($line) -or $line.Trim().StartsWith("#")) {
                continue
            }
            $parts = $line.TrimEnd("`r") -split "`t"
            if ($parts[0] -eq $Name) {
                return $parts[2].Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ }
            }
        }
        return $null
    }

    function ConvertTo-HashtableCompat($Value) {
        if ($null -eq $Value) {
            return $null
        }

        if ($Value -is [string] -or $Value -is [ValueType]) {
            return $Value
        }

        if ($Value -is [System.Collections.IDictionary]) {
            $hash = @{}
            foreach ($key in $Value.Keys) {
                $hash[$key] = ConvertTo-HashtableCompat $Value[$key]
            }
            return $hash
        }

        if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
            $items = @()
            foreach ($item in $Value) {
                $items += ,(ConvertTo-HashtableCompat $item)
            }
            return $items
        }

        if ($Value.PSObject -and $Value.PSObject.Properties.Count -gt 0) {
            $hash = @{}
            foreach ($prop in $Value.PSObject.Properties) {
                $hash[$prop.Name] = ConvertTo-HashtableCompat $prop.Value
            }
            return $hash
        }

        return $Value
    }

    function Convert-RowToCanonicalEntry([string[]]$Row) {
        if ($Row.Count -lt 6) {
            Fail "Malformed registry entry."
        }

        $args = @()
        $envMap = @{}

        if (-not [string]::IsNullOrWhiteSpace($Row[3])) {
            $args = @((ConvertFrom-Json $Row[3]))
        }

        if (-not [string]::IsNullOrWhiteSpace($Row[4])) {
            $rawEnv = ConvertTo-HashtableCompat (ConvertFrom-Json $Row[4])
            if ($rawEnv) {
                foreach ($key in $rawEnv.Keys) {
                    $envMap[$key] = [string]$rawEnv[$key]
                }
            }
        }

        foreach ($extraArg in ($Arg | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })) {
            $args += $extraArg
        }

        foreach ($envItem in ($Env | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })) {
            $idx = $envItem.IndexOf("=")
            if ($idx -lt 1) {
                Fail "Malformed -Env entry: $envItem"
            }
            $envMap[$envItem.Substring(0, $idx)] = $envItem.Substring($idx + 1)
        }

        $runtime = $Row[1]
        $source = $Row[2]

        switch ($runtime) {
            "npx" {
                $command = "npx"
                $finalArgs = @("-y", $source) + $args
            }
            "node" {
                $command = "node"
                $finalArgs = @($source) + $args
            }
            default {
                $command = $runtime
                $finalArgs = @($source) + $args
            }
        }

        return @{
            name = $Row[0]
            command = $command
            args = $finalArgs
            env = $envMap
            supports = $Row[5].Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        }
    }

    function Get-ClaudeDesktopConfigPath {
        if (-not [string]::IsNullOrWhiteSpace($claudeDesktopConfigOverride)) {
            return $claudeDesktopConfigOverride
        }

        if ($IsWindows) {
            if ([string]::IsNullOrWhiteSpace($env:APPDATA)) {
                Fail "APPDATA is required to locate Claude Desktop config."
            }
            return Join-Path $env:APPDATA "Claude\\claude_desktop_config.json"
        }

        if ($IsMacOS) {
            return Join-Path $HOME "Library/Application Support/Claude/claude_desktop_config.json"
        }

        $base = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME ".config" }
        return Join-Path $base "Claude/claude_desktop_config.json"
    }

    function Ensure-Command([string]$Name) {
        if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
            Fail "$Name was not found."
        }
    }

    function Get-NodeBin {
        if (-not [string]::IsNullOrWhiteSpace($nodeBin)) {
            Ensure-Command $nodeBin
            return $nodeBin
        }

        foreach ($candidate in @("node", "node.exe", "nodejs")) {
            if (Get-Command $candidate -ErrorAction SilentlyContinue) {
                return $candidate
            }
        }

        Fail "node was not found."
    }

    function Install-ClaudeCode($Entry) {
        Ensure-Command $claudeBin
        $json = @{
            type = "stdio"
            command = $Entry.command
            args = $Entry.args
            env = $Entry.env
        } | ConvertTo-Json -Depth 6 -Compress

        if ($DryRun) {
            Write-Host "$claudeBin mcp add-json --scope user $($Entry.name) $json"
            return
        }

        & $claudeBin mcp add-json --scope user $Entry.name $json
        if ($LASTEXITCODE -ne 0) {
            Fail "Claude Code MCP install failed."
        }
    }

    function Install-Codex($Entry) {
        Ensure-Command $codexBin
        $args = @("mcp", "add", $Entry.name)
        foreach ($item in $Entry.env.GetEnumerator()) {
            $args += @("--env", ("{0}={1}" -f $item.Key, $item.Value))
        }
        $args += @("--", $Entry.command)
        $args += $Entry.args

        if ($DryRun) {
            Write-Host ($codexBin + " " + (($args | ForEach-Object {
                if ($_ -match '\s|\"') { '"' + ($_ -replace '"', '\"') + '"' } else { $_ }
            }) -join " "))
            return
        }

        & $codexBin @args
        if ($LASTEXITCODE -ne 0) {
            Fail "Codex MCP install failed."
        }
    }

    function Install-VSCode($Entry) {
        Ensure-Command $vscodeBin
        $json = @{
            name = $Entry.name
            command = $Entry.command
            args = $Entry.args
            env = $Entry.env
        } | ConvertTo-Json -Depth 6 -Compress

        if ($DryRun) {
            Write-Host "$vscodeBin --add-mcp $json"
            return
        }

        & $vscodeBin --add-mcp $json
        if ($LASTEXITCODE -ne 0) {
            Fail "VS Code MCP install failed."
        }
    }

    function Install-ClaudeDesktop($Entry) {
        $resolvedNodeBin = Get-NodeBin
        $configPath = Get-ClaudeDesktopConfigPath
        $serverConfig = @{
            type = "stdio"
            command = $Entry.command
            args = $Entry.args
            env = $Entry.env
        }

        if ($DryRun) {
            Write-Host "Target config: $configPath"
            @{ mcpServers = @{ ($Entry.name) = $serverConfig } } | ConvertTo-Json -Depth 8
            return
        }

        $configDir = Split-Path -Parent $configPath
        if (-not (Test-Path $configDir)) {
            New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        }

        if (Test-Path $configPath) {
            Copy-Item $configPath "$configPath.bak" -Force
        }

        $entryJson = @{
            name = $Entry.name
            command = $Entry.command
            args = $Entry.args
            env = $Entry.env
        } | ConvertTo-Json -Depth 8 -Compress

        $tmp = [System.IO.Path]::GetTempFileName()
        try {
            Set-Content $tmp $entryJson
            & $resolvedNodeBin -e @"
const fs = require('fs');
const configPath = process.argv[1];
const entryPath = process.argv[2];
const entry = JSON.parse(fs.readFileSync(entryPath, 'utf8'));
let doc = {};
if (fs.existsSync(configPath)) {
  const raw = fs.readFileSync(configPath, 'utf8').trim();
  doc = raw ? JSON.parse(raw) : {};
}
if (!doc.mcpServers || typeof doc.mcpServers !== 'object' || Array.isArray(doc.mcpServers)) {
  doc.mcpServers = {};
}
doc.mcpServers[entry.name] = {
  type: 'stdio',
  command: entry.command,
  args: entry.args || [],
  env: entry.env || {}
};
fs.writeFileSync(configPath, JSON.stringify(doc, null, 2) + '\n');
"@ $configPath $tmp
            if ($LASTEXITCODE -ne 0) {
                Fail "Claude Desktop MCP install failed."
            }
        } finally {
            Remove-Item $tmp -Force -ErrorAction SilentlyContinue
        }

        Write-Host "Updated $configPath"
    }

    if ($Scope -ne "user") {
        Fail "Only user scope is supported in the first release."
    }

    if ($ListServers) {
        foreach ($line in Get-RemoteLines $registryUrl) {
            if ([string]::IsNullOrWhiteSpace($line) -or $line.Trim().StartsWith("#")) {
                continue
            }
            ($line.TrimEnd("`r") -split "`t")[0]
        }
        return
    }

    if ($ListBundles) {
        foreach ($line in Get-RemoteLines $bundlesUrl) {
            if ([string]::IsNullOrWhiteSpace($line) -or $line.Trim().StartsWith("#")) {
                continue
            }
            $parts = $line.TrimEnd("`r") -split "`t"
            Write-Host ("{0} - {1}" -f $parts[0], $parts[1])
        }
        return
    }

    if ([string]::IsNullOrWhiteSpace($Client)) {
        Fail "--Client is required."
    }

    if (-not [string]::IsNullOrWhiteSpace($Server) -and -not [string]::IsNullOrWhiteSpace($Bundle)) {
        Fail "Choose either -Server or -Bundle, not both."
    }

    if ([string]::IsNullOrWhiteSpace($Server) -and [string]::IsNullOrWhiteSpace($Bundle)) {
        Fail "Either -Server or -Bundle is required."
    }

    $targets = if (-not [string]::IsNullOrWhiteSpace($Server)) {
        @($Server)
    } else {
        $resolved = Get-BundleServers $Bundle
        if (-not $resolved) {
            Fail "Unknown bundle: $Bundle"
        }
        $resolved
    }

    Write-Host "Installing MCP entries for client: $Client" -ForegroundColor Cyan
    Write-Host "Scope: $Scope" -ForegroundColor Cyan
    if ($DryRun) {
        Write-Host "Mode: dry-run" -ForegroundColor Yellow
    }
    Write-Host "--------------------------------------------------" -ForegroundColor Cyan

    foreach ($target in $targets) {
        if ([string]::IsNullOrWhiteSpace($target)) {
            continue
        }

        Write-Host "Processing: $target" -ForegroundColor Yellow
        $row = Get-RegistryRow $target
        if (-not $row) {
            Fail "Unknown server: $target"
        }

        $entry = Convert-RowToCanonicalEntry $row
        if ($entry.supports -notcontains $Client) {
            Fail "Server '$target' does not support client '$Client'."
        }

        switch ($Client) {
            "claude-code" { Install-ClaudeCode $entry }
            "claude-desktop" { Install-ClaudeDesktop $entry }
            "codex" { Install-Codex $entry }
            "vscode" { Install-VSCode $entry }
            default { Fail "Unsupported client: $Client" }
        }

        Write-Host "--------------------------------------------------" -ForegroundColor Cyan
    }

    Write-Host "MCP installation finished." -ForegroundColor Green
}

Install-AihubMcp -Client $Client -Server $Server -Bundle $Bundle -Scope $Scope -Arg $Arg -Env $Env -DryRun:$DryRun -ListServers:$ListServers -ListBundles:$ListBundles
