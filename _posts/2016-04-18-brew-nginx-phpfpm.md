---
layout: post
category: ['Mac', 'LAMP']
title: Mac 搭建开发环境（三）Nginx/PHP-FPM
---

## 安装 Nginx+PHP-FPM

```bash
brew install nginx --with-http2
brew install php@7.4
```

## Nginx 配置

默认的 DocumentRoot 为 `/usr/local/var/www/` => `/usr/local/opt/nginx/html/`

默认是监听的是 localhost:8080 端口，可以在 nginx.conf 中修改。

    # 默认的配置文件位置
    /usr/local/etc/nginx/nginx.conf

    # 快捷方式（个人喜好）
    ln -s /usr/local/etc/nginx/ ~/nginx-conf
    ln -s /usr/local/etc/nginx/servers ~/nginx-conf/vhost

修改 vi ~/nginx-conf/nginx.conf 超时时间及缓冲区等配置，在 http {} 区块增加以下内容：

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

新建 vi ~/nginx-conf/pathinfo.conf

    fastcgi_split_path_info ^(.+?\.php)(/.*)$;
    set $path_info $fastcgi_path_info;
    fastcgi_param PATH_INFO $path_info;
    try_files $fastcgi_script_name =404;

新建虚拟主机（完整版）vi ~/nginx-conf/vhost/staylife.conf

    server {

        listen 80;
        server_name local.wp.staylife.cn local.api.staylife.cn;
        root /Users/silverd/home/wwwroot/staylife_server/app/web;

        index index.html index.htm index.php;
        autoindex on;

        location ~ [^/]\.php(/|$) {
            fastcgi_pass  127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi.conf;
            include pathinfo.conf;
        }

        location / {
            if (!-e $request_filename) {
                rewrite ^/(.*)$ /index.php/$1 last;
            }
        }

    }

但我的做法是抽出了几个配置文件：

#### vi ~/nginx-conf/php.conf

    index index.html index.htm index.php;
    autoindex on;

    location ~ [^/]\.php(/|$) {
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi.conf;
        include pathinfo.conf;
    }

#### vi ~/nginx-conf/php-yaf.conf

    include php.conf;

    location / {
        if (!-e $request_filename) {
            rewrite ^/(.*)$ /index.php/$1 last;
        }
    }

#### vi ~/nginx-conf/php-laravel.conf

    include php.conf;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

#### vi ~/nginx-conf/php-yii.conf

    include php.conf;

    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }

然后虚拟主机 `vhost/*.conf` 里都 `include php-yaf.conf`，于是 `staylife.conf` 最终变成了：

    server {
        listen 80;
        server_name local.api.staylife.cn;
        root /Users/silverd/home/wwwroot/staylife/app/web;
        include php-yaf.conf;
    }

## Nginx 进程管理

    # 如果想要 Nginx 开机自启动，则必须以 root:wheel 权限运行
    # Linux 系统非 root 用户禁用 1024 以下的端口
    sudo chown root:wheel /usr/local/bin/nginx
    sudo chmod u+s /usr/local/bin/nginx

    # 启动
    sudo nginx

    # 重启、停止等
    sudo nginx -s reload|reopen|stop|quit

    # 设置 Nginx 开机启动
    sudo ln -sfv /usr/local/opt/nginx/*.plist /Library/LaunchDaemons
    sudo chown root:wheel /Library/LaunchDaemons/homebrew.mxcl.nginx.plist
    sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.nginx.plist

## PHP-FPM 进程管理

    # 配置文件
    /usr/local/etc/php/7.4/php-fpm.conf

    # 如果想要 php-fpm 开机自启动，则必须以 root:wheel 权限运行
    sudo chown root:wheel /usr/local/sbin/php-fpm
    sudo chmod u+s /usr/local/sbin/php-fpm

    # 其他方法：启动 php-fpm
    sudo /usr/local/sbin/php-fpm --daemonize -c /usr/local/etc/php/7.4/php.ini -y /usr/local/etc/php/7.4/php-fpm.conf

    # 其他方法：关闭 php-fpm
    sudo kill -INT `cat /usr/local/var/run/php-fpm.pid`

    # 其他方法：重启 php-fpm
    sudo kill -USR2 `cat /usr/local/var/run/php-fpm.pid`

    # 设置 php-fpm 开机启动
    sudo ln -sfv /usr/local/opt/php@7.4/homebrew.mxcl.php.plist /Library/LaunchDaemons
    sudo chown root:wheel /Library/LaunchDaemons/homebrew.mxcl.php.plist
    sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.php.plist

## 或者直接设置命令别名 `vi ~/.zshrc`，加入：

    alias nginx.start="sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.nginx.plist"
    alias nginx.stop="sudo launchctl unload -w /Library/LaunchDaemons/homebrew.mxcl.nginx.plist"
    alias nginx.restart='nginx.stop && nginx.start'

    alias php.start="sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.php.plist"
    alias php.stop="sudo launchctl unload -w /Library/LaunchDaemons/homebrew.mxcl.php.plist"
    alias php.restart='php.stop && php.start'

    source ~/.zshrc

## FAQ

### 如何让 http://localhost 支持 PHP？

修改 nginx.conf，并打开 server {} 下被注释的 location ~.php$ 即可。

如果访问 http://localhost/index.php 出现 File not found
那么修改 nginx.conf

    查找：fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    替换为：fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;

### Nginx 无法启动

使用 `nginx -t` 检测配置文件是否有误，如果提示了：

```
nginx: [alert] could not open error log file: open() "/usr/local/var/log/nginx/error.log" failed (13: Permission denied)
nginx: the configuration file /usr/local/etc/nginx/nginx.conf syntax is ok
2020/04/20 14:37:55 [emerg] 61477#0: open() "/usr/local/var/run/nginx.pid" failed (13: Permission denied)
nginx: configuration file /usr/local/etc/nginx/nginx.conf test failed
```

那必须执行修改权限：

```bash
sudo chown root:wheel /usr/local/bin/nginx
sudo chmod u+s /usr/local/bin/nginx
```

### 网页报 500 服务器内部错误

修改 `/usr/local/etc/php.ini`，打开并记录错误日志 `error_log=/Users/silverd/home/wwwlogs/php_error.log`。

## 参考文章

- <http://www.cnblogs.com/cheemon/p/5638394.html>
