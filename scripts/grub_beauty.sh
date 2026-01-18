#!/bin/bash
GRUB_DIR="/boot/grub/themes"
source <(wget -qO- $REPO_URL/scripts/log_tool.sh)

# 获取GRUB主题列表
get_grub_list() {
    GRUB_THEMES=($(wget -qO- $REPO_URL/config/grub_themes.list))
}

# 选择GRUB主题
select_grub_theme() {
    echo -e "${YELLOW}===== GRUB引导主题选择 =====${NC}"
    for i in "${!GRUB_THEMES[@]}"; do
        echo " [$((i+1))] ${GRUB_THEMES[$i]}"
    done
    read -p "  请选择主题 [1-${#GRUB_THEMES[@]}]: " grub_idx
    SELECTED_GRUB=${GRUB_THEMES[$((grub_idx-1))]}
}

# 应用GRUB主题
apply_grub_theme() {
    # 下载GRUB配置文件
    info_log "应用 ${SELECTED_GRUB} GRUB配置..."
    wget -q "$REPO_URL/config/grub_tpl/grub_${SELECTED_GRUB}.cfg" -O /etc/default/grub
    update-grub > /dev/null

    success_log "GRUB美化完成！重启系统后生效"
}

# 执行GRUB美化流程
get_grub_list
select_grub_theme
apply_grub_theme
