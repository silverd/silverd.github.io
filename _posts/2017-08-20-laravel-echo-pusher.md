---
layout: post
category: ['心得']
title: Laravel 事件广播、Pusher 介绍
---

## Pusher 介绍

[Pusher](https://pusher.com/signup) 是一个第三方中间服务商，专注 C/S 实时消息推送，<u>类似极光、个推这样的消息推送商</u>。

原理：客户端通过 WebSocket 或 HTTP 建立和 Pusher 云服务器的持久链接，并不断接收 Pusher 云服务器推送过来的数据。我们自己的业务服务器只需要 HTTP POST 数据给 Puhser 云服务器即可。

![Alt text](/res/img/in_posts/1503312579376.png)

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
# 生成 `app/Events/ChatMessageWasReceived.php` 文件
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

3、注意 `ChatMessageWasReceived` 类的所有 `public` 的成员变量，都将会自动同步到 Pusher 云服务器并推送给客户端（即消息 `payload`）。或者我们可以通过 `broadcastWith` 方法来自定义消息 `payload`：

```php
/**
 * 获取广播数据
 *
 * @return array
 */
public function broadcastWith()
{
    return [
      'text'    => $this->text,
      'content' => $this->content,
      'title'   => $this->title,
  ];
}
```

4、如何触发事件推送？

```php
// 事件实例
$event = new \App\Events\ChatMessageWasReceived($message, $user);

event($event);

或者：

broadcast($event);

或者：

$manager = app(Illuminate\Broadcasting\BroadcastManager::class);
$manager->event($event);

或者：

// 使用队列
$manager = app(Illuminate\Broadcasting\BroadcastManager::class);
$manager->queue($event);
```

#### event() 和 broadcast() 两个函数的区别

`broadcast()` 数还暴露了 `toOthers()` 方法以便允许你从广播接收者中排除当前用户：

```php
broadcast(new ShippingStatusUpdated($update))->toOthers();
```

注意：`toOthers()` 实际是读取请求头中的 `X-Socket-ID` （可理解为当前连接ID）并做排除。

### JS 客户端监听、接收事件

```html
<script src="//js.pusher.com/3.0/pusher.min.js"></script>

<script>

// 打开 Pusher 的调试日志
Pusher.logToConsole = true;

// 定义 Pusher 实例
var pusher = new Pusher('{{ env('PUSHER_KEY') }}');

// 当前连接的 X-Socket-ID
// 自己触发的操作，在广播时可用于排除掉自己（排我广播）
var currentSocketId = pusher.connection.socket_id;

// 定义频道、绑定监听事件
var channel = pusher.subscribe('test-channel');
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

![Alt text](/res/img/in_posts/1503314394523.png)

在 Laravel 中可以 `Broadcast` 有三种驱动方式：

- Log
- Pusher
- Redis

修改 `.env` 的 `BROADCAST_DRIVER` 属性，或者 `config/broadcasting.php` 中配置。

详细参见文章 <https://segmentfault.com/a/1190000010759743>

#### 公开频道

公开频道是任何人都可以订阅或监听的频道，默认定义的都是公开频道。

```php
/**
 * Get the channels the event should be broadcast on.
 *
 * @return Channel|array
 */
public function broadcastOn()
{
    return ['test-channel'];
}
```

#### 私有频道（Private Channel）

私有频道要求监听前必须先授权当前认证用户。这可以通过向 Laravel 发送包含频道名称的 HTTP 请求然后让应用判断该用户是否可以监听频道来实现。使用 Laravel Echo 的时候，授权订阅私有频道的 HTTP 请求会自动发送，不过，你也需要定义相应路由来响应这些请求。

```javascript
// 定义频道，绑定事件
var channel = pusher.subscribe('private-first-channel');
channel.bind('login', function(data) {
    alert(data);
});
```

如果订阅的是私有频道（频道名是以 `private-` 开头）或存在频道（频道名是以 `presence-` 开头），则会发出权限检查请求；对应的后端需要定义私有频道和存在频道的权限。

##### 授权私有频道

频道的权限定义是在 `routes/channels.php` 里，例如：

```php
Broadcast::channel('first-channel', function ($user) {
    return (int) $user->id === 1;
});
```

注意：这里不需要写 `private-` 或 `presence-` 修饰前缀，直接写真正的频道名即可。

##### 广播到私有频道

```php
/**
 * Get the channels the event should be broadcast on.
 *
 * @return Channel|array
 */
public function broadcastOn()
{
    return new PrivateChannel('room.' . $this->message->room_id);
}
```

#### 存在频道（Presence Channel）

存在频道构建于私有频道之上，并且提供了额外功能：获知谁订阅了频道。基于这一点，我们可以构建强大的、协作的应用功能，例如当其他用户访问同一个页面时通知当前用户。

##### 授权存在频道

如果用户没有被授权加入存在频道，应该返回 `false `或 `null`；
如果用户被授权加入频道<u>不要返回 `true`，而应该返回关于该用户的数据数组</u>。

```php
Broadcast::channel('chat.*', function ($user, $roomId) {
    if ($user->canJoinRoom($roomId)) {
        return ['id' => $user->id, 'name' => $user->name];
    }
});
```

##### 广播到存在频道

```php
/**
 * Get the channels the event should be broadcast on.
 *
 * @return Channel|array
 */
public function broadcastOn()
{
    return new PresenceChannel('room.' . $this->message->room_id);
}
```


## 参考文章

- [Laravel 5.4 文档 - 事件广播](http://laravelacademy.org/post/6851.html#toc_9)
- [Laravel 大将之 广播 模块](https://segmentfault.com/a/1190000010759743)
- [基于 Pusher 驱动的 Laravel 事件广播（上）](https://segmentfault.com/a/1190000004997982)
- [基于 Pusher 驱动的 Laravel 事件广播（下）](https://segmentfault.com/a/1190000005003873)
- <http://laravelacademy.org/post/5351.html>
