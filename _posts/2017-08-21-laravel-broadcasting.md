---
layout: post
category: ['PHP', '笔记', 'Laravel']
title: Laravel Broadcaster 介绍
---

## 什么是广播？

广播 `Broadcaster` 是指发送方发送一条消息，订阅频道的各个接收方都能及时收到推送的消息，想象一下广播电视塔向外辐射发送消息的场景。

比如 A同学写了一篇文章，这时候 B同学在文章底下评论了，A同学在页面上是不用刷新就能收到提示有文章被评论了，这个本质上就是A同学收到了广播消息，这个广播消息是由B同学评论这个动作触发了发送广播消息。

### Laravel Broadcast 模块组成

![Alt text](/res/img/in_posts/1503314394523.png)

在 Laravel 中可以 `Broadcast` 有三种驱动方式：

- Log
- Pusher
- Redis

修改 `.env` 的 `BROADCAST_DRIVER` 属性，或在 `config/broadcasting.php` 中配置。

在整个广播行为中，频道的类型有三种：

- 公共频道 public
- 私有频道 private
- 存在频道 presence

### 公开频道

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

### 私有频道（Private Channel）

私有频道要求监听前必须先授权当前认证用户。

```javascript
// 定义频道，绑定事件
var channel = pusher.subscribe('private-first-channel');
channel.bind('login', function(data) {
    alert(data);
});
```

如果订阅的是私有频道（频道名是以 `private-` 开头）或存在频道（频道名是以 `presence-` 开头），则会发出权限检查请求；对应的后端需要定义私有频道和存在频道的权限。

#### 授权私有频道

通过向服务端发送包含频道名称的 HTTP 请求，来判断该用户是否允许监听该频道。使用 `Laravel Echo` 时，授权订阅私有频道的 HTTP 请求会自动发送。

频道的授权检测在 `routes/channels.php` 里，例如：

```php
Broadcast::channel('first-channel', function ($user) {
    return (int) $user->id === 1;
});
```

注意：这里频道名不需要加 `private-` 或 `presence-` 修饰前缀。

#### 广播到私有频道

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

### 存在频道（Presence Channel）

存在频道构建于私有频道之上，并且提供了额外功能：获知谁订阅了频道。基于这一点，我们可以构建强大的、协作的应用功能，例如当其他用户访问同一个页面时通知当前用户。

#### 授权存在频道

如果用户没有被授权加入存在频道，应该返回 `false `或 `null`；
如果用户被授权加入频道<u>不要返回 `true`，而应该返回关于该用户的数据数组</u>。

```php
Broadcast::channel('chat.*', function ($user, $roomId) {
    if ($user->canJoinRoom($roomId)) {
        return ['id' => $user->id, 'name' => $user->name];
    }
});
```

#### 广播到存在频道

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
- [Laravel Echo 使用：实时聊天室](http://laravelacademy.org/post/5351.html)
- 