---
layout: post
category: ['NoSQL', '复习', '笔记']
title: Memcached 的一些小结
---

阶段一哈希（客户端做，负责找出目标服务器）

阶段二哈希（服务端运算，负责根据键找出值）

memcache key 的长度最大为 250 字符，value 长度最大为1M

### Memcache VS MySQL Query Cache

1. MySQL Query Cache 是表级别，只要表中数据有变化，跟表有关的所有 Query Cache 都被清除
2. Memcache 更加灵活，除了缓存 SQL 结果集外，还可以缓存更丰富的数据集合（例如玩家名片信息）
3. Memcache 集群水平扩展成本低，要加内存，只需要加一堆廉价PC机，
4. MySQL Query Cache 只能缓存到本机，如果加内存，成本高，扩展不方便