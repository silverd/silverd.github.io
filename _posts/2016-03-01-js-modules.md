---
layout: post
category: ['Javascript']
title: 了解Javascript模块化开发
---

转贴自：<https://www.markdream.com/technologies/programs/understanding-of-javascript-module-development.shtml>

小A是某个创业团队的前端工程师，负责编写项目的Javascript程序。

## 全局变量冲突

根据自己的经验，小A先把一些常用的功能抽出来，写成函数放到一个公用文件base.js中：

    var _ = {
        $: function(id) { return document.getElementById(id); },
        getCookie: function(key) { ... },
        setCookie: function(key, value) { ... }
    };

小A把这些函数都放在_对象内，以防过多的全局变量造成冲突。他告诉团队的其他成员，如果谁想使用这些函数，只要引入base.js就可以了。

小C是小A的同事，他向小A反映：自己的页面引入了一个叫做underscore.js的类库，而且，这个类库也会占用_这个全局变量，这样一来就会跟base.js中的_冲突了。小A心想，underscore.js是第三方类库，估计不好改，但是base.js已经在很多页面铺开，不可能改。最后小A只好无奈地把underscore.js占用的全局变量改了。

此时，小A发现，把函数都放在一个名字空间内，可以减少全局变量冲突的概率，却没有解决全局变量冲突这个问题。

## 依赖

随着业务的发展，小A又编写了一系列的函数库和UI组件，比方说标签切换组件tabs.js，此组件需调用base.js以及util.js中的函数。

有一天，新同事小D跟小A反映，自己已经在页面中引用了tabs.js，功能却不正常。小A一看就发现问题了，原来小D不知道tabs.js依赖于base.js以及util.js，他并没有添加这两个文件的引用。于是，他马上进行修改：

    <script src="tabs.js"></script>
    <script src="base.js"></script>
    <script src="util.js"></script>

然而，功能还是不正常，此时小A教训小D说：“都说是依赖，那被依赖方肯定要放在依赖方之前啊”。原来小D把base.js和util.js放到tabs.js之后了。

小A心想，他是作者，自然知道组件的依赖情况，但是别人就难说了，特别是新人。

过了一段时间，小A给标签切换组件增加了功能，为了实现这个功能，tabs.js还需要调用ui.js中的函数。这时，小A发现了一个严重的问题，他需要在所有调用了tabs.js的页面上增加ui.js的引用！！！

又过了一段时间，小A优化了tabs.js，这个组件已经不再依赖于util.js，所以他在所有用到tabs.js的页面中移除了util.js的引用，以提高性能。他这一修改，出大事了，测试组MM告诉他，有些页面不正常了。小A一看，恍然大悟，原来某些页面的其他功能用到了util.js中的函数，他把这个文件的引用去掉导致出错了。为了保证功能正常，他又把代码恢复了。

小A又想，有没有办法在修改依赖的同时不用逐一修改页面，也不影响其他功能呢？

## 模块化

小A逛互联网的时候，无意中发现了一种新奇的模块化编码方式，可以把它之前遇到的问题全部解决。

在模块化编程方式下，每个文件都是一个模块。每个模块都由一个名为define的函数创建。例如，把base.js改造成一个模块后，代码会变成这样：

    define(function(require, exports, module) {
        exports.$ = function(id) { return document.getElementById(id); };
        exports.getCookie = function(key) { ... };
        exports.setCookie = function(key, value) { ... };
    });

base.js向外提供的接口都被添加到exports这个对象。而exports是一个局部变量，整个模块的代码都没有占用半个全局变量。

那如何调用某个模块提供的接口呢？以tabs.js为例，它要依赖于base.js和util.js：

    define(function(require, exports, module) {
        var _ = require('base.js'), util = require('util.js');
        var div_tabs = _.$('tabs');
        // .... 其他代码
    });

一个模块可以通过局部函数require获取其他模块的接口。此时，变量_和util都是局部变量，并且，变量名完全是受开发者控制的，如果你不喜欢_，那也可以用base：

    define(function(require, exports, module) {
        var base = require('base.js'), util = require('util.js');
        var div_tabs = base.$('tabs');
        // .... 其他代码
    });

一旦要移除util.js、添加ui.js，那只要修改tabs.js就可以了：

    define(function(require, exports, module) {
        var base = require('base.js'), ui = require('ui.js');
        var div_tabs = base.$('tabs');
        // .... 其他代码
    });

## 加载器

由于缺乏浏览器的原生支持，如果我们要用模块化的方式编码，就必须借助于一个叫做加载器（loader）的东西。

目前加载器的实现有很多，比如 RequireJs、SeaJs、LABJs

参考文章：

- <https://www.zhihu.com/question/20342350>