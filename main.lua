require 'zzz'
require './webqq'

local bot = webqq:create()
bot:login()
-- 加载所有AI模块
local loader = require('./ai/loader')
loader(bot)
-- Here we go (๑•̀ㅂ•́)و✧
while true do
    -- 里面调用的cURL会自动等待直到收到消息。。所以不用zzz
    bot:check_message()
    lastday_wakeup = ''
    if os.date('%H%M') == '0730' then
        lastday_wakeup = os.date('%Y%m%d')
        bot:send_message('起床咯')
    end
end
