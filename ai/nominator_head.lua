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

local partner_uid = 1963028587
local partner_greet_msg = {
    '又被阿绫抢镜头啦 ＞^＜',
    { '。', '阿绫让窝说几句行不。。' },
    { '阿绫又刷屏', '阿绫不准跟窝抢 ＞＜' },
    '啊啊啊阿绫肿么又是你啊QwQ'
}
ai.register_handler('nominator',
    function () end,

    function (self, uid, message)
        if uid == partner_uid and self.last_sent_time >= ai.date.epoch - 5 then
            return 2    -- 优先级非常高！官方AI肿么可以随便让给其他AI！！
        end
    end,

    function (self)
        self:send_message(ai.rand_from(partner_greet_msg))
    end
)
