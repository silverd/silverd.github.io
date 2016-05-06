---
layout: post
category: ['MySQL']
title: MySQL 字段类型 varchar 和 text 类型的区别
---

# MySQL 字段类型 varchar 和 text 类型的区别

1. text 不允许有默认值，varchar允许有默认值
2. varchar 可以替代 tinytext
3. 如果存储的数据大于64K，就必须使用到 mediumtext/longtext
4. varchar(255+) 和 text 在存储机制是一样的
5. varchar(65535+) 和 mediumtext 在存储机制是一样的

需要特别注意varchar(255)不只是255byte ,实质上有可能占用的更多。

特别注意，varchar大字段一样的会降低性能，所以在设计中还是一个原则大字段要拆出去，主表还是要尽量的瘦小

参考原文：<http://wubx.net/varchar-vs-text/>