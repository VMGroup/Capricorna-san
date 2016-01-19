ai.init_storage.dot_counter = { total = 0 }

ai.register_handler(function (self, uin, messages)
    for i = 1, #messages do
        if type(messages[i]) == 'string' and messages[i] == '。' then
            return true
        end
    end
    return false
end, function (self, uin, messages)
    self.ai_storage.dot_counter.total = self.ai_storage.dot_counter.total + 1
    self:send_message(string.rep('。', self.ai_storage.dot_counter.total))
end)
