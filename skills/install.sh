#!/bin/bash

set -e

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
EXTERNAL_DIR="$ROOT_DIR/external"
CONFIG_FILE="$EXTERNAL_DIR/needed_skills.txt"

# 检查是否是在 WSL 或者 MINGW 下运行，如果是的话将路径转换格式，以适配原生的 npm/npx
# 因为在 WSL 下 $EXTERNAL_DIR 是 /mnt/c/...，但是 npx 在 windows 下可能会识别为 C:\mnt\c\... 导致找不到路径
if command -v cygpath &> /dev/null; then
    EXTERNAL_DIR_WIN=$(cygpath -w "$EXTERNAL_DIR")
elif [[ -n "$WSL_DISTRO_NAME" ]]; then
    EXTERNAL_DIR_WIN=$(wslpath -w "$EXTERNAL_DIR")
else
    EXTERNAL_DIR_WIN="$EXTERNAL_DIR"
fi


echo "开始安装配置的技能 (Skills)..."

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 配置文件 $CONFIG_FILE 不存在！请先执行 update.sh 更新技能。"
    exit 1
fi

# 逐行读取需要的 skill 并安装
while IFS= read -r skill_path || [ -n "$skill_path" ]; do
    # 忽略空行和注释行
    if [[ -z "$skill_path" ]] || [[ "$skill_path" =~ ^#.* ]]; then
        continue
    fi

    # 去除可能的回车符（特别是 Windows 环境下）
    skill_path=$(echo "$skill_path" | tr -d '\r')
    
    # 从原始路径提取外部仓库名和技能名
    repo_dir=$(echo "$skill_path" | cut -d'/' -f1)
    skill_name=$(basename "$skill_path")

    # 检查本地 Unix 路径是否存在，但在安装时传给 npx 的是兼容的 Windows 路径
    local_source_path="$EXTERNAL_DIR/$repo_dir"
    install_source_path="$EXTERNAL_DIR_WIN\\$repo_dir"

    # 如果是Linux或Mac，替换一下反斜杠
    if [[ -z "$WSL_DISTRO_NAME" ]] && ! command -v cygpath &> /dev/null; then
         install_source_path="$EXTERNAL_DIR/$repo_dir"
    fi

    if [ -d "$local_source_path" ]; then
        echo "----------------------------------------"
        echo "正在安装: $skill_name"
        echo "来源: $install_source_path"
        
        # 使用本地路径安装：npx skills@latest add <本地路径> --skill <技能名称>
        npx skills@latest add "$install_source_path" --skill "$skill_name" -y
        
        echo "✔️  $skill_name 安装成功"
    else
        echo "⚠️ 警告: 未找到对应的外部仓库目录 $local_source_path，跳过安装 $skill_name"
    fi

done < "$CONFIG_FILE"

echo "----------------------------------------"
echo "✅ 所有技能安装完成！"
