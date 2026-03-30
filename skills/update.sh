#!/bin/bash

set -e

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
EXTERNAL_DIR="$ROOT_DIR/external"
SKILLS_DIR="$ROOT_DIR/skills"
CONFIG_FILE="$EXTERNAL_DIR/needed_skills.txt"

echo "开始更新子模块 (Submodules)..."

# 初始化并更新子模块到最新的远程提交
git submodule update --init --recursive --remote

echo "✅ 子模块更新完成！"

echo "开始同步需要的 skills 到本地 skills 目录..."

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 配置文件 $CONFIG_FILE 不存在！请先创建该文件并列出需要的 skills。"
    exit 1
fi

# 逐行读取需要的 skill 路径并拷贝
while IFS= read -r skill_path || [ -n "$skill_path" ]; do
    # 忽略空行和注释行（以 # 开头）
    if [[ -z "$skill_path" ]] || [[ "$skill_path" =~ ^#.* ]]; then
        continue
    fi

    # 去除可能的回车符（特别是 Windows 环境下）
    skill_path=$(echo "$skill_path" | tr -d '\r')

    # 源路径
    source_path="$EXTERNAL_DIR/$skill_path"
    
    # 提取最后的文件或文件夹名作为目标名称
    skill_name=$(basename "$skill_path")
    target_path="$SKILLS_DIR/$skill_name"

    if [ -d "$source_path" ] || [ -f "$source_path" ]; then
        echo "正在拷贝: $skill_name ..."
        
        # 如果目标已经存在且是文件夹，先删除它以确保干净地覆盖
        if [ -d "$target_path" ]; then
             rm -rf "$target_path"
        fi
        
        # 拷贝文件或文件夹
        cp -r "$source_path" "$SKILLS_DIR/"
        echo "  ✔️  $skill_name 拷贝完成。"
    else
        echo "⚠️ 警告: 源路径 $source_path 不存在，跳过该项。"
    fi
done < "$CONFIG_FILE"

echo "🎉 所有需要的 skills 同步完成！"
