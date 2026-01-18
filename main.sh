#!/bin/bash
set -e

# ====================== 用户唯一需要修改的地方 ======================
# 替换规则：https://raw.githubusercontent.com/你的GitHub用户名/ubuntu-optimization/main
REPO_URL="https://raw.githubusercontent.com/你的用户名/ubuntu-optimization/main"
# ==================================================================

export REPO_URL
source <(wget -qO- $REPO_URL/scripts/log_tool.sh)

# 界面ASCII标题
TITLE_ASCII=$(cat << "EOF"
 ██████╗ ██╗   ██╗██╗██╗     ██████╗ ███████╗██████╗ 
██╔════╝ ██║   ██║██║██║     ██╔══██╗██╔════╝██╔══██╗
██║  ███╗██║   ██║██║██║     ██████╔╝█████╗  ██████╔╝
██║   ██║██║   ██║██║██║     ██╔══██╗██╔══╝  ██╔══██╗
╚██████╔╝╚██████╔╝██║███████╗██████╔╝███████╗██║  ██║
 ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝
 Windows11 + Ubuntu 24.04 双系统优化脚本
 适配机型：华为 MateBook 15d 集显版
EOF
)

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 进度条函数
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local progress=$((current * width / total))
    local bar=$(printf "%${progress}s" | tr ' ' '█')
    local empty=$(printf "%$((width - progress))s" | tr ' ' '░')
    printf "\r${CYAN}[%s%s] ${PURPLE}%d/%d${NC}" "$bar" "$empty" "$current" "$total"
}

# 菜单显示函数
show_menu() {
    clear
    echo -e "${PURPLE}${TITLE_ASCII}${NC}"
    echo -e "${YELLOW}=============================================${NC}"
    echo -e "${GREEN}  资源源：$REPO_URL${NC}"
    echo -e "${YELLOW}=============================================${NC}"
    echo " [1] 基础配置（国内源+中文+指纹+华为机型适配）【必选】"
    echo " [2] 自动下载主题/字体（无需手动下载）【必选前置】"
    echo " [3] 终端美化（配色/字体+oh-my-zsh）"
    echo " [4] 桌面美化（主题+图标+配置）"
    echo " [5] GRUB美化（主题+配色）"
    echo " [6] 系统深度优化（新增：清理/电源/输入法/SSH等）"
    echo " [7] 全量配置（一键拉满所有功能）"
    echo " [0] 退出脚本"
    echo -e "${YELLOW}=============================================${NC}"
    read -p "  请输入选择 [0-7]: " choice
}

# 子脚本下载函数
download_scripts() {
    info_log "正在拉取功能子脚本..."
    local scripts=("base_setup.sh" "term_beauty.sh" "desktop_beauty.sh" "grub_beauty.sh" "log_tool.sh" "auto_download.sh" "sys_optimize.sh")
    local count=0
    local total=${#scripts[@]}
    mkdir -p scripts
    for script in "${scripts[@]}"; do
        wget -q "$REPO_URL/scripts/$script" -O "scripts/$script"
        chmod +x "scripts/$script"
        progress_bar $((++count)) $total
    done
    echo -e "\n"
}

# 主逻辑
main() {
    if [ "$(id -u)" -ne 0 ]; then
        error_log "请使用 sudo 运行本脚本：sudo ./main.sh"
        exit 1
    fi
    download_scripts
    while true; do
        show_menu
        case $choice in
            1)
                source scripts/base_setup.sh
                success_log "基础配置完成！"
                read -p "按任意键返回菜单..."
                ;;
            2)
                source scripts/auto_download.sh
                success_log "主题/字体自动下载完成！"
                read -p "按任意键返回菜单..."
                ;;
            3)
                source scripts/term_beauty.sh
                success_log "终端美化完成！"
                read -p "按任意键返回菜单..."
                ;;
            4)
                source scripts/desktop_beauty.sh
                success_log "桌面美化完成！"
                read -p "按任意键返回菜单..."
                ;;
            5)
                source scripts/grub_beauty.sh
                success_log "GRUB美化完成！"
                read -p "按任意键返回菜单..."
                ;;
            6)
                source scripts/sys_optimize.sh
                success_log "系统深度优化完成！"
                read -p "按任意键返回菜单..."
                ;;
            7)
                source scripts/base_setup.sh
                source scripts/auto_download.sh
                source scripts/term_beauty.sh
                source scripts/desktop_beauty.sh
                source scripts/grub_beauty.sh
                source scripts/sys_optimize.sh
                success_log "全量配置完成！重启系统生效"
                exit 0
                ;;
            0)
                info_log "退出脚本，感谢使用！"
                exit 0
                ;;
            *)
                error_log "无效选择，请重新输入！"
                sleep 2
                ;;
        esac
    done
}

main
