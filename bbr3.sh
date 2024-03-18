#!/bin/bash

# 安装依赖项
install_dependencies() {
    apt update
    apt install wget curl -y
}

# 获取最新内核版本的下载链接
get_latest_kernel_url() {
    curl -s "https://api.github.com/repos/Naochen2799/Latest-Kernel-BBR3/releases/latest" \
    | grep "browser_download_url" \
    | grep -v "linux-libc-dev" \
    | cut -d '"' -f 4
}

# 下载并安装内核
install_kernel() {
    local url="$1"
    wget -P /root/bbr3 "$url"
    dpkg -i /root/bbr3/*.deb
}

# 主程序
main() {
    install_dependencies
    local kernel_url
    kernel_url=$(get_latest_kernel_url)
    if [ -n "$kernel_url" ]; then
        install_kernel "$kernel_url"
        echo "安装完成，请重启以启用新内核。"
    else
        echo "无法获取内核下载链接，请检查网络连接或稍后重试。"
        exit 1
    fi
}

main