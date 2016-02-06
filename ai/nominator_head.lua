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
