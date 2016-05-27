---
layout: post
category: ['LAMP', '架构']
title: Nginx 在 StayLife 的一些应用
---

需求：将 m.69night.cn/mapi 所有请求转发到 api.staylife.cn

修改 `/usr/local/nginx/conf/vhost/69night.conf`

    location /mapi/
    {
        # 尾部的斜杠不能少，目的是不用把 /mapi 这个路径转发出去
        proxy_pass https://qa.api.staylife.cn/;
        proxy_redirect  off;
        proxy_set_header  X-Real-IP  $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
        access_log /home/wwwlogs/69night_mapi.log access;
    }

值得一提的是，原来我们用的 rewrite 来转发。当 POST 请求时，对于内部的 URL（斜杠开头）转发时，POST 数据不会丢失。对于外部跳转，实际上是一次 GET 302，所以会丢失第一次的 POST 数据。

    location /mapi/ {
        rewrite ^ https://qa.api.staylife.cn/;
    }

参考文章：

- <http://www.cnblogs.com/zhangqingping/p/4390862.html>
- <http://www.tuicool.com/articles/iYfiya>