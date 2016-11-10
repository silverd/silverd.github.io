---
layout: post
category: ['架构', '移动开发']
title: Fiddler 抓取手机 https
---

### 开启选项

打开 Fiddler，点击工具栏的 Tools – Fiddler Options

- 切换到 HTTPS 选项卡，勾选 Capture HTTPS CONNECTs + Decrypt HTTPS trafic
- 切换到 Connections 选项卡，勾选 Allow remote computers to connect

### 在手机上安装 Fiddler 根证书

打开 iOS/Android 的浏览器, 访问 http://192.168.1.104:8888
点击底部的 `FiddlerRoot certificate` 链接将证书安装到手机上（DO_NOT_TRUST_...）

目的：让客户端在之后的通信过程中可以信任该`根证书`颁发的证书（介绍信）

### Fiddler 抓包原理

`Fiddler2 使用 man-in-the-middle (中间人) 攻击的方式来截取 HTTPS 流量。在 Web 浏览器面前 Fiddler2 假装成一个 HTTPS 服务器，而在真正的 HTTPS 服务器面前 Fiddler2 假装成浏览器。Fiddler2 会动态地生成 HTTPS 证书来伪装服务器。`

我们看到 Fiddler 抓取 HTTPS 协议主要由以下几步进行：

1. Fiddler 截获客户端发送给服务器的HTTPS请求，Fiddler 伪装成客户端向服务器发送请求进行握手 。
2. 服务器发回相应，Fiddler 获取到服务器的 CA证书， 用根证书公钥进行解密，验证服务器数据签名，获取到服务器 CA 证书公钥。然后 Fiddler 伪造自己的CA证书， 冒充服务器证书传递给客户端浏览器。
3. 与普通过程中客户端的操作相同，客户端根据返回的数据进行证书校验、生成密码 Pre_master，用 Fiddler 伪造的证书公钥加密，并生成 HTTPS 通信用的对称密钥 enc_key。
4. 客户端将重要信息传递给服务器，又被 Fiddler 截获。Fiddler 将截获的密文用自己伪造证书的私钥解开， 获得并计算得到HTTPS通信用的对称密钥 enc_key。Fiddler 将对称密钥用服务器证书公钥加密传递给服务器。
5. 与普通过程中服务器端的操作相同，服务器用私钥解开后建立信任，然后再发送加密的握手消息给客户端。
6. Fiddler 截获服务器发送的密文，用对称密钥解开，再用自己伪造证书的私钥加密传给客户端。
7. 客户端拿到加密信息后，用公钥解开，验证 HASH。握手过程正式完成，客户端与服务器端就这样建立了”信任“。

在之后的正常加密通信过程中，Fiddler如何在服务器与客户端之间充当第三者呢？

`服务器—>客户端：Fiddler接收到服务器发送的密文， 用对称密钥解开， 获得服务器发送的明文。再次加密， 发送给客户端。客户端—>服务端：客户端用对称密钥加密，被Fiddler截获后，解密获得明文。再次加密，发送给服务器端。由于Fiddler一直拥有通信用对称密钥enc_key， 所以在整个HTTPS通信过程中信息对其透明。`

从上面可以看到，Fiddler抓取HTTPS协议成功的关键是根证书（具体是什么，可Google）,这是一个信任链的起点，这也是Fiddler伪造的CA证书能够获得客户端和服务器端信任的关键。接下来我们就来看如果设置让Fiddler抓取HTTPS协议。

参考文章：

- <http://m.blog.csdn.net/blog/skylin19840101/43485911>
- <http://m.blog.csdn.net/blog/roland_sun_2010/30078353>
- [浅谈HTTPS以及Fiddler抓取HTTPS协议](http://www.jianshu.com/p/54dd21c50f21)