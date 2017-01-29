---
layout: post
category: ['复习笔记']
title: Laravel 文档学习笔记
---

# 配置

$_ENV 或 env() 可读取 .env 文件中的变量

读取 config/app.php 中的数据

```php
$value = config('app.timezone');
```

如何合并、缓存所有配置文件？

```bash
# 生成文件 bootstrap/cache/config.php
php artisan config:cache

# 生成文件 bootstrap/cache/route.php
php artisan route:cache
```

除了 config 文件夹下的配置文件，永远不要在其它地方使用 env 函数，因为部署到线上时，配置文件缓存（php artisan config:cache）后，env 函数无法获得正确的值。

几点注意：

1. config 文件里严禁使用 Closure 闭包，因为 config:cache 时无法被正确序列化。
2. routes 文件中尽量不使用闭包函数，统一使用控制器，因为缓存路由的时候 php artisan route:cache，无法缓存闭包函数。

# Service Container & Provider

注册：

```php
$app->bind('HelpSpot\API', function ($app) {
    return new HelpSpot\API($app->make('HttpClient'));
});
```

注册（绑定接口和实现）：

```php
$app->singleton(
    Illuminate\Contracts\Http\Kernel::class,
    App\Http\Kernel::class
);
```

获取：

```php
方式1：app('HelpSpot\API');
方式2：app()->make('HelpSpot\API');
方式3：app()['HelpSpot\API'];
方式4：resolve('HelpSpot\API');
```

有哪些类是被服务容器解析的？

- controllers
- event listeners
- queue jobs
- middleware,
- route Closures.

在给消费者使用前，可以做最后一步监听修改（Container Events）

```php
$this->app->resolving(HelpSpot\API::class, function ($api, $app) {
    // Called when container resolves objects of type "HelpSpot\API"...
});
```

如果一个提供者中的所有代码，只是为了绑定或者说往容器里注入，那么可以把该提供者设置为懒绑定（延迟提供者绑定 Deferred Providers），例如：

```php
class RiakServiceProvider extends ServiceProvider
{
    // 标记本提供者为延迟绑定
    protected $defer = true;

    public function register()
    {
        $this->app->singleton(Connection::class, function ($app) {
            return new Connection($app['config']['riak']);
        });
    }

    public function provides()
    {
        return [Connection::class];
    }
}
```

# Facades

简单地说，就是一堆类（容器中实例）的快捷别名。

在 config/app.php 的 alias 里配置，这样以后在 Controller 里就可以直接 use 而不用记住一长串的类名。

```php
use Redis;

等价于

use Illuminate\Support\Facades\Redis;
```

# Contract

只是 Laravel 的一个概念，表示一个结构约定。
其实就是 PHP 的 interface，只不过 Contract 不局限于接口，还可以是 Abstract 父类。

# 路由

### 模型绑定（Route Model Binding）

直接给 action 传入 Eloquent models（自动根据主键查找）

```php
Route::get('api/users/{user}', function (App\User $user) {
    return $user->email;
});
```

如果主键不是 id，则可以通过修改 model 的 getRouteKey() 或 getRouteKeyName() 来解决。

### 模拟 RESTful 方法

```html
<form action="/foo/bar" method="POST">
   <input type="hidden" name="_method" value="PUT">
   <input type="hidden" name="_token" value="{{ csrf_token() }}">
</form>
```

等价于：

```html
<form action="/foo/bar" method="POST">
    {{ method_field('PUT') }}
    {{ csrf_field() }}
</form>
```

# 中间件

新建中间件：

```php
php artisan make:middleware CheckAge
```
前置、后置：

```php
class AfterMiddleware
{
    public function handle($request, Closure $next)
    {
        // 前置：干一些事情
        // ...

        $response = $next($request);

        // 后置：干一些事情
        // ...

        return $response;
    }
}
```

在 `app\Http\Kernel.php` 中注册中间件：

### 全局中间件

```php
protected $middleware = [
    \Illuminate\Foundation\Http\Middleware\CheckForMaintenanceMode::class,
    \Illuminate\Foundation\Http\Middleware\ValidatePostSize::class,
    \App\Http\Middleware\TrimStrings::class,
    \Illuminate\Foundation\Http\Middleware\ConvertEmptyStringsToNull::class,
];
```

每个请求都会经过这些中间件，例如『维护模式』的检测。

### 路由中间件

```php

protected $routeMiddleware = [
    'auth' => \Illuminate\Auth\Middleware\Authenticate::class,
];
```

主要是定义路由时（例如 routes/web.php）使用：

```php
Route::get('/', function () {
    //
})->middleware('auth', 'other');
```

### 中间件组

```php
protected $middlewareGroups = [
    'web' => [
        \App\Http\Middleware\EncryptCookies::class,
    ],
    'api' => [
        'throttle:60,1',
        'auth:api',
    ],
];
```

在可以在定义路由时使用：

```php
Route::get('/', function () {
    //
})->middleware('web');

Route::group(['middleware' => ['web']], function () {
    //
});
```

