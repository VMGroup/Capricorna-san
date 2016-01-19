ai.init_storage.dot_counter = { total = 0, members = {} }

ai.register_handler(function (self, uin, messages)
    for i = 1, #messages do
        if type(messages[i]) == 'string' and messages[i] == '。' then
            return true
        end
    end
    return false
end, function (self, uin, messages)
    self.ai_storage.dot_counter.total = self.ai_storage.dot_counter.total + 1
    self.ai_storage.dot_counter.members[uin] = (self.ai_storage.dot_counter.members[uin] or 0) + 1
    self:send_message('↑' .. self.members[uin]['card'] .. ' 的第'
        .. self.ai_storage.dot_counter.members[uin] .. '个豆豆，总共第' .. self.ai_storage.dot_counter.total
        .. '个豆豆')
end)
