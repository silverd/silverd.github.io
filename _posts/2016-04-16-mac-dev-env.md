---
layout: post
category: ['Mac']
title: Mac 搭建开发环境（二）常用软件
---

## Finder 中显示完整路径

    defaults write com.apple.finder _FXShowPosixPathInTitle -bool TRUE;killall Finder

## 关于 .DS_store 文件

说明：`.DS_Store` 文件是 MacOS 保存文件夹的自定义属性的隐藏文件，如文件的图标位置或背景色，相当于 Windows 的 desktop.ini。

    # 禁止 .DS_store 生成
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE

    # 开启 .DS_store 生成
    defaults delete com.apple.desktopservices DSDontWriteNetworkStores

## Node.js+Npm

建议用 `nvm` 来管理和安装 node 版本，[查看使用说明](http://www.tuicool.com/articles/Vzquy2) 、[nvm 和 n 的区别和原理](http://web.jobbole.com/84249/)

如果之前曾经用官网 pkg 包安装过 node，则需要先删除：

    # 查看已安装在全局模块，以便重装
    npm ls -g --depth=0

    # 删除 node
    sudo rm /usr/local/bin/node

    # 删除全局 node_modules 目录
    sudo rm -rf /usr/local/lib/node_modules

    # 删除全局 node 模块注册的软链
    cd  /usr/local/bin && ls -l | grep "../lib/node_modules/" | awk '{print $9}'| xargs rm

清理完毕后，开始通过 nvm 来安装 node：

    # 安装 nvm
    # 如想安装最新版本的 nvm 可以去 https://github.com/creationix/nvm
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash

    # 安装最新稳定版 node
    nvm install stable

    # 安装指定版本 node
    nvm install 6.9.1

    # 切换到指定 node 版本
    nvm use 7

另外可以用 `nrm` 来切换 npm 源，[查看使用说明](http://www.tuicool.com/articles/nYjqeu)

    # 安装 nrm
    sudo npm install -g nrm

    # 列出可选的源
    nrm ls

    # 测试所有源的响应时间
    nrm test

    # 切换到指定源
    nrm use taobao

提示：如果某个项目需要单独指定 node 版本，可以在项目根目录下新建一个 `.nvmrc` 文件来特殊标明：

    cd staylife_frontend/mobile
    echo 4 > .nvmrc
    nvm use
    node -v

## SublimeText3

下载地址：http://www.sublimetext.com/3

安装常用插件：

- PackageControl
- Alignment
- MarkdownHighlighting
- Sass
- Less
- Vue Syntax Highlight
- DocBlockr
- ColorsSublime 代码高亮主题管理插件，安装成功后需要照着文档配置两个地方
- Material Theme 非常棒的编辑器主题
- Blade Snippets Blade 模板自动补全
- Laravel Blade Hightlighter Blade 语法高亮支持
- SyncedSideBar 自动在左边文件夹树中定位当前文件
- BracketHighlighter 结尾处高亮
- EditorConfig .editorconfig 编码格式化支持
- Emmet 快速编码
- SideBarEnhancements 文件夹栏右键菜单增强
- AdvancedNewFile 快速创建新文件
- GitGutter 标记代码中做的编辑
- Laravel 5 Artisan Artisan 命令行调用
- Laravel 5 Snippets 代码片段
- SublimeLinter + SublimeLinterPHP 代码检测

想在命令行使用 Sublime？

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
    git config --global core.excludesfile ~/.gitignore_global

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

