#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
EXTERNAL_DIR="$ROOT_DIR/external"
SKILLS_DIR="$ROOT_DIR/skills"
REGISTRY_FILE="$SKILLS_DIR/registry.tsv"
SKILLS_LIST_FILE="$SKILLS_DIR/skills_list.txt"
LOCK_FILE="$ROOT_DIR/skills-lock.json"

should_update_submodules=1

for arg in "$@"; do
    case "$arg" in
        --skip-submodule-update)
            should_update_submodules=0
            ;;
        *)
            echo "❌ 未知参数: $arg"
            echo "用法: bash skills/update.sh [--skip-submodule-update]"
            exit 1
            ;;
    esac
done

if [ ! -f "$REGISTRY_FILE" ]; then
    echo "❌ registry 文件不存在: $REGISTRY_FILE"
    exit 1
fi

if [ "$should_update_submodules" -eq 1 ]; then
    echo "开始更新子模块 (Submodules)..."
    git submodule update --init --recursive --remote
    echo "✅ 子模块更新完成！"
else
    echo "⏭️  跳过子模块更新。"
fi

echo "开始根据 registry 同步 skills 并生成清单..."

tmp_skills_list="$(mktemp)"
tmp_lock_file="$(mktemp)"
skills_count=0

cleanup() {
    rm -f "$tmp_skills_list" "$tmp_lock_file"
}

trap cleanup EXIT

printf '{\n  "version": 2,\n  "generatedAt": "%s",\n  "skills": {\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" > "$tmp_lock_file"

while IFS=$'\t' read -r raw_name raw_type raw_path || [ -n "$raw_name$raw_type$raw_path" ]; do
    skill_name="$(printf '%s' "$raw_name" | tr -d '\r')"
    source_type="$(printf '%s' "$raw_type" | tr -d '\r')"
    source_key="$(printf '%s' "$raw_path" | tr -d '\r')"

    if [[ -z "$skill_name" ]] || [[ "$skill_name" =~ ^#.* ]]; then
        continue
    fi

    if [ -z "$source_type" ] || [ -z "$source_key" ]; then
        echo "❌ registry 条目格式错误: $skill_name"
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
                echo "❌ 源路径不存在: $source_path"
                exit 1
            fi

            if [ -e "$target_path" ]; then
                rm -rf "$target_path"
            fi

            echo "正在同步: $skill_name <- $source_key"
            cp -r "$source_path" "$target_path"

            source_repo="$(git -C "$submodule_path" config --get remote.origin.url || true)"
            source_commit="$(git -C "$submodule_path" rev-parse HEAD || true)"
            ;;
        local)
            source_path="$ROOT_DIR/$source_key"

            if [ ! -e "$source_path" ]; then
                echo "❌ 本地技能不存在: $source_path"
                exit 1
            fi

            if [ "$source_path" != "$target_path" ]; then
                if [ -e "$target_path" ]; then
                    rm -rf "$target_path"
                fi
                echo "正在复制本地技能: $skill_name <- $source_key"
                cp -r "$source_path" "$target_path"
            else
                echo "正在保留本地技能: $skill_name"
            fi

            source_repo="local"
            if git -C "$ROOT_DIR" rev-parse HEAD >/dev/null 2>&1; then
                source_commit="$(git -C "$ROOT_DIR" rev-parse HEAD)"
            fi
            ;;
        *)
            echo "❌ 不支持的 source_type: $source_type"
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

printf '\n  }\n}\n' >> "$tmp_lock_file"

mv "$tmp_skills_list" "$SKILLS_LIST_FILE"
mv "$tmp_lock_file" "$LOCK_FILE"

echo "✅ 已生成 $(basename "$SKILLS_LIST_FILE") 和 $(basename "$LOCK_FILE")"
echo "🎉 共处理 $skills_count 个 skills。"
