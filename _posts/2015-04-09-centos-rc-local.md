---
layout: post
category: ['LAMP', '心得']
title: CentOS 自启动失败分析
---

## 场景

Tony哥从家里搬来了一台机器做公司内网开发机，我给它上面装了 CentOS 6.6

## 失败情况

想要服务器自启动执行某些 sh 脚本，想当然加在 /etc/rc.local 里，但不执行。

## 解决办法：

1、先查看 /etc/rc.d/rc3.d/S99local 指向哪个文件

有些系统指向的是 /etc/rc.local，有一些是 /etc/rc.d/rc.local。

CentOS 6.6 指向的就是：/etc/rc.d/rc.local

2、保证该文件有可执行权限

    chmod +x /etc/rc.d/rc.local

3、将 /etc/rc.local 重新软连接为 /etc/rc.d/rc.local

    ln -sf /etc/rc.d/rc.local /etc/rc.local