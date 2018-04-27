# PHP7 Error & Exception 知识点整理

先说 PHP7 之前，各大框架是如何捕捉处理 **所有** 错误和异常的，以 Laravel 为例：

Laravel 的异常处理由类 `\Illuminate\Foundation\Bootstrap\HandleExceptions` 完成（略加精简）

```php

namespace Illuminate\Foundation\Bootstrap;

use Illuminate\Contracts\Debug\ExceptionHandler;
use Symfony\Component\Debug\Exception\FatalErrorException;
use Symfony\Component\Debug\Exception\FatalThrowableError;

class HandleExceptions
{
    public function bootstrap(Application $app)
    {
        $this->app = $app;

        error_reporting(-1);

        set_error_handler([$this, 'handleError']);

        set_exception_handler([$this, 'handleException']);

        register_shutdown_function([$this, 'handleShutdown']);

        if (! $app->environment('testing')) {
            ini_set('display_errors', 'Off');
        }
    }

    // Convert PHP errors to ErrorException instances.
    // @link http://php.net/manual/zh/function.set-error-handler.php
    public function handleError($errno, $errstr, $errfile = '', $errline = 0)
    {
        if (error_reporting() & $errno) {
            throw new \ErrorException($errstr, 0, $errno, $errfile, $errline);
        }
    }

    // Handle an uncaught exception from the application.
    public function handleException($e)
    {
        if (! $e instanceof Exception) {
            // FatalThrowableError 是 Symfony 装饰模式包装的 \ErrorException 子类
            $e = new FatalThrowableError($e);
        }

        $exceptionHandler = $this->app->make(ExceptionHandler::class);

        try {
            // 汇报异常（例如以日志或邮件形式）
            $exceptionHandler->report($e);
        } catch (\Exception $e) {
            // 忽略掉上报时的异常，不然没完没了了
        }

        // 正式渲染显示异常信息
        $exceptionHandler->render($this->app['request'], $e)->send();
    }

    public function handleShutdown()
    {
        if (! is_null($error = error_get_last()) && $this->isFatal($error['type'])) {
            $this->handleException($this->fatalExceptionFromError($error, 0));
        }
    }

    // Create a new fatal exception instance from an error array.
    // FatalErrorException 是 Symfony 继承 \ErrorException 的子类
    protected function fatalExceptionFromError(array $error, $traceOffset = null)
    {
        return new FatalErrorException(
            $error['message'], $error['type'], 0, $error['file'], $error['line'], $traceOffset
        );
    }

    /**
     * Determine if the error type is fatal.
     *
     * @param  int  $type
     * @return bool
     */
    protected function isFatal($type)
    {
        return in_array($type, [E_COMPILE_ERROR, E_CORE_ERROR, E_ERROR, E_PARSE]);
    }
}
```

#### 小结：

1. 对于不致命的错误，例如 E_NOTICE、E_USER_ERROR、E_USER_WARNING、E_USER_NOTICE，`handleError` 会捕捉到， Laravel 将错误转成 `\ErrorException` 异常，交给 `handleException($e)` 处理。

2. 对于致命错误，例如 E_PARSE，`handleShutdown` 将会接手捕捉，并且判断当前脚本结束是否是由于致命错误，如果是致命错误，也把错误转化为 `\ErrorException` 异常, 再交回给 `handleExceptionn($e)` 处理。

#### 1. 建议用 `error_reporting(-1)` 代替 `E_ALL`：

> So in place of E_ALL consider using a larger value to cover all bit fields from now and well into the future, a numeric value like 2147483647 (includes all errors, not just E_ALL).

> But it is better to set "-1" as the E_ALL value.
> For example, in httpd.conf or .htaccess, use
> php_value error_reporting -1
> to report all kind of error without be worried by the PHP version.

####  2. 兜底 - 异常处理器

`set_exception_handler()` 负责捕获所有在应用层 `throw`抛出但未 `catch` 的异常。

####  3. 兜底 - 错误警告处理器

`set_error_handler()` 负责处理：

. 用户通过 `trigger_error()` 主动触发的错误
. Warning、Notice 级别的错误：E_NOTICE、E_USER_ERROR、E_USER_WARNING、E_USER_NOTICE
. 不能捕捉致命错误，如 E_ERROR、E_PARSE、E_CORE_ERROR、E_CORE_WARNING、E_COMPILE_ERROR、E_COMPILE_WARNING，以及调用 `set_error_handler()` 函数所在文件中产生的大多数 E_STRICT

#### 4. 兜底 - 致命错误处理器

`register_shutdown_function()` 会在以下情况下执行：

- 当页面被用户强制停止时
-  当程序代码运行超时时
- 当 PHP 代码执行完成时，代码执行存在异常和错误、警告

通过 `$e = error_get_last()` 获取最后的错误数组， 转成 `\ErrorException` 交给 `handleException($e)` 处理。

**小坑备注**：

当定义 `register_shutdown_function()` 方法的文件本身有 E_PARSE 错误时，则捕捉不到错：

