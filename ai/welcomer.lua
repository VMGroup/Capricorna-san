require 'zzz'

local welcome_msg = {
    [1] = {
        '呀 有新人 ♪（ｖ＾＿＾）ｖ',
        '发现新人一只 =ω=',
        '迎新ww',
        '喵帕斯～欢迎来到带有显著闲聊特质的（划掉）V群 ^ ^'
    }, [2] = {
        '窝是这里的AI（之一）'
    }, [3] = {
        '找资源下载的话直接说一声“XX资源”就可以啦'
    }, [4] = {
        '有任何疑问的话。。我都不能解答。。= = 但是可以隔几分钟人工置顶哦。。只要在开头加“置顶”就好'
    }, [5] = {
        '（不不不偷懒上述功能全部没有加ˊ_>ˋ）'
    }, [6] = {
        '哦对了，本群成文规定：新人都是触～祝愉快ww'
    }
}

ai.register_timer('welcomer',
    ai.times.second * 10,
    function (self, storage)
        storage.greeted = storage.greeted or {}
        for k, v in pairs(self.member_info) do
            if v.is_newcomer and not storage.greeted[k] then
                storage.greeted[k] = true
                return true
            end
        end
        return false
    end,

    function (self, storage)
        for i = 1, #welcome_msg do
            self.send_message(ai.rand_from(welcome_msg[i]))
            zzz(3)
        end
    end
)

local downloads = {
    { name = 'fl.+破解', full_name = 'FL Studio 12 注册机', link = 'http://pan.baidu.com/s/1borvNLd 密码：kryu' },
    { name = 'fl.+注册', full_name = 'FL Studio 12 注册机', link = 'http://pan.baidu.com/s/1borvNLd 密码：kryu' },
    { name = 'fl', full_name = 'FL Studio 12', link = 'http://pan.baidu.com/s/1hqT5dmW 密码：e7nj' },
    { name = 'osu', full_name = 'osu! 安装包', link = 'http://pan.baidu.com/s/1mgriaEW 密码：ya7j' },
    { name = 'audacity', full_name = 'Audacity 2.1.1 for Windows', link = 'http://pan.baidu.com/s/1hqlhGzy 密码：4xtu' },
    { name = '入戏太深', full_name = '马旭东《入戏太深》 Vocaloid全套资源', link = 'http://pan.baidu.com/s/1pJiOfUj' },
    { name = 'lantern', full_name = 'Lantern（墙内）下载页面', link = 'https://github.com/getlantern/lantern/releases' }
}
local downloads_msg = {
    '这里是 %s ➝ %s，拿走不谢～',
    '窝这里刚好有哦。。%s | %s'
}
ai.register_handler('welcomer',
    function () end,

    function (self, uin, message)
        if message:sub(-6) == '资源' or message:sub(-6) == '下载' then return 1
        else return 0 end
    end,

    function (self, uin, message)
        local i
        message = message:lower()
        for i = 1, #downloads do
            if message:find(downloads[i].name) then
                self.send_message(string.format(ai.rand_from(downloads_msg), downloads[i].full_name, downloads[i].link))
                return
            end
        end
    end
)
