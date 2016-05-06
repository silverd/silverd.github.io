---
layout: post
category: ['心得']
title: 搭建 Github 博客小记
---

# 搭建小记

终于是把 Github 博客搭建起来了，第一次用 Markdown 写文章，记录一下过程，也不枉白折腾这几天。

前几个月听孙大力同学说起 Markdown 这东西好酷好炫，我当时还没什么感觉，认为只是一个语法转换器，就像以前BBS发帖的UBB代码一样。这几天我才知道，原来 Markdown 在程序员的世界里已经风靡了好多年，就像 Github 的 Readme.md 就是这个语法，我 ..... 我竟然不知道，我实在太落伍了，赶紧动手看看吧。

## 准备编辑器

### 1. Sublime 安装 **Markdown** 编辑插件

我用的是一款叫 MarkdownEditing 的插件，它可以让你在 Sublime 里写 Md 格式文件时有部分的所见所得的功能，前提是先要保存为 md 后缀的文件。

另外一个插件叫 MarkdownPreview，可以直接把 md 转换为 html 格式。

### 2. 学习 Markdown 的语法

其实 Markdown 语法特别简单，也就十几种，更多的[请猛戳这里](http://wowubuntu.com/markdown/)

### 3. 学习 Jeklly 的语法

Jekyll 是一款 Github 自带的页面转换器，相当于是我们本地按照他的语法和规则写好代码，提交后，GitHub 会自动运行 Jeklly 把我们的代码转换成可读的 HTML

它的中文官网在这里：<http://jekyllcn.com/>
一些约定的文件位置、文件名规则、系统变量[详情](http://jekyllrb.com/docs/variables/)、判断的写法、循环的写法，文档里都有写，或者谷歌搜索。

基本文件夹结构如下：

<pre><code class="nohighlight">
|-- _config.yml
|-- _includes
|-- _layouts
|   |-- default.html
|   |-- post.html
|-- _posts
|   |-- 2007-10-29-why-every-programmer-should-play-nethack.textile
|   |-- 2009-04-26-barcamp-boston-4-roundup.textile
|-- index.html
</code></pre>

## 构建环境

### 1. 第1种机制，让 silverd.github.io 为博客地址

`本意是针对个人或组织提供的页面`

在 GitHub 里新建一个名称为 **silverd.github.io** 的版本库（系统约定，不能改）
然后本地检出，往它的 master 分支里提交代码。

目前我采用的就是这种机制，缺点是整个项目就这能有一个主页。
要注意的是 _config.yml 里的 baseurl 要设为根目录 /

### 1. 第2种机制，让 silverd.github.io/blog 为博客地址

`本意是针对 Project 提供的项目主页`

在 GitHub 里新建一个名称为 **blog** 的版本库（相当于二级目录）
然后本地检出，往它的 gh-pages 分支里提交代码。

这里要注意 _config.yml 里的 baseurl 要设为根目录 /blog，同时页面中引入的一些 css/js 的路径，也必须为 /blog 或者直接写相对路径

## 主题风格

博客的页面一定要简单明晰，因为关键是内容，所以我想要一款清新大气的，找了一圈，这款还算不错，感谢作者，想要的同学可以 fork 他：

- **Download: [Jekyll Light](https://github.com/pexcn/Jekyll-Light/releases)**
- **Source: [GitHub](https://github.com/pexcn/Jekyll-Light)**
- **DEMO: [Pexcn Blog](http://pexcn.tk)**

## 评论系统

使用第三方评论系统，国内的有 duoshuo，国外的有 disqus。
原理都很简单，就是用 js 生成一个 iframe 内嵌第三方的评论页，独立标识为当前页面的 windows.location.href

这些让我想起了3年前自己写的享乐SNS通用评论回复组件，原来小功能还可以做这么大。

## 独立域名绑定

在项目根目录建立一个 CNAME 文件（全大写），里面内容为 `silverd.cn`，不要多余文字，而且只能填一个域名

### 如果是顶级域名

把 silverd.cn 绑定A记录到 192.30.252.153 和 192.30.252.154（IP是官方提供的，可能有变化，[点这里查看最新](https://help.github.com/articles/my-custom-domain-isn-t-working/)）

### 如果是二级域名
把 blog.silverd.cn 绑定CNAME到 silverd.github.io

## TortoiseGit 的使用

[Windows 上使用 Github 手记](http://www.oschina.net/question/54100_33045?sort=time)

简而言之，先安装 msysgit，再安装 TortoiseGit

### 提交免输入密码的办法

1. 开始菜单-打开PuTTYgen（密钥生成器），鼠标滑动，生成秘钥并保存为 ppk
2. 把生成的公钥贴到 GitHub 网站上去 Account Setting -> SSH Public Key
3. 开始菜单-打开Pageant，把刚才保存的 ppk 添加进去
4. 重新 git clone 一份代码，勾上 Auto load putty key

## 参考文章

- [搭建一个免费的，无限流量的Blog----github Pages和Jekyll入门](http://www.ruanyifeng.com/blog/2012/08/blogging_with_jekyll.html)
- [Markdown 语法说明(简体中文版)](http://wowubuntu.com/markdown/)
- [这篇比较详细 -- 使用Github Pages建独立博客](http://beiyuu.com/github-pages/)



