---
layout: post
category: ['Mac']
title: Mac 下通过 launchctl 管理自启动程序和计划任务
---

Mac 下的计划任务和服务是通过 plist 来管理，类似于 CentOS 的 crontab。

首先进入到 ~/Library/LaunchAgents 下新建一个 plist 文件

    vi ~/Library/LaunchAgents/com.TASK_NAME.launchctl.plist

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>com.TASK_NAME.launchctl.plist</string>
      <key>ProgramArguments</key>
      <array>
        <string>/Users/silverd/AutoMakeLog.sh</string>
      </array>
      <key>StartCalendarInterval</key>
      <dict>
        <key>Minute</key>
        <integer>4</integer>
        <key>Hour</key>
        <integer>13</integer>
      </dict>
      <key>StandardOutPath</key>
      <string>/var/log/AutoMakeLog.log</string>
      <key>StandardErrorPath</key>
      <string>/var/log/AutoMakeLog.err</string>
    </dict>
    </plist>

我翻译成 JSON 格式会更加直观些：

    {
      Label: 'com.TASK_NAME.launchctl.plist',
      ProgramArguments: [
        '/Users/silverd/AutoMakeLog.sh'
      ],
      StartCalendarInterval: {
        Minute: 4,
        Hour: 13
      },
      StandardOutPath: '/var/log/AutoMakeLog.log',
      StandardErrorPath: '/var/log/AutoMakeLog.err',
    }

Label 就是这个任务的名字，这里一般取 plist 的文件名，这个名字不能和其它的 plist 重复

    # 载入任务（Permanently enabling a job）
    launchctl load -w com.TASK_NAME.launchctl.plist

    # 去除任务（Permanently disabling a job）
    launchctl unload -w com.TASK_NAME.launchctl.plist

    # 立即执行，不管时间到了没有
    # 注意：手动执行任务前必须先载入
    launchctl start com.TASK_NAME.launchctl.plist

    # 停止执行任务
    launchctl stop com.TASK_NAME.launchctl.plist

    # 列出当前所有任务
    launchctl list

重要的参数说明：

| -w | Overrides the Disabled key and sets it to false or true for the load and unload subcommands respectively. |
| -F | Force the loading or unloading of the plist. Ignore the `Disabled key` |

Launchd 脚本存储在以下位置：

    ~/Library/LaunchAgents              -- For a specific user
    /Library/LaunchAgents               -- For all users  
    /Library/LaunchDaemons              -- For system boot
    /System/Library/LaunchAgents        -- For OS X use only
    /System/Library/LaunchDaemons       -- For OS X native processes only

LaunchDaemons 的拥有者必须是 root:wheel，权限是 644（rw-r-r）

LaunchAgents 除了 ~/Library/LaunchAgents 的拥有者是登录用户 （silverd）本身外，其余目录下的也应该是 root:wheel

不建议把脚本放到 /System/Library/LaunchDaemons/ 和 /System/Library/LaunchAgents/ 中，因为每次系统更新都会清空该目录。

### LaunchAgents 和 LaunchDaemon 的区别

LaunchAgents: 是用户登陆后启动的服务

LaunchDaemon: 是用户未登陆前就启动的服务

### 参考文章

- <http://launchd.info>
- <https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man5/launchd.plist.5.html>
- <https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/launchctl.1.html#//apple_ref/doc/man/1/launchctl>
- <https://my.oschina.net/jackin/blog/263024>


