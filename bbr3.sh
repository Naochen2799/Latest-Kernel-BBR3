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
    case $arch in
        x86_64) echo "x86_64" ;;
        aarch64) echo "arm64" ;;
        *) echo "不支持的系统架构，请提交issues" ;;
    esac
}

# 下载指定版本和架构下的内核包
download_all_deb_files() {
    local arch=$1
    local version=$2
    local base_url="https://github.com/Naochen2799/Latest-Kernel-BBR3/releases/download/${arch}-${version}/"
    local download_dir="/root/bbr3"
    
    mkdir -p "$download_dir"

    echo "正在从 $base_url 下载所有内核包..."
    wget -r -np -nd -P "$download_dir" -A "*.deb" "$base_url" || {
        echo "下载失败，请检查链接是否正确或网络连接状态。"
        exit 1
    }
}

# 安装内核文件
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

    if [ "$arch" == "unsupported" ]; then
        echo "不支持的系统架构：$arch"
        exit 1
    fi

    if [ -n "$version" ]; then
        echo "检测到最新内核版本：$version"
        echo "开始下载内核包..."
        download_all_deb_files "$arch" "$version"

        echo "安装内核包..."
        install_kernels

        echo "内核安装完成，请重启系统以应用新内核。"
    else
        echo "无法获取最新内核版本信息，请检查网络连接或稍后重试。"
        exit 1
    fi
}

main
