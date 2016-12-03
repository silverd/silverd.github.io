---
layout: post
category: ['架构']
title: OAuth 回顾小结
---

突然发现没啥好写了，从 OAuth1.0 到 1.0a，再到 OAuth2.0，现在街上 OAuth 的授权原理和流程介绍已经很多了，哪天有空再把一些安全或漏洞补一下吧。

可能想说的点：

- OAuth1.0 有什么漏洞？1.0a 修复了哪些问题？（回跳地址劫持）
- OAuth2.0 比 1.0 改变了哪些？为啥要用 HTTPS？
- OAuth2.0 的 state 字段的作用？（如何防止 CSRF）