### 如何在注册时给中间件传递参数？
冒号隔离，多个参数用逗号，例如：

```php
protected $middlewareGroups = [
    'api' => [
        'throttle:60,1',
    ],
];

或者：

Route::put('post/{id}', function ($id) {
    //
})->middleware('role:editor,boss');
```

### 控制器中手动调用中间件：

```php
public function __construct()
{
    $this->middleware('auth');
    $this->middleware('log')->only('index');
    $this->middleware('subscribed')->except('store');
}
```

### Terminable Middleware

在发完响应给客户端后，可以干一些事情。

For example, the "session" middleware included with Laravel writes the session data to storage after the response has been sent to the browser.


```php
namespace Illuminate\Session\Middleware;

class StartSession
{
    public function handle($request, Closure $next)
    {
        return $next($request);
    }

    // Terminable 中间件
    public function terminate($request, $response)
    {
        // 保存 session 数据...
    }
}
```

当在你的中间件调用 terminate 方法时，Laravel 会从 服务容器 解析一个全新的中间件实例。
如果你希望在 handle 及 terminate 方法被调用时使用一致的中间件实例，只需在容器中使用容器的 singleton 方法注册中间件。


# CSRF

任意定义在 `routes/web.php` 中的路由请求 POST, PUT, or DELETE 提交的表单请求都会自动检测 CSRF 令牌。

可单独例外排除：<https://laravel.com/docs/5.4/csrf#csrf-excluding-uris>

X-CSRF-TOKEN 需要放入请求头中（如果不放到 form 中的话）
X-XSRF-TOKEN 会在每次响应头里的 set-cookie 中返回

# Controller

控制器不一定强制要继承 BaseController，但父类控制器 BaseController 包括以下特性：middleware, validate, dispatch 等方法。

控制器的命名空间都是相对 App\Http\Controllers 来说的。

### 单方法的控制器

生成：

```bash
php artisan make:controller PhotoController --resource
```

```php
// 在 routes/web.php 中定义
Route::get('user/{id}', 'ShowProfile');

// 控制器中写法
class ShowProfile extends Controller
{
    public function __invoke($id)
    {
        return view('user.profile', ['user' => User::findOrFail($id)]);
    }
}
```

### Restful Controller

```php
Route::get('photos/popular', 'PhotoController@method');
Route::resource('photos', 'PhotoController');
```

方法对照：<https://laravel.com/docs/5.4/controllers#resource-controllers>

# Request

检测请求 URI 是否以指定字符开头：

```php
$request->is('admin/*')
```

只有调用了 response  实例后，cookie 才会真正被输出到客户端:

```php
$cookie = cookie('name', 'value', $minutes);
return response('Hello World')->cookie($cookie);
```

### 文件上传

```php
// 读取 $_FILES['photo']
$file = $request->file('photo');

// 保存（自动生成文件名）
$path = $request->photo->store('保存至目录名');
$path = $request->photo->store('保存至目录名', '磁盘名称');

// 保存（指定文件名）
$path = $request->photo->storeAs('保存至目录名', '重命名.jpg');
$path = $request->photo->storeAs('保存至目录名', '重命名.jpg', '磁盘名称');
```

# Response

跳到指定页

```php
return redirect('home/dashboard');
```

回到上页

```php
return back()->withInput();
```

跳到命名路由

```php
return redirect()->route('login');
```

跳到指定控制器

```php
return redirect()->action('HomeController@index');
```

返回内容的同时返回header

```php
return response()
    ->view('hello', $data, 200)
    ->header('Content-Type', $type);
```

弹出附件下载

```php
return response()->download($pathToFile);
```

直接在浏览器显示。例如 pdf，img

```php
return response()->file($pathToFile);
```

### 响应宏设置

```php
// 定义
class ResponseMacroServiceProvider extends ServiceProvider
{
    public function boot()
    {
        Response::macro('caps', function ($value) {
            return Response::make(strtoupper($value));
        });
    }
}

// 执行
return response()->caps('foo');
```

# View

### 赋值

```php
return view('greetings', ['name' => 'Victoria']);
```

等价于

```php
return view('greeting')->with('name', 'Victoria');
```

### 所有视图共享的数据

在 AppServiceProvider 的 boot() 中：

```php
public function boot()
{
    View::share('key', 'value');
}
```

### 视图合成器 View Composers/Creators

可以在指定视图渲染前，或者渲染后，改变一些数据。

使用场景：全局公用的右侧排行榜 widget 组件，例如： <https://laravel-china.org/topics/3094>

# Session

```php
// 读
$value = session('key');

// 读（设缺省值）
$value = session('key', 'default');

// 写
session(['key' => 'value']);
```

使用 $request->session()->get('key') 和 session('key') 没有实质差别

### 重新生成 Session ID

通常时为了防止恶意用户进行 Session 固定攻击 `Session Fixation`

如果你使用了 LoginController 方法，那么 Laravel 会自动重新生成 Session ID，否则，你需要手动使用 regenerate 方法重新生成 session ID

