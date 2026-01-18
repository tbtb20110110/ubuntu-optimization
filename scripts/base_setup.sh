#!/bin/bash
USER_HOME=$(eval echo ~$SUDO_USER)
source <(wget -qO- $REPO_URL/scripts/log_tool.sh)

# 国内源切换函数
replace_sources() {
    echo -e "${YELLOW}===== 国内源选择 =====${NC}"
    echo " [1] 阿里云源 [2] 清华大学源 [3] 中科大源 [4] 保留官方源"
    read -p "  请选择源 [1-4]: " src_idx
    case $src_idx in
        1)
            cat > /etc/apt/sources.list << EOF
deb http://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse
EOF
            ;;
        2)
            cat > /etc/apt/sources.list << EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-security main restricted universe multiverse
EOF
            ;;
        3)
            cat > /etc/apt/sources.list << EOF
deb https://mirrors.ustc.edu.cn/ubuntu/ noble main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ noble-updates main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ noble-backports main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ noble-security main restricted universe multiverse
EOF
            ;;
        4) return ;;
        *) error_log "无效选择"; return ;;
    esac
    apt update && apt upgrade -y > /dev/null
    success_log "国内源配置完成"
}

# 终端中文配置函数
terminal_chinese() {
    info_log "配置终端全局中文..."
    apt install -y language-pack-zh-hans fonts-wqy-microhei > /dev/null
    update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8
    echo "export LANG=zh_CN.UTF-8" >> $USER_HOME/.bashrc
    success_log "终端中文配置完成，重启终端生效"
}

# 指纹登录配置函数（强化华为MateBook15d适配）
fingerprint_setup() {
    echo -e "${YELLOW}===== 指纹机型适配选择 =====${NC}"
    echo " [1] 华为 MateBook 系列（推荐15d） [2] 联想系列 [3] 通用机型 [4] 跳过"
    read -p "  请选择机型 [1-4]: " fp_idx
    [ $fp_idx -eq 4 ] && return
    info_log "安装指纹驱动并配置..."
    apt install -y libpam-fprintd fprintd hwdata > /dev/null
    case $fp_idx in
        1)
            # 华为MateBook15d专属指纹驱动
            modprobe goodix
            echo "goodix" >> /etc/modules-load.d/modules.conf
            ;;
        2) apt install -y thinkfinger-tools > /dev/null ;;
    esac
    sed -i '2i auth    sufficient    pam_fprintd.so' /etc/pam.d/common-auth
    su - $SUDO_USER -c "fprintd-enroll"
    success_log "指纹登录配置完成，重启系统生效"
}

# 运行库补全函数（适配华为15d集显）
libs_complete() {
    echo -e "${YELLOW}===== 显卡类型选择 =====${NC}"
    echo " [1] 集显（华为15d推荐） [2] NVIDIA独显 [3] 双显卡"
    read -p "  请选择显卡 [1-3]: " gpu_idx
    info_log "安装适配运行库..."
    apt install -y build-essential lib32gcc-s1 wine wine32 mesa-utils > /dev/null
    case $gpu_idx in
        1)
            # 华为15d集显专属优化
            apt install -y libgl1-mesa-glx libgl1-mesa-dri xserver-xorg-video-intel > /dev/null
            ;;
        2) apt install -y nvidia-driver-550 nvidia-utils-550 > /dev/null ;;
        3) apt install -y nvidia-driver-550 nvidia-prime > /dev/null ;;
    esac
    success_log "运行库补全完成"
}

# 华为MateBook15d专属优化（屏幕亮度+触控板+声卡）
huawei_specific() {
    info_log "华为 MateBook 15d 专属优化..."
    # 修复屏幕亮度调节
    sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/s/"$/ acpi_backlight=vendor"/' /etc/default/grub
    # 优化触控板手势
    apt install -y xserver-xorg-input-libinput libinput-tools > /dev/null
    # 修复声卡驱动
    apt install -y alsa-utils pulseaudio > /dev/null
    update-grub > /dev/null
    success_log "华为 MateBook 15d 专属优化完成"
}

# 执行所有基础配置
replace_sources
terminal_chinese
fingerprint_setup
libs_complete
huawei_specific
