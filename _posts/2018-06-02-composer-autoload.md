---
layout: post
category: ['PHP', '笔记']
title: 理解 Composer 自动加载原理
---

## Composer 自带的几种 autoloader（加载器）

原文参考：https://docs.phpcomposer.com/04-schema.html#autoload

- PSR-4 autoloading
- PSR-0 autoloading
- Classmap generation
- Files includes

推荐使用 PSR-4，使用更简洁，另外当增加新的类文件时，无需重新生成 autoloader，Composer 会根据类名自动定位文件路径。

### (1) PSR-4 Autoloading

当执行 `composer install/update` 时，会生成 `vendor/composer/autoload_psr4.php` 文件

```json
{
    "autoload": {
        "psr-4": {
            "Monolog\\": "src/",
            "Vendor\\Namespace\\": ""
        }
    }
}
```

如果你需要搜索多个目录中一个相同的前缀，你可以将它们指定为一个数组，例：

```json
{
    "autoload": {
        "psr-4": { "Monolog\\": ["src/", "lib/"] }
    }
}
```

如果想设置一个目录作为任何命名空间的 `fallback` 查找目录，可以使用空的前缀，像这样：

```json
{
    "autoload": {
        "psr-4": { "": "src/" }
    }
}
```

> 请注意：命名空间的申明应该以 \\ 结束，以确保 autoloader 能够准确响应。例： Foo 将会与 FooBar 匹配，然而以反斜杠结束就可以解决这样的问题， Foo\\ 和 FooBar\\ 将会被区分开来，另外：JSON 里要写双斜杠只是因为须在双引号里转义。

### (2) PSR-0 Autoloading

在 `composer install/update` 过程中，会生成 `vendor/composer/autoload_namespaces.php` 文件。

```json
{
    "autoload": {
        "psr-0": {
            "Monolog\\": "src/",
            "Vendor\\Namespace\\": "src/",
            "Vendor_Namespace_": "src/"
        }
    }
}
```

如果你需要搜索多个目录中一个相同的前缀，你可以将它们指定为一个数组，例：

```json
{
    "autoload": {
        "psr-0": { "Monolog\\": ["src/", "lib/"] }
    }
}
```

PSR-0 方式并不仅限于申明命名空间，也可以是精确到类级别的指定。这对于只有一个类在全局命名空间的类库是非常有用的（如果 PHP 源文件也位于包的根目录）。例如，可以这样申明：

```json
{
    "autoload": {
        "psr-0": { "UniqueGlobalClass": "" }
    }
}
```

如果想设置一个目录作为任何命名空间的 `fallback` 查找目录，可以使用空的前缀，像这样：

```json
{
    "autoload": {
        "psr-0": { "": "src/" }
    }
}
```

### (3) Classmap generation

在 `composer install/update` 过程中，扫描指定目录（同样支持直接精确到文件）中所有的 `.php` 和 `.inc` 文件中的类，建立类名和类文件的映射，以路径层级作为命名空间，生成 `vendor/composer/autoload_classmap.php` 文件。

我们可以用 classmap 生成不遵循 PSR-0/4 规范的类库路径映射。

```json
{
    "autoload": {
        "classmap": [
            "database/seeds",
            "database/factories"
        ],
    }
}
```

> 注意：文件 `autoload_classmap.php` 还有个巧妙的用途，在执行 `composer dump-autoload -o` 时，也会冗余存储扫描得出的 PSR-4/0 规则的类文件映射 —— 所以生产服必须启用。

### (4) File includes

用于加载某些全局的特定文件，通常作为函数库的载入方式（而非类库）。

```json
{
    "autoload": {
        "files": ["src/MyLibrary/functions.php"]
    }
}
```

## (5) include-path (Legacy)

设置一个目录列表，这是一个过时的做法，用于支持老项目，相当于给 PHP 设置 `set_include_path` 的扫描目录。

## Composer 如何根据类名查找到文件的？

查找顺序是 classmap -> psr4 -> psr0，如图：

