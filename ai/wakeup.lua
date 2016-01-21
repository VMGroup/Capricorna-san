ai.register_timer('wakeup',
    ai.times.day * 0.7,
    function (self)
        return ai.date.time_id >= 0800 and ai.date.time_id <= 0805
    end,

    function (self)
        self.send_message('起床咯')    -- (¦3[▓▓]
    end
)
