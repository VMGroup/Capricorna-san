-- 最近这边越来越乱了QAQ 不行不行一定要找个空重构QAQ ← flag
-- 很多解释都在 ai/loader.lua 里面。。
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
            local commands = saver.load('commands.txt')
            if commands then
                print(os.time(), 'Commands', inspect(commands))
                bot.ai:process_commands(commands)
                saver.save('commands.txt', nil)
            end
            saver.save('status.txt', bot.ai:get_status())
        end
        -- 里面调用的cURL会自动等待直到收到消息。。所以不用zzz
        bot:check_message()
    end
end
