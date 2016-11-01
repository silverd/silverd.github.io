---
layout: post
category: ['Mac', 'LAMP']
title: Mac 搭建开发环境（三）Nginx/PHP-FPM
---

## 安装 Nginx+PHP-FPM

    brew install nginx
    brew install homebrew/php/php70 --with-fpm --without-apache

## Nginx 配置

默认的 DocumentRoot 为 /usr/local/var/www/ => /usr/local/opt/nginx/html/

默认是监听的是 localhost:8080 端口，可以在 nginx.conf 中修改。

    # 默认的配置文件位置
    /usr/local/etc/nginx/nginx.conf

    # 快捷方式（个人喜好）
    ln -s /usr/local/etc/nginx/ ~/nginx-conf
    ln -s /usr/local/etc/nginx/servers ~/nginx-conf/vhost

新建 vi ~/nginx-conf/pathinfo.conf

    fastcgi_split_path_info ^(.+?\.php)(/.*)$;
    set $path_info $fastcgi_path_info;
    fastcgi_param PATH_INFO       $path_info;
    try_files $fastcgi_script_name =404;

新建一个虚拟主机（完整版）

    vi ~/nginx-conf/vhost/staylife.conf

    server {

        listen       80;
        server_name  local.wp.staylife.cn local.api.staylife.cn;
        root /Users/silverd/home/wwwroot/staylife_server/app/web;

        index index.html index.htm index.php;
        autoindex on;
        
        location ~ [^/]\.php(/|$) {
            fastcgi_pass  127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi.conf;
            include pathinfo.conf;
        }

        location /
        {
            if (!-e $request_filename) {
                rewrite ^/(.*)$ /index.php/$1 last;
            }
        }

    }

但我的做法是抽出了 vi ~/nginx-conf/php-yaf.conf

    index index.html index.htm index.php;
    autoindex on;
    
    location ~ [^/]\.php(/|$) {
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi.conf;
        include pathinfo.conf;
    }

    location /
    {
        if (!-e $request_filename) {
            rewrite ^/(.*)$ /index.php/$1 last;
        }
    }

然后虚拟主机 vhost 都 include 它，于是 staylife.conf 就变成了：

    server {
        listen 80;
        server_name local.wp.staylife.cn local.api.staylife.cn;
        root /Users/silverd/home/wwwroot/staylife/app/web;
        include php-yaf.conf;
    }

## Nginx 进程管理

    # 必须以 root:wheel 权限运行
    sudo chown root:wheel /usr/local/Cellar/nginx/1.10.2_1/bin/nginx
    sudo chmod u+s /usr/local/Cellar/nginx/1.10.2_1/bin/nginx

    # 启动
    sudo nginx
    sudo nginx -s reload|reopen|stop|quit

    # Nginx 开机启动
    sudo ln -sfv /usr/local/opt/nginx/*.plist /Library/LaunchDaemons
    launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.nginx.plist

    # 使用 launchctl 来启动、停止 Nginx
    ln -sfv /usr/local/opt/nginx/*.plist ~/Library/LaunchAgents
    launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.nginx.plist

## PHP-FPM 进程管理

    # 启动 php-fpm
    sudo /usr/local/sbin/php-fpm --daemonize -c /usr/local/etc/php/7.0/php.ini -y /usr/local/etc/php/7.0/php-fpm.conf

    # 关闭 php-fpm
    sudo kill -INT `cat /usr/local/var/run/php-fpm.pid`

    # 重启 php-fpm
    sudo kill -USR2 `cat /usr/local/var/run/php-fpm.pid`

    # 设置 php-fpm 开机启动
    ln -sfv /usr/local/opt/php70/*.plist ~/Library/LaunchAgents
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.php70.plist

    # 配置 php-fpm.conf（如果需要）
    /usr/local/etc/php/7.0/php-fpm.conf

## 或者直接设置命令别名 vi ~/.zshrc，加入：

    alias nginx.start='launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.nginx.plist'
    alias nginx.stop='launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.nginx.plist'
    alias nginx.restart='nginx.stop && nginx.start'

    alias php-fpm.start="launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.php70.plist"
    alias php-fpm.stop="launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.php70.plist"
    alias php-fpm.restart='php-fpm.stop && php-fpm.start'

    source ~/.zshrc
