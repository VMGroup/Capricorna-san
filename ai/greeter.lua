ai.register_handler('greeter',
    function () end,

    function (self, uin, message)
        if message == 'ww' then return 1
        else return 0 end
    end,

    function (self, uin, message)
        self:send_message('wwwwwwwwwww')
    end
)

local bubble_breaker = {
    '戳',
    '戳（≧∇≦）',
    '这个给我戳泥们都别抢 ><',
    '按下去'
}
ai.register_handler('greeter',
    function () end,

    function (self, uin, message)
        if math.random() < 0.5 and (message == '冒' or message:find('冒泡')) then return 1
        else return 0 end
    end,

    function (self, uin, message)
        self:send_message(ai.rand_from(bubble_breaker))
    end
)

local ohayo_msg = {
    '%s 早',
    '%s 早上好呀',
    '早早早 \\(≧∇≦)/',
    'おはようございます～',   -- 日语
    'Bon matin',    -- 法语
    'Guten Morgen', -- 德语
    '¡Buenos dias!',    -- 西班牙语
    'Selamat pagi', -- 马来语
    'にゃんぱすー', '%s 喵帕斯～'
}
local konbanwa_msg = {
    '%s 晚上好',
    'こんばんわー', '空帮哇', '空帮汪',
    'にゃんぱすー'
}
local oyasumi_msg = {
    '%s 晚安～',
    'Oyasuminasai', -- 日语罗马音
    'Bonne nuit',   -- 法语
    'Gute Nacht',   -- 德语
    '¡Buenas noches!',  -- 西班牙语
    'Selamat malam',    -- 马来语
    'Спокойной ночи',   -- 俄语
    'Habeen wanaagsan', -- 索马里语
    'Sugeng dalu!', -- 爪哇/Java语（雾
    'Tafandria mandry!',    -- 马尔加什语
    'ゆめで すぐ あえるね おやすみなさい'   -- Zzz
}
local midnight_msg = {
    '那么晚了。。寒假应该多补补觉的啦 (¦3[▓▓]',
    '熬夜对革命的本钱不好哦～',
    '泥也是在这里守夜的AI嘛？'
}
ai.register_handler('greeter',
    function (self, storage)
        storage.last_konbanwa = storage.last_konbanwa or 0
        storage.last_midnight = storage.last_midnight or 0
    end,

    function (self, uid, message, storage)
        local nyanpasu = message:find('にゃんぱす') or message:find('喵帕斯')
        if ai.date.time_id >= 063000 and ai.date.time_id < 090000
            and (nyanpasu or message:find('早') or message:find('ohayo'))
        then return 1
        elseif ai.date.time_id >= 173000 and ai.date.time_id < 223000
            and storage.last_konbanwa ~= ai.date.day_id and (nyanpasu or message:find('晚好') or message:find('空帮')) -- 汪
        then return 1
        elseif (ai.date.time_id >= 223000 or ai.date.time_id < 010000)
            and (message:find('晚安') or message:find('yasumi'))
        then return 1
        elseif (ai.date.time_id >= 010000 and ai.date.time_id < 040000)
            and storage.last_midnight ~= ai.date.day_id
        then return 1
        else return 0 end
    end,

    function (self, uid, message, storage)
        if ai.date.time_id >= 223000 or ai.date.time_id < 010000 then
            self:send_message(string.format(ai.rand_from(oyasumi_msg), self.member_info[uid]['card']))
        elseif ai.date.time_id >= 173000 then
            storage.last_konbanwa = ai.date.day_id
            self:send_message(string.format(ai.rand_from(konbanwa_msg), self.member_info[uid]['card']))
        elseif ai.date.time_id >= 063000 then
            self:send_message(string.format(ai.rand_from(ohayo_msg), self.member_info[uid]['card']))
        else
            storage.last_midnight = ai.date.day_id
            if uid ~= 906321912 then self:send_message(ai.rand_from(midnight_msg))
            else self:send_message('群主！群主怎么还不睡！(´･Д･)」') end
        end
    end
)

local orz_msg = {
    '每个人都有自己的闪光点，对于别人的闪光点窝们应该Orz',
    '三人行必有我师焉',
    '择其善者而Orz之，其不善者而改之',
    '众人皆触唯我独渣(ノ_＜)',
    '死国矣 QwQ'
}
ai.register_handler('greeter',
    function () end,

    function (self, uid, message)
        message = message:lower()
        if message:find('orz') or message:find('sro') or message:find('渣') or message:find('角虫') then return 1
        else return 0 end
    end,

    function (self, uid, message)
        self:send_message(ai.rand_from(orz_msg))
    end
)

local manager_msg = {
    '抓住一只野生的群主 (๑•̀ㅂ•́)و✧',
    '群主粗线！excited！',
    '群主大大お帰りなさい～'
}
local manager_uid = 4
ai.register_handler('greeter',
    function (self, storage)
        storage.last_catch_manager = storage.last_catch_manager or 0
    end,

    function (self, uid, message, storage)
        if uid == manager_uid and storage.last_catch_manager + ai.times.day / 2 < ai.date.epoch then
            return 2    -- 抓群主也是非常重要的一件事！（逃
        end
    end,

    function (self, uid, message, storage)
        storage.last_catch_manager = ai.date.epoch
        self:send_message(ai.rand_from(manager_msg))
    end
)
