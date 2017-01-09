---
layout: post
category: ['LAMP', '架构']
title: Nginx 访问日志记录 RespBody 响应内容
---

Nginx 本身可以通过 `$request_body` 变量记录请求内容，但响应内容需要通过 Lua 模块来记录：

步骤如下：

安装 LuaJIT：

    wget http://luajit.org/download/LuaJIT-2.0.4.tar.gz
    tar zxvf LuaJIT-2.0.4.tar.gz
    cd LuaJIT-2.0.4
    make
    make install

安装 Lua：

    yum install readline-devel
    wget http://www.lua.org/ftp/lua-5.3.3.tar.gz
    tar zxvf lua-5.3.3.tar.gz
    cd lua-5.3.3
    make linux
    make install

安装 Nginx 开发包：

    cd /usr/local
    git clone https://github.com/simpl/ngx_devel_kit.git

安装 LuaNginx 模块：

    cd /usr/local
    git clone https://github.com/chaoslawful/lua-nginx-module.git

    # 使 ld.so.conf 立即生效

刷新动态库路径缓存：

    ldconfig --verbose

重新编译 Nginx，加入以下两个参数：

    ./configure \
        ...
        --add-module=/usr/local/ngx_devel_kit \
        --add-module=/usr/local/lua-nginx-module
    make

    # 平滑升级
    mv /usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx.bak
    \cp objs/nginx /usr/local/nginx/sbin/nginx
    make upgrade

顺便说一下，如果用的是 `lnmp1.3-full` 一键包，则修改 `/root/soft/lnmp1.3-full/lnmp.conf`：

    Nginx_Modules_Options='--add-module=/usr/local/ngx_devel_kit --add-module=/usr/local/lua-nginx-module'

然后执行 `cd /root/soft/lnmp1.3-full && ./upgrade.sh nginx`，输入 `1.10.2` 一路回车就行。

编译完 Nginx 后，修改 `/usr/local/nginx/conf/nginx.conf`，在日志格式中增加 `$resp_body` 变量：

    # 以 staylife 正在用的 `big_api` 格式示例（实际只加了最后一行）：
    log_format  big_api  '$remote_addr - $remote_user [$time_local] "$request" '
         '$status $body_bytes_sent "$request_body" "$http_referer" '
         '"$http_user_agent" $http_x_forwarded_for "appid=$http_appid,appver=$http_appver,vuser=$http_vuser" '
         '"phpsessid=$cookie_phpsessid,vuser_cookie=$cookie___vuser" '
         '"$resp_body"'
    ;

新增 `/usr/local/nginx/conf/resp_body.conf` 文件：

    lua_need_request_body on;

    set $resp_body "";
    body_filter_by_lua '
        local resp_body = string.sub(ngx.arg[1], 1, 1000)
        ngx.ctx.buffered = (ngx.ctx.buffered or "") .. resp_body
        if ngx.arg[2] then
            ngx.var.resp_body = ngx.ctx.buffered
        end
    ';

修改对应的虚拟主机配置文件 `/usr/local/nginx/conf/vhost/staylife.conf`：

在 PHP 这一段增加引入 `resp_body.conf` 文件，例如（加了最后一行）：

    location ~ [^/]\.php(/|$)
    {
        fastcgi_pass  unix:/tmp/php-cgi.sock;
        fastcgi_index index.php;
        include fastcgi.conf;
        include pathinfo.conf;
        include resp_body.conf;
    }

附：禁止记录 `favicon.ico` 的请求日志：

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
