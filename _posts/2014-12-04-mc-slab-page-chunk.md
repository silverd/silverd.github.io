---
layout: post
category: ['复习', '笔记', 'NoSQL']
title: Memcache 内存分配策略
---

## Page 是内存分配的最小单位

Memcached的内存分配以page为单位，默认情况下一个page是1M，可以通过-I参数在启动时指定。

如果需要申请内存时，memcached会划分出一个新的page并分配给需要的slab区域。page一旦被分配在重启前不会被回收或者重新分配（page ressign已经从1.2.8版移除了）

![](/res/img/in_posts/t025aa3901314343785.png)

## Chunk 是存放缓存数据的单位

启动时有一个成长因子，默认是1.25，按容量大小递增，所以会产生碎片空闲

![](/res/img/in_posts/t02ee669c8d8a0e1716.png)

![](/res/img/in_posts/t02fb68b794ee4a9c56.png)

## Slab 是一堆相同大小 Chunk 的容器

Memcached在启动时通过 -m 指定最大使用内存，但不会启动就占用，是动态按需分配。

slab申请内存时以page为单位，所以在放入第一个数据，无论大小为多少，都会有1M大小的page被分配给该slab。申请到page后，slab会将这个page的内存按chunk的大小进行切分，这样就变成了一个chunk的数组，在从这个chunk数组中选择一个用于存储数据。

## Slab/Page/Chunk 之间的关系

![](/res/img/in_posts/t025aa3901314343785.png)

## 为什么总内存没占满，还会触发LRU机制？

我的理解是，当全部内存已经被slab以page方式申请了，化为了chunk，内存容器全划分好后，不会回收。
例如：100字节的chunk所在slab中因为key过期释放了空间，但200字节的chunk所在的slab是满的。所以总和上看，内存没有占满。

现在有一个200字节的数据要存入，就会发现存不进200字节的chunk，此时就会触发LRU机制自动清理200字节chunk中的数据。即使100字节chunk所在slab还有不少内存空闲。