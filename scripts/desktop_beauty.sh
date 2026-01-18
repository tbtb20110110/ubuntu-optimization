#!/bin/bash
# 终极修复：切换到脚本自身目录，确保找到log_tool.sh
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
source ./log_tool.sh

USER_HOME=$(eval echo ~$SUDO_USER)
DESKTOP_ENV=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')

install_deps() {
    info_log "检测桌面环境：$DESKTOP_ENV"
    case $DESKTOP_ENV in
        gnome|ubuntu:gnome)
            apt install -y gnome-tweaks gnome-shell-extensions > /dev/null
            ;;
        kde|plasma)
            apt install -y kde-config-gtk-style plasma-widgets-addons > /dev/null
            ;;
        *)
            error_log "仅支持GNOME/KDE桌面环境，跳过桌面美化"
            exit 1
            ;;
    esac
}

get_theme_list() {
    DESKTOP_THEMES=($(wget -qO- $REPO_URL/config/desktop_themes.list))
    check_download "桌面主题列表"
}

select_theme() {
    echo -e "${YELLOW}===== 桌面主题选择 =====${NC}"
    for i in "${!DESKTOP_THEMES[@]}"; do
        echo " [$((i+1))] ${DESKTOP_THEMES[$i]}"
    done
    read -p "  请选择主题 [1-${#DESKTOP_THEMES[@]}]: " theme_idx
    SELECTED_THEME=${DESKTOP_THEMES[$((theme_idx-1))]}
}

apply_theme() {
    info_log "应用 ${SELECTED_THEME} 桌面配置..."
    wget -q "$REPO_URL/config/desktop_tpl/${DESKTOP_ENV}_${SELECTED_THEME}.conf" -O $USER_HOME/.config/${DESKTOP_ENV}_theme.conf
    check_download "${SELECTED_THEME} 桌面配置"
    chown -R $SUDO_USER:$SUDO_USER $USER_HOME/.themes $USER_HOME/.config

    success_log "桌面主题配置完成！重启桌面后生效"
    case $DESKTOP_ENV in
        gnome) echo -e "${BLUE}生效命令：gnome-tweaks -t $SELECTED_THEME${NC}" ;;
        kde) echo -e "${BLUE}生效命令：plasma-apply-desktoptheme $SELECTED_THEME${NC}" ;;
    esac
}

install_deps
get_theme_list
select_theme
apply_theme
