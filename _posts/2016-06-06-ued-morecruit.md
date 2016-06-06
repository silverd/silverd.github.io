---
layout: post
category: ['LAMP', 'Git']
title: 搭建 ued.morecruit.cn 笔记（Nginx Basic Auth）
---

## 1、先按照上篇文章利用 GitWebHook 自动部署代码

## 2、设置允许目录浏览

vi /usr/local/nginx/conf/vhost/ued.morecruit.cn.conf
在 server {} 段中增加：

    autoindex on;
    autoindex_exact_size off;
    autoindex_localtime on;
    charset utf-8, gbk;

## 3、给站点增加 Nginx Basic Auth

vi /usr/local/nginx/conf/vhost/ued.morecruit.cn.conf
在 server {} 段中增加：

    auth_basic "plz input password:";
    auth_basic_user_file vhost/ued.morecruit.cn.htpasswd;

注意 auth_basic_user_file 的相对目录是 /usr/local/nginx/conf

新增一对用户和密码

    printf "用户名:$(openssl passwd -crypt 密码)\n" >> /usr/local/nginx/conf/vhost/ued.morecruit.cn.htpasswd

重启 Nginx 即可

    /etc/init.d/nginx reload

参考文章：

- <http://www.ttlsa.com/nginx/nginx-basic-http-authentication/>
- <http://wiki.nginx.org/NginxHttpAuthBasicModule>