```php
$request->session()->regenerate();
```

检测一个 key 是否存在（如果值为 null，则结果为 false）

```php
if ($request->session()->has('users')) {
    //
}
```

检测一个 key 是否存在（即使值为 null，只要 key 存在，则结果为 true）

```php
if ($request->session()->exists('users')) {
    //
}
```

### 用 Redis 保存 session

1、修改 `.env` 中的 SESSION_DRIVER=redis

2、增加 `config/database.php` 中为 redis 增加一个负责存储 session 的数据库：

```php
'redis' => [

    'client' => 'predis',

    // 其他组
    // ...

    'session' => [
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'password' => env('REDIS_PASSWORD', null),
        'port' => env('REDIS_PORT', 6379),
        'database' => 1,
    ],

],
```

3、修改 `config/session.php` 设置 `'connection' => 'session'`

# Validation 输入验证、表单验证

https://laravel.com/docs/5.4/validation

# Blade View

https://laravel.com/docs/5.4/blade#control-structures

### 父模板中定义 section

```html
<!-- Stored in resources/views/layouts/app.blade.php -->

<html>
    <head>
        <title>App Name - @yield('title')</title>
    </head>
    <body>
        @section('sidebar')
            This is the master sidebar.
        @show
        <div class="container">
            @yield('content')
        </div>
    </body>
</html>
```

### 子模板中继承并填充 section

```html
<!-- Stored in resources/views/child.blade.php -->

@extends('layouts.app')

@section('title', 'Page Title')

@section('sidebar')
    @parent
    <p>This is appended to the master sidebar.</p>
@endsection

@section('content')
    <p>This is my body content.</p>
@endsection
```

### 组件和插槽

定义一个 alert 组件：

```html
<div class="alert alert-danger">
    <div class="alert-title">{{ $title }}</div>
    {{ $slot }}
</div>
```

外部如何使用：

```html
@component('alert')
    @slot('title')
        Forbidden
    @endslot
    You are not allowed to access this resource!
@endcomponent
```

最终会生成：

```html
<div class="alert alert-danger">
    <div class="alert-title">Forbidden</div>
    You are not allowed to access this resource!
</div>
```

### 显示未经 htmlentities 后的 Dangerous HTML

```html
Hello, {!! $name !!}.
```

我就是想显示两个花括号，怎么办？

```html
Hello, @{{ name }}.
```

或者用包起一大段：

```html
@verbatim
    <div class="container">
        Hello, {{ name }}.
        {{ memos }}
        {{ gender }}
    </div>
@endverbatim
```

循环无记录时的判断：

```html
@forelse ($users as $user)
    <li>{{ $user->name }}</li>
@empty
    <p>No users</p>
@endforelse
```

循环中的一些操作：按条件跳出、按条件继续

```html
@foreach ($users as $user)
    @continue($user->type == 1)
    <li>{{ $user->name }}</li>
    @break($user->number == 5)
@endforeach
```

判断是否首个、最后一个：

```html
@foreach ($users as $user)
    @if ($loop->first)
        This is the first iteration.
    @endif
    @if ($loop->last)
        This is the last iteration.
    @endif
    <p>This is user {{ $user->id }}</p>
@endforeach
```

循环指定的子模板：

```html
@each('view.name', $jobs, 'job', 'view.empty')
```

模板里写注释：

```html
{{-- This comment will not be present in the rendered HTML --}}
```

在模板里写原生 PHP 代码：

```html
@php
    // ...
@endphp
```

### 栈的使用

父组件中定义：

```html
<head>
    <!-- Head Contents -->
    @stack('scripts')
</head>
```

子组件中使用：

```html
@push('scripts')
    <script src="/example1.js"></script>
    <script src="/example2.js"></script>
@endpush
```

清理模板缓存（例如增加、修改自定义指令后）：

```bash
php artisan view:clear
```

# Console/Command

定义命令（新建文件 `App/Console/Commands/SendEmail.php`）：

```php
namespace App\Console\Commands;

use Illuminate\Console\Command;

class SendEmail extends Command
{
    protected $signature = 'email:send
                        {uid : The ID of the user}
                        {--queue= : Whether the job should be queued}';

    protected $description = 'Command description';

    public function handle()
    {
        // 接收参数
        $uid = $this->argument('uid');
        $shouldQueue = $this->option('queue');

        // 要求输入
        $name = $this->ask('What is your name?');
        $password = $this->secret('What is the password?');

        if ($this->confirm('Do you wish to continue?')) {
            $city = $this->anticipate('你在哪个城市？', ['Shanghai', 'Hongkong', 'Beijing']);
            $habbit = $this->choice('你喜欢哪项运动？', ['NBA', 'Football', 'Tennis'], 'NBA');
        }

        // 输出文本
        // line, info, comment, question and error
        $this->info('Display this on the screen');
        $this->error('Something went wrong!');
        $this->line('Display this on the screen');

        // 输出表格
        $headers = ['Name', 'Email'];

        $users = [
            ['Jack', 'jack@hello.com'],
            ['Rose', 'rose@hello.com'],
        ];

        $this->table($headers, $users);

        // 进度条
        $bar = $this->output->createProgressBar(count($users));

        foreach ($users as $user) {
            $this->performTask($user);

            $bar->advance();
        }

        $bar->finish();

        dd($name, $password);
    }
}

```

