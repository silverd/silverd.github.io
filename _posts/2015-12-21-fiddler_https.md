---
layout: post
title: Fiddler 抓取手机 https 
---

### 开启选项

打开 Fiddler，点击工具栏的 Tools – Fiddler Options

- 切换到 HTTPS 选项卡，勾选 Capture HTTPS CONNECTs + Decrypt HTTPS trafic
- 切换到 Connections 选项卡，勾选 Allow remote computers to connect 

### 在手机上安装 Fiddler 证书

打开 iOS/Android 的浏览器, 访问 http://192.168.1.104:8888
点击底部的`FiddlerRoot certificate`链接将证书安装到手机上（DO_NOT_TRUST_...）

参考文章：

- <http://m.blog.csdn.net/blog/skylin19840101/43485911>
- <http://m.blog.csdn.net/blog/roland_sun_2010/30078353>