---
layout: post
category: ['LAMP']
title: Linux 学习笔记：输出日志 >/dev/null 2>&1
---

1. 标准输入 stdin 文件描述符为 0
2. 标准输出 stdout 文件描述符为 1
3. 标准错误 stderr 文件描述符为 2
4. /dev/null 表示空设备，相当于垃圾桶

### 2>1 与 2>&1 的区别

- 2>1  把标准错误 stderr 重定向到文件 1 中
- 2>&1 把标准错误 stderr 重定向到标准输出 stdout

### 各种举例说明

假设有脚本 test.sh，内容如下：

t 是一个不存在的命令，执行脚本进行下面测试。

    # cat test.sh
    t
    date

标准输出重定向到 log，错误信息输出到终端上，如下：

    # ./test.sh > log
    ./test.sh: line 1: t: command not found

    # cat log
    Thu Mar 23 22:53:02 CST 2016
   
删除 log 文件，重新执行，这次是把标准输出定向到 log，错误信息定向到文件 1

    # ./test.sh > log 2>1
    # cat log
    Thu Mar 23 22:56:20 CST 2016
    # cat 1
    ./test.sh: line 1: t: command not found

把标准输出重定向到 log 文件，把标准错误重定向到标准输出

    # ./test.sh > log 2>&1
    #
    # cat log
    ./test.sh: line 1: t: command not found
    Thu Mar 23 22:58:54 CST 2016

把错误信息重定向到空设备

    # ./test.sh 2>/dev/null
    Thu Mar 23 23:01:07 CST 2016
   
把标准输出重定向到空设备

    # ./test.sh >/dev/null
    ./test.sh: line 1: t: command not found

把标准输出和标准错误全重定向到空设备
   
    #./test.sh >/dev/null 2>&1
   
