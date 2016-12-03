---
layout: post
category: ['LAMP', '架构']
title: 如何升级 CentOS 的 OpenSSL 库
---

Nginx 开启 HTTP/2 要求 OpenSSL 库版本必须 1.0.2 以上（因为 1.0.1a~f 有安全威胁，虽然 1.0.1g 已修复）。除了在安装 Nginx 时临时指定 OpenSSL 源码路径外，我们也可以动手将 CentOS 系统自带的 OpenSSL 库升级，一劳永逸。

OpenSSL 官网：<https://www.openssl.org>

查看当前 OpenSSL 版本：

    openssl version -a

先更新 zlib（提供压缩传输支持）：

    yum install -y zlib

然后开始下载安装 OpenSSL：

    # 下载解压
    wget https://www.openssl.org/source/openssl-1.0.2j.tar.gz
    tar -zxvf openssl-1.0.2j.tar.gz
    cd openssl-1.0.2j

    # 编译安装
    ./config shared zlib-dynamic
    make && make install

    # 备份旧的版本
    mv /usr/bin/openssl /usr/bin/openssl.old
    mv /usr/include/openssl /usr/include/openssl.old

    # 为新的版本建立软链
    ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
    ln -s /usr/local/ssl/include/openssl /usr/include/openssl

然后修改系统自带的 OpenSSL 库文件：

    # 找到系统库位置（各种 Linux 版本都不同）
    # CentOS 6.6 是在以下位置：`/usr/lib64/libssl.so`
    find / -name 'libssl.so'

    # 建立软链（因为 /usr/local/lib64/ 读取优先级高于 /usr/lib64/）
    ln -s /usr/local/ssl/lib/libssl.so /usr/local/lib64/libssl.so

    rm -f /usr/lib64/libssl.so
    ln -s /usr/local/ssl/lib/libssl.so /usr/lib64/libssl.so

查看 OpenSSL 依赖库版本是否为 1.0.2j 了：

    strings /usr/local/lib64/libssl.so | grep OpenSSL

更新可共享的动态链接库的搜索路径：

    echo "/usr/local/ssl/lib" >> /etc/ld.so.conf

    # 使 ld.so.conf 立即生效
    # ldconfig 命令会重建缓存文件 `/etc/ld.so.cache`
    # 参数 `-v` 或 `--verbose` 可以让 ldconfig 显示正在扫描的目录及搜索到的共享库
    ldconfig --verbose

升级完成。再次看看版本是不是最新的了？

    openssl version

参考文章：

- <http://blog.csdn.net/xysoul/article/details/49913645>
- <http://www.jbxue.com/LINUXjishu/4964.html>


