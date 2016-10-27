---
layout: post
category: ['LAMP']
title: Redis Server 连接端口-随手记
---

安装完 redis server 后，发现 telnet 127.0.0.1 6379 报 connetion failed 错误，也无法提供外网访问。查看 redis.conf 里的确实 bind 127.0.0.1 没错呀。

其实是防火墙的原因，测试服的话，可以直接关闭：

    /etc/init.d/iptables stop 或 service iptables stop

输入 `/usr/local/redis/bin/redis-cli` 即可连上。

如果不想这么粗鲁，那么可以打开指定端口：

    iptables -I INPUT -p tcp --dport 6379 -j ACCEPT

    # 查看当前防火墙状态：
    /etc/init.d/iptables status

    # 记得改完要保存，否则重启了就无效
    /etc/init.d/iptables save

    # 重启防火墙策略
    /etc/init.d/iptables restart

如果执行 redis-cli 时看到以下错误：

    Could not connect to Redis at 127.0.0.1:6379: Connection refused

那一定是 redis server 忘记启动了 =_=!

    /etc/init.d/redis start