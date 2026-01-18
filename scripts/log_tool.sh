#!/bin/bash
# 补充颜色变量，解决子脚本调用时无颜色输出的问题
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

LOG_FILE="logs/dualboot_$(date +%Y%m%d).log"
mkdir -p logs

# 核心修复：date 格式符添加双引号
info_log() {
    echo -e "${BLUE}[*] $(date +"%H:%M:%S") $1${NC}"
    echo "[$(date +%Y-%m-%d %H:%M:%S)] [INFO] $1" >> $LOG_FILE
}

success_log() {
    echo -e "${GREEN}[√] $(date +"%H:%M:%S") $1${NC}"
    echo "[$(date +%Y-%m-%d %H:%M:%S)] [SUCCESS] $1" >> $LOG_FILE
}

error_log() {
    echo -e "${RED}[×] $(date +"%H:%M:%S") $1${NC}"
    echo "[$(date +%Y-%m-%d %H:%M:%S)] [ERROR] $1" >> $LOG_FILE
}

# 通用下载失败检查函数
check_download() {
    if [ $? -ne 0 ]; then
        error_log "$1 下载失败，请检查网络或仓库地址"
        exit 1
    fi
}
