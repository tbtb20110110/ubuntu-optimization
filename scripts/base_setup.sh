#!/bin/bash
# 终极修复：切换到脚本自身目录，确保找到log_tool.sh
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
source ./log_tool.sh

USER_HOME=$(eval echo ~$SUDO_USER)

# 核心修复：自动检测架构，arm64用ubuntu-ports源，amd64用普通源
replace_sources() {
    # 检测系统架构，aarch64对应arm64
    ARCH=$(uname -m)
    if [ "$ARCH" = "aarch64" ]; then
        PORT_FLAG="-ports"
        echo -e "${YELLOW}检测到 arm64 架构，自动使用 ubuntu-ports 源${NC}"
    else
        PORT_FLAG=""
    fi

    echo -e "${YELLOW}===== 国内源选择 =====${NC}"
    echo " [1] 阿里云源 [2] 清华大学源 [3] 中科大源 [4] 保留官方源"
    read -p "  请选择源 [1-4]: " src_idx
    case $src_idx in
        1)
            cat > /etc/apt/sources.list << EOF
deb http://mirrors.aliyun.com/ubuntu${PORT_FLAG}/ noble main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu${PORT_FLAG}/ noble-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu${PORT_FLAG}/ noble-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu${PORT_FLAG}/ noble-security main restricted universe multiverse
EOF
            ;;
        2)
            cat > /etc/apt/sources.list << EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu${PORT_FLAG}/ noble main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu${PORT_FLAG}/ noble-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu${PORT_FLAG}/ noble-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu${PORT_FLAG}/ noble-security main restricted universe multiverse
EOF
            ;;
        3)
            cat > /etc/apt/sources.list << EOF
deb https://mirrors.ustc.edu.cn/ubuntu${PORT_FLAG}/ noble main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu${PORT_FLAG}/ noble-updates main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu${PORT_FLAG}/ noble-backports main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu${PORT_FLAG}/ noble-security main restricted universe multiverse
EOF
            ;;
        4) return ;;
        *) error_log "无效选择"; return ;;
    esac
    # 忽略索引下载失败，强制更新
    apt update -o Acquire::Failed-Timeout=30 -y || true
    apt upgrade -y > /dev/null
    success_log "国内源配置完成"
}

# 核心修复：替换缺失的字体包为 arm64 兼容版
terminal_chinese() {
    info_log "配置终端全局中文..."
    # 用 fonts-wqy-microhei-lite 替代原包，兼容所有架构
    apt install -y language-pack-zh-hans fonts-wqy-microhei-lite > /dev/null
    update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8
    echo "export LANG=zh_CN.UTF-8" >> $USER_HOME/.bashrc
    success_log "终端中文配置完成，重启终端生效"
}

fingerprint_setup() {
    echo -e "${YELLOW}===== 指纹机型适配选择 =====${NC}"
    echo " [1] 华为 MateBook 系列（推荐15d） [2] 联想系列 [3] 通用机型 [4] 跳过"
    read -p "  请选择机型 [1-4]: " fp_idx
    [ $fp_idx -eq 4 ] && return
    info_log "安装指纹驱动并配置..."
    apt install -y libpam-fprintd fprintd hwdata > /dev/null
    case $fp_idx in
        1)
            modprobe goodix
            echo "goodix" >> /etc/modules-load.d/modules.conf
            ;;
        2) apt install -y thinkfinger-tools > /dev/null ;;
    esac
    sed -i '2i auth    sufficient    pam_fprintd.so' /etc/pam.d/common-auth
    su - $SUDO_USER -c "fprintd-enroll"
    success_log "指纹登录配置完成，重启系统生效"
}

libs_complete() {
    echo -e "${YELLOW}===== 显卡类型选择 =====${NC}"
    echo " [1] 集显（华为15d推荐） [2] NVIDIA独显 [3] 双显卡"
    read -p "  请选择显卡 [1-3]: " gpu_idx
    info_log "安装适配运行库..."
    apt install -y build-essential lib32gcc-s1 wine wine32 mesa-utils > /dev/null
    case $gpu_idx in
        1)
            apt install -y libgl1-mesa-glx libgl1-mesa-dri xserver-xorg-video-intel > /dev/null
            ;;
        2) apt install -y nvidia-driver-550 nvidia-utils-550 > /dev/null ;;
        3) apt install -y nvidia-driver-550 nvidia-prime > /dev/null ;;
    esac
    success_log "运行库补全完成"
}

huawei_specific() {
    info_log "华为 MateBook 15d 专属优化..."
    # 避免重复写入 GRUB 参数
    if ! grep -q "acpi_backlight=vendor" /etc/default/grub; then
        sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/s/"$/ acpi_backlight=vendor"/' /etc/default/grub
    fi
    apt install -y xserver-xorg-input-libinput libinput-tools alsa-utils pulseaudio > /dev/null
    update-grub > /dev/null
    success_log "华为 MateBook 15d 专属优化完成"
}

# 执行所有配置
replace_sources
terminal_chinese
fingerprint_setup
libs_complete
huawei_specific
