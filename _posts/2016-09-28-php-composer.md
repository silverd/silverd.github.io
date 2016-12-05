---
layout: post
category: ['LAMP', '笔记']
title: PHP Composer 使用指南
---

Composer 是 PHP 的一个依赖管理工具。类似 Node 的 npm/yarn。以下记录一些注意点，详细的文档这里说得比较清楚：<http://docs.phpcomposer.com/>

## 安装

    brew install homebrew/php/composer

    或

    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer

    # 启用 Packagist 中国镜像
    composer config -g repo.packagist composer https://packagist.phpcomposer.com

### 第一次使用（创建 composer.json）

    # 它会以交互方式填写信息，同时聪明的使用一些默认值
    composer init

### 根据 composer.json 拉取包

定义好包版本后，别的同学可以直接通过以下命令拉取（相当于 Node 的 `npm install`）

    composer install

执行后会生成 vendor 文件夹（相当于 `node_modules`）和一个 composor.lock 锁文件（这点比 npm 高级，作用类似于 yarn 里的 yarn.lock 文件）

### composor.lock 锁文件的作用

在第一次安装依赖后，Composer 将把安装时精确的版本号列表写入 composer.lock 文件。
别的同学 composer install 时将会检查锁文件是否存在，如果存在，它将下载指定的版本，而忽略 composer.json 文件中的定义。这样保证任何人都将下载与指定版本完全相同的依赖。

如果不存在 composer.lock 文件，Composer 将读取 composer.json 并创建锁文件。
所以 composer.lock 一定要和 composer.json 一起提交到项目的 Git 代码仓库中。

### 安装指定包并自动写入 composer.json

    composer require foo/bar

### 更新依赖版本

根据 composer.json 中的定义升级、更新各依赖版本，并重建 composer.lock 文件。

    # 更新所有
    composer update

    # 更新某个特定的库
    composer update foo/bar

### 手动改了 composer.json，只想刷新下 composer.lock

    composer update nothing 或者 composer update --lock

### 优化自动加载，生成类名&文件路径的映射关系

    composer dump-autoload --optimize

## 软件包的版本号

假设 composer.json 中引入的 monolog 版本指定为 1.0.*。这表示任何从 1.0 开始的开发分支，它将会匹配 1.0.0、1.0.2 或者 1.0.20。

版本约束可以用几个不同的方法来指定。

![](/res/img/in_posts/composer.png)

### 下一个重要版本（波浪号运算符）

~1.2 相当于 >=1.2 且 <2.0。

~1.2.3 相当于 >=1.2.3 且 <1.3。

通俗地说，~ 意思是只允许版本号的最后一位数字上升。

注意： 虽然 2.0-beta.1 严格地说是早于 2.0，但是，根据版本约束条件，例如 ~1.2 却不会安装这个版本。就像前面所讲的 ~1.2 只意味着 .2 部分可以改变，但是 1. 部分是固定的。

关于版本的定义详细参见：<http://docs.phpcomposer.com/01-basic-usage.html#Package-Versions>

### 使用私有资源库

Composer 默认是使用 Packagist <https://packagist.org> 上的资源。
也可以让你使用你 GitHub 和 BitBucket 上的私人代码库进行工作：

    {
        "require": {
            "vendor/my-private-repo": "dev-master"
        },
        "repositories": [
            {
                "type": "vcs",
                "url":  "git@bitbucket.org:vendor/my-private-repo.git"
            }
        ]
    }

参考文档：

- <http://www.phpcomposer.com>
- <http://docs.phpcomposer.com>
- <https://packagist.org>

