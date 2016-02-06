-- http://stackoverflow.com/questions/8555320

local not_found_msg = {
    '并不知道 ╮(╯▽╰)╭',
    '随便查了一下并没有找到。。泥可以试试问度娘'
}
ai.register_handler('wiki',
    function () end,

    function (self, uin, message)
        if message:find('是什么') ~= nil or message:find('是.*啥') ~= nil then return 1
        else return 0 end
    end,

    function (self, uin, message)
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
                self:send_message('[' .. page.title .. '](1/' .. #chunks .. ')\n' .. chunks[1])
                for i = 2, #chunks do
                    zzz(2)
                    self:send_message('[' .. page.title .. '](' .. i .. '/' .. #chunks .. ')\n…' .. chunks[i])
                end
            end
        end
    end
)