注册（在 `App/Console/Kernel.php` 绑定）：

```php
protected $commands = [
    Commands\SendEmails::class
];
```

除了在 CLI 模式下，在 PHP 代码里如何调用命令？

```php
$exitCode = Artisan::call('email:send', [
    'user' => 1,
    '--queue' => 'default',
    '--force' => true,
]);

// 队列模式（注意如何配置队列？）
Artisan::queue('email:send', [
    'user' => 1, '--queue' => 'default'
]);
```

如果是在其他 Commands 文件中，则能直接通过 this 调用

```php
$this->call('email:send', [
    'user' => 1, '--queue' => 'default'
]);

// 忽略所有输出
$this->callSilent('email:send', [
    'user' => 1, '--queue' => 'default'
]);
```
### Laravel REPL Tinker？
REPL 即为 Read-Eval-Print Loop，中文译为“读取-求值-输出”循环。
https://github.com/bobthecow/psysh

```bash
php artisan tinker
```

# Cache

配置文件在 app/cache.php

访问指定库：

```php
Cache::store('库名')->put('bar', 'baz', 10);
```

设置默认值：
```php
$value = Cache::get('key', 'default');

// 异步
$value = Cache::get('key', function () {
    return DB::table(...)->get();
});

// 等价于
$value = Cache::get('key');
if ($value === null) {
    $value = DB::table(...)->get();
}
```

阅后即焚：

```php
$value = Cache::pull('key');
```

```php
// 单位：分
Cache::put('key', 'value', $minutes);

// 会清空整台服务器缓存
Cache::flush();
```

取值后塞回（非常有用）：

```php
$users = Cache::remember('users', $minutes, function () {
    return $db->fetchAll(....);
});

// 等价于

$users = $cache->get('users');

if (! $users) {
    $users = $db->fetchAll(...);
}

$cache->set('users', $users);
```

# Collection

我的理解是 PHP 版的 immutable 对象，每次变更都会返回一个新的完整实例。

https://laravel.com/docs/5.4/collections

### Higher Order Messages 高阶消息传递（Laravel 5.4 新特性）

支持方法：contains, each, every, filter, first, map, partition, reject, sortBy,  sortByDesc, and sum.

举例说明：

```php
原来写法：

$invoices->each(function ($invoice) {
    $invoice->pay();
});

变成了：

$invoices->each->pay();
```

另一个例子：

```php
原来写法：

$employees->reject(function ($employee) {
    return $employee->retired;
})->each(function ($employee){
    $employee->sendPayment();
});

变成了：

$employees->reject->retired->each->sendPayment();
```

# Error & Log

错误日志级别：debug, info, notice, warning, error, critical, alert, emergency

```php
use Illuminate\Support\Facades\Log;

Log::emergency($message, $contextualInfo);
Log::alert($message);
Log::critical($message);
Log::error($message);
Log::warning($message);
Log::notice($message);
Log::info($message);
Log::debug($message);

// 或者全局助手方法

// Log::info()
info('Some helpful information!');

// Log::debug()
logger('Debug message');

// Log::error()
logger()->error('You are not allowed here.');

```

# Event 事件与监听

为了代码解耦，使用场景例如，下订单后发送通知，这样就可以把发送通知的代码放到监听者中。

### 通过 $listen 数组来注册事件和监听：

修改 app/Provider/EventServiceProvider.php 中的 $listen 属性：

```php
protected $listen = [
    'App\Events\SomeEvent' => [
        'App\Listeners\EventListener',
    ],
];
```

生成事件和监听者类文件：

```php
php artisan event:generate
```

会根据上面的 $listen 自动生成收发双方两个文件：

- app\Events\SomeEvent.php
- app\Listeners\EventListener.php

监听者 EventListener 代码如下：

```php
namespace App\Listeners;

use App\Events\SomeEvent;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Contracts\Queue\ShouldQueue;

class EventListener
{
    use InteractsWithQueue;

    // 队列连接名和队列名（省略则是使用缺省队列）
    public $connection = 'sqs';
    public $queue = 'listeners';

    public function handle(SomeEvent $event)
    {
        // 在这里写处理逻辑
    }
}
```

如果想阻止冒泡（传播给其他监听者），那么在 handle() 里返回 false 即可，其他该事件的监听者将不再处理该事件。

同样，如果监听者可能要处理长时间的逻辑，那么可以实现 ShouldQueue 接口，则自动会进入异步队列执行。

`trait InteractsWithQueue` 的作用是让我们可以手动操纵一个队列元素（queue job），例如进行 delete 或 release 等操作。

