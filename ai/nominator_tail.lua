local called_msg = {
    '嗯。。',
    '？',
    '窝在这儿',
    'Here~'
}

ai.register_handler('nominator',
    function (self, storage)
        storage.called = storage.called or false
    end,

    function (self, uid, message, storage)
        if storage.called == 5 then return 1
        else return 0 end   -- 如果在前面任何一个模块中被处理过，这里的1将不会发挥作用。。
    end,

    function (self)
        self:send_message(ai.rand_from(called_msg))
    end
)
