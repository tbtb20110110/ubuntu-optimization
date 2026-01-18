#!/bin/bash
LOG_FILE="logs/dualboot_$(date +%Y%m%d).log"
mkdir -p logs

# 日志输出函数
info_log() {
    echo -e "${BLUE}[*] $(date +%H:%M:%S) $1${NC}"
    echo "[$(date +%Y-%m-%d %H:%M:%S)] [INFO] $1" >> $LOG_FILE
}

success_log() {
    echo -e "${GREEN}[√] $(date +%H:%M:%S) $1${NC}"
    echo "[$(date +%Y-%m-%d %H:%M:%S)] [SUCCESS] $1" >> $LOG_FILE
}

error_log() {
    echo -e "${RED}[×] $(date +%H:%M:%S) $1${NC}"
    echo "[$(date +%Y-%m-%d %H:%M:%S)] [ERROR] $1" >> $LOG_FILE
}
