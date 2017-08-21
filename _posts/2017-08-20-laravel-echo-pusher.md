---
layout: post
category: ['心得']
title: Laravel 事件广播、Pusher/Echo 介绍
---

## Pusher 介绍

[Pusher](https://pusher.com/signup) 是客户端和服务器之间的实时中间服务商，<u>类似极光、个推这样的第三方消息推送商</u>。

原理：客户端通过 WebSocket 或 HTTP 建立和 Pusher 云服务器的持久链接，并不断接收 Pusher 云服务器推送过来的数据。我们自己的业务服务器只需要 HTTP POST 数据给 Puhser 云服务器即可。

![Alt text](./1503312579376.png)

所以，Pusher 本质上可以适用于任意语言的 C/S，双端只需要接入官方 SDK 即可：<https://pusher.com/docs/libraries>

## Pusher On Laravel

适用于 Laravel 框架的 Pusher 服务端 SDK，文档在此：<https://github.com/vinkla/laravel-pusher>

先通过 Composer 安装：

```bash
composer require vinkla/pusher
```

注册 `ServiceProvider` 和 `Alias`：

```php
Vinkla\Pusher\PusherServiceProvider::class,
```

修改 `.env` 中的配置：

```ini
PUSHER_APP_ID=YOUR_APP_ID
PUSHER_KEY=YOUR_APP_KEY
PUSHER_SECRET=YOUR_APP_SECRET
```

安装完成后，开始使用：

### 直接调用

```php
use Pusher;
Pusher::trigger(
    'test-channel',
    'test-event',
    ['message' => $message],
    $excludeSocketId
);

或者：

app('pusher')->trigger(
    'test-channel',
    'test-event',
    ['message' => $message],
    $excludeSocketId
);
```

### 通过 Event Broadcaster 集成调用

利用 Laravel 本身的 Event/Listener 机制来触发推送。

现在开始集成：

1、创建一个 Event 类：

```bash
// 生成 `app/Events/ChatMessageWasReceived.php` 文件
php artisan make:event ChatMessageWasReceived
```

2、修改 `ChatMessageWasReceived` 类，实现 `ShouldBroadcast` 接口，增加 `broadcastOn` 方法：

```php

class PusherEvent extends Event implements ShouldBroadcast
{
    use SerializesModels;

    public $text, $id;
    private $content;
    protected $title;

    public function __construct($text, $id, $content, $title)
    {
        $this->text    = $text;
        $this->id      = $id;
        $this->content = $content;
        $this->title   = $title;
    }

    /**
     * Get the channels the event should be broadcast on.
     * 推送到哪个频道
     *
     * @return array
     */
    public function broadcastOn()
    {
        return ['test-channel'];
    }

    // 自定义广播名称（可选）
    // 缺省事件名为类名：App\Events\PusherEvent
    public function broadcastAs()
    {
        return 'test-event';
    }
}
```

3、注意 `ChatMessageWasReceived` 类的所有 `public` 属性的成员变量，都将会自动同步到 Pusher 云服务器并推送给客户端。

4、如何触发事件推送？

```php
event(new \App\Events\ChatMessageWasReceived($message, $user));
```

### JS 客户端监听、接收事件

```html
<script src="//js.pusher.com/3.0/pusher.min.js"></script>
<script>
Pusher.log = function(msg) {
  console.log(msg);
};
var pusher = new Pusher('{{ env('PUSHER_KEY') }}');
var channel = pusher.subscribe('test-channel');
var currentSocketId = pusher.connection.socket_id;
channel.bind('test-event', function(data) {
  console.log(data);
  console.log(data.text);
});
</script>
```

可以使用 `Pusher Debug Console` 控制面板查看触发情况。

### 什么是广播？

广播 `Broadcaster` 是指发送方发送一条消息，订阅频道的各个接收方都能及时收到推送的消息，想象一下广播电视塔向外辐射发送消息的场景。

比如 A同学写了一篇文章，这时候 B同学在文章底下评论了，A同学在页面上是不用刷新就能收到提示有文章被评论了，这个本质上就是A同学收到了广播消息，这个广播消息是由B同学评论这个动作触发了发送广播消息。

#### Laravel Broadcast 模块组成

![Alt text](./1503314394523.png)

在 Laravel 中可以 `Broadcast` 有三种驱动方式：

- Log
- Pusher
- Redis


## 参考文章

- [Laravel 大将之 广播 模块](https://segmentfault.com/a/1190000010759743)
- [基于 Pusher 驱动的 Laravel 事件广播（上）](https://segmentfault.com/a/1190000004997982)
- [基于 Pusher 驱动的 Laravel 事件广播（下）](https://segmentfault.com/a/1190000005003873)
- <http://laravelacademy.org/post/5351.html>
