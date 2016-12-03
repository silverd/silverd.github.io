---
layout: post
category: ['复习', '笔记', 'LAMP']
title: PHP-FPM 的进程数动态和静态
---

# PHP-FPM 的进程数动态和静态

- pm = static
- pm.max_children：静态方式下开启的php-fpm进程数量
- pm.start_servers：动态方式下的起始php-fpm进程数量
- pm.min_spare_servers：动态方式下的最小php-fpm进程数量
- pm.max_spare_servers：动态方式下的最大php-fpm进程数量

### 1. 如果 pm=static，那么其实只有pm.max_children这个参数生效

系统会开启设置数量的php-fpm进程。

### 2. 如果 pm=dynamic，那么pm.max_children参数失效，后面3个参数生效。

系统会在php-fpm运行开始的时候启动pm.start_servers个php-fpm进程，然后根据系统的需求动态在pm.min_spare_servers和pm.max_spare_servers之间调整php-fpm进程数。

## 如何选择

事实上，跟Apache一样，运行的PHP程序在执行完成后，或多或少会有内存泄露的问题。这也是为什么开始的时候一个php-fpm进程只占用3M左右内存，运行一段时间后就会上升到20-30M的原因了。

- 内存紧张的机器或VPS，用动态的。
- 内存充裕的，完全可以用静态的，因为这样不需要进行额外的进程数目控制，会提高效率。因为频繁开关php-fpm进程也会有时滞。

## 并发量的估算

pm.max_children = 32G (机器物理内存) / 64MB (每个进程的 memory_limit) = 256

假设一个PHP请求耗费250ms，那一个进程1秒就可以处理4次请求

那一台32G的机器可支撑的QPS = 4 * pm.max_children = 2000~3000

## 带宽的预估

并发请求数 * 5K (单次请求耗费流量，单位字节) / 1000 * 8 = 带宽 (单位比特)

# 参考

[(总结)Nginx使用的php-fpm的两种进程管理方式及优化](http://www.ha97.com/4339.html)