-- 活到老学到老 ^^
-- 啊啊啊窝们需要自动化测试！> <
--   "CAP学习/QUESTION/ANSWER"
--   "cap学习 /quest  /ans"
--   " Cap 学习/Question Question Question /Answer"
--   "Cap   学习。/Q/A"
--   "capricorna，学习 / Trim me! /  Also trim me! "
--   "  cap 学习。。/a/b/c/d/e"  (Should not crash)

--   "cap Q"
--   "capQuestion"  (问题不区分大小写)
--   "cap  Quest     "

local get_msg = {
    'get√',
    '哦。。そうか',
    'Cap酱已经get啦～',
    '涨姿势√',
    '嗯嗯 明白明白w',
    '哦。。。。'
}
local told_msg = {
    {1, '咦。。%s上次告诉窝说是“%s”啊。。'},
    {1, '%s。。说好的“%s”呢 ←_←'},
    {2, '不是“%s”嘛。。（%s说的）'},
    {3, '上次说的不是这样的。。。'},
    {3, '窝不听窝不听＞＜'},
    {3, '不明觉厉ing…和说好的不一样QAQ'}
}
ai.register_handler('learn',
    function (self, storage)
    end,

    function (self, uin, message, storage)
        if message:lower():find('cap.*学习.*/%s*.-%s*/%s*.-%s*$') then return 1
        else
            local question = message:lower():match('cap%s*(.-)%s*$')
            if storage[question] then return 1
            else return 0 end
        end
    end,

    function (self, uin, message, storage)
        local qst, ans = message:match('学习.*/%s*(.-)%s*/%s*(.-)%s*$')
        if qst then
            --print(qst .. '-' .. ans .. '.')   -- For debug use
            qst = qst:lower()
            local last = storage[qst]
            if last then
                local typ, fmt = ai.rand_from(told_msg)
                if typ == 1 then
                    self:send_message(string.format(fmt, self.member_info[last.teacher].card, last.text))
                elseif typ == 2 then
                    self:send_message(string.format(fmt, last.text, self.member_info[last.teacher].card))
                else
                    self:send_message(fmt)
                end
            else
                -- 新增记录
                storage[qst] = { teacher = uin, text = ans }
                self:send_message(ai.rand_from(get_msg))
            end
        else
            -- 被问问题了。。
            local question = message:lower():match('cap%s*(.-)%s*$')
            self:send_message(storage[question].text)
        end
    end
)

