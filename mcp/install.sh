#!/bin/bash

set -e

REPO_ROOT_URL="${AIHUB_MCP_REPO_URL:-https://raw.githubusercontent.com/zhangga/aihub/main/mcp}"
REGISTRY_URL="${AIHUB_MCP_REGISTRY_URL:-$REPO_ROOT_URL/registry.tsv}"
BUNDLES_URL="${AIHUB_MCP_BUNDLES_URL:-$REPO_ROOT_URL/bundles.tsv}"
NODE_BIN="${AIHUB_MCP_NODE_BIN:-}"
CODEX_BIN="${AIHUB_MCP_CODEX_BIN:-codex}"
CLAUDE_BIN="${AIHUB_MCP_CLAUDE_BIN:-claude}"
VSCODE_BIN="${AIHUB_MCP_VSCODE_BIN:-code}"
CLAUDE_DESKTOP_CONFIG_OVERRIDE="${AIHUB_MCP_CLAUDE_DESKTOP_CONFIG:-}"

CLIENT=""
SERVER=""
BUNDLE=""
SCOPE="user"
DRY_RUN=0
LIST_SERVERS=0
LIST_BUNDLES=0
EXTRA_ARGS=()
EXTRA_ENVS=()

fail() {
    echo "Error: $1" >&2
    exit 1
}

need_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        fail "$1 was not found."
    fi
}

resolve_node_bin() {
    if [ -n "$NODE_BIN" ]; then
        return
    fi
    if command -v node >/dev/null 2>&1; then
        NODE_BIN="node"
        return
    fi
    if command -v nodejs >/dev/null 2>&1; then
        NODE_BIN="nodejs"
        return
    fi
    fail "node or nodejs was not found."
}

usage() {
    cat <<'EOF'
Usage: bash mcp/install.sh --client <name> (--server <name> | --bundle <name>) [--scope user] [--arg <value>] [--env KEY=VALUE] [--dry-run]
       bash mcp/install.sh --list-servers
       bash mcp/install.sh --list-bundles
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --client)
            CLIENT="${2:-}"
            shift 2
            ;;
        --server)
            SERVER="${2:-}"
            shift 2
            ;;
        --bundle)
            BUNDLE="${2:-}"
            shift 2
            ;;
        --scope)
            SCOPE="${2:-}"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --arg)
            [ $# -ge 2 ] || fail "--arg requires a value."
            EXTRA_ARGS+=("$2")
            shift 2
            ;;
        --env)
            [ $# -ge 2 ] || fail "--env requires a KEY=VALUE pair."
            EXTRA_ENVS+=("$2")
            shift 2
            ;;
        --list-servers)
            LIST_SERVERS=1
            shift
            ;;
        --list-bundles)
            LIST_BUNDLES=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage
            fail "unknown argument: $1"
            ;;
    esac
done

if [ "$SCOPE" != "user" ]; then
    fail "only --scope user is supported in the first release."
fi

fetch_resource() {
    local source="$1"
    if [ -f "$source" ]; then
        cat "$source"
        return
    fi
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$source"
        return
    fi
    if command -v wget >/dev/null 2>&1; then
        wget -qO- "$source"
        return
    fi
    fail "curl or wget is required to fetch remote MCP metadata."
}

if [ "$LIST_SERVERS" -eq 1 ]; then
    fetch_resource "$REGISTRY_URL" | awk -F '\t' 'NF && $1 !~ /^#/ { print $1 }'
    exit 0
fi

if [ "$LIST_BUNDLES" -eq 1 ]; then
    fetch_resource "$BUNDLES_URL" | awk -F '\t' 'NF && $1 !~ /^#/ { printf "%s - %s\n", $1, $2 }'
    exit 0
fi

resolve_node_bin

if [ -n "$SERVER" ] && [ -n "$BUNDLE" ]; then
    fail "choose either --server or --bundle, not both."
fi

if [ -z "$CLIENT" ]; then
    fail "--client is required."
fi

if [ -z "$SERVER" ] && [ -z "$BUNDLE" ]; then
    fail "either --server or --bundle is required."
fi

read_registry_entry() {
    local wanted="$1"
    fetch_resource "$REGISTRY_URL" | awk -F '\t' -v wanted="$wanted" '
        NF && $1 !~ /^#/ && $1 == wanted { print; found=1; exit }
        END { if (!found) exit 1 }
    '
}

resolve_bundle_servers() {
    local wanted="$1"
    fetch_resource "$BUNDLES_URL" | awk -F '\t' -v wanted="$wanted" '
        NF && $1 !~ /^#/ && $1 == wanted { print $3; found=1; exit }
        END { if (!found) exit 1 }
    '
}

