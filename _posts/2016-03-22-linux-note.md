---
layout: post
category: ['LAMP', '笔记']
title: Linux 学习笔记
---

六年前的学习笔记（2010年）

### 终端语言乱码问题

设置语言包编码 `/etc/sysconfig/i18n`，同时结合 SecureCRT 的外观语言设置 UTF-8 和中文字体，可解决 SecureCRT 中文乱码问题。

### CentOS启动默认进入命令行界面（关闭X-Windows）

    vi /etc/inittab
    设置 id:3:initdefault: 编号

### 虚拟机三种上网方式的含义和区别

- NAT: 跟主机同一个IP，没有自己独立IP，主机与虚拟机之间不可互相通信；可以方便上外网。
- Host-Only: 跟主机构成一个私有的小局域网，有独立IP，但不能上外网（可研究共享主机Internet连接解决）
- Bridge: 和主机同级，加入到主机所在的大局域网内，有独立IP，可上外网，主机与虚拟机之间可相互通信。

### 一些命令

    # 精确查找文件[包括后缀]
    find / -name libmysqlclient.so

    # 模糊查找文件名，引号不可少
    find / -name 'libmysqlclient*'  

注意 find 、locate、whereis 的异同

### 查看 Linux 版本

    uname –a -s、lsb_release –a

### 查看文件夹容量大小

    du -sh dir_name/

### 目录操作

    cd - （减号），返回刚才的目录（refer）
    cd 空 <=> cd ~ 返回家目录

复制时强制覆盖(命令前面加斜杠)

    # \cp xxx xxx

后缀名 *.tar.gz 等价于 *.tgz

### Linux 访问光驱

挂载

    mkdir /mnt/cdrom
    mount -o ro /dev/cdrom /mnt/cdrom

卸载

    umount /mnt/cdrom

### 关闭 SELINUX

    vi /etc/sysconfig/selinux 或者（/etc/selinux/config）
    修改 SELINUX=enforcing 为 disabled

### 编译PHP参数串

    ./configure --prefix=/usr/local/php \
    --with-config-file-path=/usr/local/php/etc \
    --with-apxs2=/usr/local/apache/bin/apxs \
    --with-mysql=/usr --with-mysqli=/usr/bin/mysql_config \
    --with-libxml-dir=/usr \
    --with-zlib=/usr --with-zlib-dir=/usr \
    --with-iconv-dir=/usr/local \
    --with-curl=/usr/include/curl \
    --with-mcrypt=/usr/local \
    --with-mhash=/usr/local \
    --with-openssl=/usr \
    --with-xsl=/usr \
    --enable-mbstring \
    --enable-ftp \
    --enable-soap \
    --enable-sockets \
    --enable-fastcgi --enable-force-cgi-redirect --enable-fpm \
    --with-gd=/usr \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --with-freetype-dir=/usr \
    --enable-gd-native-ttf

颜色说明：
蓝色  php.ini 放置的路径，缺省是 `/usr/local/php/lib/php.ini`
红色  必须项目。注意，如以 Nginx + PHP-FPM 方式安装，则必须去除 `--with-apxs2=/usr/local/apache/bin/apxs` 这项，并且加上 `--enable-fpm`，这样才能以 `fast-cgi` 方式运行
黑色  其他扩展 [--enable-zip --with-bz2]

补充:
如果 make 时报错：`/usr/bin/ld: cannot find –lgcrypt`， 则是 `–with-xsl`没有正确安装，需先装 libxml2 + libxslt

其中路径 /usr/local 为缺省，例如 --with-mhash=/usr/local 可以省略为 --with-mhash

编译 PHP 前要先安装 apache 和 mysql (client, server, devel, share) RPM 包，这次安装的 zlib、gd 库采用的都是RPM包

### 设置网卡IP和地址

快速修改（一次有效，重启后无效）

    ifconfig eth0 192.168.0.20 netmask 255.255.255.0

永久修改：

    vi /etc/sysconfig/network-scripts/ifcfg-eth0

修改MAC地址、网卡名(eth0)等等。
修改或增加一行 IPADDR=xx.xxx.xx.xx

注：BOOTPROTO （启动协议）必须设置为 static 或 none 才可以使用自定义 IP 设置信息。
默认是 dhcp 则无效。

