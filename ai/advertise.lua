ai.register_handler('advertise',
    function (self, storage)
    end,

    function (self, uid, message, storage)
        if message:sub(1, 6) == '安利' or message == '取消安利' then return 1
        else return 0 end
    end,

    function (self, uid, message, storage)
        if message:find('取消.+安利') then
            storage[uid] = nil
            self:send_message('安利已经停下啦～')
        else
            message = message:sub(7):match('^%s*(.-)%s*$')  -- 先 trim 一发
            storage[uid] = message
            self:send_message('收到啦√ 这条消息会出现在以后的定时安利中～（随时说一声“取消安利”就可以停下了哦）')
        end
    end
)

ai.register_timer('advertise',
    ai.times.hour * 2 - ai.times.minute * 2,
    function (self)
        return ai.date.time_id % 20000 <= 200
    end,

    function (self, storage)
        local list = {}
        for k, v in pairs(storage) do list[#list + 1] = {k, v} end
        if #list == 0 then return end
        local i = ai.rand_from(list)
        self:send_message(
            '定时安利 [' .. os.date('%Y-%m-%d %H点整') .. ']\n'
            .. i[2] .. '\n——来自 ' .. self.member_info[i[1]].nick)
    end
)
