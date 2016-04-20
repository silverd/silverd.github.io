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

## SecrueCRT 破解版

    TODO

## Navicat 破解版

    TODO

## Alfred+Dash

    TODO