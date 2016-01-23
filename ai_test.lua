inspect = inspect or require('./libs/inspect')
require './ai/loader'

local zodiac = {
    [1] = 'Aries', [2] = 'Taurus', [3] = 'Gemini', [4] = 'Cancer',
    [5] = 'Leo', [6] = 'Virgo', [7] = 'Libra', [8] = 'Scorpio',
    [9] = 'Sagittarius', [10] = 'Capricornus', [11] = 'Aquarius', [12] = 'Pisces'
}
local zodiac_group_members = {}
for i = 1, 12 do
    zodiac_group_members[i] = {
        uin = i,
        card = zodiac[i],
        nick = zodiac[i]
    }
end
local yagi = ai:create({
    nick = 'Yagi'
}, zodiac_group_members, function (m) print(m) end)

local t = io.read('*l')
local sender = 12
local try_sender
while t do
    yagi:check_time()
    try_sender = string.match(t, 'sender (%d+)')
    try_newcomer = string.match(t, 'newcomer (.+)')
    if try_sender then
        try_sender = tonumber(try_sender)
        if type(try_sender) == 'number' and try_sender >= 1 and try_sender <= 12 then
            sender = try_sender
        else print('Invalid sender :( Only 1 ~ 12 can be accepted') end
    elseif try_newcomer then
        zodiac_group_members[#zodiac_group_members + 1] = {
            uin = #zodiac_group_members + 1,
            card = try_newcomer,
            nick = try_newcomer,
            is_newcomer = true
        }
    else
        yagi:handle(sender, t)
    end
    t = io.read('*l')
end
