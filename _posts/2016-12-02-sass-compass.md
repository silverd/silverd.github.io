---
layout: post
category: ['前端', '笔记']
title: SASS 和 Compass 用法小记
---

## 安装

    # 更新 RubyGems
    sudo gem update --system

    sudo gem install -n /usr/local/bin sass
    sudo gem install -n /usr/local/bin compass

注意务必增加 `-n /usr/local/bin`，否则安装时会遇到权限问题：

    ERROR:  While executing gem ... (Errno::EPERM)
    Operation not permitted - /usr/bin/sass

## 初始化

在父目录执行：

    compass create myproject
    cd myproject

或者进入已有目录后执行：

    compass create init

会生成了一个 config.rb 和两个目录：

    |-- config.rb       --- 配置文件
    |-- sass/           --- 存放 sass 源文件
    |-- stylesheets/    --- 编译后的 css 文件

配置文件 `config.rb` 的设置详见[官方文档](http://compass-style.org/help/documentation/sass-based-configuration-options/)

## 编译

下划线开头的文件（例如 `_common.scss`）表示局部文件，只能被别的 scss 引用包含。本身不会被编译成单独的 scss 文件。

手动编译：

    compass compile [path/to/project]

自动检测文件变化并自动编译：

    compass watch [path/to/project]

生产环境需要压缩后的 css 文件，去除注释空行等：

    compass compile --output-style compressed

Compass 只编译发生变动的文件，如果你要重新编译未变动的文件，使用 `--force` 参数：

    compass compile --force

也可以通过指定环境配置，智能判断编译模式，修改 `config.rb`：

    environment = :development
    output_style = (environment == :production) ? :compressed : :expanded

然后用以下命令编译：

    compass compile -e production --force

## 内置模块

Compass 采用模块结构，内置五个模块。[官网文档](http://compass-style.org/reference/compass)和[最佳实践](http://compass-style.org/help/tutorials/best_practices/)

- reset
- css3
- layout
- typography
- utilities

如何在自己的 scss 中引用？

    @import "compass/reset";

除了模块，Compass 还提供一系列函数。比如 `inline-image()` 可以将图片转为 data 协议的数据。

    @import "compass";
    .icon { background-image: inline-image("icon.png"); }

编译后得到

    .icon { background-image: url('data:image/png;base64,iBROR...QmCC');}

函数与 mixin 的主要区别是，不需要使用 `@include` 命令，可以直接调用。

参考文章：

* Website: <http://compass-style.org/>
* Sass: <http://sass-lang.com>
* Community: <http://groups.google.com/group/compass-users/>
* 阮老师：Compass用法指南 <http://www.ruanyifeng.com/blog/2012/06/sass.html>
* 阮老师：SASS用法指南 <http://www.ruanyifeng.com/blog/2012/11/compass.html>
