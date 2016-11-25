---
layout: post
category: ['MySQL']
title: MySQL 中 trim 处理字段多余字符
---

## 删除两侧空格

    SELECT trim(`path`) as paths FROM `ts_back_pic`

## 删除左侧斜杠（头部）

    SELECT trim(LEADING '/' FROM `path`) as paths FROM `ts_back_pic`

## 删除右侧斜杠（尾部）

    SELECT trim(TRAILING '/' FROM `path`) as paths FROM `ts_back_pic`

## 删除两侧斜杠

    SELECT trim(BOTH '/' FROM `path`) as paths FROM `ts_back_pic`

## 删除两侧空格+回车

    SELECT trim(BOTH '\r\n' FROM trim(`path`)) as paths FROM `ts_back_pic`