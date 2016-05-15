---
layout: post
category: ['Javascript']
title: VueJS 爬坑笔记
---

Mark神塞，90后技术极客直男，通晓前端技术，在他的推荐下，我接触了vue。
起初吸引我的是vue的小巧轻快，以及优雅的数据绑定操作，但随着学习的深入，发现vue完全是有别于以往前端开发的架构和流程，作为十几年的老司机，耳目一新，技术的演进真是令人兴奋。
但目前vue国内文档和生态社区尚不完整，有问题基本搜索不到。好在QQ群有近500多名先行者，很多问题在不断地虚心讨教后基本可以得到解决。

爬坑笔记其实不算笔记，一切尽在代码中吧：

Repo: <https://github.com/silverd/staylife>

Demo: <http://m.staylife.cn>

项目采用 vue-cli 的 webpack 标准模板构建，使用到的主要社区组件有：

- vue-router
- vue-resource
- vue-infinite-scroll
- vux （weui）
- sass-loader
- vue-lazyload
- vue-spinner （很赞的 loading 组件）
- locutus （经典的 phpjs.org 的一些函数库）

几个可以特别指出的点：

- 神奇的计算属性 computed
- 组件 keep-alive 的使用
- 组件 attach/ready 的执行时机
- AJAX POST CORS 跨域（withCredentials）
- 全局 Preloader 的实现
- 过渡动画 transition 的使用
- webpack 的加载路径（参见 webpack.base.conf 中的 resolve）
- 让文本框聚焦需要使用 v-el 属性
- vm.$nextTick 的使用
- 微信 iOS 修改网页标题的黑科技
- 微信 wx.config 代码位置
- 微信安卓版不能正确执行字符串的 includes/startWith 等 ES6 的新方法