canonical_json_from_row() {
    local row="$1"
    printf '%s' "$row" | "$NODE_BIN" -e '
const fs = require("fs");
const line = fs.readFileSync(0, "utf8").trim();
const parts = line.split("\t");
if (parts.length < 6) {
  console.error("Malformed registry row");
  process.exit(1);
}
const [name, runtime, source, argsJson, envJson] = parts;
const args = JSON.parse(argsJson);
const env = JSON.parse(envJson);
const extraArgs = JSON.parse(process.argv[1]);
const extraEnvs = JSON.parse(process.argv[2]);
let command = runtime;
let finalArgs = [];
if (runtime === "npx") {
  command = "npx";
  finalArgs = ["-y", source, ...args, ...extraArgs];
} else if (runtime === "node") {
  command = "node";
  finalArgs = [source, ...args, ...extraArgs];
} else {
  command = runtime;
  finalArgs = [source, ...args, ...extraArgs];
}
process.stdout.write(JSON.stringify({ name, command, args: finalArgs, env: { ...env, ...extraEnvs } }));
' "$(printf '%s\n' "${EXTRA_ARGS[@]}" | "$NODE_BIN" -e 'const fs=require("fs"); const input=fs.readFileSync(0,"utf8").split(/\r?\n/).filter(Boolean); process.stdout.write(JSON.stringify(input));')" "$(printf '%s\n' "${EXTRA_ENVS[@]}" | "$NODE_BIN" -e 'const fs=require("fs"); const envs={}; for (const line of fs.readFileSync(0,"utf8").split(/\r?\n/)) { if (!line) continue; const idx=line.indexOf("="); if (idx === -1) { console.error("Malformed --env entry: " + line); process.exit(1); } envs[line.slice(0, idx)] = line.slice(idx + 1); } process.stdout.write(JSON.stringify(envs));')"
}

supports_client() {
    local row="$1"
    local wanted_client="$2"
    printf '%s' "$row" | "$NODE_BIN" -e '
const fs = require("fs");
const line = fs.readFileSync(0, "utf8").trim();
const parts = line.split("\t");
const supports = (parts[5] || "").split(",").map(v => v.trim()).filter(Boolean);
const wanted = process.argv[1];
process.exit(supports.includes(wanted) ? 0 : 1);
' "$wanted_client"
}

claude_desktop_config_path() {
    if [ -n "$CLAUDE_DESKTOP_CONFIG_OVERRIDE" ]; then
        printf '%s\n' "$CLAUDE_DESKTOP_CONFIG_OVERRIDE"
        return
    fi

    case "$(uname -s)" in
        Darwin)
            printf '%s\n' "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
            ;;
        Linux)
            if [ -n "${XDG_CONFIG_HOME:-}" ]; then
                printf '%s\n' "$XDG_CONFIG_HOME/Claude/claude_desktop_config.json"
            else
                printf '%s\n' "$HOME/.config/Claude/claude_desktop_config.json"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            if [ -n "${APPDATA:-}" ]; then
                printf '%s\n' "$APPDATA/Claude/claude_desktop_config.json"
            else
                fail "APPDATA is required to locate Claude Desktop config on Windows."
            fi
            ;;
        *)
            fail "unsupported platform for Claude Desktop config discovery."
            ;;
    esac
}

install_claude_code() {
    local json="$1"
    need_command "$CLAUDE_BIN"
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "$CLAUDE_BIN mcp add-json --scope user $(printf '%q' "$(printf '%s' "$json" | "$NODE_BIN" -e 'const x=JSON.parse(require("fs").readFileSync(0,"utf8")); process.stdout.write(x.name);')") $(printf '%q' "$json")"
        return
    fi

    local name
    name="$(printf '%s' "$json" | "$NODE_BIN" -e 'const x=JSON.parse(require("fs").readFileSync(0,"utf8")); process.stdout.write(x.name)')"
    "$CLAUDE_BIN" mcp add-json --scope user "$name" "$json"
}

