---
layout: post
category: ['架构']
title: OAuth 回顾小结
---

突然发现没啥好写了，从 OAuth1.0 到 1.0a，再到 OAuth2.0，现在街上 OAuth 的授权原理和流程介绍已经很多了，哪天有空再把一些安全或漏洞补一下吧。

这里有详细的说明：[OAuth 1.0/1.0a/2.0 的之间的区别有哪些？](https://www.zhihu.com/question/19851243)

可能想说的点：

- OAuth 1.0 有什么漏洞？1.0a 修复了哪些问题？（回跳地址劫持）
- OAuth 2.0 比 1.0 改变了哪些？为啥要用 HTTPS？
- OAuth 2.0 的 `state` 字段的作用？（如何防止 CSRF）
- RefreshToken 的意义？（AccessToken 一般有效期为2小时，RefreshToken 有效期7天）
- 授权作用域 `scopes` 的应用

以下是 `2020.05.08` 的回顾：

### OAuth 授权流程如下：

1. A 网站让用户跳转到 GitHub。
2. GitHub 要求用户登录（没登录则先登录），然后询问"A 网站要求获得 xx 权限，你是否同意？"
3. 用户同意，GitHub 就会重定向回 A 网站，同时发回一个授权码。
4. A 网站使用授权码，向 GitHub 请求令牌。
5. GitHub 返回令牌.
6. A 网站使用令牌，向 GitHub 请求用户数据。

### OAuth 授权代码演示

1、A 网站让用户跳转到 GitHub。

A 网站拼接一个 authorizeUrl 跳转去 GitHub

```
https://github.com/oauth/authorize?
  response_type=code&
  client_id=CLIENT_ID&
  redirect_uri=CALLBACK_URL&
  scope=read
  state=随机数
```

2、GitHub 要求用户登录（没登录则先登录），然后询问"A 网站要求获得 xx 权限，你是否同意？"

3、用户同意，GitHub 就会重定向回 A 网站，同时发回一个授权码。

```php
function getAuthCodeByClientId(
    int $uid,
    string $clientId,
    string $redirectUri,
    array $scopes = [],
)
{
    // 1、检测 clientId 是否存在
    $clientInfo = OAuthClient::find($clientId);

    // 2、回调地址必须一致
    if ($clientInfo->redirect_uri != $redirectUri) {
        // 验证失败
        return false;
    }

    // 3、生成授权码
    $authCode = OAuthAuthCode::create([
        'auth_code' => '随机生成',
        'client_id' => $clientId,
        'uid'       => $uid,
        'scopes'    => $scopes,
        'revoked'   => 0,
    ]);

    return $authCode;
}
```

GitHub 通过 URL 跳转把 `authCode` 传回给 A 网站：

```
https://{redirect_uri}/?
  code=code
  state=
```

4、A 网站使用授权码，向 GitHub 请求令牌 + 5、GitHub 返回令牌

服务端间 API 访问：

```php
function getAccessTokenByAuthCode(string $clientId, string $clientSecret, string $authCode)
{
    // 1、检测 clientId 和 clientSecret 是否正确
    $clientInfo = OAuthClient::find($clientId);

    if ($clientInfo->client_secret != $clientSecret) {
        // 验证失败
        return false;
    }

    // 2、拿 code 去 auth_codes 表查出单条记录
    $codeInfo = OAuthAuthCode::find($authCode);

    if ($codeInfo->client_id != $clientId) {
        // 验证失败
        return false;
    }

    // 3、创建 accessToken
    $accessTokenInfo = OAuthAccessToken::create([
        'access_token' => '随机生成',
        'expires_in'   => 86400 * 7,
        'uid'          => $codeInfo->uid,
        'scopes'       => $codeInfo->scopes,
        'revoked'      => 0,
        'created_at'   => now(),
    ]);

    // 4、创建 refreshToken
    $refreshTokenInfo = OAuthRefreshToken::create([
        'refresh_token' => '随机生成',
        'access_token' => '随机生成',
        'expires_in'   => 86400 * 7,
        'scopes'       => $codeInfo->scopes,
        'revoked'      => 0,
        'created_at'   => now(),
    ]);

    return [
        $accessTokenInfo,
        $refreshTokenInfo,
    ];
}
```

6、A 网站使用令牌，向 GitHub 请求用户数据。

```php
function getUserInfoByAccessToken(string $accessToken)
{
    // 1. 检测 accessToken 是否存在、是否过期
    $accessTokenInfo = OAuthAccessToken::find($accessToken);

    // 2、检测该 accessToken 的 scopes 是否可访问 userInfo
    if (in_array('sns_userinfo', $accessTokenInfo->scopes)) {
        // 无权访问
        return false;
    }

    // 3、取回 accessToken 对应的 UID
    $uid = $accessTokenInfo->uid;

    // 4、根据 UID 取用户信息并返回
    $userInfo = getUserInfoByUid($uid);

    return $userInfo;
}
```

### OAuth Server 服务端表结构设计

`clients`

| 字段 | 类型 | 说明 |
| ---- | ---- | ---- |
| client_id | String | 应用 ID |
| client_secret | String | 应用密钥 |
| redirect_uri | String | 回调地址或域名 |

`users`

| 字段 | 类型 | 必填 |
| ---- | ---- | ---- |
| uid | Int | 用户 UID |
| nickname | String | 昵称 |
| avatar_url | String | 头像 |

`auth_codes`

| 字段 | 类型 | 必填 |
| ---- | ---- | ---- |
| code | String | 授权码 |
| client_id | String | 应用 ID |
| uid | Int | 用户 UID |
| scopes | ARRAY | 已授权访问作用域 |
| revoked | Boolean | 是否已使用 |
| created_at | Timestamp | 创建使用 |

`access_tokens`

| 字段 | 类型 | 必填 |
| ---- | ---- | ---- |
| access_token | String | 访问令牌 |
| client_id | String | 应用 ID |
| expires_in | Int | 几秒后过期 |
| scopes | ARRAY | 已授权访问作用域（从 `auth_codes` 表冗余 ） |
| uid | Int | 用户 UID |
| created_at | Timestamp | 创建使用 |

`refresh_tokens`

| 字段 | 类型 | 必填 |
| ---- | ---- | ---- |
| refresh_tokens | String | 访问令牌 |
| access_token | String | 访问令牌 |
| client_id | String | 应用 ID |
| expires_in | Int | 几秒后过期 |
| uid | Int | 用户 UID |
| created_at | Timestamp | 创建使用 |

### OAuth 和 SSO 的区别

SSO 非常像 OAuth 的 **隐藏式** 授权码 `implicit` 方式，下面介绍下 OAuth 的这种隐式授权码方式：

第一步、A 网站提供一个链接，要求用户跳转到 B 网站，授权用户数据给 A 网站使用。

```
https://b.com/oauth/authorize?
  response_type=token&
  client_id=CLIENT_ID&
  redirect_uri=CALLBACK_URL&
  scope=read
```

上面 URL 中，`response_type` 参数为 `token`，表示要求直接返回令牌。

第二步、用户跳转到 B 网站，登录后同意给予 A 网站授权。这时，B 网站就会跳回 `redirect_uri` 参数指定的跳转网址，并且把令牌作为 URL 参数，传给 A 网站。

```
https://a.com/callback#token=ACCESS_TOKEN
```

上面 URL 中，`token` 参数就是令牌，A 网站因此直接在前端拿到令牌。

注意，令牌的位置是 URL 锚点（fragment），而不是查询字符串（querystring），这是因为 OAuth 2.0 允许跳转网址是 HTTP 协议，因此存在"中间人攻击"的风险，而浏览器跳转时，锚点不会发到服务器，就减少了泄漏令牌的风险。

总结区别：OAuth 和 SSO 都可以做统一认证登录，但是 OAuth 可用于授权其他资源，SSO 只能登录认证。

### OAuth 中 `state` 参数的作用

一句话：防止 CSRF，类似于表单 `FormHash`

假设有场景「A网站」，在个人资料页有「绑定 GitHub」按钮，最后授权完 GitHub 回跳「A 网站」的 URL  是：

```
https://a.com?code=xxx
```

先说正常流程：此时「A网站」会用`code` 去换 `accessToken` 再换 `GithubUserInfo`，然后将当前用户张三 `uid` 与 GitHub 的 `thirdUid` 进行绑定，以后张三就可以用 GitHub 账号来登录「A网站」。

#### 怎么破坏？

1. 恶意者拿着用自己 GitHub 账号正常授权后获得的带 `code` 的链接 URL（抓包截断），发给张三
2. 张三打开这个 URL，就会上面逻辑，将自己的「A网站」UID 与恶意者的 GitHub 的 `thirdUid` 绑定了
3. 后果：恶意者可以用自己的 GitHub 账号登录「A网站」（登录进去是以张三的身份）

当然，这种破坏只对张三之前没绑定过 GitHub 这种情况有效，如果已绑过，那么这种破坏方式会失效。

#### 怎么防范？

1. 在有「绑定 GitHub」按钮的页面渲染时，生成一个随机字符串 `state` 存在服务端 `session` 中
2. 把这个 `state` 放到 `authorize_url` 里，等授权完成跳回来到本站时，也带回这个 `state`
3. 因为这一步时浏览器跳转，所以请求头里有 `cookie` 即 `PHP_SESSID`
4. 服务端从 `session` 中拿出之前存出的 `state` 与 `redirect_uri` 里带回的 `state` 做对比，如果一致，说明本次请求并非伪造。
