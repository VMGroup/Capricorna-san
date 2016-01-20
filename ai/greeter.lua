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
