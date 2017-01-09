---
layout: post
category: ['LAMP', '笔记']
title: PHP 中 ob_* 系列函数的一些理解
---

通常来说，ob_* 最常用的用法组合是这样：

    <?php

    ob_start();
    echo '...';
    $content = ob_get_contents();

    // 清除并关闭缓存，否则会输出到屏幕
    ob_end_clean();

    // 然后自由处理 $content ...

注：ob_end_* 必须在缓冲区内调用，即必须要有 ob_start 才能 ob_end_*。

### 输出的多级缓冲机制（ob_start 嵌套）

假设有代码如下：

    <?php

    ob_start();
    echo 'A' . PHP_EOL;
    ob_start();
    echo 'B' . PHP_EOL;
    ob_start();
    echo 'C' . PHP_EOL;
    ob_end_clean();
    ob_end_flush();
    ob_end_clean();

结果是什么没有输出，为什么？

每次 ob_start() 都会新建一个缓冲区，PHP 程序本身也有一个最终的输出缓冲区，我们把他叫做F。

步骤解释：

    // 初始 F:空

    // 新建缓冲区A
    // 此时缓存区内容为 F:空, A:空,
    ob_start();

    // 此时缓存区内容为 F:空, A:'level A'
    echo 'level A';

    // 新建缓冲区B
    // 此时缓存区内容为 F:空, A:'level A', B:空
    ob_start();

    // 此时缓存区内容为 F:空, A:'level A', B:'level B'
    echo 'level B';

    // 新建缓冲区C
    // 此时缓存区内容为 F:空, A:'level A', B:'level B', C:空
    ob_start();

    // 此时缓存区内容为 F:空, A:'level A', B:'level B', C:'level C'
    echo 'level C';

    // 缓冲区C被清空并关闭
    // 此时缓存区内容为 F:空, A:'level A', B:'level B'
    ob_end_clean();

    // 缓冲区B输出到上一级的缓冲区A并关闭
    // 此时缓存区内容为 F:空, A:'level A level B'
    ob_end_flush();

    // 缓冲区A被清空并关闭
    // 此时缓冲区A里的内容还没真正输出到最终的F中，因此整个程序也就没有任何输出
    ob_end_clean();

### flush 和 ob_flush 的区别

1、ob_flush 刷新 PHP 自身的缓冲区
2、flush 只有在 PHP 做为 Apache Module 安装时, 才有实际作用. 它是刷新 WebServer (Apache) 的缓冲区

正确使用俩者的顺序是：先 ob_flush，再 flush。

在其他 sapi 下，不调用 flush 也可以。但为了保证代码可移植性，建议配套使用。

### 完整的方法说明

PHP 官网文档：<http://php.net/manual/zh/ref.outcontrol.php>

| 方法 | 说明 |
| ---- | ---- |
| ob_start | 打开输出控制缓冲 |
| ob_clean | 清空（擦掉）输出缓冲区 |
| ob_flush | 冲刷出（送出）输出缓冲区中的内容 |
| ob_end_clean | ob_clean + 关闭输出缓冲 |
| ob_end_flush | ob_flush + 关闭输出缓冲 |
| ob_get_clean | ob_get_contents + ob_end_clean |
| ob_get_flush | ob_get_contents + ob_end_flush |
| ob_implicit_flush | 打开/关闭隐式刷送。建议关闭。开启相当于在每次 echo/print 后都自动调用 flush() |

参考文章：

- [鸟哥的《深入理解 ob_flush 和 flush 的区别》](http://www.laruence.com/2010/04/15/1414.html)
- <https://my.oschina.net/CuZn/blog/68650>
