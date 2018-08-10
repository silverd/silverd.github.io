---
layout: post
category: ['PHP', '笔记', 'Laravel']
title: Laravel Broadcaster 进阶使用 & 原理分析
---

上一篇简单介绍了[什么是 Laravel 广播](http://silverd.cn/2017/08/21/laravel-broadcasting.html)，本篇我们来剖析一下 Laravel 广播的原理，以及使用时的注意事项。

正好看到一篇老外写的搭建攻略，也非常不错：

<https://medium.com/@dennissmink/laravel-echo-server-how-to-24d5778ece8b>

# 开始使用

## Laravel App Server - 应用服务端

修改 `.env` 的 `BROADCAST_DRIVER = redis`，同时启用 `QUEUE_DRIVER` 队列服务，广播队列应独立一条，默认走 `default` 队列。

因为所有广播事件 `App\Events\*` 只要实现了 `ShowBroadcast` 接口，那么都强制走队列，如果想立即发送，则改成实现 `ShowBroadcastNow` 接口。

### 代码示例

> App\Events\RealTimeStatsUpdated

```php
/**
 * 实时数据广播更新
 *
 * @author JiangJian <silverd@sohu.com>
 */

namespace App\Events;

use Cache;
use Illuminate\Broadcasting\Channel;
use Illuminate\Queue\SerializesModels;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;

class RealTimeStatsUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    /**
     * 广播指定队列
     *
     * @var string
     */
    public $broadcastQueue = 'broadcasts';

    public $shopId;
    public $apiUri;
    public $shotAt;
    public $extras = [];

    public function __construct(int $shopId, string $apiUri, int $shotAt, array $extras = [])
    {
        $this->shopId = $shopId;
        $this->apiUri = $apiUri;
        $this->shotAt = $shotAt;
        $this->extras = $extras;
    }

    /**
     * 广播频道
     *
     * @return Channel|array
     */
    public function broadcastOn()
    {
        return new PrivateChannel('gmall.shop.' . $this->shopId);
    }

    /**
     * 广播事件名
     *
     * @return string
     */
    public function broadcastAs()
    {
        return 'real-time-stats.updated';
    }

    /**
     * 广播载体 payload 数据
     *
     * @return array
     */
    public function broadcastWith()
    {
        return [
            'api_uri' => $this->apiUri,
            'date'    => date('Y-m-d', $this->shotAt),
            'extras'  => $this->extras,
        ];
    }

    /**
     * 决定是否应该广播此事件
     *
     * @return bool
     */
    public function broadcastWhen()
    {
        // 同一事件冷却5秒
        return Cache::add('RealTimeStatsUpdated:' . $this->apiUri, 1, now()->addSeconds(5));
    }
}
```

### 代码关键配置

如需私有频道，修改 `config/app.php` 中引入（取消注释） `App\Providers\BroadcastServiceProvider`

```php
namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Broadcast;

class BroadcastServiceProvider extends ServiceProvider
{
    public function boot()
    {
        // 私有频道和存在频道鉴权专用
        // 其中的 /broadcasting/auth 仅检测是否游客
        Broadcast::routes(['middleware' => 'api']);

        // 具体的业务范围鉴权
        // 例如只有订单主人才能监听订单事件
        require base_path('routes/channels.php');
    }
}
```

#### 附：踩坑说明

Laravel 这里原始代码为 `Broadcast::routes()`，即使用的缺省中间件 `['middleware' => 'web']`，表示鉴权访问 `/broadcasting/auth` 时会走 `web` 中间件，我们要改成 `['middleware' => 'api']`，否则 `web` 中间件里的 `VerifyCsrfToken` 验证过不去。或者 `CSRF` 排除掉 `/broadcasting/auth` 这个路由也可以解决，如下：

```php
class VerifyCsrfToken extends Middleware
{
    protected $except = [
        '/broadcasting/auth',
    ];
}
```

### 私信通知广播

Notifaction 消息通知可以很轻松的支持广播，走的是私有频道。

#### 私信频道名称定义

私信频道默认的频道名为 `$notifiable`  对象的类名`App\Models\Users.{$uid}`，如果觉得太长了，可以在 User 模型类中重新定义这个频道名：

```php
class User extends Authenticatable
{
    use Notifiable;

    /**
     * 接收用户的频道广播通知.
     *
     * @return string
     */
    public function receivesBroadcastNotificationsOn()
    {
        // 这里的频道名必须跟 `routes/channels.php` 定义的鉴权路由一致
        // 也必须跟客户端 `EchoClient.private(频道名)` 监听的频道名一致
        return 'users.' . $this->id;
    }
}
```

在具体 Notifacation 实例中跟广播有关的方法定义（仔细看代码注释）：

> App\Notifications\ShopAlarm

```php
namespace App\Notifications;

use Illuminate\Notifications\Messages\BroadcastMessage;

class ShopAlarm extends Notification
{
    // 广播通知类型
    // 缺省为类名：App\Notifications\ShopAlarm
    public function broadcastType()
    {
        return $this->msgType;
    }

    /**
     * 广播 Payload 数据
     *
     * @param  mixed  $notifiable
     * @return BroadcastMessage|array
     */
    public function toBroadcast($notifiable)
    {
        $message = new BroadcastMessage([
            'shop_id'    => $this->shop->id,
            'type'       => $this->msgType,
            'message'    => $this->message,
            'created_at' => $GLOBALS['_DATE'],
        ]);

        // 所有广播都必须走队列（框架如此，不可修改）
        // 默认走的 default 队列，建议指定一下，换成其他
        return $message->onQueue('broadcasts');
    }
```

#### 附：踩坑说明

消息通知广播事件实例，最终会被 `Illuminate\Notifications\Events\BroadcastNotificationCreated` 类包装，它会覆盖我们在 Notification 类定义的载体中的两个字段 `id` 和 `type`，证据如下：

```php
namespace Illuminate\Notifications\Events;

class BroadcastNotificationCreated implements ShouldBroadcast
{
    public function broadcastWith()
    {
        return array_merge($this->data, [
            'id' => $this->notification->id,
            'type' => $this->broadcastType(),
        ]);
    }
}
```

所以我们定义通知类时注意避开，或者重写 `broadcastType()` 定义，否则缺省为 Notification 的类名：`App\Notification\ShopAlarm`。

## Laravel Echo Server Socket.io 服务端

首先服务端上安装 NodeJS：`http://nvm.sh` 然后全局安装：

```bash
npm install -g laravel-echo-server
```

Socket.io Server 官方文档：https://github.com/tlaverdure/laravel-echo-server

> NodeJs server for Laravel Echo broadcasting with Socket.io. 支持 Pusher、Redis、HTTP 驱动传递消息

### 安装配置

按照官方文档生成并配置 `laravel-echo-server.json` 后（建议按环境区分该配置文件），例如  `envs/对应环境/laravel-echo-server.json`，注意修改以下几个关键字段：

```javascript
{
  // 后端
  "authHost": "https://dev.api.gmall.gaopeng.com",
  // 订阅驱动
  "database": "redis",
  // 订阅的 Redis 服务器，务必后端配置保持一致
  "databaseConfig": {
    // @see https://github.com/luin/ioredis/blob/HEAD/API.md#new_Redis
    "redis": {
      "port": "6379",
      "host": "127.0.0.1",
      "password": "gaopeng.123",
      "db": 0  // 注意：PUB/SUB跟数据库编号无关，Redis 同时也负责存储『存在频道』信息
    },
    // ...
  },
  // 调试模式（会输出控制台日志，生产服应关闭）
  "devMode": false,
  // WS 服务接受一切本机IP地址
  "host": null,
  // WS 缺省端口
  "port": "6001",
  // WS + SSL = WSS
  "protocol": "https",
  "sslCertPath": "/usr/local/nginx/conf/ssl/api.gmall.gaopeng.com.crt",
  "sslKeyPath": "/usr/local/nginx/conf/ssl/api.gmall.gaopeng.com.key",
}
```

然后把 `laravel-echo-server start` 命令加入到 `supervisord` 中守护

```ini
[program:AI_GMall_WebSocketServer]
process_name=%(program_name)s
autostart=true
autorestart=true
redirect_stderr=true
command=laravel-echo-server start --dir=/home/wwwroot/ai_gmall_server/envs/prod
stdout_logfile=/home/wwwlogs/supervisord_ai_gmall_websocket.out
```

#### 故障排查心得

问题：假设突然发现生产服的 Websocket 实时消息不正常工作了

1. 首先开启调试模式 `laravel-echo-server.json` 的 `devMode=true`，这样控制台才会输出日志。
2. 再查看控制台日志文件 `supervisord_ai_gmall_websocket.out`，日志里会有连接记录、断开记录、广播的事件发布记录等。

可能的原因：

- 如果是 WebSocket Server 连接失败，则 Chrome 控制台会红色报错
- 如果是私有频道授权失败，则 Chrome - Network - WS 里的 `Frames` 页里会有 `subscription_error` 的提示
- 如果还不行，则可能是 Echo Server 和 App Server 之间的通信出错，如果用的 Redis 广播驱动，那么确保双方连的同一台 Redis 服务器且 Redis 服务器正常可用。
- 如果还不行，请确保频道名称是否跟客户端监听的一致，有可能是 Redis Key Prefix 导致频道名不匹配。

### 附：私有、存在频道鉴权原理

https://laravel.com/docs/5.6/broadcasting#authorizing-channels

以 API 服务器为例子，鉴权标识为请求头里的 `api_token`，形式如：`Authorization: Bearer ABCDEFG`。

##### 鉴权步骤：

1、Echo Client 把 `api_token` 通过 Websocket 协议发至 Echo Server 端。

2、Echo Server 端再通过 HTTP 请求向 App Server 的 `http://{authHost}/broadcasting/auth` 发起鉴权请求（这个 URL 定义在 `laravel_echo_server.json` 中）。

3、App Server 代码里通过 `$request->user()` 获取当前用户实例，注意这里 `$request->user($guard = null)` 等同于 `Auth::user()`，只是一种解耦注入的写法。`$guard` 不填则使用定义在 `config/auth.php` 中的默认守护器 `api`。

1) 第一步鉴权，检测是否游客（只检测 `$request->user()` 是否空值）
2) 第二步鉴权，检测频道业务权限（例如是否一个店长才能收到该门店通知）