```php
class SendShipmentNotification implements ShouldQueue
{
    use InteractsWithQueue;

    public function handle(OrderShipped $event)
    {
        if (true) {
            // 30秒后重新塞回队列
            $this->release(30);
        }
    }
}
```

### 手动设置监听

在 EventServiceProvider.php 的 boot() 方法体内增加：

```php
public function boot()
{
    parent::boot();

    Event::listen('event.name', function ($foo, $bar) {
        //
    });

    Event::listen('event.*', function ($eventName, array $data) {
        //
    });
}
```

### Event Subscribers 订阅者

之前在 `EventServiceProvider::$listen` 中注册的监听者，一个监听者只能监听一个事件。现在引入新的写法 `EventServiceProvider::$subscribe`，订阅者也是监听者，但可以同时监听多个事件。

注册订阅者：

```php
class EventServiceProvider extends ServiceProvider
{
    protected $subscribe = [
        'App\Listeners\UserEventSubscriber',
    ];
}
```

订阅者实现 `app\Listeners\UserEventSubscriber.php`：

```php
namespace App\Listeners;

class UserEventSubscriber
{
    /**
     * Register the listeners for the subscriber.
     *
     * @param  Illuminate\Events\Dispatcher  $events
     */
    public function subscribe($events)
    {
        $events->listen(
            'Illuminate\Auth\Events\Login',
            'App\Listeners\UserEventSubscriber@doSth1'
        );

        $events->listen(
            'Illuminate\Auth\Events\Logout',
            'App\Listeners\UserEventSubscriber@doSth2'
        );
    }

    public function doSth1($event)
    {
    }

    public function doSth2($event)
    {
    }
}
```

# File Storage

```php
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\File;

// 相当于 file_put_content
Storage::put('file.jpg', $contents);

// 自动生成保存后的文件名
Storage::putFile('保存至目录', new File('/path/to/photo.jpg'));

// 手动指定保存后的文件名
Storage::putFileAs('保存至目录', new File('/path/to/photo.jpg'), '新文件名');
```

### 将上传文件（$_FILES）保存

文件名自动生成：

```php
$path = $request->file('avatar')->store('保存至目录');
// 或
$path = Storage::putFile('保存至目录', $request->file('avatar'));
```

手动指定文件名：
```php
$path = $request->file('avatar')->storeAs('保存至目录', '新文件名');
// 或
$path = Storage::putFileAs('保存至目录', $request->file('avatar'), '新文件名');
```

# Helpers

我觉得一些常用的：

```php
app_path()
base_path('vendor/bin');
config_path()

// 等价于 htmlspecialchars
e('<html>foo</html>');

// read config
config('app.timezone');

// 生成密码
$password = bcrypt('my-secret-password');

// get cache
$value = cache('key');
$value = cache('key', 'default');

// set cache
cache(['key' => 'value'], 5);
cache(['key' => 'value'], Carbon::now()->addSeconds(10));

// 记录日志
info('User login attempt failed.', ['id' => $user->id]);
logger('User has logged in.', ['id' => $user->id]);
logger()->error('You are not allowed here.');

// retry
return retry(5, function () {
    // Attempt 5 times while resting 100ms in between attempts...
}, 100);

// request()
$request = request();
$value = request('key', $default = null)

// response()
return response('Hello World', 200, $headers);
return response()->json(['foo' => 'bar'], 200, $headers);
```

# Queue

### 缺省队列

在文件 `config/queue.php` 的 `connections` 数组里：

```php
'redis' => [
    'driver' => 'redis',
    'connection' => 'queue',
    'queue' => 'default',   // 缺省队列，当 push 时不填队列名，则进入缺省队列
    'retry_after' => 90,
],
```

创建任务：

```bash
php artisan make:job SendReminderEmail
```

如何入列？

```php
// push 到缺省队列
dispatch(new Job);

// push 到指定队列
dispatch((new Job)->onQueue('指定队列名'));

// push 到指定连接的指定队列
dispatch((new Job)->->onConnection('sqs')->onQueue('指定队列名'));
```

如何出列？

```bash

php artisan queue:work [缺省连接名] [--queue=缺省队列名]

php artisan queue:work 连接名 --queue=队列1(高优先),队列2(低优先) --tries=最大重试次数
```
平滑重启队列

```bash
php artisan queue:restart
```

```bash
php artisan queue:work
   {connection? : The name of connection}
   {--queue= : The queue to listen on}
   {--daemon : Run the worker in daemon mode (Deprecated)}
   {--once : Only process the next job on the queue}
   {--delay=0 : Amount of time to delay failed jobs}
   {--force : Force the worker to run even in maintenance mode}
   {--memory=128 : The memory limit in megabytes}
   {--sleep=3 : Number of seconds to sleep when no job is available}
   {--timeout=60 : The number of seconds a child process can run}
   {--tries=0 : Number of times to attempt a job before logging it failed, 如果不指定，表示无限重试}
```

### retry_after 和 ---timeout

