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
        if page.missing then
            self.send_message(ai.rand_from(not_found_msg))
        else
            self.send_message('[' .. page.title .. ']\n' .. page.extract)
        end
    end
)
