#!/bin/bash

# 安装依赖项
install_dependencies() {
    apt update
    apt install wget curl jq -y # 安装jq用于解析JSON
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
        *) echo "unsupported" ;;
    esac
}

# 从GitHub API获取最新版本的真实下载链接
get_download_url_from_api() {
    local arch=$1
    local version=$2
    local api_url="https://api.github.com/repos/Naochen2799/Latest-Kernel-BBR3/releases/tags/${arch}-${version}"
    
    # 获取下载链接
    local download_urls
    download_urls=$(curl -s $api_url | jq -r '.assets[] | .browser_download_url')
    echo "$download_urls"
}

# 下载所有文件
download_all_files() {
    local arch=$1
    local version=$2
    
    # 获取真实下载链接
    local download_urls
    download_urls=$(get_download_url_from_api "$arch" "$version")
    
    if [ -z "$download_urls" ]; then
        echo "无法获取下载链接，请检查版本号或架构。"
        exit 1
    fi
    
    local download_dir="/root/bbr3"
    mkdir -p "$download_dir"

    # 下载所有链接
    for url in $download_urls; do
        echo "正在下载：$url"
        wget -e robots=off -P "$download_dir" "$url" || {
            echo "下载失败，请检查链接是否正确或网络连接状态。"
            exit 1
        }
    done
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
        echo "开始下载所有内核包..."
        download_all_files "$arch" "$version"

        echo "安装内核包..."
        install_kernels

        echo "内核安装完成，请重启系统以应用新内核。"
    else
        echo "无法获取最新内核版本信息，请检查网络连接或稍后重试。"
        exit 1
    fi
}

main
