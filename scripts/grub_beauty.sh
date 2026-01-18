#!/bin/bash
# 核心修改：本地引用日志工具
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "$SCRIPT_DIR/log_tool.sh"

GRUB_DIR="/boot/grub/themes"

# 获取主题列表（核心修改：添加check_download检查）
get_grub_list() {
    GRUB_THEMES=($(wget -qO- $REPO_URL/config/grub_themes.list))
    check_download "GRUB主题列表"
}

# 选择主题（无修改）
select_grub_theme() {
    echo -e "${YELLOW}===== GRUB引导主题选择 =====${NC}"
    for i in "${!GRUB_THEMES[@]}"; do
        echo " [$((i+1))] ${GRUB_THEMES[$i]}"
    done
    read -p "  请选择主题 [1-${#GRUB_THEMES[@]}]: " grub_idx
    SELECTED_GRUB=${GRUB_THEMES[$((grub_idx-1))]}
}

# 应用主题（核心修改：添加check_download检查）
apply_grub_theme() {
    info_log "应用 ${SELECTED_GRUB} GRUB配置..."
    wget -q "$REPO_URL/config/grub_tpl/grub_${SELECTED_GRUB}.cfg" -O /etc/default/grub
    check_download "${SELECTED_GRUB} GRUB配置"
    update-grub > /dev/null

    success_log "GRUB美化完成！重启系统后生效"
}

# 执行流程（无修改）
get_grub_list
select_grub_theme
apply_grub_theme
