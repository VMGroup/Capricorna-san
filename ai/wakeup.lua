ai.register_timer('wakeup',
    ai.times.day - ai.times.minute * 5,
    function (self)
        return ai.date.time_id >= 080000 and ai.date.time_id <= 080500
    end,

    function (self)
        self.send_message('起床咯')    -- (¦3[▓▓]
    end
)
