require 'zzz'

local welcome_msg = {
    [1] = {
        '唔 有新人 ♪（ｖ＾＿＾）ｖ',
        '发现新人一只 =ω=',
        '迎新ww 欢迎来到带有显著闲聊特质的（划掉）V群',
        '喵帕斯～欢迎来到带有显著闲聊特质的（划掉）V群 ^ ^'
    }, [2] = {
        '有任何疑问的话。。我都不能解答。。= = 但是可以隔几分钟人工置顶一次哦。。只要在开头加“置顶”就好'
    }, [3] = {
        '（不不不coder菌偷懒啦置顶功能没有加ˊ_>ˋ）'
    }, [4] = {
        '哦对了，本群成文规定：新人都是触～祝愉快ww（Orz'
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
            self:send_message(ai.rand_from(welcome_msg[i]))
            zzz(3)
        end
    end
)

local downloads = {
    -- 正经的内容
    { name = 'v[34].+安装包', full_name = 'Vocaloid 3/4 安装包+中文音源（洛天依&言和&乐正绫&心华）', link = 'http://pan.baidu.com/s/1o6wzmBo 密码：rih3' },
    { name = '音源.+下载', full_name = 'Vocaloid 3/4 所有音源（所有语种）', link = 'http://pan.baidu.com/s/1jGvl3j4 密码：yzy5' },
    { name = 'fl.+破解', full_name = 'FL Studio 11/12 注册机', link = 'http://pan.baidu.com/s/1borvNLd 密码：kryu' },
    { name = 'fl.+注册', full_name = 'FL Studio 11/12 注册机', link = 'http://pan.baidu.com/s/1borvNLd 密码：kryu' },
    { name = 'fl.+安装包', full_name = 'FL Studio 12', link = 'http://pan.baidu.com/s/1hqT5dmW 密码：e7nj' },
    { name = 'audacity.+下载', full_name = 'Audacity 2.1.1 for Windows', link = 'http://pan.baidu.com/s/1hqlhGzy 密码：4xtu' },
    -- 有点不正经的内容
    { name = '入戏太深', full_name = '马旭东《入戏太深》 谱&伴奏', link = 'http://pan.baidu.com/s/1pJiOfUj' },
    -- 非常不正经的内容
    { name = 'osu.+安装包', full_name = 'osu! 安装包', link = 'http://pan.baidu.com/s/1mgriaEW 密码：ya7j' },
    { name = 'lantern', full_name = 'Lantern（墙内）下载页面', link = 'https://github.com/getlantern/lantern/releases' },
    { name = 'free pascal', full_name = 'Free Pascal 2.6.4 for OS X', link = 'http://pan.baidu.com/s/1i3leJtV 密码：mqdf' },
    { name = '20151029', full_name = 'HSEFZ Practice Contest 2015.10.29', link = 'http://pan.baidu.com/s/1mgjHQIk' }
}
local downloads_msg = {
    '这里是 %s ➝ %s，拿走不谢～',
    '窝这里有。。%s | %s'
}
ai.register_handler('welcomer',
    function () end,

    function (self, uin, message)
        message = message:lower()
        for i = 1, #downloads do
            if message:find(downloads[i].name) then
                return 1
            end
        end
    end,

    function (self, uin, message)
        message = message:lower()
        for i = 1, #downloads do
            if message:find(downloads[i].name) then
                self:send_message(string.format(ai.rand_from(downloads_msg), downloads[i].full_name, downloads[i].link))
                return
            end
        end
    end
)

ai.register_handler('welcomer',
    function () end,

    function (self, uid, message, storage)
        if message:lower():find('cap') and (message:find('群网站') or message:find('群主页')) then return 1
        else return 0 end
    end,

    function (self)
        self:send_message('http://vocaloid.yesterday17.cn/')
    end
)
