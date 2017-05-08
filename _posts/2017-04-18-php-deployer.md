---
layout: post
category: ['PHP', '笔记']
title: PHP Deployer 小试
---

Deployer 是一个具有模块化、代码回滚、并行任务等功能的 PHP 部署工具，支持多个 PHP 框架。 原理是在本地通过 SSH Client 执行远程 shell 命令。比传统自写 shell 脚本，更加直观易用。

### 安装

```bash
curl -LO https://deployer.org/deployer.phar
mv deployer.phar /usr/local/bin/dep
chmod +x /usr/local/bin/dep
```

或者

```bash
composer require deployer/deployer --dev
```

或者

```bash
composer global require deployer/deployer
```

### 初始化

在项目目录运行：

```bash
dep init
```

可以选择支持的 PHP 框架。每种框架菜谱的区别在于会设置不同的可写目录，以及执行不同的命令，例如 Laravel 会执行 `php artisan migrate` 和 `composer install` 等等。

然后会在项目目录生成一个 `deploy.php` 文件。

### 编写部署脚本

详细配置说明参见：<https://deployer.org/docs/getting-started>

附上我正在使用的一个 `deploy.php` 脚本：

```php
<?php

/*
* --------------------------------------------------------------------------
* 自动部署脚本
* --------------------------------------------------------------------------
*
* 部署测试服：
* dep deploy
* dep deploy staging
*
* 部署生产服：
* dep deploy prod
*
* 回滚最近一次发布：
* dep rollback staging|prod
*
* 更多文档：@see https://deployer.org/docs
*/

namespace Deployer;
require 'recipe/laravel.php';

// Configuration

set('ssh_type', 'native');
set('ssh_multiplexing', true);

set('repository', 'git@git.oschina.net:silverd/adminlte.git');
set('deploy_path', '/home/wwwroot/adminlte');
set('default_stage', 'staging');

set('writable_mode', 'chmod');
add('writable_dirs', [
    'bootstrap/cache',
    'storage',
    'public/upload',
]);
add('shared_files', []);
add('shared_dirs', [
    'vendor',
    'storage',
    'public/upload',
]);

// Servers

server('staging', '121.43.110.121')
    ->user('root')
    ->identityFile()
    ->pty(true)
    ->set('branch', 'develop')
    ->stage('staging');

$serverNo = 1;
foreach (['生产服IP_1', '生产服IP_2'] as $serverIp) {
    server('prod_' . ($serverNo++), $serverIp)
        ->user('root')
        ->identityFile()
        ->pty(true)
        ->set('branch', 'master')
        ->stage('prod');
}

// Tasks

task('confirm', function () {
    askConfirmation('Are you sure want to deploy?');
});
before('deploy:prepare', 'confirm');

desc('Restart PHP-FPM service');
task('php-fpm:restart', function () {
    run('/etc/init.d/php-fpm reload');
});
after('deploy:symlink', 'php-fpm:restart');

// [Optional] if deploy fails automatically unlock.
after('deploy:failed', 'deploy:unlock');

// Migrate database before symlink new release.
before('deploy:symlink', 'artisan:migrate');

task('notify', function () {
    run('curl https://hooks.pubu.im/services/xxxx -F text="通知: 部署了测试环境服务端 PHP 代码"');
});
after('success', 'notify');
```

### 部署前准备

所有的待部署的目标机器，都必须满足以下条件：

1. 都需安装 Git Client + PHP Composer <http://docs.phpcomposer.com> 并切中国镜像
2. 都需生成『部署公钥』并上传到对应的 Git 项目里（用于免密 `git pull` 代码）
3. 都需先手动 ssh git@oschina.net 一次（用于添加 ssh 指纹 ~/.ssh/known_hosts）
4. 解禁一些 PHP 函数（修改 `php.ini` 的 `disable_functions`）
    - passthru
    - exec
    - system
    - shell_exec
    - proc_open
    - proc_get_status

### 开始部署

```bash
# 部署测试服
dep deploy
dep deploy staging

# 部署生产服：
dep deploy prod

# 回滚最近一次发布：
dep rollback staging|prod

# 查看详细步骤
dep deploy staging -vvv

```

部署成功时，Deployer 会自动在服务器上生成以下文件和目录：

- releases 包含你部署项目的版本（默认保留 5 个版本）
- shared 包含你部署项目的共享文件或目录（如：Laravel 的 Storage 目录、.env 文件等 ）
- current 软连接到你当前发布的版本

Nginx VirtualHost DocumentRoot 指向 `current/public` 目录即可。

### 我认为的缺点

1. 每次部署都会重新 `git clone` 代码，如果仓库体积大，拉取速度有些慢。
2. 如果生产服有10台服务器，那相当于这10台上都要维护一套 Git 仓库（每次部署相当于自动登录到10台机器上自动 `git clone`），还需要把10台机器的『部署公钥』都上传到 git 项目里以实现免密码拉取代码（详见上文：部署前准备）。
3. 同时要求，本机（即发布机：执行部署命令的那台机器）的公钥必须上传到这10台机器上，如果有多个部署人如何处理？

对于以上第2点、第3点，我认为的解决办法：

还是需要一台专用发布机，本机 `deploy.php` 连这台发布机，在发布机上按正常步骤 deploy，然后由这台发布机 `rsync` 代码到10台真正对外的 WebServer 服务器上。这样 ssh 公钥和 git 部署公钥只需要一份即可。

### 参考文章

- <https://deployer.org/docs>
- <https://juejin.im/entry/58f465f8a22b9d006c0035ed>
