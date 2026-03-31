#!/bin/bash

set -e

echo "=================================================="
echo "Starting AI Hub skill installation..."
echo "=================================================="

REPO_URL="github.com/zhangga/aihub"
SKILLS_LIST_URL="https://raw.githubusercontent.com/zhangga/aihub/main/skills/skills_list.txt"
BUNDLES_URL="https://raw.githubusercontent.com/zhangga/aihub/main/skills/bundles.tsv"
SELECTED_BUNDLE="${AIHUB_BUNDLE:-}"
INSTALL_SCOPE="${AIHUB_SCOPE:-project}"
LIST_BUNDLES=0
TEMP_NPMRC=""

while [ $# -gt 0 ]; do
    case "$1" in
        --bundle)
            if [ $# -lt 2 ]; then
                echo "Error: --bundle requires a value."
                exit 1
            fi
            SELECTED_BUNDLE="$2"
            shift 2
            ;;
        --global)
            INSTALL_SCOPE="global"
            shift
            ;;
        --project)
            INSTALL_SCOPE="project"
            shift
            ;;
        --list-bundles)
            LIST_BUNDLES=1
            shift
            ;;
        *)
            echo "Error: unknown argument: $1"
            echo "Usage: bash install.sh [--bundle <name|a,b>] [--global|--project] [--list-bundles]"
            exit 1
            ;;
    esac
done

if ! command -v npx >/dev/null 2>&1; then
    echo "Error: npx was not found. Please install Node.js and npm first."
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl was not found. Cannot fetch remote skill metadata."
    exit 1
fi

if [[ "$INSTALL_SCOPE" != "project" && "$INSTALL_SCOPE" != "global" ]]; then
    echo "Error: install scope must be 'project' or 'global'."
    exit 1
fi

SKILLS=()
ALL_BUNDLES=()
FAILED_SKILLS=()

unique_lines() {
    awk '!seen[$0]++'
}

cleanup() {
    if [ -n "$TEMP_NPMRC" ] && [ -f "$TEMP_NPMRC" ]; then
        rm -f "$TEMP_NPMRC"
    fi
}

trap cleanup EXIT

prepare_npm_userconfig() {
    local source_npmrc=""

    if [ -n "${NPM_CONFIG_USERCONFIG:-}" ] && [ -f "${NPM_CONFIG_USERCONFIG}" ]; then
        source_npmrc="${NPM_CONFIG_USERCONFIG}"
    elif [ -n "${HOME:-}" ] && [ -f "${HOME}/.npmrc" ]; then
        source_npmrc="${HOME}/.npmrc"
    fi

    TEMP_NPMRC="$(mktemp "${TMPDIR:-/tmp}/aihub-npmrc.XXXXXX")"

    if [ -n "$source_npmrc" ]; then
        awk 'BEGIN { IGNORECASE = 1 } !/^[[:space:]]*prefix[[:space:]]*=/' "$source_npmrc" > "$TEMP_NPMRC"
    else
        : > "$TEMP_NPMRC"
    fi
}

run_skills_command() {
    NPM_CONFIG_USERCONFIG="$TEMP_NPMRC" npx skills@latest "$@"
}

if [ "$LIST_BUNDLES" -eq 1 ]; then
    while IFS=$'\t' read -r raw_bundle raw_description raw_skills; do
        if [[ -z "$raw_bundle" ]] || [[ "$raw_bundle" =~ ^#.* ]]; then
            continue
        fi

        bundle_name="$(printf '%s' "$raw_bundle" | tr -d '\r' | xargs)"
        bundle_description="$(printf '%s' "$raw_description" | tr -d '\r' | xargs)"
        echo "$bundle_name - $bundle_description"
    done < <(curl -fsSL "$BUNDLES_URL")
    exit 0
fi

if [ -n "$SELECTED_BUNDLE" ]; then
    found_bundle=0
    requested_bundles=()
    IFS=',' read -r -a requested_bundles <<< "$SELECTED_BUNDLE"

    while IFS=$'\t' read -r raw_bundle raw_description raw_skills; do
        if [[ -z "$raw_bundle" ]] || [[ "$raw_bundle" =~ ^#.* ]]; then
            continue
        fi

        bundle_name="$(printf '%s' "$raw_bundle" | tr -d '\r' | xargs)"
        bundle_skills="$(printf '%s' "$raw_skills" | tr -d '\r' | xargs)"
        ALL_BUNDLES+=("$bundle_name")

        for requested_bundle in "${requested_bundles[@]}"; do
            requested_bundle="$(printf '%s' "$requested_bundle" | xargs)"
            if [[ -n "$requested_bundle" && "$requested_bundle" == "$bundle_name" ]]; then
                found_bundle=1
                IFS=',' read -r -a bundle_skill_list <<< "$bundle_skills"
                for bundle_skill in "${bundle_skill_list[@]}"; do
                    bundle_skill="$(printf '%s' "$bundle_skill" | xargs)"
                    if [[ -n "$bundle_skill" ]]; then
                        SKILLS+=("$bundle_skill")
                    fi
                done
            fi
        done
    done < <(curl -fsSL "$BUNDLES_URL")

    if [ "$found_bundle" -eq 0 ]; then
        echo "Warning: no matching bundle was found."
        echo "Available bundles:"
        printf '%s\n' "${ALL_BUNDLES[@]}" | sort -u | sed 's/^/  - /'
        exit 0
    fi

    mapfile -t SKILLS < <(printf '%s\n' "${SKILLS[@]}" | unique_lines)
else
    while IFS= read -r line; do
        if [[ -z "$line" ]] || [[ "$line" =~ ^#.* ]]; then
            continue
        fi

        skill_name="$(printf '%s' "$line" | tr -d '\r' | xargs)"
        if [[ -n "$skill_name" ]]; then
            SKILLS+=("$skill_name")
        fi
    done < <(curl -fsSL "$SKILLS_LIST_URL")
fi

if [ ${#SKILLS[@]} -eq 0 ]; then
    echo "Warning: no skills matched the requested install target."
    exit 0
fi

echo "The following skills will be installed:"
if [ -n "$SELECTED_BUNDLE" ]; then
    echo "  Bundle: $SELECTED_BUNDLE"
else
    echo "  Mode: full"
fi
echo "  Scope: $INSTALL_SCOPE"
for skill in "${SKILLS[@]}"; do
    echo "  - $skill"
done
echo "--------------------------------------------------"

prepare_npm_userconfig

for skill in "${SKILLS[@]}"; do
    echo "Installing: $skill"

    install_cmd=(add "$REPO_URL" --skill "$skill" -y)
    if [ "$INSTALL_SCOPE" = "global" ]; then
        install_cmd+=(--global)
    fi

    if run_skills_command "${install_cmd[@]}"; then
        echo "Success: $skill installed."
    else
        echo "Error: $skill installation failed."
        FAILED_SKILLS+=("$skill")
    fi
    echo "--------------------------------------------------"
done

if [ ${#FAILED_SKILLS[@]} -gt 0 ]; then
    echo "The following skills failed to install:"
    for skill in "${FAILED_SKILLS[@]}"; do
        echo "  - $skill"
    done
    exit 1
fi

echo "Skill installation finished."
echo "=================================================="
