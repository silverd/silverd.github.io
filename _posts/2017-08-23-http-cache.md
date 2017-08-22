---
layout: post
category: ['复习', '笔记']
title: HTTP 缓存机制
---

浏览器缓存分两类：强制缓存、对比缓存。

两类缓存规则可以同时存在，强制缓存优先级高于对比缓存，当执行强制缓存的规则时，如果缓存生效，直接使用缓存，不再执行对比缓存规则。

## 强制缓存

强制缓存如果生效，不需要再和服务器发生交互。

主要有两个首部字段：`Expires` 和 `Cache-Control`。`Expires` 是 HTTP/1.0 版本的东西，在 HTTP/1.1 中，被 `Cache-Control` 替代。

Cache-Control 常见取值：

- private（缺省）客户端可以缓存
- public 客户端和代理服务器都可缓存
- no-cache 需要使用对比缓存来验证缓存数据
- no-store 所有内容都不会缓存，强制缓存，对比缓存都不会触发
- max-age=X秒 指定时间内不需要再问服务器要数据（不产生网络请求）

## 对比缓存

对比缓存不管是否生效，都一定会与服务端发生交互。

- `Last-Modified / If-Modified-Since`
- `Etag / If-None-Match`（优先级高于 `Last-Modified`）

## 三种刷新的姿势

假设对一个资源,浏览器第一次访问，响应头为：

- `Cache-Control: max-age:600`
- `Last-Modified: Wed, 10 Aug 2013 15:32:18 GMT`

于是浏览器把资源放到缓存中，下次直接到缓存中取。

1、浏览器中写地址，回车

浏览器不会发送任何网络请求，直接去缓存中取资源。

2、F5 刷新

浏览器请求头中带着 `If-Modified-Since` 和 `If-None-Match` 去请求服务器，服务端返回完整资源或者 `304` 状态码。

3、Ctrl+F5 强刷

浏览器请求头中带着 `Cache-Control:no-cache` 和 `Pragma:no-cache` 去请求服务器，服务端强制返回完整资源。

## 参考文章

- <https://segmentfault.com/a/1190000010775131>
