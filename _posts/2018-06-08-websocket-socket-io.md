---
layout: post
category: ['架构', '笔记']
title: WebSocket & Socket.io
---

# Socket.io

Socket.io 是一个开源的 JS 实时通信库，包括了客户端和服务端。以下是最简单的 WebSocket 通信流程，分为四个角色：

1. PHP App Server
2. WebSocket Server (NodeJS) -- Socket.io Server
3. WebSocket Client (HTML) -- Socket.io Client
4. Redis (订阅&发布)

## PHP - 应用服务器

```php
// 连接 Redis
$redis = new Redis;
$redis->connect('127.0.0.1', 6379);
$redis->auth('密码');

// 发布消息
$redis->publish('频道名', '消息载体');
```

注意：发布时的『消息内容』可以是一个 JSON 字符串，例如 Laravel 里代码如下：

```php
$payload = json_encode([
    'event'  => $event,
    'data'   => $payload,
    'socket' => Arr::pull($payload, 'socket'),  // 排我标识，后面再说
]);

$redis->publish('频道名', $payload);
```

## Socket.io - WebSocket 服务器

```bash
npm install --save ioredis
npm install --save socket.io
```

单文件 `server.js` 代码如下：

```js
var app = require('http').createServer(function (req, res) {
  res.writeHead(200);
  res.end('');
});

var io = require('socket.io')(app);

app.listen(7002, function () {
  console.log('WebSocketServer is running!');
});

io.on('connection', function (socket) {
  console.log(socket);
  console.log('connected');
  socket.on('message', function (message) {
    console.log(message);
  });
  socket.on('disconnect', function () {
    console.log('disconnected');
  });
});

var Redis = require('ioredis');
var redis = new Redis({
  port: 6379,
  host: '127.0.0.1',
  password: '密码',
});

redis.psubscribe('*', function (err, count) {
  console.log('err: ' + err + ', count: ' + count);
});

redis.on('pmessage', function (subscrbed, channel, message) {
  console.log('subscrbed: ' + subscrbed + ', channel: ' + channel + ', message: ' + message);
  // 这里须和 App Server 约定，消息载体为 JSON 字符串
  message = JSON.parse(message);
  // 拼接完整的『频道名:事件名』
  var eventName = channel + ':' + message.event;
  // 给客户端广播消息
  io.emit(eventName, message.data);
});

```

## Socket.io - WebSocket 客户端

[socket.io-client API 手册](https://github.com/socketio/socket.io-client/blob/master/docs/API.md)

引入 `socket.io-client` 库：

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/socket.io/2.1.1/socket.io.js"></script>
```

可以直接到 CDN 下载：<https://cdnjs.com/libraries/socket.io>

也可通过 npm 安装以下库：

> npm install socket.io-client

然后从以下路径中拷贝出来：

> node_modules/socket.io-client/dist/socket.io.js

Javascript 部分代码：

```js
// @see https://socket.io/docs/client-api/
const socket = io('https://dev.api.gaopeng.com:7002');

socket.on('connect', function (socket) {
  // 即 X-Socket-ID
  console.log(socket.id);
});

socket.on('事件名称', function (event) {
  console.log(event);
});
```

> 注：监听的『事件名称』即 `io.emit()` 时的 `eventName` 变量（即『频道名:事件名』完整字符串）

## 值得一提

### 1、广播的排我发布是如何实现的？

客户端 `X-Socket-ID`

### 2、微信小程序如何使用 WebSocket？

由于 Socket.io 在使用过程中会给 client 植入 cookie 完成验证，而微信小程序不支持 cookie，所以就需要修改 Socket.io 客户端。

- 小程序改造版的 socket.io-client: [weapp.socket.io](https://github.com/weapp-socketio/weapp.socket.io)
- [微信小程序官方文档](https://developers.weixin.qq.com/miniprogram/dev/api/network-socket.html)

用法与浏览器端一致：

```js
const io = require('./yout_path/weapp.socket.io.js')

const socket = io('http://localhost:8000')

socket.on('news', d => {
  console.log('received news: ', d)
})

socket.emit('news', {
  title: 'this is a news'
})
```

### 3、Socket.io Server 负载均衡

<https://socket.io/docs/using-multiple-nodes>

通过增加 socket.io-redis 可以在多个 Socket.io Server 节点中传递事件。

### 4、安卓客户端的 Socket.io Client

<https://socket.io/blog/native-socket-io-and-android>

### 5、客户端向服务器、客户端之间发消息

参考 `laravel-echo client` 里的 `Echo.whisper(eventName, data)`，代码如下：

```js
this.socket.emit('client event', {
  channel: this.name,
  event: 'client-' + eventName,
  data: data
});
```

Socket.io Server: 通过 `socket.broadcast.emit()` 发布排我广播

```js
io.on('connection', function(socket){
  socket.broadcast.emit('hi');
});
```

## 参考文章

- <https://socket.io>
- <http://websocketd.com>
- <http://www.ruanyifeng.com/blog/2017/05/websocket.html>
