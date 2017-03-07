---
layout: post
category: ['Git', '笔记']
title: Git SubModule
---

### 添加子模块

进入某个项目，执行：

    git submodule add https://git.coding.net/Grampus/hmb_yaf_framework.git system

完成后通过 `git status` 会发现多了两个东东：

    new file:   .gitmodules
    new file:   system

其中 `.gitmodules` 文件的内容如下：

    [submodule "hmb_yaf_framework"]
        path = system
        url = https://git.coding.net/Grampus/hmb_yaf_framework.git

保存并推送：

    git commit -a -m '增加子模块'
    git push -u origin master

### 更新子模块

    cd system && git pull origin master

回到上级目录 git status，会显示：

    modified:   system (new commits)

为什么子模块 `system` 目录会有一个新变更？

其实，Git 在顶级项目中记录了一个子模块的提交日志的指针，用于保存子模块的提交日志所处的位置，以保证无论子模块是否有新的提交，在任何一个地方克隆下顶级项目时，各个子模块的记录是一致的。作用类似于 composer.lock 或者 yarn.lock，避免因为所引用的子模块不一致导致的潜在问题。如果我们更新了子模块，我们需要把这个最近的记录提交到版本库中，以方便和其他人协同。

提交这个子模块版本锁：

    git commit -am "更新子模块"
    git push origin master

### 批量更新所有子模块（强烈推荐）

    git submodule foreach git pull

### 如何克隆含子模块的仓库？

方式1：

    git clone git@github.com:diguage/parent.git
    cd parent
    git submodule update --init --recursive
    cd system && git checkout master && cd ..

方式2：

    git clone --recursive git@github.com:diguage/parent.git
    cd parent/system && git checkout master && cd ..

参数 `--recursive` 或 `--recurse-submodules` 的意思是：

可以在 clone 项目时同时 clone 关联的 submodules。

After the clone is created, initialize all submodules within, using their default settings. This is equivalent to running git
submodule update --init --recursive immediately after the clone is finished. This option is ignored if the cloned repository
does not have a worktree/checkout (i.e. if any of --no-checkout/-n, --bare, or --mirror is given)

注意：子模块缺省 Not currently on any branch 不在任何分支上，需要手动 gco master

### 删除子模块

    git rm -r <SubModuleName>

例如：

    git rm -r system
    git commit -a -m "删除子模块"
    git push origin master

### 参考文章

- <http://www.kafeitu.me/git/2012/03/27/git-submodule.html>

