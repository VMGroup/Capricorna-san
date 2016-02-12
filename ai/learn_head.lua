-- 活到老学到老 ^^
-- 啊啊啊窝们需要自动化测试！> <
--   "CAP学习/QUESTION/ANSWER"
--   "cap学习 /quest  /ans"
--   " Cap 学习/Question Question Question /Answer"
--   "Cap   学习。/Q/A"
--   "capricorna，学习 / Trim me! /  Also trim me! "
--   "  cap 学习。。/a/b/c/d/e"  (Should not crash)

local get_msg = {
    'get√',
    '哦。。そうか',
    'Cap酱已经get啦～',
    '涨姿势√',
    '嗯嗯 明白明白w',
    '哦。。。。'
}
ai.register_handler('learn',
    function () end,

    function (self, uin, message)
        if message:lower():find('cap.*学习.*/%s*.-%s*/%s*.-%s*$') then return 1 end
    end,

    function (self, uin, message, storage)
        local qst, ans = message:match('学习.*/%s*(.-)%s*/%s*(.-)%s*$')
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
    end
)
