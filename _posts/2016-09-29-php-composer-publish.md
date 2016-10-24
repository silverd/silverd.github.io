---
layout: post
category: ['LAMP']
title: PHP Composer 如何创建、发布自己的包
---

Composer 本身不托管代码，代码放在 GitHub，Composer 只负责管理版本和依赖。

例如我们要发布一个 SilverQ 队列组件到 Composer，步骤如下：

## 1、前往 https://github.com 建立仓库 silverq

1. 克隆代码到目录 ~/home/wwwroot/_git_sth/silverd/silverq
2. 进入目录执行 `composer init` 按提示依次填写，示例：

```
{
    "name": "silverd/silverq",
    "type": "library",
    "description": "Queue Library for Yaf Framework",
    "keywords": ["yaf", "queue"],
    "homepage": "http://silverd.cn",
    "license": "MIT",
    "authors": [
        {
            "name": "silverd",
            "email": "silverd29@gmail.com",
            "homepage": "http://silverd.cn"
        }
    ],
    "require": {
        "php": ">=5.3"
    },
    "require-dev": {
        "phpunit/phpunit": "~4.0"
    },
    "autoload": {
        "psr-4": {"SilverQ\\": "src/SilverQ"}
    }
}
```

3. 编写其他代码并创建好 README.md 提交

## 2、前往 http://packagist.org

1. 用 GitHub 帐号登录
2. 点击 [Submit Package]，在 Repository URL 处填写 GitHub 的仓库地址 `https://github.com/silverd/silverq`
3. 点击 [Check]，系统自动检测项目中 composer.json 是否合格，合格则成功发布
4. 设置 GitHub  Webhooks [更新指南](https://packagist.org/about#how-to-update-packages) ，这样只要在 GitHub 发布新版本后，可自动推送到 Packagist
    - 进入 GitHub.com -> silverd/silverq -> Settings -> Webhooks 或 Installed integrations 页面
    - 点击 Add service -> 选择 Packagist，按提示填写并提交
        - User: silverd
        - Token: 在 `https://packagist.org/profile/` 看到的 API Token
        - Domain: 可不填
        - 底部 Active 复选勾上
5. 此时访问 `https://packagist.org/packages/silverd/silverq` 可以看到包已经可以访问并被拉取了

Note: 也可以不设置钩子，每次发布后手动推送下：

    curl -X POST -H 'content-type:application/json' 'https://packagist.org/api/update-package?username=silverd&apiToken=XXXXXX' -d '{"repository":{"url":"https://github.com/silverd/silverq"}}'

## 3、项目中如何使用？

紧接上一步，到项目中执行以下命令：

    composer require silverd/silverq

会提示组件版本找不到：

    [InvalidArgumentException]
    Could not find package silverd/silverq at any version for your minimum-stability (stable). Check the package spelling or your minimum-stability

可能是因为我们的 Composer 使用的国内镜像没有及时同步的原因，把“源”还原回去试试：

    composer config -g repo.packagist composer https://packagist.org

仍然不行。

原来是我们还没有在 GitHub 正式 release 一个版本。此时只能拉 dev-master 主分支开发版本，重新执行：

    composer require silverd/silverq:dev-master

那么如何在 GitHub 上发布正式版本？

进入 `https://github.com/silverd/silverq/releases`，或点击仓库导航里的 Release Tab，然后按提示操作。

有了正式的 release 版本后，再执行 `composer require silverd/silverq` 就可正常拉取包内容了。

