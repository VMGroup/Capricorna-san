Capricorna-san
==============

AI一只，可以为群内成员提供各种服务~\\(≧∇≦)/ （想歪的孩纸们自行面壁）

废话少说窝们进入正题（哈欠

运行前的准备
------------

* 电脑，随便什么系统不过 Windows 下没有测试过。。理论可行
* cURL 命令行工具（窝很困啊就不加链接了行不QAQ
* Lua & liblua
* 一个安装 QQ、有摄像头的爪机
* 安装 [Pegasus.lua](https://github.com/EvandroLG/pegasus.lua)

如何运行
--------

* `cd` 进入项目目录，编译 `compiled/zzz-posix.c` 或者 `compiled/zzz-windows.c`（有啥编译错误自己调吧。。。）
* 执行 `lua main.lua`，稍等片刻
* 用爪机 QQ 扫描目录下的 `login.png`
* 等到 `1 / 212`、`2 / 212` 这种东西开始的时候 `^C` 结束程序。。。（嘛这是个 bug 必须这么做。。。）
* 访问 [SmartQQ原版网站](http://w.qq.com/)，用爪机再登录一遍
* 打开浏览器的控制台，找到“网络”一栏（Chrome/Firefox 都有），随便点开一个 `poll2` 之类的请求
* 查看请求 Cookies，找到 skey（如，“@VROiP3Tbc”），复制（越来越＊疼了有木有啊 -, -
* 回到项目目录，打开 `cookies.txt`，用新的 skey 替换原来的 skey（二者可能相同，不用理会即可）
* 再次执行 `lua main.lua`
* 呼～～～
* AI 运行起来之后，用新的进程开启 Web API：`lua main.lua weblistener`（不想写多线程。。Lua 协程似乎并不可行的样子。。）
* 如果泥并不需要 Web API：第2、9步运行 AI 时使用 `lua main.lua disable-webapi` 可以略微（！）加快程序效率。。

如何编写 AI
-----------

略（TODO）

如何测试 AI
-----------

`$ lua ai_test.lua`

* 发送消息：直接输入消息回车即可
* 更改用户：`sender <uid>`
* 新人加入：`newcomer <nick>`（程序结束后不保存）

程序开始时会建立12个用户（Aries ~ Pisces），不触发 `welcomer` 模块，默认使用 Pisces 进行发送。

如何使用 Web API 查询 AI 状态信息
----------------

细节请见 [Vocaloid学习制作群主页](https://github.com/VMGroup/vmgroup.github.io) 中的 AI 状态页面

闲扯时间
--------

**Capricorna** is brought to you by developers including **Pisces** together with the library **Pegasus.lua**. Cool astronomy right?

本神奇的AI曾经：
* 发红包抢红包
* 逛空间，点赞转发
* 撤回消息
* 回复私戳消息并通过图灵测试
* 在群内另一个机器人“乐正绫”处每天签到

其中除最后一项外均在高(ren)级(gong)模式下完成。
