pegasus = pegasus or require('pegasus')
json = json or require('./libs/JSON')
require './saver'

local server = pegasus:new({ port = '8080' })

local main_status = function ()
    ai = saver.load('status.txt')
    ai.self_info.vfwebqq = nil
    return json:encode(ai)
end

local mute = function ()
    saver.save('commands.txt', { MUTE = true })
    return '{}'
end
local unmute = function ()
    saver.save('commands.txt', { UNMUTE = true })
    return '{}'
end

local router = function (path)
    if path == '/' then return main_status()
    elseif path == '/mute' then return mute()
    elseif path == '/unmute' then return unmute()
    else return ''
    end
end

server:start(function (req, resp)
    print('Visited ' .. os.date() .. ' from ' .. req.client:getpeername())
    resp:addHeader('Access-Control-Allow-Origin', '*')
        :addHeader('Content-Type', 'application/json; charset=utf-8')
        :write(router(req:path()))
end)