具体代码可见：`Illuminate\Broadcasting\Broadcasters\RedisBroadcaster::auth` 方法。

## Laravel Echo Client - Socket.io 客户端

安装客户端库：https://www.npmjs.com/package/laravel-echo

```bash
npm install --save laravel-echo
npm install --save socket.io-client
```

Vue 内如何使用？

```javascript
import Echo from 'laravel-echo'
import io from 'socket.io-client';

const EchoClient = new Echo({
  broadcaster: 'socket.io',
  host: 'http://local.api.gmall.gaopeng.com:7002',
  client: io,
  auth: {
    headers: {
      // 重要：用于私有频道鉴权（同 API 用户鉴权）
      Authorization: 'Bearer e05295c388270d7354864c3231ed7e86c791964e',
    },
  },
});

// 公开频道
EchoClient.channel('gmall.borad')
  .listen('.new-message.created', function (event) {
    console.log(event);
  });

// 私有频道
EchoClient.private('gmall.shop.1')
  .listen('.real-time-stats.updated', function (event) {
    console.log(event);
  });

// 私有频道-私信（消息通知）
// 频道名必须和服务端的 `App\Models\User::receivesBroadcastNotificationsOn()` 
// 以及 `routes/channels.php` 定义的频道鉴权路由保持完全一致
EchoClient.private('users.67')
  .notification(function (notification) {
    console.log(notification);
  });
```

纯网页中如何使用？

```html
<script src="http://115.159.58.121:10088/js/echo.js"></script>
<script src="http://115.159.58.121:10088/js/socket.io.js"></script>
<script>
window.Echo = new Echo({
  broadcaster: 'socket.io',
  host: 'http://' + window.location.hostname + ':6001',
  client: io,
  auth: {
    headers: {
      // ... 用户鉴权信息
    },
  },
});
Echo.private('gmall.shop.1')
  .listen('.real-time-stats.updated', function (event) {
    console.log(event);
  });
</script>
```

其中的 `echo.js` 和 `socket.io.js` 去哪里下载？

可以自己通过 npm 安装以下库：

```bash
npm install laravel-echo
npm install socket.io-client
```

然后从以下路径中拷贝出来：

```
node_modules/laravel-echo/dist/echo.js
node_modules/socket.io-client/dist/socket.io.js
```