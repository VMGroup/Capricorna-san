require './webqq'
inspect = require('./libs/inspect')

local bot = webqq:create()
bot:login()
local loader = require('./ai/loader')
bot:init_ai_storage()
loader(bot)

bot.send_message = function (self, text)
    print(inspect(text))
end
local t = io.read('*l')
while t do
    bot:handle_message(0, { t })
    bot:save_ai_storage()
    t = io.read('*l')
end
