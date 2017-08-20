---
layout: post
category: ['心得']
title: Laravel 事件广播、Pusher/Echo 介绍
---

## Pusher 介绍

Pusher 是客户端和服务器之间的实时中间服务商 <https://pusher.com/signup>，<u>可以理解为类似极光、个推这样的第三方消息推送商</u>。

原理：客户端通过 WebSocket 或 HTTP 和 Pusher 云服务器保持持久链接，并不断接收 Pusher 云服务器的数据。我们自己的业务服务器只需要 HTTP POST 数据给 Puhser 云服务器即可。

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
Pusher::trigger('test-channel', 'test-event', ['message' => $message]);

或者：

app('pusher')->trigger('test-channel', 'test-event', ['message' => $message]);
```

### 通过 Event Broadcaster 集成调用

利用 Laravel 本身的 Event/Listener 机制来触发推送，其实这里取名叫 `Broadcaster` 应理解为推送（服务器主动向客户端推送消息），不局限于跟单播、组播在发送范围上的区别，想象一下广播电视塔向外辐射发送消息就明白了。

开始集成：

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
}
```

3、注意 `ChatMessageWasReceived` 类的所有 `public` 属性的成员变量，都将会自动同步到 Pusher 云服务器并推送给客户端。

4、如何触发事件推送？

```php
event(new \App\Events\ChatMessageWasReceived($message, $user));
```

### 客户端监听事件

```html
<script src="//js.pusher.com/3.0/pusher.min.js"></script>
<script>
Pusher.log = function(msg) {
  console.log(msg);
};
var pusher = new Pusher('{{ env('PUSHER_KEY') }}');
var channel = pusher.subscribe('test-channel');
channel.bind('test-event', function(data) {
  console.log(data);
  console.log(data.text);
});
</script>
```

可以使用 `Pusher Debug Console` 控制面板查看触发情况。

## 参考文章

- <https://segmentfault.com/a/1190000004997982>
- <https://segmentfault.com/a/1190000005003873>
- <http://laravelacademy.org/post/5351.html>