retry_after 在 config/queue.php 中每个队列连接中设置，缺省是90秒。
--timeout 在出列命令众设置，或者单个 Job 类中设置，缺省是60秒。

```php
namespace App\Jobs;

class ProcessPodcast implements ShouldQueue
{
    public $tries = 5;
    public $timeout = 120;
}
```

retry_after 必须比 --timeout 大，否则任务可能执行两次。
具体没搞懂。待研究

If queued listener exceeds the maximum number of attempts as defined by your queue worker, the failed method will be called on your listener. The failed method receives the event instance and the exception that caused the failure:

```php
class SendShipmentNotification implements ShouldQueue
{
    use InteractsWithQueue;

    public function handle(OrderShipped $event)
    {
        //
    }

    public function failed(OrderShipped $event, $exception)
    {
        //
    }
}
```

### 任务的前置、后置事件

放入到任意一个 ServiceProvider 中

```php
Queue::before(function (JobProcessing $event) {
    // $event->connectionName
    // $event->job
    // $event->job->payload()
});

Queue::after(function (JobProcessed $event) {
    // $event->connectionName
    // $event->job
    // $event->job->payload()
});

// execute before the worker attempts to fetch a job from a queue.
Queue::looping(function () {
    while (DB::transactionLevel() > 0) {
        DB::rollBack();
    }
});
```

### Supervisor

配置文件在 `/etc/supervisor/conf.d` 目录中

### 重试失败任务

```bash
# 列出 failed_jobs 中的失败任务
php artisan queue:failed

# 重试指定失败任务id
php artisan queue:retry 5

# 重试所有失败任务
php artisan queue:retry all

# 忽略指定失败任务id
php artisan queue:forget 5

# 清空所有失败任务
php artisan queue:flush
```

# 计划任务 Schedule Tasks

```php
$schedule
    ->command('foo')
    ->weekdays()
    ->hourly()
    ->timezone('America/Chicago')
    ->between('8:00', '17:00')
    ->when(function () {
        return true;
    })
    ->before(function () {
        // Task is about to start...
    })
    ->after(function () {
        // Task is complete...
    })
    ->appendOutputTo('日志输出绝对路径')
    ->emailOutputTo('foo@example.com')
    ->pingBefore('通知外部URL')
    ->thenPing('通知外部URL');
```

Note: The emailOutputTo, sendOutputTo and appendOutputTo methods are exclusive to the command method and are not supported for call.

如何防止任务重叠执行？

```php
$schedule->command('emails:send')->withoutOverlapping();
```

让计划任务在维护模式时仍然执行

```php
$schedule->command('emails:send')->evenInMaintenanceMode();
```

# Mail

### 定义邮件

首先在 config/mail.php 中定义全局 from 发送者：

```php
'from' => [
    'address' => 'noreply@bigins.cn',
    'name' => 'App Name'
],
```

```php
// 生成普通 HTML 邮件模板
// 文件路径为 app/Mail/OrderShipped.php
php artisan make:mail OrderShipped

// 生成 Markdown 格式邮件模板
php artisan make:mail OrderShipped --markdown=emails.orders.shipped
```

OrderShipped 类中的所有 public 成员变量都会自动传递到模板中。另外也可以在调用 view() 时单独传递变量。

普通邮件模板（支持 Blade）里传递变量：

```php
public function build()
{
    return $this->view('emails/orders/shipped', [
        'orderName' => $this->order->name,
        'orderPrice' => $this->order->price,
    ]);
}
```

Markdown 邮件模板里传递变量：

```php
public function build()
{
    return $this->markdown('emails/orders/shipped', [
        'orderName' => $this->order->name,
        'orderPrice' => $this->order->price,
    ]);
}
```

Markdown 邮件模板里面一些组件的写法，参考官方文档：
<https://laravel.com/docs/5.4/mail#markdown-mailables>

### 发送邮件

直发：

```php
Mail::to('silverd@qq.com')
    ->send(new OrderShipped($order));
```

用队列发：

```php
$message = (new OrderShipped($order))
    ->onConnection('sqs')
    ->onQueue('emails');

Mail::to('silverd@qq.com')
    ->queue($message);
```

用队列发的第二种方法，定义邮件时实现 ShouldQueue 接口，并定义好连接和队列名（未经测试）：

```php
use Illuminate\Contracts\Queue\ShouldQueue;

class OrderShipped extends Mailable implements ShouldQueue
{
    public $connection = 'sqs';
    public $queue = 'emails';
}
```


### 开发环境假装发邮件

- 方法1：修改 `.env` 把 MAIL_DRIVER 改为 log，则只会记录邮件发送日志，不会真发
- 方法2：在 config/mail.php 中增加以下全局收件人，则所有邮件都会发送给这个假人

```php
'to' => [
    'address' => 'op.sh@bigins.com',
    'name' => 'Example'
],
```

# Notification 通知系统

可以构建一个简单的站内信系统，可选择是否同时发送 SMS/Email/Slack 等。

