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
* 等到 `1 / 212`、`2 / 212` 这种东西开始的时候 `^C` 结束程序。。。（这是个 bug 必须这么做。。。）
* 访问 [SmartQQ原版网站](http://w.qq.com/)，用爪机再登录一遍
* 打开浏览器的控制台，找到“网络”一栏（Chrome/Firefox 都有），随便点开一个 `poll2` 之类的请求
* 查看请求 Cookies，找到 skey（如，“@VROiP3Tbc”），复制（越来越＊疼了有木有啊 -, -
* 回到项目目录，打开 `cookies.txt`，用新的 skey 替换原来的 skey（二者可能相同，不用理会即可）
* 再次执行 `lua main.lua`
* 呼～～～

* 另外，开启 Web API 的方法：`lua main.lua webapi`

如何编写 AI
===========

略（TODO）

如何使用 Web API
================

细节请见 [Vocaloid学习制作群主页](https://github.com/VMGroup/vmgroup.github.io)
