# MCP Distribution Design

Date: 2026-04-02
Status: Proposed
Owner: Codex

## Summary

This document proposes a new `mcp/` distribution system for the `aihub` repository. The goal is to make MCP servers installable across machines with a one-command experience similar to the current `skills/` distribution flow, while preserving the important difference that MCP distribution must also configure client applications.

The first release targets four clients:

- Codex
- Claude Code
- Claude Desktop
- VS Code

The default install scope is user-global configuration.

The first MCP server shipped through this system will be `chrome-devtools`, backed by `chrome-devtools-mcp@latest`.

## Goals

- Add a repository-native MCP distribution system parallel to `skills/`
- Support online one-command installation from raw GitHub URLs
- Default to user-global installation
- Support installation into Codex, Claude Code, Claude Desktop, and VS Code
- Make adding future MCP servers data-driven through a registry file
- Keep installation behavior predictable, inspectable, and reversible

## Non-Goals

- Building a generic hosted remote MCP platform
- Supporting every MCP client in the first release
- Solving credential lifecycle management for third-party remote MCP servers
- Auto-enabling Chrome remote debugging or bypassing Chrome permission prompts
- Replacing the existing `skills/` system

## Why A Separate `mcp/` Domain

`skills/` distributes prompt assets and reusable instructions. In contrast, MCP distribution needs to install runnable servers and write configuration into specific client applications. Treating MCP as just another skill would blur these responsibilities and lead to a poor "copy docs and do the rest manually" experience.

A dedicated `mcp/` directory keeps the model clean:

- `skills/` explains capabilities and usage
- `mcp/` installs and configures MCP servers

This mirrors the existing repository pattern of keeping different deliverables in separate top-level domains.

## Proposed Directory Structure

```text
mcp/
  README.md
  registry.tsv
  bundles.tsv
  install.sh
  install.ps1
  lib/
    common.sh
    common.ps1
  templates/
    claude-desktop.json
    claude-code.json
    codex.json
    vscode.json
```

Notes:

- `lib/` contains shared install logic so the top-level scripts stay readable
- `templates/` contains minimal configuration fragments or examples for each client
- Unlike `skills/`, the first release does not need an `update.sh` flow because MCP entries are metadata-driven rather than synced from source folders

## Registry Format

`mcp/registry.tsv` is the source of truth for distributable MCP servers.

Initial schema:

```tsv
# name	runtime	source	args	env	supports
chrome-devtools	npx	chrome-devtools-mcp@latest	[]	{}	codex,claude-code,claude-desktop,vscode
```

Field definitions:

- `name`: stable server name exposed to users and written into client config
- `runtime`: execution strategy such as `npx`, `node`, `uvx`, `python`, or `docker`
- `source`: package name, executable, or entrypoint payload for the selected runtime
- `args`: JSON array of default arguments
- `env`: JSON object of default environment variables
- `supports`: comma-separated list of supported clients

Design constraints:

- Registry values must be installable without custom code per server in the first release
- `args` and `env` are stored as JSON to avoid inventing a new escaping format
- Unsupported clients must fail early with a clear message

## Bundles

`mcp/bundles.tsv` groups MCP servers into user-facing install presets.

Example future schema:

```tsv
# bundle	servers	description
browser-dev	chrome-devtools	Browser debugging with Chrome DevTools MCP
```

The first release can ship with either one bundle or none. The installer should support the bundle mechanism from day one so the repository can expand without redesigning CLI flags.

## Installer Interface

Both `install.sh` and `install.ps1` expose a similar surface:

- `--client <name>`
- `--server <name>`
- `--bundle <name>`
- `--scope user`
- `--dry-run`

Behavior:

- Default scope is `user`
- Installing one server is the default path
- `--bundle` installs all servers listed in the bundle
- `--dry-run` prints the resolved config changes without mutating files

The scripts should reject ambiguous invocations, such as specifying both `--server` and `--bundle` unless explicitly supported.

## Client Installation Strategy

The installer uses a two-level strategy:

1. Prefer official client CLI commands when available
2. Fall back to editing the client configuration file directly

### Why Prefer CLIs

Using official CLIs reduces drift in config schema handling, path resolution, and validation rules. It also keeps the install scripts smaller and more future-proof.

### Fallback Rules

If the target client CLI is unavailable, the installer locates the user-global configuration file, creates a backup, merges in the new server definition, and writes the updated config.

Fallback requirements:

- Never overwrite unrelated MCP entries
- Preserve valid existing JSON structure
- Backup before write
- Print the exact config target path

## Per-Client Plan

### Claude Code

Preferred path:

- Use `claude mcp add-json <name> <json> --scope user`

Fallback:

