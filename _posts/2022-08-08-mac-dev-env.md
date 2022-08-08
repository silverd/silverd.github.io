---
layout: post
category: ['Mac']
title: Mac 搭建开发环境 2022 重制版
---

## Mac 必装软件

#### 1、日常工具

- Chrome
- Alfred4 + Dash
- Downie
- QQ音乐 + 网易云音乐
- IINA 万能播放器
- 微信 + 企业微信 + QQ
- 腾讯会议
- WPS Office
- The Unarchiver
- CleanMyMac X 或者 Tencent Lemon Lite

#### 2、网络相关

- trojan-qt5
- EasyConnect VPN
- TunnelBlick VPN
- 迅雷

#### 3、生产力工具

- Sublime
- Postman
- Apifox
- Querious
- SourceTree
- iTerm2
- 有道云笔记
- Charles
- Microsoft Todo
- Mircosoft Remote Desktop Beta
- cos-browser & oss-browser

#### 4、命令行

- Homebrew
- Docker
- Git
- Nginx + PHP

#### 5、有趣的应用

- pap.er 自动换壁纸

## Finder 中显示完整路径

```bash
defaults write com.apple.finder _FXShowPosixPathInTitle -bool TRUE;killall Finder
```

## 关于 .DS_store 文件

说明：`.DS_Store` 文件是 MacOS 保存文件夹的自定义属性的隐藏文件，如文件的图标位置或背景色，相当于 Windows 的 desktop.ini。

```bash
# 禁止 .DS_store 生成
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE

# 开启 .DS_store 生成
defaults delete com.apple.desktopservices DSDontWriteNetworkStores
```

## 安装 homebrew

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

如果出现连接不上，可尝试修改DNS解析 `sudo vi /etc/resolev.conf`

```
nameserver 114.114.114.114
nameserver 8.8.8.8
```

## 安装 Command Line Tools

```bash
xcode-select --install
```

## 安装 brew 必备扩展库

```bash
brew install wget
brew install libevent
brew link libevent
brew install autoconf
brew install pkg-config
```

## 安装 ZSH/OhMyZSH

```bash
brew install zsh
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
echo 'export PATH="/usr/local/sbin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## 安装 Nginx + PHP7

```
brew install nginx
brew install php@7.4
```

#### 配置 Nginx

默认配置：

- 默认的 DocumentRoot 为 `/usr/local/var/www/`
- 默认的配置文件 `/usr/local/etc/nginx/nginx.conf`

目录初始化：

```bash
mkdir -p ~/home
mkdir -p -m 777 ~/home/wwwlogs

# 快捷方式（个人喜好）
ln -s /usr/local/var/www ~/home/wwwroot
ln -s /usr/local/etc/nginx/ ~/nginx-conf
ln -s /usr/local/etc/nginx/servers ~/nginx-conf/vhost
```

修改 `vi ~/nginx-conf/nginx.conf` 超时时间及缓冲区等配置，在 `http {}` 区块增加以下内容：

```ini
server_names_hash_bucket_size 128;
client_header_buffer_size 32k;
large_client_header_buffers 4 32k;
client_max_body_size 50m;

fastcgi_connect_timeout 300;
fastcgi_send_timeout 300;
fastcgi_read_timeout 300;
fastcgi_buffer_size 64k;
fastcgi_buffers 4 64k;
fastcgi_busy_buffers_size 128k;
fastcgi_temp_file_write_size 256k;
```

新建 `vi ~/nginx-conf/pathinfo.conf`

```ini
fastcgi_split_path_info ^(.+?\.php)(/.*)$;
set $path_info $fastcgi_path_info;
fastcgi_param PATH_INFO $path_info;
try_files $fastcgi_script_name =404;
```

新建 `vi ~/nginx-conf/php.conf`

```ini
index index.html index.htm index.php;
autoindex on;

location ~ [^/]\.php(/|$) {
    fastcgi_pass  127.0.0.1:9000;
    fastcgi_index index.php;
    include fastcgi.conf;
    include pathinfo.conf;
}
```

新建 `vi ~/nginx-conf/php-laravel.conf`

```ini
include php.conf;