![image](http://note.youdao.com/yws/res/13479/D904351190A94C9CBB1F74AF7A982A0A)

源代码 `vendor/composer/ClassLoader.php` 如下：

```php
public function findFile($class)
{
    // class map lookup
    if (isset($this->classMap[$class])) {
        return $this->classMap[$class];
    }

    if ($this->classMapAuthoritative || isset($this->missingClasses[$class])) {
        return false;
    }

    if (null !== $this->apcuPrefix) {
        $file = apcu_fetch($this->apcuPrefix.$class, $hit);
        if ($hit) {
            return $file;
        }
    }

    $file = $this->findFileWithExtension($class, '.php');

    // Search for Hack files if we are running on HHVM
    if (false === $file && defined('HHVM_VERSION')) {
        $file = $this->findFileWithExtension($class, '.hh');
    }

    if (null !== $this->apcuPrefix) {
        apcu_add($this->apcuPrefix.$class, $file);
    }

    if (false === $file) {
        // Remember that this class does not exist.
        $this->missingClasses[$class] = true;
    }

    return $file;
}
```

其中 PSR-4 的加载方法 `findFileWithExtension` 代码如下：

```php
private function findFileWithExtension($class, $ext)
{
    // PSR-4 lookup
    $logicalPathPsr4 = strtr($class, '\\', DIRECTORY_SEPARATOR) . $ext;

    $first = $class[0];
    if (isset($this->prefixLengthsPsr4[$first])) {
        $subPath = $class;
        while (false !== $lastPos = strrpos($subPath, '\\')) {
            $subPath = substr($subPath, 0, $lastPos);
            $search = $subPath . '\\';
            if (isset($this->prefixDirsPsr4[$search])) {
                $pathEnd = DIRECTORY_SEPARATOR . substr($logicalPathPsr4, $lastPos + 1);
                foreach ($this->prefixDirsPsr4[$search] as $dir) {
                    if (file_exists($file = $dir . $pathEnd)) {
                        return $file;
                    }
                }
            }
        }
    }

    // ....
}
```

PSR-4 找文件的大致流程是从尾部开始倒着切割类名和命名空间，依次去 `autoload_psr4.php` 里匹配找出指定命名空间对应的 `src` 目录，然后把类名拼接在 `src` 目录后，就是完整的文件路径。

例如 `composer.json` 中 PSR-4 规则定义为：

```json
{
    "autoload": {
        "psr-4": {
            "App\\": "application/",
            "App\\Models\\" : "application_models/" # 子目录可以另立山头，不一定要放在 app/ 目录里
        }
    }
}
```

那么类 `\App\Controller\Foo\BarController` 查找流程是：

1. 先找 `autoload.psr-4` 里有没有定义 `\App\Controller\Foo\` 对应的目录
2. 没有的话，继续找有没有定义 `\App\Controller\` 对应的目录，一直找到 `\App` 目录
3. 然后把目录 `\App` 切割出来，其余部分 `Controller\Foo\BarController` 即类名
4. 拼接成最终的文件路径：`application/类名.php`（须把类名中的反斜杠 `\\` 替换为 `DIRECTORY_SEPARATOR`）

### 生产服加载优化

综上所述，ClassMap 的查找是最高效的，但缺点是每次有新增的类，都得通过 `composer dump-autoload` 重新生成，开发时不方便。而 PSR-4 虽然查找遍历灵活，但查找起来运算较多，还有 `file_exists` 等 IO 操作，总体效率有待加强。

那么生产环境在确定文件不会有动态新增的前提下，我们可以这样优化：

```bash
composer dump-autoload -o 或者 --optimize
```

这条命令的作用是扫描 `composer.json` 设置的 PSR-4/0 对应目录下所有类文件，把类名和文件路径都冗余记录在 `autoload_classmap.php` 文件里，以最简单粗暴的方式定位到类所在的文件，内容如下：

```php
$vendorDir = dirname(dirname(__FILE__));
$baseDir = dirname($vendorDir);

return array(
    'App\\Models\\Article' => $baseDir . '/app/models/Article.php',
    'App\\Controllers\\BaseController' => $baseDir . '/app/controllers/BaseController.php',
    'App\\Controllers\\HomeController' => $baseDir . '/app/controllers/HomeController.php',
);
```

## 四合一文件 autoload_static.php 的作用

PHP 5.6 以后，为了优化加载大数组，Composer 把上述四个文件合并成了一个 `autoload_static.php` 文件。

> Optimized the autoloader initialization using static loading on PHP 5.6 and above, this reduces the load time for large classmaps to almost nothing

### 为什么要定义 composerRequire 这个方法？

为了隔离作用域，防止变量被污染：
想象一下，如果有人在 autoload_files 中的文件中写了 $this 或者 self 那就屎了。

### composerRequire 里为什么用的是 require 而不是 require_once？

因为 Composer 的开发者认为 `require_once` 效率低下，而且认为 `vendor/autoload.php` 为第一等公民，不论什么框架，都必须在入口第一行就引入。

所以 `require` 足以满足绝大多数场景，后面作者又为了满足避免重复引入的需求，增加了 `$GLOBALS` 全局数组来做去重，他觉得这样仍然比 `require_once` 靠谱。

<https://github.com/composer/composer/pull/4186>

## 参考文章

- [PHP PSR-4 自动加载代码赏析](https://www.cnblogs.com/wangmy/p/6692970.html)
- [PSR-4 规范：自动加载](https://www.cnblogs.com/huanxiyun/articles/6555942.html)
- [PHP 闭包绑定 Closure::bindTo](http://php.net/manual/zh/closure.bindto.php)
- [Laravel 学习笔记之 Composer 自动加载](https://www.cnblogs.com/xiaoqian1993/p/6541992.html)
- [Composer 自动加载原理 2017.03](https://blog.csdn.net/u012129607/article/details/65935556)
- [深入 Composer autoload](https://laravel-china.org/topics/1002/deep-composer-autoload)
