#!/bin/bash

set -e

# 这个脚本设计为可以直接通过 curl 一键执行：
# curl -fsSL https://raw.githubusercontent.com/zhangga/aihub/main/skills/install.sh | bash

echo "=================================================="
echo "🚀 开始安装 AI Hub 技能 (Agent Skills)..."
echo "=================================================="

# 定义主仓库地址
REPO_URL="github.com/zhangga/aihub"
# 定义外部依赖列表配置文件的远程地址
CONFIG_URL="https://raw.githubusercontent.com/zhangga/aihub/main/skills/skills_list.txt"

# 检查环境依赖
if ! command -v npx &> /dev/null; then
    echo "❌ 错误: 未找到 npx 命令！请先安装 Node.js 和 npm。"
    exit 1
fi
if ! command -v curl &> /dev/null; then
    echo "❌ 错误: 未找到 curl 命令！无法获取技能列表。"
    exit 1
fi

echo "📥 正在从远程获取技能列表..."
# 获取并解析 skills_list.txt
SKILLS=()
while IFS= read -r line; do
    # 忽略空行和注释
    if [[ -z "$line" ]] || [[ "$line" =~ ^#.* ]]; then
        continue
    fi
    # 去除可能的回车符和首尾空格
    skill_name=$(echo "$line" | tr -d '\r' | xargs)
    
    if [[ -n "$skill_name" ]]; then
        SKILLS+=("$skill_name")
    fi
done < <(curl -fsSL "$CONFIG_URL")

if [ ${#SKILLS[@]} -eq 0 ]; then
    echo "⚠️ 警告: 未获取到任何需要安装的技能。"
    exit 0
fi

echo "📦 即将安装以下技能："
for skill in "${SKILLS[@]}"; do
    echo "  - $skill"
done
echo "--------------------------------------------------"

# 逐个安装技能
for skill in "${SKILLS[@]}"; do
    echo "🔄 正在安装: $skill ..."
    
    # 执行远程安装命令
    # 注意：npx skills 默认会去目标仓库的 skills/ 目录或者通过 manifest 寻找对应的技能
    npx skills@latest add "$REPO_URL" --skill "$skill" -y
    
    if [ $? -eq 0 ]; then
        echo "✔️  $skill 安装成功！"
    else
        echo "❌ $skill 安装失败！"
    fi
    echo "--------------------------------------------------"
done

echo "🎉 所有技能安装流程执行完毕！"
echo "=================================================="
