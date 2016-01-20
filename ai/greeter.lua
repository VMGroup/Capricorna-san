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
    'おはよう～'
}
ai.register_handler('greeter',
    function () end,

    function (self, uin, message)
        if math.random() < 0.5 and (message == '早' or message == '早上好' or message == 'ohayo') then return 1
        else return 0 end
    end,

    function (self, uin, message)
        self.send_message(string.format(ai.rand_from(ohayo_msg), self.member_info[uin]['nick']))
    end
)
