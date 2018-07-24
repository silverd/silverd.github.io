---
layout: post
category: ['复习', '笔记']
title: HTTP 缓存机制
---

浏览器缓存分两类：强制缓存、对比缓存。

两类缓存规则可以同时存在，『强制缓存』优先级高于『对比缓存』。如果『强制缓存』生效，则不再发起服务器请求，即不再执行『对比缓存』规则。

## 强制缓存

强制缓存如果生效，<u>不需要再和服务器发生交互</u>。

主要有两个首部字段：`Expires` 和 `Cache-Control`。其中 `Expires` 是 HTTP/1.0 版本的东西，在 HTTP/1.1 中，被 `Cache-Control` 替代。

#### Cache-Control

![Alt text](/res/img/in_posts/1503477393236.png)

#### 响应首部的 `Cache-Control` 字段：

| 字段值 | 说明 |
| -- | -- |
| no-cache | 不缓存过期的资源。告诉浏览器，不论本地缓存是否过期，都不能直接使用本地缓存。在使用本地缓存之前，必须先通过 `ETag` 或 `Last-Modified` 向服务器发起二次验证，如果服务器响应 304 则可用该本地缓存，否则不可。 |
| no-store | 请求和响应的信息都不应该被存储在对方的磁盘系统中（Internet 临时文件中）。当下次请求时，都会直接向服务器发送请求，并下载完整的响应。 |
| max-age | 指定时间内不需要再问服务器要数据<br />不产生网络请求，但仍有响应状态码 `200 OK from disk cache` |
| s-maxage | CDN 或共享缓存服务器响应的最大 Age 值 |
| public | 表明响应可以被任何对象（包括：发送请求的客户端，代理服务器，等等）缓存 |
| private | 表明响应只能被单个用户缓存，不能作为共享缓存（即 CDN 或代理服务器不能缓存它） |
| must-revalidate | 缓存必须在使用之前验证旧资源的状态，并且不可使用过期资源。 |
| no-transform | 代理不可更改媒体类型 |
| proxy-revalidate | 要求中间缓存服务器对缓存的响应有效性再进行确认 |

#### 请求首部的 `Cache-Control` 字段：

## 对比缓存

对比缓存不管是否生效，都一定会与服务端发生交互。

- `Last-Modified / If-Modified-Since`
- `ETag / If-None-Match`（优先级高于 `Last-Modified`）

Last-Modified 与 ETag 的区别：

1、服务器会优先验证 `ETag`，一致的情况下，再对比 `Last-Modified`；
2、`Last-Modified` 只能精确到秒，有些资源在1秒内改变过，只能靠 `ETag` 来区分；
3、 一些资源的最后修改时间变了，但是内容并没改变，使用 `ETag` 就认为资源还是没有修改。

## 三种刷新的姿势

假设对一个资源,浏览器第一次访问，响应头为：

- `Cache-Control: max-age:600`
- `Last-Modified: Wed, 10 Aug 2013 15:32:18 GMT`

于是浏览器把资源放到缓存中，下次直接到缓存中取。

#### 1、浏览器中写地址，回车

浏览器不会发送任何网络请求，直接去缓存中取资源。

#### 2、F5 刷新

浏览器请求头中忽略 `Expires/Cache-Control` 的设置，并带着 `If-Modified-Since` 和 `If-None-Match` 去请求服务器，服务端返回完整资源或者 `304` 或 `200` 状态码。

#### 3、Ctrl+F5 强刷

浏览器请求头中带着 `Cache-Control:no-cache` 并且不带 `If-None-Match` 和 `If-Modified-Since` 去请求服务器，服务端虽然收到 `no-cache`，但并没有收到 `ETag` 或 `Last-Modified`，这种情况下，服务器无法使用对比缓存（无法检验资源有效性），只能响应完整资源给浏览器，不可能响应 `304` 状态码。

Ctrl+F5 强刷等价于在 Chrome 控制台中勾选 `Disable cache`。

#### 借一图胜前言

![Alt text](/res/img/in_posts/1503482315088.png)

## 附

在HTTP请求和响应的消息报头中，常见的与缓存有关的消息报头有：

![Alt text](/res/img/in_posts/1503484351920.png)

## 示例

#### 禁止缓存

发送如下指令可以关闭缓存。此外，可以参考Expires 和 Pragma 标题。

```
Cache-Control: no-cache, no-store, must-revalidate
```

### 缓存静态资源

对于应用程序中不会改变的文件，你通常可以在发送响应头前添加积极缓存。这包括例如由应用程序提供的静态文件，例如图像，CSS文件和JavaScript文件。另请参阅Expires标题。

```
Cache-Control:public, max-age=31536000
```

### Nginx 对 Vue SPA 的 `index.html` 禁用缓存

```
location = /index.html {
    add_header Cache-Control "no-cache, no-store";
}
```

## 参考文章

- <https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Cache-Control>
- <https://segmentfault.com/a/1190000010786900>
- <https://segmentfault.com/a/1190000010775131>
- <https://segmentfault.com/a/1190000009954478>
