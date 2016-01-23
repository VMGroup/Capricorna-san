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
        '（不不不主任偷懒上述功能全部没有加ˊ_>ˋ）'
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
