---
layout: post
category: ['LAMP']
title: PHP Composer 使用笔记
---

### 只想更新某个特定的库，不想更新它的所有依赖
composer update foo/bar

### 手动改了 composer.json，只想刷新下 composer.lock
composer update nothing 或者 composer update --lock

### 优化自动加载，生成类名&文件路径的映射关系
composer dump-autoload --optimize

### 软件包的版本限制

| 规范 | 示例 | 描述 |
| -- | -- | -- |
| 确切版本 | 1.0.2 | 软件包的确切版本。 |
| 范围 | >=1.0>=1.0 <2.0>=1.0 <1.1  | 比较运算符可以指定有效版本的范围。有效的运算符是 >、>=、<、<= 和 | !=。可以定义多个范围，而且默认情况下按照 AND 处理，或者用双竖线 (||) 分开它们，则作为一个 OR 运算符。 |
| 连字符范围 | 1.0 - 2.0 | 创建一个包容性的版本集。 |
| 通配符 | 1.0.* | 带有 * 通配符的模式。1.0.* 相当于 >=1.0 <1.1。 |
| 波浪运算符 | ~1.2.3 | “下一个重要版本”：允许最后一位数字增加，因此变得和 >=1.2.3 <1.3.0 一样。允许最后一位数字增加。 |
| ^运算符 | ^1.2.3 | “下一个重要版本”：类似于波浪线运算符，但假设语义版本和直到下一个主要版本的所有变更都应该被允许，因此变得和 >=1.2.3 <2.0 | 一样。 |

参考文档：

- <http://www.phpcomposer.com>
- <http://docs.phpcomposer.com/00-intro.html>
- <https://packagist.org>