生成新通知：

```php
php artisan make:notification InvoicePaid
```

### 发送方式（有两种）

```php
use App\Notifications\InvoicePaid;

$user->notify(new InvoicePaid($invoice));
```

# Database

# Eloquent ORM

## Relation 多表关系

### 一对一 One To One

场景：用户表（users）、用户设置表（user_settings）

```php
class User extends Model
{
    public function settings()
    {
        return $this->hasOne('App\Models\Settings', 'user_id', 'id');
    }
}
```

然后通过动态属性 `User::find(1)->settings` 可以读取。

外键可以自定义：

```php
return $this->hasOne('App\Models\Settings', 'user_settings 表的 uid 字段名', '本表的 uid 字段名');
```

hasOne 的反向定义：belongsTo（貌似很少有这样的使用场景）

```
class UserSettings extends Model
{
    public function user()
    {
        return $this->belongsTo('App\Models\User', '本表的 uid 字段名', 'users 表的 uid 字段名');
    }
}
```

### 一对多 One To Many

场景：文章表（posts）、文章评论表（comments）

定义：

```php
class Post extends Model
{
    public function comments()
    {
        return $this->hasMany('App\Models\Comment', 'foreign_key', 'local_key');
    }
}
```

读取：

```php
$comments = App\Post::find(1)->comments;

或者带条件的：

$comments = App\Post::find(1)->comments()->where('title', 'foo')->first();

foreach ($comments as $comment) {
    // ...
}
```

hasMany 的反向定义也是：belongsTo

```php
class Comment extends Model
{
    public function post()
    {
        return $this->belongsTo('App\Models\Post', 'post_id', 'id');
    }
}
```

读取：

```php
$comment = App\Models\Comment::find(1);
echo $comment->post->title;
```

### 多对多 Many To Many

场景：用户表（users）、角色组（roles）、用户角色关系（role_user）

```php
class User extends Model
{
    public function roles()
    {
        return $this->belongsToMany('App\Models\Role', 'role_id');
    }
}
```
### 多级 Has Many（Has Many Through）

场景：取指定国家的人发表的所有文章

```
countries 国家表
    id - integer
    name - string

users 用户表
    id - integer
    country_id - integer
    name - string

posts 文章表
    id - integer
    user_id - integer
    title - string
```

定义：

```php
class Country extends Model
{
    /**
     * Get all of the posts for the country.
     */
    public function posts()
    {
        return $this->hasManyThrough(
            'App\Models\Post', 'App\Models\User',
            'country_id', 'user_id', 'id'
        );
    }
}
```

读取：

```php
$country = App\Models\Country::find(1);
echo $country->posts;
```

### 多态关联（Polymorphic Relations）

非常有用和常见的一种关系，例如通用的评论系统，可以有文章评论，也可以有视频评论：

```
posts 文章表
    id - integer
    title - string
    body - text

videos 视频表
    id - integer
    title - string
    url - string

comments 通用评论表
    id - integer
    body - text
    commentable_id - integer
    commentable_type - string -- 重点：存储的模型 class 名，例如 App\Models\Post
```

Model 定义：

```php
class Comment extends Model
{
    /**
     * Get all of the owning commentable models.
     */
    public function commentable()
    {
        return $this->morphTo();
    }
}

class Post extends Model
{
    /**
     * Get all of the post's comments.
     */
    public function comments()
    {
        return $this->morphMany('App\Models\Comment', 'commentable');
    }
}

class Video extends Model
{
    /**
     * Get all of the video's comments.
     */
    public function comments()
    {
        return $this->morphMany('App\Models\Comment', 'commentable');
    }
}
```

读取指定文章的评论：

```php
$post = App\Models\Post::find(1);

foreach ($post->comments as $comment) {
    //
}
```

### Eager Loading 热心加载

十分常见、重要的一个特性。例如场景：书籍表（books）、作者表（authors）

```php
class Book extends Model
{
    /**
     * Get the author that wrote the book.
     */
    public function author()
    {
        return $this->belongsTo('App\Models\Author');
    }
}
```

显示书籍列表，同时显示每本书的作者名：

```php
$books = App\Models\Book::all();

foreach ($books as $book) {
    echo $book->author->name;
}
```
以上会产生 N+1 条SQL查询：

```sql
select * from books;
select * from authors where id = 1;
select * from authors where id = 2;
...
select * from authors where id = $N;
```

常见的解决办法是：先用 `select ... from authors where in` 批量查询作者名，然后再循环赋值回 $books。

Laravel 犀利地提供了一个非常简便的办法：通过 with 方法，即可实现 `select in` 热心加载：

```php
$books = App\Models\Book::with('author')->get();

foreach ($books as $book) {
    echo $book->author->name;
}
```

以上相当于只执行了2条SQL：

```sql
select * from books;
select * from authors where id in (1, 2, 3, 4, 5, ...);
```

另外 `with` 方法可以同时预加载多个关系属性：

```php
$books = App\Models\Book::with('author', 'publisher')->get();
```

