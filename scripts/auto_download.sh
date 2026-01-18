#!/bin/bash
# 核心修改：本地引用日志工具，替换远程依赖
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "$SCRIPT_DIR/log_tool.sh"

# 核心修改：新增trap命令，脚本退出时自动清理临时文件
trap "rm -rf /tmp/fonts* /tmp/theme* /tmp/grub*" EXIT

# 路径定义（无修改）
FONTS_DIR="/usr/share/fonts/truetype"
THEMES_DIR="$USER_HOME/.themes"
GRUB_THEME_DIR="/boot/grub/themes"
mkdir -p $FONTS_DIR $THEMES_DIR $GRUB_THEME_DIR

count=0
total=6

# 下载JetBrainsMono字体（核心修改：添加check_download检查）
info_log "下载 JetBrainsMono 字体..."
wget -q "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip" -O /tmp/fonts1.zip
check_download "JetBrainsMono 字体"
unzip -q /tmp/fonts1.zip -d /tmp/fonts1
cp /tmp/fonts1/fonts/ttf/JetBrainsMono-Regular.ttf $FONTS_DIR/JetBrainsMono.ttf
progress_bar $((++count)) $total

# 下载FiraCode字体（核心修改：添加check_download检查）
info_log "下载 FiraCode 字体..."
wget -q "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip" -O /tmp/fonts2.zip
check_download "FiraCode 字体"
unzip -q /tmp/fonts2.zip -d /tmp/fonts2
cp /tmp/fonts2/ttf/FiraCode-Regular.ttf $FONTS_DIR/FiraCode.ttf
progress_bar $((++count)) $total

# 下载Catppuccin桌面主题（核心修改：添加check_download检查）
info_log "下载 Catppuccin 桌面主题..."
wget -q "https://github.com/catppuccin/gtk/releases/download/v0.7.0/Catppuccin-Macchiato.tar.gz" -O /tmp/theme1.tar.gz
check_download "Catppuccin 主题"
tar -zxf /tmp/theme1.tar.gz -C $THEMES_DIR
mv $THEMES_DIR/Catppuccin-Macchiato $THEMES_DIR/Catppuccin
progress_bar $((++count)) $total

# 下载Nordic桌面主题（核心修改：添加check_download检查）
info_log "下载 Nordic 桌面主题..."
wget -q "https://github.com/EliverLara/Nordic/archive/refs/tags/v2.2.0.tar.gz" -O /tmp/theme2.tar.gz
check_download "Nordic 主题"
tar -zxf /tmp/theme2.tar.gz -C $THEMES_DIR
mv $THEMES_DIR/Nordic-2.2.0 $THEMES_DIR/Nordic
progress_bar $((++count)) $total

# 下载Catppuccin GRUB主题（核心修改：添加check_download检查）
info_log "下载 Catppuccin GRUB 主题..."
wget -q "https://github.com/catppuccin/grub/archive/refs/heads/main.tar.gz" -O /tmp/grub1.tar.gz
check_download "Catppuccin GRUB 主题"
tar -zxf /tmp/grub1.tar.gz -C $GRUB_THEME_DIR
mv $GRUB_THEME_DIR/grub-main $GRUB_THEME_DIR/Catppuccin
progress_bar $((++count)) $total

# 下载Nordic GRUB主题（核心修改：添加check_download检查）
info_log "下载 Nordic GRUB 主题..."
wget -q "https://github.com/EliverLara/Nordic-grub/archive/refs/heads/master.tar.gz" -O /tmp/grub2.tar.gz
check_download "Nordic GRUB 主题"
tar -zxf /tmp/grub2.tar.gz -C $GRUB_THEME_DIR
mv $GRUB_THEME_DIR/Nordic-grub-master $GRUB_THEME_DIR/Nordic
progress_bar $((++count)) $total

# 刷新字体缓存（无修改）
fc-cache -fv > /dev/null
chown -R $SUDO_USER:$SUDO_USER $THEMES_DIR

success_log "所有主题和字体下载完成！"
