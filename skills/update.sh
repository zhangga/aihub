#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
EXTERNAL_DIR="$ROOT_DIR/external"
SKILLS_DIR="$ROOT_DIR/skills"
REGISTRY_FILE="$SKILLS_DIR/registry.tsv"
PROXY_REGISTRY_FILE="$SKILLS_DIR/proxy_registry.tsv"
SKILLS_LIST_FILE="$SKILLS_DIR/skills_list.txt"
LOCK_FILE="$ROOT_DIR/skills-lock.json"

should_update_submodules=1

for arg in "$@"; do
    case "$arg" in
        --skip-submodule-update)
            should_update_submodules=0
            ;;
        *)
            echo "Error: unknown argument: $arg"
            echo "Usage: bash skills/update.sh [--skip-submodule-update]"
            exit 1
            ;;
    esac
done

if [ ! -f "$REGISTRY_FILE" ]; then
    echo "Error: registry file not found: $REGISTRY_FILE"
    exit 1
fi

if [ ! -f "$PROXY_REGISTRY_FILE" ]; then
    echo "Error: proxy registry file not found: $PROXY_REGISTRY_FILE"
    exit 1
fi

if [ "$should_update_submodules" -eq 1 ]; then
    echo "Updating submodules..."
    git submodule update --init --recursive --remote
    echo "Submodule update complete."
else
    echo "Skipping submodule update."
fi

echo "Syncing skills from registry and generating derived artifacts..."

tmp_skills_list="$(mktemp)"
tmp_lock_file="$(mktemp)"
skills_count=0

hash_file() {
    local file_path="$1"

    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file_path" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file_path" | awk '{print $1}'
    else
        echo "Error: sha256sum or shasum is required to hash local skills."
        exit 1
    fi
}

hash_local_skill_dir() {
    local dir_path="$1"
    local manifest_file
    local relative_path
    local file_hash
    local repo_relative_path

    manifest_file="$(mktemp)"

    find "$dir_path" -type f | LC_ALL=C sort | while IFS= read -r file_path; do
        relative_path="${file_path#$dir_path/}"
        repo_relative_path="${file_path#$ROOT_DIR/}"
        file_hash="$(git -C "$ROOT_DIR" hash-object --path "$repo_relative_path" "$file_path" 2>/dev/null || true)"

        if [ -z "$file_hash" ]; then
            file_hash="$(hash_file "$file_path")"
        fi

        printf '%s\t%s\n' "$relative_path" "$file_hash"
    done > "$manifest_file"

    hash_file "$manifest_file"
    rm -f "$manifest_file"
}

cleanup() {
    rm -f "$tmp_skills_list" "$tmp_lock_file"
}

trap cleanup EXIT

printf '{\n  "version": 2,\n  "skills": {\n' > "$tmp_lock_file"

