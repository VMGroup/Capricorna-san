require 'zzz'
require './webqq'

local bot = webqq:create()
bot:login()
-- Here we go (๑•̀ㅂ•́)و✧
while true do
    -- 里面调用的cURL会自动等待直到收到消息。。所以不用zzz
    bot:check_message()
end
