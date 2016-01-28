---
layout: post
title: PHP Composer 使用笔记
---

### 只想更新某个特定的库，不想更新它的所有依赖
composer update foo/bar

### 手动改了 composer.json，只想刷新下 composer.lock
composer update nothing 或者 composer update --lock

### 优化自动加载，生成文件路径地图
composer dump-autoload --optimize

参考文档：

- <http://www.phpcomposer.com>
- <http://docs.phpcomposer.com/00-intro.html>
- <https://packagist.org>