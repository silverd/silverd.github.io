---
layout: post
title: CentOS 自启动失败分析
---

### 失败情况

想要服务器自启动执行某些SHELL，想当然加在 /etc/rc.local 里，但不执行。

### 解决办法：

先查看 /etc/rc.d/rc3.d/S99local 指向哪个文件

有些系统指向的是 /etc/rc.local，有一些是 /etc/rc.d/rc.local
CentOS 6.6 指向的就是 /etc/rc.d/rc.local