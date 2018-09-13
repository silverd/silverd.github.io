---
layout: post
category: ['架构', '笔记']
title: WebSocket 协议握手流程
---

## HTTP 1.1 的 keep-alive?

WebSocket 协议解决了服务器与客户端全双工通信的问题。

1. 信息只能单向传送为单工
2. 信息能双向传送但不能同时双向传送称为半双工
3. 信息能够同时双向传送则称为全双工

## 握手流程

### 客户端请求头

```
GET /chat HTTP/1.1
Connection: Upgrade                             # 通知服务器协议升级
Upgrade: websocket                              # 协议升级为websocket协议
Host: server.example.com:7001                   # 升级协议的服务主机:端口地址
Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==     # 下文解释
Sec-WebSocket-Protocol: chat, superchat         # 子协议（应用层协议层协议）
Sec-WebSocket-Version: 13                       # WebSocket 协议版本必须是13
Origin: http://example.com
```

其中 `Upgrade: websocket` 和 `Connection: Upgrade` 表示

#### Sec-WebSocket-Key

其中 `Sec-WebSocket-Key` 是客户端随机生成的一个 Base64 值，模拟生成算法如下：

```python
def _create_sec_websocket_key():
    randomness = os.urandom(16)
    return base64encode(randomness).decode('utf-8').strip()
```

#### Sec-WebSocket-Protocol

字段表示客户端可以接受的子协议类型，也就是在 WebSocket 协议上的应用层协议类型。
上面可以看到客户端支持 chat 和 superchat 两个应用层子协议，当服务器接受到这个字段后要从中选出一个子协议返回给客户端。

### 服务端响应头

```
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: HSmrc0sMlYUkAGmm5OPpG2HaGWk=
Sec-WebSocket-Protocol: chat
```

#### Upgrade 和 Connection

服务器告知客户端协议已成功升级为 WebSocket 协议，用来完善 HTTP 升级响应。

#### Sec-WebSocket-Accept

服务端拿到客户端的 `Sec-WebSocket-Key` 后，跟 `MAGIC` 全局字符串常量拼接，再经过 `sha1` 和 `base64_encode` 后得出 `Sec-WebSocket-Accept`，模拟生成算法如下：

```php
const MAGIC = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
$accept = base64encode(sha1($key . MAGIC));

echo $accpet;
```

注意：`MAGIC` 魔术字符串是 [`RFC6455`](https://tools.ietf.org/html/rfc6455#section-5.5.2) 官方定义的一个固定字符串，官方就是这么任性，不得修改。

客户端拿到服务端响应的 `Sec-WebSocket-Accept` 后，会拿自己之前生成的 `Sec-WebSocket-Key` 用相同算法算一次，如果匹配，则握手成功。然后判断 HTTP Response 状态码是否为 101（切换协议），如果是，则建立连接，大功告成。

#### Sec-WebSocket-Protocol

表示服务器最终选择的一个应用层子协议

