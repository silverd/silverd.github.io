---
layout: post
category: ['LAMP']
title: CentOS 安装 Java
---

下载安装 JDK [查看官方最新版本](http://www.oracle.com/technetwork/indexes/downloads/index.html#java)

    wget wget http://download.oracle.com/otn-pub/java/jdk/8u73-b02/jdk-8u73-linux-x64.rpm?AuthParam=1456243902_0c6c969e56ef0f0d93e786fc8691d178
    rpm -ivh *.rpm

增加全局变量

    vi /etc/profile

在底部增加

    JAVA_HOME=/usr/java/latest
    CLASSPATH=$JAVA_HOME/lib:$JAVA_HOME/jre/lib
    PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin
    export PATH CLASSPATH JAVA_HOME

使立即生效

    source /etc/profile

查看系统环境状态

    echo $PATH