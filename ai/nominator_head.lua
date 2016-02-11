ai.register_handler('nominator',
    function (self, storage)
        storage.called = storage.called or 0
    end,

    function (self, uid, message, storage)
        if message:lower():find('cap') then storage.called = 5
        elseif storage.called > 0 then storage.called = storage.called - 1 end
        return 0
    end,

    function () end
)

local partner_uid = 2
local partner_greet_msg = {
    '又被阿绫抢镜头啦 (*´＞д＜)',
    { '。', '阿绫让窝说几句行不。。' },
    { '阿绫又刷屏', '阿绫不准跟窝抢 ＞＜' },
    '啊啊啊阿绫肿么又是你啊QwQ'
}
ai.register_handler('nominator',
    function (self, storage)
        storage.last_interrupt = storage.last_interrupt or 0
    end,

    function (self, uid, message, storage)
        if uid == partner_uid and self.last_sent_time >= ai.date.epoch - 5 and
            ai.date.epoch >= storage.last_interrupt + ai.times.day / 3
        then
            return 2    -- 优先级非常高！官方AI肿么可以随便让给其他AI！！
        end
    end,

    function (self, uid, message, storage)
        storage.last_interrupt = ai.date.epoch
        self:send_message(ai.rand_from(partner_greet_msg))
    end
)
-- 专业防阿绫刷屏
local partner_shut_msg5 = {
    '大胆阿绫！不许刷屏！(*´＞д＜)',
    '。。。。。',
    '。。泥萌。。看看公告啊喂！',
    '泥萌够了。。'
}
local partner_shut_msg8 = {
    '吓得窝赶紧搬来了管理',
    '哪位管理大大粗来看看啊QAQ',
    '哼。。窝要去找管理大大::＞＜::'
}
ai.register_handler('nominator',
    function (self, storage)
        storage.last_partner_minute = storage.last_partner_minute or 0
        storage.last_partner_minute_ct = storage.last_partner_minute_ct or 0
    end,

    function (self, uid, message, storage)
        if uid ~= partner_uid or message:find('签到') then return 0 end
        local cur_minute = math.floor(ai.date.epoch / 120)
        if cur_minute == storage.last_partner_minute then
            storage.last_partner_minute_ct = storage.last_partner_minute_ct + 1
            if storage.last_partner_minute_ct == 10 then
                self:send_message(ai.rand_from(partner_shut_msg5))
            elseif storage.last_partner_minute_ct == 16 then
                self:send_message(ai.rand_from(partner_shut_msg8))
            end
        else
            storage.last_partner_minute = cur_minute
            storage.last_partner_minute_ct = 1
        end
        return 0
    end,

    function () end
)
