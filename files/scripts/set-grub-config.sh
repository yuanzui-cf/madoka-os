#!/bin/bash

# =========================================================
# MadokaOS GRUB 配置脚本
# =========================================================

set -e

GRUB_FILE="/etc/default/grub"
THEME_PATH="/usr/share/grub/themes/Cyrene_cn/theme.txt"

echo "🔧 正在配置 GRUB 设置..."

update_grub_config() {
    local key="$1"
    local value="$2"

    if grep -q "^${key}=" "$GRUB_FILE"; then
        # 情况A: 配置项存在，直接修改
        echo "   -> 修改: ${key} = ${value}"
        sed -i "s|^${key}=.*|${key}=${value}|" "$GRUB_FILE"
    elif grep -q "^#${key}=" "$GRUB_FILE"; then
        # 情况B: 配置项存在但被注释掉了，取消注释并修改
        echo "   -> 启用: ${key} = ${value}"
        sed -i "s|^#${key}=.*|${key}=${value}|" "$GRUB_FILE"
    else
        # 情况C: 配置项完全不存在，追加到文件末尾
        echo "   -> 新增: ${key} = ${value}"
        echo "${key}=${value}" >> "$GRUB_FILE"
    fi
}

# --- 1. 禁用控制台输出 ---
# 图形主题需要禁用 GRUB_TERMINAL_OUTPUT="console"
if grep -q "^GRUB_TERMINAL_OUTPUT=" "$GRUB_FILE"; then
    echo "   -> 禁用纯文本控制台模式 (为了显示图形主题)"
    sed -i 's|^GRUB_TERMINAL_OUTPUT=|#GRUB_TERMINAL_OUTPUT=|' "$GRUB_FILE"
fi

# --- 2. 设置核心参数 ---

# 设置倒计时为 5 秒
update_grub_config "GRUB_TIMEOUT" "5"

# 强制显示菜单 (而不是隐藏或倒计时)
update_grub_config "GRUB_TIMEOUT_STYLE" "menu"

# 启用 efi 混合模式 (Surface 这种高分屏设备推荐)
update_grub_config "GRUB_GFXPAYLOAD_LINUX" "keep"

# --- 3. 设置主题 ---
# 先检查主题文件是否真的存在，防止配置了路径却找不到文件导致 GRUB 报错
if [ -f "$THEME_PATH" ]; then
    update_grub_config "GRUB_THEME" "$THEME_PATH"
else
    echo "⚠️ 警告: 主题文件 $THEME_PATH 不存在！跳过主题设置。"
fi

echo "✅ GRUB 配置脚本执行完毕。"
