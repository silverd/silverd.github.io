---
layout: post
title: Mac 搭建开发环境（二）常用软件
---

## Finder 中显示完整路径

    defaults write com.apple.finder _FXShowPosixPathInTitle -bool TRUE;killall Finder

## NodeJS/NPM

    # https://nodejs.org/en/
    https://nodejs.org/dist/v6.0.0/node-v6.0.0.pkg

    # 使用淘宝 CNPM 镜像（http://npm.taobao.org）
    npm install -g cnpm --registry=https://registry.npm.taobao.org

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

    # 安装 monokai 主题
    1.下载 Monokai.vim (https://github.com/sickill/vim-monokai) 保存到 ~/.vim/colors 下;
    2.编辑 ~/.vimrc 文件，添加 syntax enable、colorscheme Monokai 两行，例如：

        syntax enable
        colorscheme Monokai

        set encoding=utf-8
        set fileencoding=utf-8
        set fileencodings=ucs-bom,utf-8,chinese,cp936
        set guifont=Consolas:h15
        language messages zh_CN.utf-8
        set number
        set autoindent
        set smartindent
        set tabstop=4
        set autochdir
        set shiftwidth=4
        set foldmethod=manual
        set nocompatible
        set nobackup

## CharlseProxy

    http://www.charlesproxy.com/download/

    如何抓取 https?

    # 1、将证书导入手机，用手机 Safari 打开以下地址：
    http://www.charlesproxy.com/assets/legacy-ssl/charles.crt

    # 2、手机安装好证书并设置代理IP
    # 3、Charles -> Proxy -> Proxy Settings -> SSL -> Enable SSL Proxying，在下方 Locations 区域添加要抓取的域名和端口443

## Wine

    # XQuartz >= 2.7.7
    brew install Caskroom/cask/xquartz

    # 安转 wine
    brew install wine

    # 或者去官网下载
    https://dl.winehq.org/wine-builds/macosx/download.html

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

    # 设置提交者
    git config --global user.name "silverd"
    git config --global user.email "silverd29@gmail.com"

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