加入额外的条件：

```php
$users = App\Models\Book::with(['author' => function ($query) {
    $query->where('name', 'LIKE', '%silverd%');
}])->get();
```
### Lazy Eager Loading（重要）

```php
$books = App\Models\Book::all();

if (一些条件) {
    $books->load('author', 'publisher');
}

或者

if (一些条件) {
    $books->load(['author' => function ($query) {
        $query->orderBy('published_date', 'asc');
    }]);
}
```
### Touching Parent Timestamps

当子模型（belongsTo/belongsToMany）更新后，如何自动更新父模型的 updated_at 字段？

只需要在子模型内增加 $touches 成员属性即可。

```php
class Comment extends Model
{
    /**
     * All of the relationships to be touched.
     *
     * @var array
     */
    protected $touches = ['post'];

    /**
     * Get the post that the comment belongs to.
     */
    public function post()
    {
        return $this->belongsTo('App\Models\Post');
    }
}
```

## Mutators 修改器

例如时间戳字段，读出时转成日期格式，存入时转为 int。
又如某个字段存储 JSON 数据，读出时自动 `json_decode`，存入时自动 `json_encode`。

举例：order 表的 `extra_info` 字段是以 JSON 格式存储：

```php
class Order extends Model
{
    // Accessor 访问器
    public function getExtraInfoAttribute($value)
    {
        return json_decode($value, true);
    }

    // Mutator 修改器
    public function setExtraInfoAttribute($value)
    {
        $this->attributes['extra_info'] = json_encode($value);
    }
}

读取：

$order = App\Models\Order::find(1);
$extraInfo = $order->extra_info;
```

如果仅仅需要做属性的类型强制转换，可以有更简单的方法（Attribute Casting），定义 `$casts` 属性，支持的类型转换有：integer, real, float, double, string, boolean, object, array, collection,  date, datetime, timestamp

```php
class User extends Model
{
    /**
     * The attributes that should be casted to native types.
     *
     * @var array
     */
    protected $casts = [
        'is_admin' => 'boolean',
        'view_count' => 'integer',
        'extra_info' => 'array',
    ];
}
```

存储时，`extra_info` 会自动序列化成 JSON 字符串：

```php
$user = App\User::find(1);
$options = $user->options;
$options['key'] = 'value';
$user->options = $options;
$user->save();
```

## Eloquent: Serialization

如何把 Models & Collections 转成数组？

```php
$users = App\User::all();
return $users->toArray();

甚至是含有 relationship 的多层级也能转：

$user = App\User::with('roles')->first();
return $user->toArray();
```

转成 JSON：

```php
$user = App\User::find(1);
echo $user->toJson();

或者自动触发实例的 __toString() 方法来实现 JSON 自动转换：

echo (string) $user;

既然能把实例当字符串输出，那么路由或控制器就能直接返回，便会自动变成 JSON 输出了：

Route::get('users', function () {
    return App\Model\User::all();
});
```

隐藏 toArray/toJson 后的个别字段：

```php
class User extends Model
{
    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = ['password', 'posts()'];
}
```

特别注意：When hiding relationships, use the relationship's method name, not its dynamic property name.

或者使用 `$hidden` 的反向：`$visible`（白名单）

```php
class User extends Model
{
    /**
     * The attributes that should be visible in arrays.
     *
     * @var array
     */
    protected $visible = ['first_name', 'last_name'];
}
```

一次性隐藏、显示个别字段：

```php
return $user->makeVisible('字段名')->toArray();
return $user->makeHidden('字段名')->toArray();
```

### 虚拟的动态属性

有些字段，数据表里没有，但是想在模型里赋值，方便外面使用。有点类似于 VueJS 里的 `computed` 计算属性。可以通过 上文中的 accessor 访问器来实现。

<https://laravel.com/docs/5.4/eloquent-serialization#appending-values-to-json>



# Package/Vendor

这里讨论的是 Laravel 专用扩展。一个扩展可以是一个模块，包含路由、控制器、视图、配置等。

首先必须有一个自己的 SilverServiceProvider，负责向服务容器注册东西。

### 发布扩展资源

publishes 动作其实就是 vendor 里代码文件++复制到应用目录去++，让开发者可以使用或自由修改。

### 扩展配置

```php
public function boot()
{
    // 发布配置文件
    $this->publishes([
        __DIR__ . '/path/to/config/courier.php' => config_path('courier.php'),
    ]);
    // 和原有的配置文件合并（只覆盖第1级下标）
    $this->mergeConfigFrom(
        __DIR__.'/path/to/config/courier.php', 'courier'
    );
}
```

发布完成后就可以通过 `$value = config('courier.option')` 来读取了。

### 扩展路由

```php
public function boot()
{
    // 相当于是 require /path/to/routes.php
    // 里面多了一个路由缓存的判断：如果存在 bootstrap/cache/routes.php 则不引入该文件
    $this->loadRoutesFrom(__DIR__.'/path/to/routes.php');
}
```



