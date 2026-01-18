#!/bin/bash
# 核心修改：本地引用日志工具
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "$SCRIPT_DIR/log_tool.sh"

USER_HOME=$(eval echo ~$SUDO_USER)

# 系统清理（无修改）
sys_clean() {
    info_log "开始清理系统垃圾..."
    apt autoclean -y > /dev/null
    apt autoremove -y > /dev/null
    find /var/log -type f -mtime +7 -name "*.log" -delete > /dev/null
    rm -rf $USER_HOME/.cache/* $USER_HOME/.local/share/Trash/* > /dev/null
    success_log "系统垃圾清理完成"
}

# 启动项管理（核心修改：修正工具描述，"可视化"改为"文本交互式"）
boot_manage() {
    info_log "安装启动项管理工具..."
    apt install -y sysv-rc-conf > /dev/null
    echo -e "${YELLOW}===== 启动项管理说明 =====${NC}"
    echo "  运行命令：sysv-rc-conf  进行文本交互式管理"
    echo "  建议禁用：bluetooth（不用蓝牙）、cups（不用打印机）"
    success_log "启动项管理工具安装完成"
}

# 电源优化（核心修改：删除重复的GRUB配置代码）
power_optimize() {
    info_log "配置电源优化（华为MateBook专属）..."
    apt install -y powertop tlp > /dev/null
    systemctl enable --now tlp > /dev/null
    echo "CPU_SCALING_GOVERNOR_ON_BAT=powersave" >> /etc/tlp.conf
    echo "DISK_APM_LEVEL_ON_BAT="128 128"" >> /etc/tlp.conf
    echo "WIFI_PWR_ON_BAT=on" >> /etc/tlp.conf
    success_log "华为MateBook电源优化完成"
}

# 输入法配置（无修改）
input_optimize() {
    info_log "安装并配置中文输入法..."
    apt install -y fcitx5 fcitx5-rime fcitx5-config-qt > /dev/null
    echo "export GTK_IM_MODULE=fcitx5" >> $USER_HOME/.bashrc
    echo "export QT_IM_MODULE=fcitx5" >> $USER_HOME/.bashrc
    echo "export XMODIFIERS=@im=fcitx5" >> $USER_HOME/.bashrc
    chown $SUDO_USER:$SUDO_USER $USER_HOME/.bashrc
    success_log "中文输入法配置完成，重启终端生效"
}

# 文件管理器优化（无修改）
filemanager_optimize() {
    info_log "优化文件管理器显示..."
    gsettings set org.gnome.nautilus.preferences show-hidden-files true > /dev/null
    gsettings set org.gnome.nautilus.preferences show-file-extensions true > /dev/null
    mkdir -p $USER_HOME/Templates
    touch $USER_HOME/Templates/"新建文本文档.txt"
    chown -R $SUDO_USER:$SUDO_USER $USER_HOME/Templates
    success_log "文件管理器优化完成"
}

# 防火墙配置（无修改）
firewall_optimize() {
    info_log "配置防火墙规则..."
    apt install -y ufw > /dev/null
    ufw default deny incoming > /dev/null
    ufw default allow outgoing > /dev/null
    ufw allow ssh > /dev/null
    ufw enable > /dev/null
    success_log "防火墙配置完成（默认拒绝入站，允许SSH）"
}

# SSH配置（核心修改：添加密钥登录提示）
ssh_optimize() {
    info_log "安装并配置SSH服务..."
    apt install -y openssh-server > /dev/null
    systemctl enable --now ssh > /dev/null
    read -p "是否禁止密码登录SSH（需先配置客户端密钥，y/n）: " ans
    if [ "$ans" = "y" ]; then
        echo -e "${YELLOW}提示：请确保已通过 ssh-copy-id 将客户端公钥上传至服务器${NC}"
        sleep 3
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        systemctl restart ssh > /dev/null
    fi
    success_log "SSH服务配置完成"
}

# 执行所有优化（无修改）
sys_clean
boot_manage
power_optimize
input_optimize
filemanager_optimize
firewall_optimize
ssh_optimize

success_log "===== 所有系统优化功能执行完毕 ====="
