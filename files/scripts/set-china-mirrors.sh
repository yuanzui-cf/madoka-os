#!/bin/bash

# =========================================================
# MadokaOS 镜像源切换脚本 (USTC - 中科大源)
# =========================================================

set -e # 遇到错误立即停止

echo "🔵 正在切换 RPM/DNF 软件源为中科大 (USTC)..."

# 定义要修改的 Repo 文件列表
REPO_FILES=(
    "/etc/yum.repos.d/fedora.repo"
    "/etc/yum.repos.d/fedora-updates.repo"
    "/etc/yum.repos.d/fedora-modular.repo"
    "/etc/yum.repos.d/fedora-updates-modular.repo"
)

for repo_file in "${REPO_FILES[@]}"; do
    if [ -f "$repo_file" ]; then
        echo "   -> 处理: $repo_file"

        # 备份原始文件 (如果还没有备份过)
        if [ ! -f "${repo_file}.bak" ]; then
            cp "$repo_file" "${repo_file}.bak"
        fi

        # 1. 注释掉 metalink
        # 2. 替换 baseurl 为 USTC 镜像地址
        sed -i \
            -e 's|^metalink=|#metalink=|g' \
            -e 's|^#baseurl=http://download.example/pub/fedora/linux|baseurl=https://mirrors.ustc.edu.cn/fedora/linux|g' \
            "$repo_file"
    else
        echo "   ⚠️ 跳过: $repo_file (文件不存在)"
    fi
done

echo "✅ RPM 源切换完成。"

# =========================================================

echo "🔵 正在切换 Flatpak (Flathub) 源为中科大 (USTC)..."

# 检查 flatpak 命令是否存在
if command -v flatpak &> /dev/null; then
    # 检查是否存在名为 flathub 的远程源
    if ! flatpak remote-list | grep -q "flathub"; then
        echo "⚠️ 未找到 'flathub' 源，正在尝试添加..."
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    fi

    flatpak remote-modify --system flathub --url=https://mirrors.ustc.edu.cn/flathub
    echo "✅ Flatpak 源已指向 USTC。"
else
    echo "⚠️ 未找到 flatpak 命令，跳过 Flatpak 源配置。"
fi

echo "🎉 所有镜像源已切换至 USTC (中科大)！"
