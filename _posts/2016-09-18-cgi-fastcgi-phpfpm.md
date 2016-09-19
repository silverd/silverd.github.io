---
layout: post
category: ['LAMP']
title: 什么是 CGI/FastCGI/PHP-FPM？
---

## 什么是 CGI？

CGI 全称是“公共网关接口”(Common Gateway Interface)，定义了一套协议。HTTP服务器与你的或其它机器上的程序进行“交谈”的一种工具，其程序须运行在网络服务器上。
CGI 可以用任何一种语言编写，只要这种语言具有标准输入、输出和环境变量。如 php，perl，tcl 等

Nginx 只是内容的分发者。比如，如果请求 index.html，那么 Nginx 会去文件系统中找到这个文件，发送给浏览器，这里分发的是静态数据。
如果现在请求的是 index.php，根据配置文件，nginx知道这个不是静态文件，则启动对应的CGI程序，找到PHP解析器来处理（PHP解析器会解析php.ini文件，初始化执行环境，然后处理请求，再以规定CGI规定的格式返回处理后的结果，退出进程。Nginx 再把结果返回给浏览器）。

Nginx 会传哪些数据给PHP解析器呢？URL+QueryString+PostData+HttpHeader。

好的，CGI就是规定要传哪些数据、以什么样的格式传递给后方处理这个请求的一套协议。

## 什么是 FastCGI

FastCGI 相当于定义了`一套管理办法`。FastCGI 是一套跟语言无关的、可伸缩架构的CGI开放扩展，其主要行为是`将CGI解释器进程保持在内存中并因此获得较高的性能`。

##### 1. CGI程序的性能问题在哪呢？
CGI解释器的反复加载是CGI性能低下的主要原因，如果CGI解释器保持在内存中并接受 FastCGI 进程管理器调度，则可以提供良好的性能、伸缩性、Fail- Over特性等等。即一个常驻(long-live)型的CGI，它可以一直执行着，只要激活后，不会每次都要花费时间去fork一次 (这是CGI最为人诟病的fork-and-execute 模式)。它还支持分布式的运算，即 FastCGI 程序可以在网站服务器以外的主机上执行并且接受来自其它网站服务器来的请求。

##### 2. FastCGI 如何优化性能？
FastCGI 会先启一个master，解析配置文件，初始化执行环境，然后再启动多个worker。当请求过来时，master会传递给一个worker，然后立即可以接受下一个请求。这样就避免了重复的劳动，效率自然是高。而且当worker不够用时，master可以根据配置预先启动几个worker等着；当然空闲worker太多时，也会停掉一些，这样就提高了性能，也节约了资源。master和children之间通过`共享内存`来共享配置文件

## 什么是 PHP-FPM？

FastCGI 是一个协议，PHP-FPM 实现了这个协议。
PHP-FPM 是一个 PHP FastCGI 管理器，可以有效控制内存和进程、平滑重载PHP配置，已被PHP官方收录。在 ./configure 的时候带 --enable-fpm 参数即可。

## 什么是 PHP-CGI？

PHP-CGI 与 PHP-FPM 一样，是 PHP 自带的FastCGI管理器，PHP-CGI 的问题在于：

1. PHP-CGI 变更 php.ini 配置后需重启 PHP-CGI 才能生效，不可以平滑重启。
2. 直接杀死 PHP-CGI 进程，php 就不能运行了。（PHP-FPM 和 Spawn-FCGI 就没有这个问题，守护进程会平滑从新生成新的子进程。）

针对 PHP-CGI 的不足，PHP-FPM 应运而生。

## 什么是 Spawn-FCGI？

Spawn-FCGI 也是一个FastCGI管理器，它是 lighttpd 中的一部份。
PHP-FPM 控制的进程CPU回收的速度比较慢，内存分配的很均匀。
Spawn-FCGI 控制的进程CPU下降的很快，而内存分配的比较不均匀。有很多进程似乎未分配到，而另外一些却占用很高。导致了总体响应速度的下降。

参考文章

- <https://segmentfault.com/q/1010000000256516>
- <http://www.mike.org.cn/articles/what-is-cgi- FastCGI -PHP-FPM -spawn-fcgi>