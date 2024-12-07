#!/bin/bash

# 安装依赖项
install_dependencies() {
    apt update
    apt install wget curl -y
}

# 获取最新内核版本号
get_latest_kernel_version() {
    local latest_version
    latest_version=$(curl -s https://www.kernel.org | grep -A 1 -m 1 "stable:" | grep -oP '\d+\.\d+\.\d+')
    echo $latest_version
}

# 获取系统架构
get_system_arch() {
    local arch
    arch=$(uname -m)
    echo $arch
}

# 根据系统架构获取下载链接
get_download_link() {
    local arch=$1
    local version=$2
    if [ "$arch" == "x86_64" ]; then
        echo "https://github.com/Naochen2799/Latest-Kernel-BBR3/releases/tag/x86_64-$version"
    elif [ "$arch" == "aarch64" ]; then
        echo "https://github.com/Naochen2799/Latest-Kernel-BBR3/releases/tag/arm64-$version"
    else
        echo "不支持的系统架构：$arch"
        exit 1
    fi
}

# 下载内核
download_kernels() {
    local url=$1
    wget -P /root/bbr3 "$url"
}

# 安装内核
install_kernels() {
    dpkg -i /root/bbr3/*.deb
}

# 主程序
main() {
    install_dependencies
    local version
    version=$(get_latest_kernel_version)
    local arch
    arch=$(get_system_arch)
    if [ -n "$version" ] && [ -n "$arch" ]; then
        local download_link
        download_link=$(get_download_link "$arch" "$version")
        if [ -n "$download_link" ]; then
            download_kernels "$download_link"
            install_kernels
            echo "安装完成，请重启以启用新内核。"
        else
            echo "无法获取内核下载链接，请稍后重试。"
            exit 1
        fi
    else
        echo "无法获取最新内核版本信息，请检查网络连接或稍后重试。"
        exit 1
    fi
}

main
