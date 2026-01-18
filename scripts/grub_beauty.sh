#!/bin/bash
# 核心修复：兼容sudo运行的路径获取逻辑
SCRIPT_DIR=$(cd "$(dirname "$(readlink -f "$0")")" || exit 1; pwd)
source "$SCRIPT_DIR/log_tool.sh"

GRUB_DIR="/boot/grub/themes"

get_grub_list() {
    GRUB_THEMES=($(wget -qO- $REPO_URL/config/grub_themes.list))
    check_download "GRUB主题列表"
}

select_grub_theme() {
    echo -e "${YELLOW}===== GRUB引导主题选择 =====${NC}"
    for i in "${!GRUB_THEMES[@]}"; do
        echo " [$((i+1))] ${GRUB_THEMES[$i]}"
    done
    read -p "  请选择主题 [1-${#GRUB_THEMES[@]}]: " grub_idx
    SELECTED_GRUB=${GRUB_THEMES[$((grub_idx-1))]}
}

apply_grub_theme() {
    info_log "应用 ${SELECTED_GRUB} GRUB配置..."
    wget -q "$REPO_URL/config/grub_tpl/grub_${SELECTED_GRUB}.cfg" -O /etc/default/grub
    check_download "${SELECTED_GRUB} GRUB配置"
    update-grub > /dev/null

    success_log "GRUB美化完成！重启系统后生效"
}

get_grub_list
select_grub_theme
apply_grub_theme
