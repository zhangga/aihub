#!/bin/bash

set -e

# 这个脚本设计为可以直接通过 curl 一键执行：
# 全部安装到当前项目：curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash
# 安装预设包到全局：curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash -s -- --bundle creative --global

echo "=================================================="
echo "🚀 开始安装 AI Hub 技能 (Agent Skills)..."
echo "=================================================="

REPO_URL="github.com/zhangga/aihub"
SKILLS_LIST_URL="https://raw.githubusercontent.com/zhangga/aihub/main/skills/skills_list.txt"
BUNDLES_URL="https://raw.githubusercontent.com/zhangga/aihub/main/skills/bundles.tsv"
SELECTED_BUNDLE="${AIHUB_BUNDLE:-}"
INSTALL_SCOPE="${AIHUB_SCOPE:-project}"
LIST_BUNDLES=0

while [ $# -gt 0 ]; do
    case "$1" in
        --bundle)
            if [ $# -lt 2 ]; then
                echo "❌ 错误: --bundle 需要一个值。"
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
            echo "❌ 未知参数: $1"
            echo "用法: bash install.sh [--bundle <name|a,b>] [--global|--project] [--list-bundles]"
            exit 1
            ;;
    esac
done

if ! command -v npx &> /dev/null; then
    echo "❌ 错误: 未找到 npx 命令！请先安装 Node.js 和 npm。"
    exit 1
fi
if ! command -v curl &> /dev/null; then
    echo "❌ 错误: 未找到 curl 命令！无法获取技能目录。"
    exit 1
fi

if [[ "$INSTALL_SCOPE" != "project" && "$INSTALL_SCOPE" != "global" ]]; then
    echo "❌ 错误: 安装目标只支持 project 或 global。"
    exit 1
fi

SKILLS=()
ALL_BUNDLES=()

unique_lines() {
    awk '!seen[$0]++'
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
        echo "⚠️ 警告: 未找到符合条件的 bundle。"
        echo "可用 bundle："
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
    echo "⚠️ 警告: 未找到符合条件的技能。"
    exit 0
fi

echo "📦 即将安装以下技能："
if [ -n "$SELECTED_BUNDLE" ]; then
    echo "  预设包: $SELECTED_BUNDLE"
else
    echo "  模式: full"
fi
echo "  位置: $INSTALL_SCOPE"
for skill in "${SKILLS[@]}"; do
    echo "  - $skill"
done
echo "--------------------------------------------------"

for skill in "${SKILLS[@]}"; do
    echo "🔄 正在安装: $skill ..."

    install_cmd=(npx skills@latest add "$REPO_URL" --skill "$skill" -y)
    if [ "$INSTALL_SCOPE" = "global" ]; then
        install_cmd+=(--global)
    fi

    "${install_cmd[@]}"

    if [ $? -eq 0 ]; then
        echo "✔️  $skill 安装成功！"
    else
        echo "❌ $skill 安装失败！"
    fi
    echo "--------------------------------------------------"
done

echo "🎉 所有技能安装流程执行完毕！"
echo "=================================================="
