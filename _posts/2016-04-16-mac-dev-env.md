---
layout: post
title: Mac 搭建开发环境（二）常用软件
---

## SublimeText3

    http://www.sublimetext.com/3

    # 常用插件
    - PackageControl
    - Alignment
    - MarkdownHighlighting
    - SublimeLinter+SublimeLinterPHP
    - Sass
    - Vue Syntax Highlight
    - DocBlockr

## Zsh/OhMyZsh

    brew install zsh
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh

    # 自定义配置文件
    vim ~/.zshrc

## Vi/Vim

    # 启用 vim 语法高亮
    echo 'syntax on' >> ~/.vimrc
    source ~/.vimrc

## CharlseProxy

    http://www.charlesproxy.com/download/

    如何抓取 https?

    # 1、将证书导入手机，用手机 Safari 打开以下地址：
    http://www.charlesproxy.com/assets/legacy-ssl/charles.crt

    # 2、手机安装好证书并设置代理IP
    # 3、Charles -> Proxy -> Proxy Settings -> SSL -> Enable SSL Proxying，在下方 Locations 区域添加要抓取的域名和端口443

## Wine

    brew install Caskroom/cask/xquartz
    brew install wine

    # 开始安装
    wine heidisql-installer.exe

    # 启动程序
    wine /User/....exe

## Git

    brew install git
    git config --global branch.autosetuprebase always
    git config --global core.autocrlf false
    git config --global core.safecrlf true
    git config --global credential.helper store

## SourceTree

    https://www.sourcetreeapp.com/download/

## iTerm2

    http://www.iterm2.com/downloads.html

## Scroll Reverser

    http://pilotmoon.com/scrollreverser/

## ShadowsocksX

    # ShadowsocksX-2.6.3.dmg
    https://github.com/shadowsocks/shadowsocks-iOS/releases

## SecureCRT

    # v7.3.7 下载地址
    http://macabc.com/detail.htm?app_id=24

    # 破解方法

        # 1. 下载破解文件 securecrt_mac_crack.pl [地址1](http://yun.baidu.com/share/link?shareid=297986172&uk=18145526) [地址2](/attach/securecrt_mac_crack.pl)

        # 2. 在终端执行命令，会返回一组序列号信息，然后打开 SecureCRT 手动依次输入这些信息就可
        sudo perl securecrt_mac_crack.pl /Applications/SecureCRT.app/Contents/MacOS/SecureCRT

    # 破解方法原文
    http://bbs.feng.com/read-htm-tid-6939481.html

## Navicat 破解版

    # 下载链接
    https://www.baidu.com/link?url=Y2t3PwH15wRS7C9DhwP3w_pv1cI9F5Ugag_8N2l6xcFMxxzJvJNn_-E8J8tyJTGoRXarhpcLX1Za2Caq_pS1Sa&wd=&eqid=ecf428b4000340a200000005571a288b

## Alfred+Dash

    TODO