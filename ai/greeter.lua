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

local ohayo_msg = {
    '%s 早上好',
    'おはよう～',
    'にゃんぱすー'
}
local konbanwa_msg = {
    '%s 晚上好',
    'こんばんわー', '空帮哇', '空帮汪',
    'にゃんぱすー'
}
local oyasumi_msg = {
    '%s 晚安～',
    'Oyasuminasai',
    'おやすみなさい'
}
ai.register_handler('greeter',
    function (self, storage)
        storage.last_ohayo = storage.last_ohayo or 0
        storage.last_konbanwa = storage.last_konbanwa or 0
    end,

    function (self, uid, message, storage)
        local nyanpasu = message:find('にゃんぱす') or message:find('喵帕斯')
        if ai.date.time_id >= 0630 and ai.date.time_id < 0900
            and storage.last_ohayo ~= ai.date.day_id and (nyanpasu or message:find('早') or message:find('ohayo'))
        then return 1
        elseif ai.date.time_id >= 1830 and ai.date.time_id < 2230
            and storage.last_konbanwa ~= ai.date.day_id and (nyanpasu or message:find('晚好') or message:find('空帮')) -- 汪
        then return 1
        elseif (ai.date.time_id >= 2230 or ai.date.time_id < 0100)
            and (message:find('晚安') or message:find('yasumi'))
        then return 1
        else return 0 end
    end,

    function (self, uid, message, storage)
        if ai.date.time_id >= 2230 or ai.date.time_id < 0100 then
            self.send_message(string.format(ai.rand_from(oyasumi_msg), self.member_info[uid]['card']))
        elseif ai.date.time_id >= 1830 then
            storage.last_konbanwa = ai.date.day_id
            self.send_message(string.format(ai.rand_from(konbanwa_msg), self.member_info[uid]['card']))
        else
            storage.last_ohayo = ai.date.day_id
            self.send_message(string.format(ai.rand_from(ohayo_msg), self.member_info[uid]['card']))
        end
    end
)
