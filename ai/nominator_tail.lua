local called_msg = {
    '嗯。。',
    '？',
    '。',
    'Here',
    '喜闻乐见',
    '啊哈哈哈哈……你说什么？'
}
local asked_msg = {
    '布吉岛',
    '不知道。。不过泥可以告诉我啊。。',
    'coder没讲过这事 = =',
    '这个时候说“nil”一定没错←_←',
    '虽然不明白你们在说什么但我觉得挠头一定是对的',
    '（假装自己明白但是不说',
    '。。今天天气真好',
    '。。阿绫出来 问你个问题',
    '作甚。。\nCap 学习/问题/应答\nCap Wiki 某某某'
}
local greet_msg = { -- 真·greeter?
    'Hello',
    'Hi',
    '泥壕',
    '窝是这里的AI之一。。请多指教ww'
}

ai.register_handler('nominator',
    function (self, storage)
        storage.called = storage.called or false
    end,

    function (self, uid, message, storage)
        if storage.called == 5 then return 1
        else return 0 end   -- 如果在前面任何一个模块中被处理过，这里的1将不会发挥作用。。
    end,

    function (self, uid, message)
        message = message:lower()
        if message:find('hello') or message:find('[^%w]?hi[^%w]?') or message:find('你好')
            or message:find('泥嚎') or message:find('泥壕')
        then self:send_message(ai.rand_from(greet_msg))
        elseif message:find('什么') or message:find('谁') or message:find('啥') then
            self:send_message(ai.rand_from(asked_msg))
        else self:send_message(ai.rand_from(called_msg)) end
    end
)
