---
layout: post
category: ['LAMP', '架构']
title: Nginx 访问日志记录 POST/COOKIE/HEADER 等数据
---

初始日志格式中的变量：

    $remote_addr        The remote host
    $remote_user        The authenticated user (if any)
    $time_local         The time of the access
    $request            The first line of the request
    $status             The status of the request
    $body_bytes_sent    The size of the server's response, in bytes
    $http_referer       The referrer URL, taken from the request's headers
    $http_user_agent    The user agent, taken from the request's headers

我们要用到的几个变量：

    $request_body   请求体（含POST数据）
    $http_XXX       指定某个请求头（XXX为字段名，全小写）
    $cookie_XXX     指定某个cookie值（XXX为字段名，全小写）

修改 `/usr/local/nginx/conf/nginx.conf`，增加新的日志格式 `big_api`：

    log_format  big_api  '$remote_addr - $remote_user [$time_local] "$request" '
        '$status $body_bytes_sent "$request_body" "$http_referer" '
        '"$http_user_agent" $http_x_forwarded_for "appid=$http_appid,appver=$http_appver,vuser=$http_vuser" '
        '"phpsessid=$cookie_phpsessid,vuser_cookie=$cookie___vuser" ';

修改 `/usr/local/nginx/conf/vhost/hicrew.conf`，底部对应的日志格式也改为 `big_api`：

    access_log  /home/wwwlogs/hicrew.log big_api;

参考文章：

- <http://www.cnblogs.com/zhangqingping/p/4390862.html>