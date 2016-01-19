ai.register_handler(function (self, uin, messages)
    for i = 1, #messages do
        if type(messages[i]) == 'string' and messages[i] == 'ww' then
            return true
        end
    end
    return false
end, function (self, uin, messages)
    self:send_message('wwwwwwwwwww')
end)