while IFS=$'\t' read -r raw_name raw_type raw_path || [ -n "$raw_name$raw_type$raw_path" ]; do
    skill_name="$(printf '%s' "$raw_name" | tr -d '\r')"
    source_type="$(printf '%s' "$raw_type" | tr -d '\r')"
    source_key="$(printf '%s' "$raw_path" | tr -d '\r')"

    if [[ -z "$skill_name" ]] || [[ "$skill_name" =~ ^#.* ]]; then
        continue
    fi

    if [ -z "$source_type" ] || [ -z "$source_key" ]; then
        echo "Error: malformed registry entry for skill: $skill_name"
        exit 1
    fi

    target_path="$SKILLS_DIR/$skill_name"
    source_repo=""
    source_commit=""

    case "$source_type" in
        submodule)
            source_path="$EXTERNAL_DIR/$source_key"
            source_root="${source_key%%/*}"
            submodule_path="$EXTERNAL_DIR/$source_root"

            if [ ! -e "$source_path" ]; then
                echo "Error: source path does not exist: $source_path"
                exit 1
            fi

            if [ -e "$target_path" ]; then
                rm -rf "$target_path"
            fi

            echo "Syncing: $skill_name <- $source_key"
            cp -r "$source_path" "$target_path"

            source_repo="$(git -C "$submodule_path" config --get remote.origin.url || true)"
            source_commit="$(git -C "$submodule_path" rev-parse HEAD || true)"
            ;;
        local)
            source_path="$ROOT_DIR/$source_key"

            if [ ! -e "$source_path" ]; then
                echo "Error: local skill path does not exist: $source_path"
                exit 1
            fi

            if [ "$source_path" != "$target_path" ]; then
                if [ -e "$target_path" ]; then
                    rm -rf "$target_path"
                fi
                echo "Copying local skill: $skill_name <- $source_key"
                cp -r "$source_path" "$target_path"
            else
                echo "Keeping local skill in place: $skill_name"
            fi

            source_repo="local"
            source_commit="$(hash_local_skill_dir "$source_path")"
            ;;
        *)
            echo "Error: unsupported source_type: $source_type"
            exit 1
            ;;
    esac

    printf '%s\n' "$skill_name" >> "$tmp_skills_list"

    if [ "$skills_count" -gt 0 ]; then
        printf ',\n' >> "$tmp_lock_file"
    fi

    printf '    "%s": {\n' "$skill_name" >> "$tmp_lock_file"
    printf '      "sourceType": "%s",\n' "$source_type" >> "$tmp_lock_file"
    printf '      "sourcePath": "%s",\n' "$source_key" >> "$tmp_lock_file"
    printf '      "sourceRepo": "%s",\n' "$source_repo" >> "$tmp_lock_file"
    printf '      "sourceCommit": "%s"\n' "$source_commit" >> "$tmp_lock_file"
    printf '    }' >> "$tmp_lock_file"

    skills_count=$((skills_count + 1))
done < "$REGISTRY_FILE"

while IFS=$'\t' read -r raw_name raw_repo raw_skill || [ -n "$raw_name$raw_repo$raw_skill" ]; do
    skill_name="$(printf '%s' "$raw_name" | tr -d '\r')"
    proxy_repo="$(printf '%s' "$raw_repo" | tr -d '\r')"
    proxy_skill="$(printf '%s' "$raw_skill" | tr -d '\r')"

    if [[ -z "$skill_name" ]] || [[ "$skill_name" =~ ^#.* ]]; then
        continue
    fi

    if [ -z "$proxy_repo" ] || [ -z "$proxy_skill" ]; then
        echo "Error: malformed proxy registry entry for skill: $skill_name"
        exit 1
    fi

    target_path="$SKILLS_DIR/$skill_name"
    if [ -e "$target_path" ]; then
        rm -rf "$target_path"
    fi

    printf '%s\n' "$skill_name" >> "$tmp_skills_list"

    if [ "$skills_count" -gt 0 ]; then
        printf ',\n' >> "$tmp_lock_file"
    fi

    printf '    "%s": {\n' "$skill_name" >> "$tmp_lock_file"
    printf '      "sourceType": "proxy",\n' >> "$tmp_lock_file"
    printf '      "sourcePath": "%s",\n' "$proxy_skill" >> "$tmp_lock_file"
    printf '      "sourceRepo": "%s",\n' "$proxy_repo" >> "$tmp_lock_file"
    printf '      "sourceCommit": "proxy"\n' >> "$tmp_lock_file"
    printf '    }' >> "$tmp_lock_file"

    skills_count=$((skills_count + 1))
done < "$PROXY_REGISTRY_FILE"

printf '\n  }\n}\n' >> "$tmp_lock_file"

mv "$tmp_skills_list" "$SKILLS_LIST_FILE"
mv "$tmp_lock_file" "$LOCK_FILE"

rm -f "$SKILLS_DIR/skills_catalog.tsv"

echo "Generated $(basename "$SKILLS_LIST_FILE") and $(basename "$LOCK_FILE")."
echo "Processed $skills_count skills."
