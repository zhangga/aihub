#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
EXTERNAL_DIR="$ROOT_DIR/external"
REGISTRY_FILE="$SCRIPT_DIR/registry.tsv"
PROXY_REGISTRY_FILE="$SCRIPT_DIR/proxy_registry.tsv"
BUNDLES_FILE="$SCRIPT_DIR/bundles.tsv"

if [ ! -f "$REGISTRY_FILE" ]; then
    echo "Error: registry file not found: $REGISTRY_FILE"
    exit 1
fi

if [ ! -f "$PROXY_REGISTRY_FILE" ]; then
    echo "Error: proxy registry file not found: $PROXY_REGISTRY_FILE"
    exit 1
fi

seen_names=""
line_no=0
entry_count=0

while IFS=$'\t' read -r raw_name raw_type raw_path raw_unused extra || [ -n "$raw_name$raw_type$raw_path$raw_unused$extra" ]; do
    line_no=$((line_no + 1))

    name="$(printf '%s' "$raw_name" | tr -d '\r')"
    source_type="$(printf '%s' "$raw_type" | tr -d '\r')"
    source_path="$(printf '%s' "$raw_path" | tr -d '\r')"
    unused_field="$(printf '%s' "$raw_unused" | tr -d '\r')"
    extra_field="$(printf '%s' "$extra" | tr -d '\r')"

    if [[ -z "$name" ]] || [[ "$name" =~ ^#.* ]]; then
        continue
    fi

    if [ -n "$extra_field" ] || [ -n "$unused_field" ]; then
        echo "Error: registry line $line_no must contain exactly 3 tab-separated fields."
        exit 1
    fi

    if [ -z "$source_type" ] || [ -z "$source_path" ]; then
        echo "Error: registry line $line_no is missing required fields."
        exit 1
    fi

    case "$source_type" in
        submodule)
            resolved_path="$EXTERNAL_DIR/$source_path"
            ;;
        local)
            resolved_path="$ROOT_DIR/$source_path"
            ;;
        *)
            echo "Error: registry line $line_no uses unsupported source_type: $source_type"
            exit 1
            ;;
    esac

    if [ ! -e "$resolved_path" ]; then
        echo "Error: registry line $line_no references a missing path: $resolved_path"
        exit 1
    fi

    if printf '%s\n' "$seen_names" | grep -Fx -- "$name" >/dev/null 2>&1; then
        echo "Error: duplicate skill name on registry line $line_no: $name"
        exit 1
    fi

    seen_names="$(printf '%s\n%s' "$seen_names" "$name")"
    entry_count=$((entry_count + 1))
done < "$REGISTRY_FILE"

while IFS=$'\t' read -r raw_name raw_command raw_unused extra || [ -n "$raw_name$raw_command$raw_unused$extra" ]; do
    line_no=$((line_no + 1))

    name="$(printf '%s' "$raw_name" | tr -d '\r')"
    proxy_command="$(printf '%s' "$raw_command" | tr -d '\r')"
    unused_field="$(printf '%s' "$raw_unused" | tr -d '\r')"
    extra_field="$(printf '%s' "$extra" | tr -d '\r')"

    if [[ -z "$name" ]] || [[ "$name" =~ ^#.* ]]; then
        continue
    fi

    if [ -n "$extra_field" ] || [ -n "$unused_field" ]; then
        echo "Error: proxy registry line $line_no must contain exactly 2 tab-separated fields."
        exit 1
    fi

    if [ -z "$proxy_command" ]; then
        echo "Error: proxy registry line $line_no is missing its command."
        exit 1
    fi

    if printf '%s\n' "$seen_names" | grep -Fx -- "$name" >/dev/null 2>&1; then
        echo "Error: duplicate skill name across registries on line $line_no: $name"
        exit 1
    fi

    seen_names="$(printf '%s\n%s' "$seen_names" "$name")"
    entry_count=$((entry_count + 1))
done < "$PROXY_REGISTRY_FILE"

if [ "$entry_count" -eq 0 ]; then
    echo "Error: registry does not contain any usable skills."
    exit 1
fi

if [ -f "$BUNDLES_FILE" ]; then
    bundle_line_no=0
    seen_bundles=""

    while IFS=$'\t' read -r raw_bundle raw_description raw_skills extra || [ -n "$raw_bundle$raw_description$raw_skills$extra" ]; do
        bundle_line_no=$((bundle_line_no + 1))

        bundle_name="$(printf '%s' "$raw_bundle" | tr -d '\r')"
        bundle_skills="$(printf '%s' "$raw_skills" | tr -d '\r')"
        extra_field="$(printf '%s' "$extra" | tr -d '\r')"

        if [[ -z "$bundle_name" ]] || [[ "$bundle_name" =~ ^#.* ]]; then
            continue
        fi

        if [ -n "$extra_field" ]; then
            echo "Error: bundle line $bundle_line_no must contain exactly 3 tab-separated fields."
            exit 1
        fi

        if [ -z "$bundle_skills" ]; then
            echo "Error: bundle line $bundle_line_no is missing its skill list."
            exit 1
        fi

        if printf '%s\n' "$seen_bundles" | grep -Fx -- "$bundle_name" >/dev/null 2>&1; then
            echo "Error: duplicate bundle name on line $bundle_line_no: $bundle_name"
            exit 1
        fi

        IFS=',' read -r -a bundle_skill_list <<< "$bundle_skills"
        for bundle_skill in "${bundle_skill_list[@]}"; do
            bundle_skill="$(printf '%s' "$bundle_skill" | xargs)"
            if [ -z "$bundle_skill" ]; then
                continue
            fi

            if ! printf '%s\n' "$seen_names" | grep -Fx -- "$bundle_skill" >/dev/null 2>&1; then
                echo "Error: bundle line $bundle_line_no references an unknown skill: $bundle_skill"
                exit 1
            fi
        done

        seen_bundles="$(printf '%s\n%s' "$seen_bundles" "$bundle_name")"
    done < "$BUNDLES_FILE"
fi

echo "Registry validation passed with $entry_count skills."
