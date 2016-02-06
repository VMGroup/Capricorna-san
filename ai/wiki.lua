-- http://stackoverflow.com/questions/8555320

local not_found_msg = {
    '并不知道 ╮(╯▽╰)╭',
    '随便查了一下并没有找到。。泥可以试试问度娘'
}
local too_much_msg = {
    '嘛。。。看上去好多的样子。。。要继续嘛。。',
    '讲不完了QAQ 叫声“继续”吧。。',
    '。。再下去目测要刷屏了哎。。继续。。？',
    'AI要听话！叫窝继续才能继续 ^^;',
    '东西好多啊 泥自己去网上查查可以不qwq',
    '窝似乎刷屏了(´Д` ) 泥们真的欢迎窝这么做嘛。。。'
}
ai.register_handler('wiki',
    function (self, storage)
        storage.last_result = storage.last_result or nil
    end,

    function (self, uin, message, storage)
        if message:find('是什么') ~= nil or message:find('是.*啥') ~= nil
            or (storage.last_result and message:find('继续') or message:find('嗯') or message:lower():find('ye[sp]')) ~= nil then return 1
        else return 0 end
    end,

    function (self, uin, message, storage)
        -- 如果五分钟以内还有东西没讲完就继续讲。。
        if storage.last_result ~= nil and storage.last_result.time >= ai.date.epoch - 300 and not message:find('是') then
            local finish = storage.last_result.pos + 3  -- inclusive [pos, pos + 3]
            if finish > #storage.last_result.chunks then finish = #storage.last_result.chunks end
            for i = storage.last_result.pos, finish do
                self:send_message('[' .. storage.last_result.title .. '](' .. i .. '/'
                    .. #storage.last_result.chunks .. ')\n…' .. storage.last_result.chunks[i])
                zzz(2)
            end
            if finish == #storage.last_result.chunks then
                storage.last_result = nil
            else
                storage.last_result.pos = finish + 1
                self:send_message(ai.rand_from(too_much_msg))
            end
            return
        end
        storage.last_result = {}
        local i, resp
        local query_str = message:sub(1, message:find('是') - 1)
        while resp == nil do
            print('Retrieving Wikipedia data...')
            resp = json:decode(http.get(
                'https://zh.wikipedia.org/w/api.php?format=json&redirects=&action=query&prop=extracts&exintro=&explaintext=&titles=' .. query_str))
        end
        local page
        for k, v in pairs(resp.query.pages) do page = v; break end
        --[[page = {
            title = 'hahahahahahaha',
            extract = '哈哈哈哈哈asdasd哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈qweqwe哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈'
        }]]
        if page.missing then
            self:send_message(ai.rand_from(not_found_msg))
        else
            local text = page.extract:match('^%s*(.-)%s*$')
            local chunks, ct, chunk_num = { '' }, 0, nil
            for pos, charcode in utf8.codes(text) do
                chunk_num = math.floor(ct / 100) + 1
                if ct % 100 == 99 then chunks[chunk_num + 1] = utf8.char(charcode) end
                chunks[chunk_num] = chunks[chunk_num] .. utf8.char(charcode)
                ct = ct + 1
            end
            if #chunks == 1 then
                self:send_message('[' .. page.title .. ']\n' .. chunks[1])
            else
                local chunk_ct = #chunks
                if #chunks > 4 then
                    -- 好多啊。。。-^-#
                    storage.last_result = { title = page.title, chunks = chunks, pos = 5, time = ai.date.epoch }
                    chunk_ct = 4
                end
                self:send_message('[' .. page.title .. '](1/' .. #chunks .. ')\n' .. chunks[1])
                for i = 2, chunk_ct do
                    zzz(2)
                    self:send_message('[' .. page.title .. '](' .. i .. '/' .. #chunks .. ')\n…' .. chunks[i])
                end
                if storage.last_result then
                    zzz(2)
                    self:send_message(ai.rand_from(too_much_msg))
                end
            end
        end
    end
)
