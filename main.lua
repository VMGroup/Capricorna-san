require './webqq'

local bot = webqq:create()
bot:login()
while true do bot:check_message() end
