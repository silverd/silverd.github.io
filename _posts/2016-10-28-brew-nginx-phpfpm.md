---
layout: post
category: ['Mac', 'LAMP']
title: Mac 通过 brew 安装 Nginx 和 PHP-FPM
---

## 安装服务端 Nginx+PHP-FPM

    brew install nginx
    brew install homebrew/php/php70 --with-fpm

## 启动、重启、停止 Nginx

    brew services restart|start|stop nginx

## Nginx 虚拟主机配置

定位配置文件

    # 快捷方式（个人喜好）
    ln -s /usr/local/etc/nginx/ ~/nginx-conf
    ln -s /usr/local/etc/nginx/servers ~/nginx-conf/vhost

    vi ~/nginx-conf/vhost/hicrew.conf

编辑配置文件（完整版）

    server {

        listen       80;
        server_name  local.m.hicrew.cn local.api.hicrew.cn;

        root /Users/silverd/home/wwwroot/hicrew/app/web;

        location / {
            index index.php;
            autoindex on;
        }

        location ~ \.php$ {
            include /usr/local/etc/nginx/fastcgi.conf;
            fastcgi_intercept_errors on;
            fastcgi_pass   127.0.0.1:9000;
        }
    }

但我的做法是抽出了 vi ~/nginx-conf/php.conf

    location / {
        index index.php;
        autoindex on;
    }

    location ~ \.php$ {
        include /usr/local/etc/nginx/fastcgi.conf;
        fastcgi_intercept_errors on;
        fastcgi_pass   127.0.0.1:9000;
    }

然后虚拟主机 vhost 都 include 它，于是 hicrew.conf 就变成了：

    server {
        listen 80;
        server_name local.m.hicrew.cn local.api.hicrew.cn;
        root /Users/silverd/home/wwwroot/hicrew/app/web;
        include /usr/local/etc/nginx/php.conf;
    }

    server {
        listen 80;
        server_name local.admincp.hicrew.cn;
        root /Users/silverd/home/wwwroot/hicrew/admin/web;
        include /usr/local/etc/nginx/php.conf;
    }

## Nginx 进程管理

    # 必须以 root:wheel 权限运行
    sudo chown root:wheel /usr/local/Cellar/nginx/1.10.0/bin/nginx
    sudo chmod u+s /usr/local/Cellar/nginx/1.10.0/bin/nginx

    # 启动
    sudo nginx
    sudo nginx -s reload|reopen|stop|quit

    # Nginx 开机启动
    sudo ln -sfv /usr/local/opt/nginx/*.plist /Library/LaunchDaemons
    launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.nginx.plist

    # 使用 launchctl 来启动、停止 Nginx
    ln -sfv /usr/local/opt/nginx/*.plist ~/Library/LaunchAgents
    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.nginx.plist
    launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.nginx.plist

## PHP-FPM 进程管理

    # 删除系统自带的 php-fpm5.5
    sudo rm -rf /usr/sbin/php-fpm
    sudo ln -s /usr/local/sbin/php-fpm /usr/sbin/php-fpm

    # 启动 php-fpm
    sudo php-fpm --daemonize -c /usr/local/etc/php/7.0/php.ini -y /usr/local/etc/php/7.0/php-fpm.conf

    # 关闭 php-fpm
    sudo kill -INT `cat /usr/local/var/run/php-fpm.pid`

    # 重启 php-fpm
    sudo kill -USR2 `cat /usr/local/var/run/php-fpm.pid`

    # 设置 php-fpm 开机启动
    ln -sfv /usr/local/opt/php70/*.plist ~/Library/LaunchAgents
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.php70.plist

    # 配置 php-fpm.conf（如果需要）
    /usr/local/etc/php/7.0/php-fpm.conf

## 或者直接设置命令别名 vi ~/.bash_profile 或者 vi ~/.zshrc，加入：

    alias nginx.start='launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.nginx.plist'
    alias nginx.stop='launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.nginx.plist'
    alias nginx.restart='nginx.stop && nginx.start'

    alias php-fpm.start="launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.php70.plist"
    alias php-fpm.stop="launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.php70.plist"
    alias php-fpm.restart='php-fpm.stop && php-fpm.start'
