#!/bin/bash
USER_HOME=$(eval echo ~$SUDO_USER)
source <(wget -qO- $REPO_URL/scripts/log_tool.sh)

# 功能1：系统垃圾清理
sys_clean() {
    info_log "开始清理系统垃圾..."
    # APT缓存清理
    apt autoclean -y > /dev/null
    apt autoremove -y > /dev/null
    # 删除旧日志文件（7天前）
    find /var/log -type f -mtime +7 -name "*.log" -delete > /dev/null
    # 清理用户缓存
    rm -rf $USER_HOME/.cache/* > /dev/null
    rm -rf $USER_HOME/.local/share/Trash/* > /dev/null
    success_log "系统垃圾清理完成"
}

# 功能2：启动项管理（交互禁用无用服务）
boot_manage() {
    info_log "安装启动项管理工具..."
    apt install -y sysv-rc-conf > /dev/null
    echo -e "${YELLOW}===== 启动项管理说明 =====${NC}"
    echo "  运行命令：sysv-rc-conf  进行可视化管理"
    echo "  建议禁用：bluetooth（不用蓝牙）、cups（不用打印机）"
    success_log "启动项管理工具安装完成"
}

# 功能3：华为MateBook电源优化（续航提升）
power_optimize() {
    info_log "配置电源优化（华为MateBook专属）..."
    apt install -y powertop tlp > /dev/null
    # 启用tlp电源管理
    systemctl enable tlp > /dev/null
    systemctl start tlp > /dev/null
    # 华为集显节能配置
    echo "CPU_SCALING_GOVERNOR_ON_BAT=powersave" >> /etc/tlp.conf
    echo "DISK_APM_LEVEL_ON_BAT="128 128"" >> /etc/tlp.conf
    echo "WIFI_PWR_ON_BAT=on" >> /etc/tlp.conf
    # 修复华为屏幕亮度
    sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/s/"$/ acpi_backlight=vendor"/' /etc/default/grub
    update-grub > /dev/null
    success_log "华为MateBook电源优化完成"
}

# 功能4：中文输入法优化（fcitx5+rime）
input_optimize() {
    info_log "安装并配置中文输入法..."
    apt install -y fcitx5 fcitx5-rime fcitx5-config-qt > /dev/null
    # 设置默认输入法
    echo "export GTK_IM_MODULE=fcitx5" >> $USER_HOME/.bashrc
    echo "export QT_IM_MODULE=fcitx5" >> $USER_HOME/.bashrc
    echo "export XMODIFIERS=@im=fcitx5" >> $USER_HOME/.bashrc
    chown -R $SUDO_USER:$SUDO_USER $USER_HOME/.bashrc
    success_log "中文输入法配置完成，重启终端生效"
}

# 功能5：文件管理器优化（Nautilus）
filemanager_optimize() {
    info_log "优化文件管理器显示..."
    # 显示隐藏文件和扩展名
    gsettings set org.gnome.nautilus.preferences show-hidden-files true > /dev/null
    gsettings set org.gnome.nautilus.preferences show-file-extensions true > /dev/null
    # 添加右键新建文档
    mkdir -p $USER_HOME/Templates
    touch $USER_HOME/Templates/"新建文本文档.txt"
    chown -R $SUDO_USER:$SUDO_USER $USER_HOME/Templates
    success_log "文件管理器优化完成"
}

# 功能6：防火墙配置（ufw）
firewall_optimize() {
    info_log "配置防火墙规则..."
    apt install -y ufw > /dev/null
    ufw default deny incoming > /dev/null
    ufw default allow outgoing > /dev/null
    ufw allow ssh > /dev/null
    ufw enable > /dev/null
    success_log "防火墙配置完成（默认拒绝入站，允许SSH）"
}

# 功能7：SSH服务配置（远程管理）
ssh_optimize() {
    info_log "安装并配置SSH服务..."
    apt install -y openssh-server > /dev/null
    systemctl enable ssh > /dev/null
    systemctl start ssh > /dev/null
    # 安全配置：禁止密码登录（可选，需先配置密钥）
    read -p "是否禁止密码登录SSH（需配置密钥，y/n）: " ans
    if [ "$ans" = "y" ]; then
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        systemctl restart ssh > /dev/null
    fi
    success_log "SSH服务配置完成"
}

# 执行所有优化功能
sys_clean
boot_manage
power_optimize
input_optimize
filemanager_optimize
firewall_optimize
ssh_optimize

success_log "===== 所有系统优化功能执行完毕 ====="
