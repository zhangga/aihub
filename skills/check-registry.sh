#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
EXTERNAL_DIR="$ROOT_DIR/external"
REGISTRY_FILE="$SCRIPT_DIR/registry.tsv"

if [ ! -f "$REGISTRY_FILE" ]; then
    echo "❌ registry 文件不存在: $REGISTRY_FILE"
    exit 1
fi

seen_names=""
line_no=0
entry_count=0

while IFS=$'\t' read -r raw_name raw_type raw_path extra || [ -n "$raw_name$raw_type$raw_path$extra" ]; do
    line_no=$((line_no + 1))

    name="$(printf '%s' "$raw_name" | tr -d '\r')"
    source_type="$(printf '%s' "$raw_type" | tr -d '\r')"
    source_path="$(printf '%s' "$raw_path" | tr -d '\r')"
    extra_field="$(printf '%s' "$extra" | tr -d '\r')"

    if [[ -z "$name" ]] || [[ "$name" =~ ^#.* ]]; then
        continue
    fi

    if [ -n "$extra_field" ]; then
        echo "❌ 第 $line_no 行列数错误: 只允许 3 列 tab 分隔字段"
        exit 1
    fi

    if [ -z "$source_type" ] || [ -z "$source_path" ]; then
        echo "❌ 第 $line_no 行缺少必填字段"
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
            echo "❌ 第 $line_no 行包含不支持的 source_type: $source_type"
            exit 1
            ;;
    esac

    if [ ! -e "$resolved_path" ]; then
        echo "❌ 第 $line_no 行引用的路径不存在: $resolved_path"
        exit 1
    fi

    if printf '%s\n' "$seen_names" | grep -Fx -- "$name" >/dev/null 2>&1; then
        echo "❌ 第 $line_no 行 skill 名称重复: $name"
        exit 1
    fi

    seen_names="$(printf '%s\n%s' "$seen_names" "$name")"
    entry_count=$((entry_count + 1))
done < "$REGISTRY_FILE"

if [ "$entry_count" -eq 0 ]; then
    echo "❌ registry 中没有可用条目"
    exit 1
fi

echo "✅ registry 校验通过，共 $entry_count 个 skills。"