- Direct file editing only if the config location is stable and verified during implementation

### Claude Desktop

Preferred path:

- Use a CLI if one is available and stable enough during implementation

Fallback:

- Edit `claude_desktop_config.json`

### Codex

Preferred path:

- Use a native `codex mcp add` style command if available and confirmed during implementation

Fallback:

- Edit the user MCP config file if its format and location are stable and verified

### VS Code

Preferred path:

- Use `code --add-mcp` or equivalent if available and verified

Fallback:

- Edit the appropriate user settings file if the MCP config surface is stable and documented

Implementation note:

The exact CLI capability and fallback file paths for Codex and VS Code must be verified during implementation from primary documentation or direct local CLI help before shipping.

## Config Generation

The registry entry is transformed into a client-specific server definition.

Canonical internal representation:

```json
{
  "name": "chrome-devtools",
  "command": "npx",
  "args": ["-y", "chrome-devtools-mcp@latest"],
  "env": {}
}
```

Transformation rules:

- For `runtime=npx`, emit `command: "npx"` and prepend `-y` before the package name
- Append registry `args` after the package source
- Merge `env` as-is
- Keep the server key stable across clients

The install layer should generate this canonical object first, then adapt it to each client schema.

## Chrome DevTools MCP First-Party Sample

The first shipped server is:

- Name: `chrome-devtools`
- Runtime: `npx`
- Source: `chrome-devtools-mcp@latest`

Default behavior:

- Install without `--autoConnect`
- Do not force Chrome beta or stable channel flags unless required by current upstream behavior
- Keep optional flags documented rather than silently enabled

Rationale:

- `--autoConnect` depends on browser-side remote debugging setup and user permission prompts
- Safe defaults are more important than aggressive convenience for the first release

Documentation for this server should explain:

- Chrome version requirements where relevant
- How to enable remote debugging in Chrome
- What changes when the user opts into `--autoConnect`
- That Chrome may prompt for debugging permission

## README UX

`mcp/README.md` should provide:

- What this system is for
- Supported clients
- Quick install examples for shell and PowerShell
- A table of available MCP servers
- A note on default global install behavior
- Troubleshooting for missing CLIs and config permissions

Example UX:

```bash
curl -fsSL https://raw.githubusercontent.com/<repo>/main/mcp/install.sh | bash -s -- --client claude-code --server chrome-devtools
```

```powershell
irm https://raw.githubusercontent.com/<repo>/main/mcp/install.ps1 | iex
Install-AihubMcp -Client claude-desktop -Server chrome-devtools
```

## Error Handling

The install scripts must fail loudly and specifically.

Expected error cases:

- Unknown server name
- Unknown bundle name
- Unsupported client for the selected server
- Missing target CLI when no safe fallback exists
- Malformed registry JSON in `args` or `env`
- Unable to read or write user config

Error messages should state:

- What failed
- Which file or client was involved
- The next action the user can take

## Testing Strategy

Testing is mostly script-level validation plus config rendering checks.

Minimum coverage for the first release:

- Registry parser accepts valid rows
- Registry parser rejects malformed JSON in `args` and `env`
- Config rendering for `chrome-devtools` is correct for each supported client
- `--dry-run` produces the expected output without file writes
- Fallback config merge preserves existing entries
- Unsupported client combinations fail with clear messages

Where practical:

- Add smoke-test commands that validate syntax of generated JSON
- Keep tests lightweight and shell-friendly
## Security Considerations

MCP installers execute local commands and alter client configuration, so the system must be explicit and auditable.

Security requirements:

- Do not execute arbitrary registry strings through shell interpolation
- Treat `args` and `env` as structured data
- Backup config files before mutating them
- Print exactly what command definition is being installed
- Avoid enabling privileged or invasive defaults such as `--autoConnect` without opt-in

## Migration and Rollout

Phase 1:

- Add `mcp/` skeleton
- Implement `chrome-devtools`
- Support `Claude Code` and `Claude Desktop`

Phase 2:

- Add verified support for `Codex` and `VS Code`
- Add first bundle entry

Phase 3:

- Add more MCP servers using the same registry format

## Open Decisions Already Resolved

- Use a separate `mcp/` domain instead of overloading `skills/`
- Default install scope is global user config
- First supported clients are Codex, Claude Code, Claude Desktop, and VS Code
- First server is `chrome-devtools`
- Preferred architecture is registry-driven installers with client-specific adapters

## Residual Risks

- Client MCP config surfaces may change faster than shell installers
- Codex and VS Code CLI support must be verified before claiming first-class automation
- Cross-platform config file discovery can be fragile if upstream clients change paths

These are acceptable for the first release if the implementation prefers verified CLI paths and uses conservative fallbacks.


