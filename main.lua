if arg[1] == 'webapi' then
    os.execute('lua web-api/web-api.lua')
else
    require 'zzz'
    require './webqq'

    local bot = webqq:create()
    bot:login()
    -- Here we go (๑•̀ㅂ•́)و✧
    while true do
        if arg[1] ~= 'disable-webapi' then
            saver.save('./status.txt', bot.ai:get_status())
        end
        -- 里面调用的cURL会自动等待直到收到消息。。所以不用zzz
        bot:check_message()
    end
end
