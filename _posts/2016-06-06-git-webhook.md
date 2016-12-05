---
layout: post
category: ['架构']
title: 使用 Coding.net 的 WebHook 来自动更新、部署
---

需求：

开发人员提交 git push 后，在目标机器上可以自动触发执行 git pull 获取最新代码

特别要注意是操作权限问题，假设目标机器为我们的 BigIns 测试机。

1、在『目标机器』上执行生成公钥：

    mkdir /home/www/.ssh
    chown www.www /home/www/.ssh

    sudo -u www ssh-keygen
    cat /home/www/.ssh/id_rsa.pub

2、把公钥文本粘贴到 Coding.net 中指定项目的『设置-项目设置-部署公钥』里

3、在『目标机器』找一个 Web 可访问到的目录，新建 PHP 文件：

    sudo -u www vi git_hook.php

    <?php

    const WIKI_DIR = '/home/wwwroot/pai.bigins.wiki';

    // 假设 wiki 文档放在 coding-pages 分支上
    echo shell_exec('cd ' . WIKI_DIR . ' && git pull origin coding-pages 2>&1');

    ?>

4、设置 Coding.net 的 WebHook，填入以下 URL：

    http://pai.bigins.wiki/git_hooks.php

5、在『目标机器』初始化检出代码（必须用 www 用户）

    # 新建
    cd /home/wwwroot/
    mkdir pai.bigins.wiki
    chown www.www pai.bigins.wiki

    # 检出代码
    # 注意：git remote 仓库地址必须用 SSH 地址：git@git.coding.net，不能用 https://git.coding.net
    # 因为经测试 https 检出的库，每次 pull 还是要输入密码，ssh 方式则无需重复认证
    sudo -u www git clone -b coding-pages git@git.coding.net:grampus/hmb_oa_wiki.git pai.bigins.wiki

6、如果需要手动 pull，则必须以 www 身份执行：

    cd /home/wwwroot/pai.bigins.wiki
    sudo -u www git pull origin coding-pages

参考文章：

- <http://www.myexception.cn/web/1817710.html>
- <http://san-yun.iteye.com/blog/1980178>