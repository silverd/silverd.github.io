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

- 计算属性的奥秘 computed <http://vuejs.org.cn/guide/reactivity.html#计算属性的奥秘>
- 组件 keep-alive 的使用
- 组件 attach/ready 的执行时机
- AJAX POST CORS 跨域（withCredentials）
- 全局 Preloader 的实现
- 过渡动画 transition 的使用
- webpack 的加载路径（参见 webpack.base.conf 中的 resolve）
- 让文本框聚焦需要使用 v-el 属性
- vm.$nextTick 的使用 <http://vuejs.org.cn/guide/reactivity.html#异步更新队列>
- 微信 iOS 修改网页标题的黑科技
- 微信 wx.config 代码位置
- 微信安卓版不能正确执行字符串的 includes/startWith 等 ES6 的新方法

## NPM 相关

package.json 中 dependencies 和 devDependencies 区别

- dependencies 正常运行该包时所需要的依赖项
- devDependencies 开发的时候需要的依赖项，比如一些单元测试的包

默认会安装两种依赖，如果你只是单纯的使用这个包而不需要进行一些改动测试之类的，可以使用

    npm install

只安装dependencies而不安装devDependencies。

    npm install --production

如果你是通过以下命令进行安装

    npm install XXX

那么只会安装 dependencies，如果想要安装 devDependencies，需要输入

    npm install XXX --dev

`-save` 和 `-save-dev` 可以省掉你手动修改 package.json 文件的步骤。

- npm install XXX -save 自动把模块和版本号添加到dependencies部分
- npm install XXX -save-dev 自动把模块和版本号添加到devdependencies部分

## 观[《TalkingCoder@Vue+Webpack直播内容分享》](https://www.talkingcoder.com/article/live1)的后续补充：

#### Vue

- Vue.config.debug（在调试模式中，打印所有警告的栈追踪，所有的锚节点以注释节点显示在 DOM 中）
- 异步组件 component resolve <http://vuejs.org.cn/guide/components.html#异步组件>
- 双向绑定的原理 <http://vuejs.org.cn/guide/reactivity.html#如何追踪变化>
- vm.$emit（父组件向指定的一个子组件触发事件）<http://vuejs.org.cn/api/#vm-emit>
- this.$refs（在父组件上注册一个子组件的索引，便于直接访问）
- this.$els（相当于 document.getElementById，获取页面上指定的DOM元素，例如修改 innerHTML 或光标自动聚焦等场景）
- slot 插槽的作用
- 循环里删除指定一行的小技巧： this.itemList.$remove(item)
- 路由 hashbang 和 HTML5 history 模式的各自使用场景区别和优劣势
- 组件里引入一个 CSS 的几种写法以及区别：
    - `<style> @import 'a.css' </style>`
    - `<script> import 'a.css' </script>`
    - `<style src="a.css"></style>`
- css scoped 的表现
- 组件里 ready 和 attached 的区别（组件的生命周期 beforeDestroy）
- 自己开发的组件，如何发布到 npmjs？

#### Webpack

- Webpack 和 gulp/grunt 的区别（gulp 只做合并压缩的事，webpack 除了做 gulp 的事外，还会做代码抽离、模块化、依赖管理）
- package.json 中 dependencies 和 devDependencies 的区别
- config.devtool = '#source-map' 的作用和优化
- 优化 webpack 打包后的文件大小
- 热刷新 hot-reload 的原理和注意点（只有子组件可以热刷，css文件无法热刷）
