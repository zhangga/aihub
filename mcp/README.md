# MCP Distribution

This directory distributes MCP servers with one-command installers, similar to the repository's `skills/` flow.

The first release ships `chrome-devtools` and `filesystem` and targets these clients:

- Codex
- Claude Code
- Claude Desktop
- VS Code

Default install scope is user-global configuration.

## Quick Start

Install one MCP server:

```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/mcp/install.sh | bash -s -- --client claude-code --server chrome-devtools
```

On Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/zhangga/aihub/main/mcp/install.ps1 | iex
Install-AihubMcp -Client claude-desktop -Server chrome-devtools
```

Install the filesystem MCP and allow it to access one local directory:

```bash
curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/mcp/install.sh | bash -s -- --client codex --server filesystem --arg "$HOME/projects"
```

```powershell
irm https://raw.githubusercontent.com/zhangga/aihub/main/mcp/install.ps1 | iex
Install-AihubMcp -Client codex -Server filesystem -Arg "C:\work\github"
```

Preview the config change without mutating local config:

```bash
bash mcp/install.sh --client codex --server chrome-devtools --dry-run
```

```powershell
Install-AihubMcp -Client vscode -Server chrome-devtools -DryRun
```

## Supported Servers

| Name | Runtime | Source | Clients |
|------|---------|--------|---------|
| `chrome-devtools` | `npx` | `chrome-devtools-mcp@latest` | `codex`, `claude-code`, `claude-desktop`, `vscode` |
| `filesystem` | `npx` | `@modelcontextprotocol/server-filesystem` | `codex`, `claude-code`, `claude-desktop`, `vscode` |

## Flags

- `--client <name>`: `codex`, `claude-code`, `claude-desktop`, `vscode`
- `--server <name>`: install one server from `registry.tsv`
- `--bundle <name>`: install all servers from a bundle
- `--scope <scope>`: currently only `user` is supported in the first release
- `--arg <value>`: append an extra argument to the MCP server command. Repeatable.
- `--env KEY=VALUE`: append an extra environment variable to the MCP server definition. Repeatable.
- `--dry-run`: print the resolved config changes without applying them
- `--list-servers`: list available server names
- `--list-bundles`: list available bundle names

## Notes

- `chrome-devtools` is installed with conservative defaults. It does not enable `--autoConnect` by default.
- `filesystem` requires at least one allowed directory path. Pass it with `--arg` in Bash or `-Arg` in PowerShell.
- For Chrome session takeover flows, users still need to enable remote debugging in Chrome and approve the debugging prompt when applicable.
- VS Code user installs use the official `code --add-mcp` CLI path.
- Claude Desktop installs edit `claude_desktop_config.json` directly and create a backup before writing.

## Environment Overrides

These are mainly useful for testing or custom mirrors:

- `AIHUB_MCP_REGISTRY_URL`
- `AIHUB_MCP_BUNDLES_URL`
- `AIHUB_MCP_NODE_BIN`
- `AIHUB_MCP_CODEX_BIN`
- `AIHUB_MCP_CLAUDE_BIN`
- `AIHUB_MCP_VSCODE_BIN`
- `AIHUB_MCP_CLAUDE_DESKTOP_CONFIG`

## Security

- Only install MCP servers from sources you trust.
- Local MCP servers can run arbitrary code on your machine.
- Review generated commands with `--dry-run` before broad rollout.
