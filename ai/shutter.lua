-- -x- 沉默是金。

local shutup_triggers = {
    'shut up', '关机', '屏蔽', '闭嘴', 'power off'
}
local ask_msg = {
    '啊。。说我么',
    '是在叫我嘛'
}
local confirm_triggers = {
    '嗯', '[^不]对', '[^不]是', 'ye[sp]', 'en'
}
local shut_msg = {
    '好的好的 -x-',
    '啊抱歉。。似乎影响到你们了QAQ',
    'ごめんなさい〜打扰到你们的话尽管提意见。。'
}
local revive_triggers = {
    '复活', '开机'
}
local revived_msg = {
    'ｖ（＾＿＾ｖ）♪ 窝又复活啦'
}
local cancel_msg = {
    '不是窝。。回去潜水咯'
}
local confirm_dur = 5
local string_list_match = function (str, tab)
    local i
    for i = 1, #tab do if str:find(tab[i]) then return true end end
    return false
end

ai.register_handler('shutter',
    function (self, storage)
        storage.is_shut = storage.is_shut or false
        storage.confirming = storage.confirming or 0
    end,

    function (self, uin, message, storage)
        message = message:lower()
        if storage.confirming > 0 then
            if string_list_match(message, confirm_triggers) then
                if storage.is_shut then
                    self.send_message(ai.rand_from(revived_msg))
                else
                    self.send_message(ai.rand_from(shut_msg))
                end
                storage.is_shut = not storage.is_shut
                storage.confirming = 0
                return 2
            else
                storage.confirming = storage.confirming + 1
                if storage.confirming > confirm_dur then
                    self.send_message(ai.rand_from(cancel_msg))
                    storage.confirming = 0
                end
            end
        elseif storage.is_shut then
            if string_list_match(message, revive_triggers) then
                self.send_message(ai.rand_from(ask_msg))
                storage.confirming = 1
                return 1
            end
            return 2
        else
            if string_list_match(message, shutup_triggers) then
                self.send_message(ai.rand_from(ask_msg))
                storage.confirming = 1
                return 1
            end
        end
    end,

    function () end
)
