# Ubuntu 24.04 双系统一键优化脚本
> 适配 **华为 MateBook 15d 集显版** | 自动下载主题字体 | 系统深度优化 | 终端/桌面/GRUB 美化

## 🌟 核心功能
### 基础配置
- 国内源切换（阿里/清华/中科大）
- 终端强制中文汉化
- 华为专属指纹驱动+登录配置
- 集显适配运行库补全

### 自动资源下载
- 自动下载终端字体（JetBrainsMono/FiraCode）
- 自动下载桌面/GRUB主题（Catppuccin/Nordic）
- 无需手动上传主题文件

### 美化功能
- 终端：oh-my-zsh + 多配色方案 + 语法高亮
- 桌面：GNOME/KDE 主题+图标配置
- GRUB：引导菜单美化，支持双系统识别

### 新增系统深度优化（重点）
1. **系统清理**：APT缓存、旧日志、用户垃圾一键清理
2. **启动项管理**：安装sysv-rc-conf，可视化禁用无用服务
3. **华为电源优化**：tlp电源管理+屏幕亮度修复，提升续航
4. **中文输入法**：fcitx5+rime配置，开箱即用
5. **文件管理器**：显示隐藏文件/扩展名，添加右键新建文档
6. **防火墙**：ufw默认拒绝入站，允许SSH远程连接
7. **SSH服务**：安装配置，支持密钥登录（可选）

## 🚀 使用方法
1. **拉取脚本**
   ```bash
   wget -q https://raw.githubusercontent.com/你的用户名/ubuntu-optimization/main/main.sh -O main.sh
   chmod +x main.sh