location / {
    try_files $uri $uri/ /index.php?$query_string;
}
```

新建具体应用 `vi ~/nginx-conf/vhost/silverd.conf`：

```ini
server {
    listen 80;
    server_name local.silverd.cn
    root /usr/local/var/www/silverd/public;
    include php-laravel.conf;
}
```

配置完成后，先对 Nginx 配置进行语法检测确保无误：

```bash
nginx -t
```

#### PHP-FPM 配置

1、默认的配置文件 `/usr/local/etc/php/7.4/php.ini`

2、直接使用 `pecl install` 命令安装 PECL 扩展

```
pecl install xlswriter
pecl install mongodb
```

#### Nginx & PHP 进程管理

```bash
# 启动 Nginx
brew services start|restart nginx

# 启动 PHP-FPM
brew services start|restart php@7.4
```

#### 关于 Localhost 的 FAQ

- 1、默认是监听的是 localhost:8080 端口，可以在 nginx.conf 中修改。

- 2、如何让 http://localhost 支持 PHP？

修改 nginx.conf，并打开 server {} 下被注释的 `location ~.php$` 即可。

- 3、如果访问 http://localhost/index.php 出现 File not found，则修改 nginx.conf

```
查找：fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
替换为：fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
```

### HTTP 500 服务器内部错误

修改 `/usr/local/etc/php/7.4/php.ini`，打开并记录错误日志 `error_log=/Users/silverd/home/wwwlogs/php_error.log`。

## Node.js + NPM

建议用 `nvm` 来管理和安装 node 版本，[查看使用说明](http://www.tuicool.com/articles/Vzquy2) 、[nvm 和 n 的区别和原理](http://web.jobbole.com/84249/)

如果之前曾经用官网 pkg 包安装过 node，则需要先删除：

```bash
# 查看已安装在全局模块，以便重装
npm ls -g --depth=0

# 删除 node
sudo rm /usr/local/bin/node

# 删除全局 node_modules 目录
sudo rm -rf /usr/local/lib/node_modules

# 删除全局 node 模块注册的软链
cd  /usr/local/bin && ls -l | grep "../lib/node_modules/" | awk '{print $9}'| xargs rm
```

清理完毕后，开始通过 nvm 来安装 node：

```bash
# 安装 nvm
# 如想安装最新版本的 nvm 可以去 https://github.com/creationix/nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash

# 安装最新稳定版 node
nvm install stable

# 安装指定版本 node
nvm install 6.9.1

# 切换到指定 node 版本
nvm use 14
```

另外可以用 `nrm` 来切换 npm 源，[查看使用说明](http://www.tuicool.com/articles/nYjqeu)

```bash
# 安装 nrm
sudo npm install -g nrm

# 列出可选的源
nrm ls

# 测试所有源的响应时间
nrm test

# 切换到指定源
nrm use taobao
```

提示：如果某个项目需要单独指定 node 版本，可以在项目根目录下新建一个 `.nvmrc` 文件来特殊标明：

```bash
cd staylife_frontend/mobile
echo 4 > .nvmrc
nvm use
node -v
```

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
- Material Theme 非常棒的编辑器主题
- BracketHighlighter 结尾处高亮
- EditorConfig .editorconfig 编码格式化支持
- Emmet 快速编码
- SideBarEnhancements 文件夹栏右键菜单增强
- AdvancedNewFile 快速创建新文件
- GitGutter 标记代码中做的编辑
- SublimeLinter + SublimeLinterPHP 代码检测

想在命令行使用 Sublime？

```bash
ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl
ln -s /usr/local/bin/subl /usr/local/bin/sublime
```

## CharlseProxy

手机代理设置教程，一阵折腾，仿佛回到五年前，详见攻略 https://blog.csdn.net/tantan5201314/article/details/122963056

iPhone (iOS 15) 设置的关键步骤：

- 1、手机 WIFI 设置电脑代理
- 2、手机浏览器访问 https://chls.pro/ssl 下载证书
- 3、通用 -> VPN与设备管理 -> 安装刚刚下载的证书
- 4、通用 -> 关于本机 -> 证书信任设置 -> 启用信任 Charlse 证书

Charles 激活码计算器 https://www.zzzmode.com/mytools/charles


## Git

```
brew install git
git config --global branch.autosetuprebase always
git config --global core.ignorecase false
git config --global core.autocrlf input
git config --global core.safecrlf true
git config --global credential.helper store
git config --global core.excludesfile ~/.gitignore_global
git config --global push.default simple

# 设置提交者
git config --global user.name "silverd"
git config --global user.email "silverd29@gmail.com"
```

## SourceTree

下载安装 https://www.sourcetreeapp.com/download

## iTerm2

下载安装 http://www.iterm2.com/downloads.html 主题下载 http://www.iterm2.com/colorgallery


