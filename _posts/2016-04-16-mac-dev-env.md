---
layout: post
category: ['Mac']
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
    - Less
    - Vue Syntax Highlight
    - DocBlockr
    - Emmet
    - SideBar Enhancement

    # 在命令行使用 Sublime
    ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl
    ln -s /usr/local/bin/subl /usr/local/bin/sublime

## Zsh/OhMyZsh

    brew install zsh
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh

    echo 'export PATH="/usr/local/sbin:$PATH"' >> ~/.zshrc
    source ~/.zshrc

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

    # 设置手机代理、安装证书（依次点击可查看当前电脑IP、端口、证书地址）
    1、Charles ->Help -> SSL Proxying ->Install Charles Root Certifate on a Mobile Device or Remote Browser
    2、用手机浏览器（Safari）打开并安装上面窗口提示的证书，例如：
        http://www.charlesproxy.com/getssl

    # 设置需要捕获的域名
    4、Charles -> Proxy -> Proxy Settings -> SSL -> Enable SSL Proxying，在下方 Locations 区域添加要抓取的域名和端口443

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
    git config --global core.autocrlf input
    git config --global core.safecrlf true
    git config --global credential.helper store

    # 设置提交者
    git config --global user.name "silverd"
    git config --global user.email "silverd29@gmail.com"

## SourceTree

    https://www.sourcetreeapp.com/download/

## iTerm2

    http://www.iterm2.com/downloads.html

    # 安装主题（Solarized Dark Higher Contrast 不错）
    http://www.iterm2.com/colorgallery

## Scroll Reverser

    http://pilotmoon.com/scrollreverser/

## ShadowsocksX

    # ShadowsocksX-2.6.3.dmg
    https://github.com/shadowsocks/shadowsocks-iOS/releases

## SecureCRT

    # v7.3.7 下载地址
    http://macabc.com/detail.htm?app_id=24

    # 正常安装

    # 破解方法1. 下载破解文件 securecrt_mac_crack.pl
    地址1：http://yun.baidu.com/share/link?shareid=297986172&uk=18145526
    地址2：https://raw.githubusercontent.com/silverd/silverd.github.io/master/res/attach/securecrt_mac_crack.pl

    # 破解方法2. 在终端执行命令，会返回一组序列号信息，然后打开 SecureCRT 手动依次输入这些信息就可
    sudo perl securecrt_mac_crack.pl /Applications/SecureCRT.app/Contents/MacOS/SecureCRT

    # 破解方法原文
    http://bbs.feng.com/read-htm-tid-6939481.html

## Navicat

    # 下载链接（直接就是破解版 v11.1.8）
    http://www.waitsun.com/navicat-premium-11-1-11.html

## Alfred+Dash

    # Alfred3 破解版
    http://www.sdifenzhou.com/alfred3.html

    # Dash
    http://scriptfans.iteye.com/blog/1543219

    # Dash 集成 Alfred
    Dash -> Preference -> Integration -> Alfred Import

## Genymotion+VitualBox

    https://www.virtualbox.org/wiki/Downloads
    https://www.genymotion.com/download/

## 增加 ssh-copy-id 命令（MacOS 不自带）

    # 仓库原地址：https://github.com/beautifulcode/ssh-copy-id-for-OSX
    curl -L https://raw.githubusercontent.com/beautifulcode/ssh-copy-id-for-OSX/master/install.sh | sh

    # 用法示例
    ssh-copy-id -i ~/.ssh/dev@morecruit.pub root@m.hicrew.cn

