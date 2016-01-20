ai.register_handler('dot_counter',
    function (self, storage)
        storage.total = storage.total or 0
        storage.members = storage.members or {}
    end,

    function (self, uin, message, storage)
        if message == '。' then return 1
        else return 0 end
    end,

    function (self, uin, message, storage)
        storage.total = storage.total + 1
        storage.members[uin] = (storage.members[uin] or 0) + 1
        self.send_message('↑' .. self.member_info[uin]['card'] .. ' 的第'
            .. storage.members[uin] .. '个豆豆，总共第' .. storage.total
            .. '个豆豆')
    end
)
