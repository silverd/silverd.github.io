---
layout: post
category: ['Mac', '心得']
title: Charlse 抓包使用心得
---

最常见的抓包或抓SSL包就不累述了，这里记录几个有价值的功能。

## 电脑浏览器抓包SSL

去 <http://www.charlesproxy.com/ssl.zip> 下载CA证书文件。
双击其中的.crt文件，选择“总是信任”，从钥匙串访问中即可看到添加成功的证书。

然后 Charles -> Proxy -> Mac OS X Proxy 将 Charles 设置成系统代理。

## 过滤网络请求

方法1：在主界面的中部的 Filter 栏中填入过滤出来的关键字（模糊匹配）
方法2：Charles -> Proxy -> Recording Settings -> Include 栏，选择添加一个项目，然后填入需要监控的协议，主机地址，端口号

通常情况下，方法1做一些临时性的封包过滤，方法2做一些经常性的封包过滤。

## 重复发包

通常情况下，我们使用方法1做一些临时性的封包过滤，使用方法2做一些经常性的封包过滤。

在请求上右键可以选择 Repeat（发包一次） / Repeat Advanced（发包多次），这个功能用来测试短信轰炸漏洞很方便。

## 修改网络请求内容

在请求上右键可以选择 Edit，即可创建一个可编辑的网络请求

## 修改网络响应内容

功能类似 Fiddler 的 AutoResponder，可用于线上调试JS/CSS代码

## 模拟慢速网络 Throttle

模拟慢速网络或者高延迟的网络，以测试在移动网络下，应用的表现是否正常。
Charles -> Proxy -> Throttle Setting，勾选上 Enable Throttling，并且可设置 Throttle Preset 的类型

如果只想模拟指定网站的慢速网络，可以再勾选上图中的 Only for selected hosts 项，然后在对话框的下半部分设置中增加指定的 hosts 项即可。

----

参考文章：

- <http://www.inbiji.com/biji/wang-luo-feng-bao-fen-xi-gong-ju-charles.html>
- <http://drops.wooyun.org/tips/2423>