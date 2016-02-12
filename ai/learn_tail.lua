--   "cap Q"
--   "capQuestion"  (问题不区分大小写)
--   "cap  Quest     "

local told_msg = {
    {1, '咦。。%s上次告诉窝说是“%s”啊。。'},
    {1, '%s。。说好的“%s”呢 ←_←'},
    {2, '不是“%s”嘛。。（%s说的）'},
    {3, '上次说的不是这样的。。。'},
    {3, 'What? ＞＜'},
    {3, '不明觉厉ing…和说好的不一样QAQ'}
}
ai.register_handler('learn',
    function (self, storage)
    end,

    function (self, uin, message, storage)
        if not message:lower():find('cap') then return 0 end
        for k, _ in pairs(storage) do
            if k ~= ' _last_question' and message:lower():find(k) then
                storage[' _last_question'] = k
                return 1
            end
        end
        return 0
    end,

    function (self, uin, message, storage)
        self:send_message(storage[storage[' _last_question']].text)
    end
)

