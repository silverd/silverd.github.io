---
layout: post
category: ['心得']
title: 从七牛同步备份资源到阿里云OSS
---

# 先下载并解压

    wget http://oss.aliyuncs.com/import-service-package/ossimport4linux.zip
    unzip ./ossimport4linux.zip -d /root/aliyun-oss

# 修改配置文件

    vim /root/aliyun-oss/conf/sys.properties
    workingDir=/root/aliyun-oss
    slaveUserName=
    slavePassword=
    privateKeyFile=
    slaveTaskThreadNum=60
    slaveMaxThroughput(KB/s)=100000000
    slaveAbortWhenUncatchedException=false
    dispatcherThreadNum=5

# 新增任务配置文件（按69发布机上的样例填写）

    vi /root/aliyun-oss/stay-user.cfg
    vi /root/aliyun-oss/stay-event.cfg

# 开始守护进程

    nohup java -jar /root/aliyun-oss/bin/ossimport2.jar -c /root/aliyun-oss/conf/sys.properties start > /root/aliyun-oss/logs/ossimport2.log 2>&1 &

# 提交新的任务

    java -jar /root/aliyun-oss/bin/ossimport2.jar -c /root/aliyun-oss/conf/sys.properties submit /root/aliyun-oss/stay-event.cfg
    java -jar /root/aliyun-oss/bin/ossimport2.jar -c /root/aliyun-oss/conf/sys.properties submit /root/aliyun-oss/stay-user.cfg

# 重置任务进度

    java -jar /root/aliyun-oss/bin/ossimport2.jar -c /root/aliyun-oss/conf/sys.properties clean stay-event
    java -jar /root/aliyun-oss/bin/ossimport2.jar -c /root/aliyun-oss/conf/sys.properties clean stay-user

# 查看任务执行状态

    java -jar /root/aliyun-oss/bin/ossimport2.jar -c /root/aliyun-oss/conf/sys.properties stat detail

如需要开启OSS的图片处理服务，需要开通CDN域名，否则浏览器打开会直接下载。

官方文档：

- <https://help.aliyun.com/document_detail/oss/utilities/oss-import2/ossimport2_user_guide_for_linux.html?spm=5176.2060224.101.14.SeboT4>