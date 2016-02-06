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
    '又被阿绫抢镜头啦 >^<'
}
ai.register_handler('nominator',
    function () end,

    function (self, uid, message)
        if uid == partner_uid and self.last_sent_time >= ai.date.epoch - 10 then
            self:send_message(ai.rand_from(partner_greet_msg))
        end
    end,

    function () end
)
