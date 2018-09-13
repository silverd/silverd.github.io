---
layout: post
category: ['PHP', '笔记']
title: Composer 生产服性能优化指南
---

### Level-1 优化：生成 classmap

生产环境一定要执行该命令，为啥呢？

```bash
composer dump-autoload -o（-o 等同于 --optimize）
```

#### 原理：

这个命令的本质是将 PSR-4/PSR-0 的规则转化为 classmap 规则（classmap 中包含了所有类名与类文件路径的对应关系）避免了加载器再去文件系统中遍历查找文件产生不必要的 IO。

当加载器找不到目标类时，仍旧会根据 PSR-4/PSR-0 的规则去文件系统中查找。

### Level-2 优化：权威的（Authoritative）classmap

如果想实现加载器找不到类时即停止，那可以采用 Authoritative classmap：

```bash
composer dump-autoload -a （-a 等同于 --classmap-authoritative）
```

#### 原理：

执行这个命令隐含的也执行了 Level-1 的命令， 即同样也是生成了 classmap，区别在于当加载器在 classmap 中找不到目标类时，不会再去文件系统中查找（即隐含的认为 classmap 中就是所有合法的类，不会有其他的类了，除非法调用）

注意：
如果你的项目在运行时会生成类，使用这个优化策略会找不到这些新生成的类。

### Level-1 Plus 优化：使用 APCu Cache

在生产环境下，这个策略一般也会与 Level-1 一起使用， 执行：

```bash
composer dump-autoload -o --apcu
```

APCu 是 APC 去除 opcode 缓存后的精简版，只用于本机数据缓存（共享内存使得数据在多进程间可共享）。

这样，即使生产环境下生成了新的类，只需要文件系统中查找一次即可被缓存 ， 弥补了 Level-2/A 的缺陷。

### 如何选择 & 小结

如果项目在运行时不会生成新的类文件，那么使用 Level-2/A，否则使用 Level-1 及 Level-1 Plus。

Level-2 的优化基本都是 Level-1 优化的补充，Level-2 主要是决定在 classmap 中找不到目标类时是否继续找下去。

Level-1 Plus 主要是在提供了一个缓存机制，将在 classmap 中找不到时，将从文件系统中找到的文件路径缓存起来，加速后续查找的速度。

## 参考文章

- <http://www.dahouduan.com/2018/03/16/composer-autoload-optimize>