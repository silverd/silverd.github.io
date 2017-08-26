---
layout: post
category: ['PHP', '笔记', 'Laravel']
title: Laravel Pusher 介绍
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
// add providers
Vinkla\Pusher\PusherServiceProvider::class,

// add aliases
'Pusher' => Vinkla\Pusher\Facades\Pusher::class,
```

发布配置文件 `config/pusher.php`：

```bash
php artisan vendor:publish --provider='Vinkla\Pusher\PusherServiceProvider'
```

继续修改 `config/pusher.php`：

```
'connections' => [

    'main' => [
        'auth_key' => env('PUSHER_APP_KEY'),
        'secret' => env('PUSHER_APP_SECRET'),
        'app_id' => env('PUSHER_APP_ID'),
        'options' => [
            'cluster' => env('PUSHER_APP_CLUSTER'),
            'encrypted' => true,
        ],
        'host' => null,
        'port' => null,
        'timeout' => null,
    ],
    ....

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
// 消息载体
$payload = [
    'title' => $title,
    'message' => $message,
];

use Vinkla\Pusher\Facades\Pusher;
Pusher::trigger(
    'test-channel',
    'test-event',
    $payload,
    $excludeSocketId
);

或者：

app('pusher')->trigger(
    'test-channel',
    'test-event',
    $payload,
    $excludeSocketId
);

例如简易调用下：

Route::get('/broadcasting/pusher', function () {
    app('pusher')->trigger(
        'test-channel',
        'test-event',
        $payload,
        $excludeSocketId
    );
    return 'This is a Laravel Pusher Bridge Test!';
});
```

### 查看触发结果

登录 `Pusher` 网站，在 `Debug Console` 面板中可查看 Api 推送日志，也可以在 Web 上直接发起事件推送（不赘述了，和极光一个样）。

### 注入日志记录器

如果发现推送失败或者了解推送步骤，可以开启推送日志：

```php

// 日志记录器
// 这里用到了 PHP7 匿名类的语法
$logger = new class {
    public function log(string $msg)
    {
        // 日志记录在 `storage/logs/laravel.log` 中
        \Log::info($msg);
    }
};

$pusher = app('pusher');

// 注入日志记录器
$pusher->set_logger($logger);

// 正常使用 ...
$pusher->trigger(
    'test-channel',
    'test-event',
    ['message' => 'Hello World']
);
```

日志文件内容如下：

```log
[2017-08-27 00:23:01] local.INFO: Pusher: ->trigger received string channel "test-channel". Converting to array.
[2017-08-27 00:23:01] local.INFO: Pusher: create_curl( http://api.pusherapp.com:80/apps/your-app-id/events?auth_key=your-auth-key&auth_signature=ca561c9df94720ef9d8d157e65187601112b0df659ee783ee67a311712c5e70a&auth_timestamp=1503764581&auth_version=1.0&body_md5=f22dec0bcf6ef3d5f06f3f1d06dbfa06 )
[2017-08-27 00:23:01] local.INFO: Pusher: trigger POST: {"name":"test-event","data":"{\"text\":\"2017-08-27 00:23:01-hello\"}","channels":["test-channel"]}
[2017-08-27 00:23:03] local.INFO: Pusher: exec_curl error:
[2017-08-27 00:23:03] local.INFO: Pusher: exec_curl response: Array
(
    [body] => auth_key should be a valid app key
    [status] => 400
)
```

其实也可以看出，底层就是通过 CURL 发 HTTP POST 请求给 Pusher 云服务器。

### 其他触发方式

如果用的 PHP 框架不是 Laravel，我们也可以通过原生 PHP 方式发起推送：

首先 Composer 安装服务端 SDK：

```bash
composer require pusher/pusher-php-server
```

发起推送：

```php
require __DIR__ . '/vendor/autoload.php';

$options = [
  'cluster' => 'ap1',
  'encrypted' => true
];

$pusher = new Pusher\Pusher(
  'c8d9bff0b5eaa518e5fc',
  '183fc63d5a19a60283c1',
  '390114',
  $options
);

$data['message'] = 'hello world';
$pusher->trigger('my-channel', 'my-event', $data);
```

### 通过 Event Broadcaster 集成调用

除了直接通过 Pusher Api 发起推送之外，也可以利用 Laravel 本身的 Event/Listener 机制来触发推送，Laravel Broadcaster 本身是 Laravel 的一个广播模块，Puhser 只是 Broadcaster 支持的其中一种通信驱动，其他支持的通信驱动还有 Redis、Socket.io 等。

开始集成：

0、修改 `config/broadcasting.php` 中 `connections.pusher` 的配置。

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

### 结语

这一章我们介绍了 Pusher 的概念和简单是使用，下一章介绍广播模块。

## 参考文章

- [基于 Pusher 驱动的 Laravel 事件广播（上）](https://segmentfault.com/a/1190000004997982)
- [基于 Pusher 驱动的 Laravel 事件广播（下）](https://segmentfault.com/a/1190000005003873)