重启网卡：

    /etc/init.d/network restart
    或
    service network restart

### RPM 包的安装和卸载

    查看 rpm -qa|grep -i mysql 参数i表示忽略大小写
    安装 rpm -ivh MySQL-server-5.1.53-1.glibc23.i386.rpm
    卸载 rpm -e MySQL-server  SILVER-TIPS 不要写RPM后缀名，版本号也可省略，否则会提示找不到组件

### 防火墙的设置

    vi /etc/sysconfig/iptables

    # 增加一行：
    -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 11211 -j ACCEPT

重启命令

    /etc/inid.d/iptables restart
    或
    service iptables restart

停止或开启

    /etc/inid.d/iptables stop|start
    或
    service iptables stop|start

查看状态

    /etc/inid.d/iptables status

### 查看 Linux 运行了多少时间

    uptime

    显示如下信息：
    11:09:38 up 50 days, 23:00,  2 users,  load average: 0.75, 1.06, 0.90

### echo 写文件时的用法

    # 1个箭头，把文件清空并重写内容
    echo 'xxxxxxx' > /dir/test.txt

    # 2n个箭头，在文件尾追加内容
    echo 'xxxxxxx' >> /dir/test.txt

### SCP 远程拷贝

    # 将本地（来源）的推送复制到远程（目标）
    scp /tmp/test.zip root@192.168.1.155:/soft

    # 将远程（来源）的拉取复制到本地（目标）
    scp root@192.168.1.150/tmp/test.zip /soft

    # 拷贝文件夹
    scp –r /tmp/testdir/ root@10.1.1.54:/etc/testdir/

### Linux只能访问 IP 不能解析域名？

原因：本机没有设置DNS解析服务器

解决办法：

    vi /etc/resolv.conf 

    # 加入以下几行
    nameserver 8.8.8.8
    nameserver 202.96.128.86
    nameserver 202.96.128.166

然后重启网络服务：

    service network restart

### 修改 ssh 的端口号

    # 修改其中的 Port 22，可以有多行，表示启用多个端口
    vi /etc/ssh/sshd_config

    # 重启 SSH 服务
    /etc/init.d/sshd restart

### SecureCRT 没有 rz/sz 命令

    # 安装 lrzsz 软件包
    yum install lrzsz

### 修改 Linux 用户密码

    # 修改当前用户密码
    passwd

    # 修改指定用户
    passwd silverd

### 输出空 1>/dev/null 2>&1

- `1` 表示标准输出，输出到空设备 /dev/null
- `2` 表示错误输出，引用指向1，表示也输出为空

### mysql 命令行创建数据库

    mysqladmin create dbname -uroot -proot

### ubuntu 下禁用/开启触摸板

    modprobe psmouse# modprobe -r psmouse

### 查找大于2M的文件或目录(用于清理空间)

    find / -size +2048k
    du -h|sort –gr
    du --max-depth=1 –h
    find / -name *.log* -type f -size +100M

### 确定当前MySQL正在使用的 my.cnf 位置

    mysql --help | grep my.cnf

### 统计某文件夹及其子文件夹的文件总数

    ls -lR | grep "^-" | wc -l

### vi编辑器的批量替换

    :%s/查找的文字/替换成的文字/g
    注意：/g 表示忽略大小写

### 把查找到的文件的内容合并成一个文件

    find ./ -name 'sqlError.log' -exec 'cat' {} \; > target.log

### 读兄弟连 PPT 记录 vi 常用命令

| 命令 | 说明 |
| -- | -- |
| :setnu | 显示行号 |
| :setnonu | 不显示行号 |
| gg | 跳到文件头 |
| G | 跳到文件尾 |
| :n | 跳到指定行 |
| nG | 跳到指定行 |
| dG | 删除当前行到文件末尾 |
| :%s/old/new/g | 全文替换指定字符串 |
| :n1,n2s/old/new/g | 在一定范围内替换指定字符串 |
| :wq! | 保存修改并退出 |
| ZZ | 快捷键，保存修改并退出 |

### 读兄弟连PPT其他笔记

- kill -9 进程号（强行关闭）
- kill -1 进程号（重启进程）

