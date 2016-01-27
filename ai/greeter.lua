ai.register_handler('greeter',
    function () end,

    function (self, uin, message)
        if message == 'ww' then return 1
        else return 0 end
    end,

    function (self, uin, message)
        self.send_message('wwwwwwwwwww')
    end
)

local bubble_breaker = {
    '戳',
    '戳（≧∇≦）',
    '这个给我戳泥们都别抢 ><'
}
ai.register_handler('greeter',
    function () end,

    function (self, uin, message)
        if math.random() < 0.5 and (message == '冒' or message:find('冒泡')) then return 1
        else return 0 end
    end,

    function (self, uin, message)
        self.send_message(ai.rand_from(bubble_breaker))
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
ai.register_handler('greeter',
    function (self, storage)
        storage.last_konbanwa = storage.last_konbanwa or 0
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
        else return 0 end
    end,

    function (self, uid, message, storage)
        if ai.date.time_id >= 223000 or ai.date.time_id < 010000 then
            self.send_message(string.format(ai.rand_from(oyasumi_msg), self.member_info[uid]['card']))
        elseif ai.date.time_id >= 173000 then
            storage.last_konbanwa = ai.date.day_id
            self.send_message(string.format(ai.rand_from(konbanwa_msg), self.member_info[uid]['card']))
        else
            self.send_message(string.format(ai.rand_from(ohayo_msg), self.member_info[uid]['card']))
        end
    end
)