```php
register_shutdown_function('test', function () {
    if ($error = error_get_last()) {
        var_dump($error);
    }
});

var_dump(23+-+); // 此处语法错误
```

因为如果本身有错，脚本直接就 `parse-time` 编译错误了，根本就没运行起来。只有在 `run-time` 运行出错的时候，才会捕捉到。所幸框架都是单入口 `index.php` ，其他文件都是通过运行时 `include()` 加载，只需要保证 `index.php` 本身无错就行，无需担心这个问题。

#### 其他说明

1. 关于 `\EngineException`

现已更名为 `\Error`，只是在 PHP7 alpha-2 中临时叫 `\EngineException`

2. PHP 错误种类和级别

**Fatal Error**
致命错误（脚本终止运行）
- E_ERROR          // 致命的运行错误，错误无法恢复，暂停执行脚本
- E_CORE_ERROR     // PHP 启动时初始化过程中的致命错误
- E_COMPILE_ERROR  // 编译时致命性错，就像由 Zend 脚本引擎生成了一个 E_ERROR
- E_USER_ERROR     // 自定义错误消息。像用 PHP 函数 trigger_error（错误类型设置为：E_USER_ERROR）

**Parse Error**
编译时解析错误，语法错误（脚本终止运行）
- E_PARSE          // 编译时的语法解析错误

**Warning Error**
警告错误（仅给出提示信息，脚本不终止运行）
- E_WARNING         // 运行时警告 (非致命错误)。
- E_CORE_WARNING    // PHP初始化启动过程中发生的警告 (非致命错误) 。
- E_COMPILE_WARNING // 编译警告
- E_USER_WARNING    // 用户产生的警告信息

**Notice Error**
通知错误（仅给出通知信息，脚本不终止运行）
- E_NOTICE         // 运行时通知。表示脚本遇到可能会表现为错误的情况.
- E_USER_NOTICE    // 用户产生的通知信息

由此可知有5类是产生ERROR级别的错误，这种错误直接导致PHP程序退出

```php
const ERROR = E_ERROR | E_CORE_ERROR | E_COMPILE_ERROR | E_USER_ERROR | E_PARSE;
```

3. 关于 `\Throwable`

PHP7 新增定义了 `\Throwable` 接口，原来的 `\Exception` 和部分 `\Error` 都实现了这个接口。

更多的错误和异常可以被现场 `try-catch` 或兜底 `set_exception_handler()` 捕获了，也就是说 `set_exception_handler()` 捕获的不只是 `\Exception` 的实例，还包括 `\Error`，这也就是下面 `handleException($e)` 里面这么判断的原因：

```php
    // Handle an uncaught exception from the application.
    public function handleException($e)
    {
        if (! $e instanceof Exception) {
            // FatalThrowableError 是 Symfony 装饰模式包装的 \ErrorException 子类
            $e = new FatalThrowableError($e);
        }

        // ...
    }
```

4. 详见 `\Throwable` 层次树：<http://php.net/manual/en/class.error.php#122323>

```text
Throwable
    Error
        ArithmeticError
            DivisionByZeroError
        AssertionError
        ParseError
        TypeError
            ArgumentCountError
    Exception
        ClosedGeneratorException
        DOMException
        ErrorException
        IntlException
        LogicException
            BadFunctionCallException
              BadMethodCallException
            DomainException
            InvalidArgumentException
            LengthException
            OutOfRangeException
        PharException
        ReflectionException
        RuntimeException
            OutOfBoundsException
            OverflowException
            PDOException
            RangeException
            UnderflowException
            UnexpectedValueException
        SodiumException
```

5. 关于 `\ErrorException`

注意 `\ErrorException` 跟 PHP7+ 的 `\Erorr` 的区别：

(1) `\Error` 是 PHP7+ 新增的错误类型，例如上述的 `DivisionByZeroError`，供 `try-catch` 或 `set_exception_handler()` 捕获。
(2) `\ErrorException` 是继承于 `\Exception` 的异常子类，扩展了更多的参数，例如文件名和行号。一般专门用在 `set_error_handler()` 或者 `register_shutdown_function()` 将错误转化为异常（因为普通异常只有 code/message 两个属性）。

定义如下：<http://php.net/manual/en/class.errorexception.php>

```php
class ErrorException extends Exception {
    public __construct(
        string $message = "",
        int $code = 0,
        int $severity = E_ERROR,
        string $filename = __FILE__,
        int $lineno = __LINE__,
        Exception $previous = NULL
    )
}

使用如下：

```php
throw new ErrorException($message, $code, $severity, $errfile, $errline);
```

#### 参考文章：

- [再谈PHP错误与异常处理](https://www.cnblogs.com/zyf-zhaoyafei/p/6928149.html)
- [Laravel Exceptions——异常与错误处理](https://laravel-china.org/articles/5657/laravel-exceptions-exception-and-error-handling)
- [PHP 错误与异常](https://segmentfault.com/a/1190000009504337)
- [PHP 错误日志收集之 ErrorException](https://mengkang.net/1198.html]