#!/bin/bash
USER_HOME=$(eval echo ~$SUDO_USER)
mkdir -p $USER_HOME/.oh-my-zsh/custom/plugins
source <(wget -qO- $REPO_URL/scripts/log_tool.sh)

# 获取配色&字体列表
get_lists() {
    TERM_COLORS=($(wget -qO- $REPO_URL/config/term_colors.list))
    TERM_FONTS=($(wget -qO- $REPO_URL/config/term_fonts.list))
}

# 选择终端配色
select_color() {
    echo -e "${YELLOW}===== 终端配色方案选择 =====${NC}"
    for i in "${!TERM_COLORS[@]}"; do
        echo " [$((i+1))] ${TERM_COLORS[$i]}"
    done
    read -p "  请选择配色 [1-${#TERM_COLORS[@]}]: " color_idx
    SELECTED_COLOR=${TERM_COLORS[$((color_idx-1))]}
}

# 选择终端字体
select_font() {
    echo -e "${YELLOW}===== 终端字体选择 =====${NC}"
    for i in "${!TERM_FONTS[@]}"; do
        echo " [$((i+1))] ${TERM_FONTS[$i]}"
    done
    read -p "  请选择字体 [1-${#TERM_FONTS[@]}]: " font_idx
    SELECTED_FONT=${TERM_FONTS[$((font_idx-1))]}
}

# 应用终端配置
apply_config() {
    # 安装oh-my-zsh
    info_log "安装oh-my-zsh框架..."
    su - $SUDO_USER -c "sh -c \"\$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" --unattended"

    # 下载对应配色的zsh配置
    info_log "应用 ${SELECTED_COLOR} 配色配置..."
    wget -q "$REPO_URL/config/zsh_tpl/.zshrc_${SELECTED_COLOR}" -O "$USER_HOME/.zshrc"
    sed -i "s/FONT_PLACEHOLDER/$SELECTED_FONT/g" "$USER_HOME/.zshrc"

    # 安装zsh插件
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$USER_HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions > /dev/null
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$USER_HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting > /dev/null

    # 权限修复&切换默认shell
    chown -R $SUDO_USER:$SUDO_USER $USER_HOME/.oh-my-zsh $USER_HOME/.zshrc
    chsh -s $(which zsh) $SUDO_USER
    success_log "终端美化完成！重启终端后按提示配置主题"
}

# 执行终端美化流程
get_lists
select_color
select_font
apply_config