install_codex() {
    local json="$1"
    need_command "$CODEX_BIN"
    local tmp
    tmp="$(mktemp)"
    printf '%s' "$json" > "$tmp"
    if [ "$DRY_RUN" -eq 1 ]; then
        "$NODE_BIN" - "$tmp" "$CODEX_BIN" <<'EOF'
const fs = require("fs");
const [tmp, bin] = process.argv.slice(2);
const entry = JSON.parse(fs.readFileSync(tmp, "utf8"));
const envFlags = Object.entries(entry.env || {}).flatMap(([k, v]) => ["--env", `${k}=${v}`]);
const parts = [bin, "mcp", "add", entry.name, ...envFlags, "--", entry.command, ...(entry.args || [])];
console.log(parts.map(v => /[\s"]/u.test(v) ? JSON.stringify(v) : v).join(" "));
EOF
        rm -f "$tmp"
        return
    fi

    "$NODE_BIN" - "$tmp" "$CODEX_BIN" <<'EOF'
const fs = require("fs");
const { spawnSync } = require("child_process");
const [tmp, bin] = process.argv.slice(2);
const entry = JSON.parse(fs.readFileSync(tmp, "utf8"));
const args = ["mcp", "add", entry.name];
for (const [k, v] of Object.entries(entry.env || {})) {
  args.push("--env", `${k}=${v}`);
}
args.push("--", entry.command, ...(entry.args || []));
const result = spawnSync(bin, args, { stdio: "inherit" });
process.exit(result.status ?? 1);
EOF
    rm -f "$tmp"
}

install_vscode() {
    local json="$1"
    need_command "$VSCODE_BIN"
    local vscode_json
    vscode_json="$(printf '%s' "$json" | "$NODE_BIN" -e '
const entry = JSON.parse(require("fs").readFileSync(0, "utf8"));
process.stdout.write(JSON.stringify({
  name: entry.name,
  command: entry.command,
  args: entry.args,
  env: entry.env
}));
')"
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "$VSCODE_BIN --add-mcp $(printf '%q' "$vscode_json")"
        return
    fi
    "$VSCODE_BIN" --add-mcp "$vscode_json"
}

install_claude_desktop() {
    local json="$1"
    local config_path
    config_path="$(claude_desktop_config_path)"
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "Target config: $config_path"
        printf '%s\n' "$json" | "$NODE_BIN" -e '
const entry = JSON.parse(require("fs").readFileSync(0, "utf8"));
console.log(JSON.stringify({
  mcpServers: {
    [entry.name]: {
      type: "stdio",
      command: entry.command,
      args: entry.args,
      env: entry.env
    }
  }
}, null, 2));
'
        return
    fi

    local config_dir
    config_dir="$(dirname "$config_path")"
    mkdir -p "$config_dir"

    if [ -f "$config_path" ]; then
        cp "$config_path" "$config_path.bak"
    fi

    local tmp_input tmp_output
    tmp_input="$(mktemp)"
    tmp_output="$(mktemp)"
    printf '%s' "$json" > "$tmp_input"
    "$NODE_BIN" - "$config_path" "$tmp_input" "$tmp_output" <<'EOF'
const fs = require("fs");
const [configPath, inputPath, outputPath] = process.argv.slice(2);
const entry = JSON.parse(fs.readFileSync(inputPath, "utf8"));
let doc = {};
if (fs.existsSync(configPath)) {
  const raw = fs.readFileSync(configPath, "utf8").trim();
  doc = raw ? JSON.parse(raw) : {};
}
if (!doc.mcpServers || typeof doc.mcpServers !== "object" || Array.isArray(doc.mcpServers)) {
  doc.mcpServers = {};
}
doc.mcpServers[entry.name] = {
  type: "stdio",
  command: entry.command,
  args: entry.args || [],
  env: entry.env || {}
};
fs.writeFileSync(outputPath, JSON.stringify(doc, null, 2) + "\n");
EOF
    mv "$tmp_output" "$config_path"
    rm -f "$tmp_input"
    echo "Updated $config_path"
}

install_entry() {
    local row="$1"
    supports_client "$row" "$CLIENT" || fail "server does not support client '$CLIENT'."
    local canonical_json
    canonical_json="$(canonical_json_from_row "$row")"

    case "$CLIENT" in
        claude-code)
            install_claude_code "$canonical_json"
            ;;
        codex)
            install_codex "$canonical_json"
            ;;
        vscode)
            install_vscode "$canonical_json"
            ;;
        claude-desktop)
            install_claude_desktop "$canonical_json"
            ;;
        *)
            fail "unsupported client: $CLIENT"
            ;;
    esac
}

TARGET_SERVERS=()
if [ -n "$SERVER" ]; then
    TARGET_SERVERS+=("$SERVER")
else
    bundle_servers="$(resolve_bundle_servers "$BUNDLE")" || fail "unknown bundle: $BUNDLE"
    IFS=',' read -r -a TARGET_SERVERS <<< "$bundle_servers"
fi

echo "Installing MCP entries for client: $CLIENT"
echo "Scope: $SCOPE"
if [ "$DRY_RUN" -eq 1 ]; then
    echo "Mode: dry-run"
fi
echo "--------------------------------------------------"

for target in "${TARGET_SERVERS[@]}"; do
    target="$(printf '%s' "$target" | xargs)"
    [ -n "$target" ] || continue
    echo "Processing: $target"
    row="$(read_registry_entry "$target")" || fail "unknown server: $target"
    install_entry "$row"
    echo "--------------------------------------------------"
done

echo "MCP installation finished."
