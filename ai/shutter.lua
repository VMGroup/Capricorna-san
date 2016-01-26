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
local string_list_match = function (str, tab)
    local i
    for i = 1, #tab do if str:find(tab[i]) then return true end end
    return false
end

ai.register_handler('shutter',
    function (self, storage)
        storage.is_shut = storage.is_shut or false
        storage.is_shutting = storage.is_shutting or false
        storage.is_reviving = storage.is_reviving or false
    end,

    function (self, uin, message, storage)
        message = message:lower()
        if storage.is_shutting or storage.is_reviving then
            if string_list_match(message, confirm_triggers) then
                if storage.is_shutting then
                    self.send_message(ai.rand_from(shut_msg))
                    storage.is_shutting = false
                    storage.is_shut = true
                else
                    self.send_message(ai.rand_from(revived_msg))
                    storage.is_reviving = false
                    storage.is_shut = false
                end
                return 2
            else
                storage.is_reviving = false
                storage.is_shutting = false
            end
        elseif storage.is_shut then
            if string_list_match(message, revive_triggers) then
                self.send_message(ai.rand_from(ask_msg))
                storage.is_reviving = true
                return c
            end
            return 2
        else
            if string_list_match(message, shutup_triggers) then
                self.send_message(ai.rand_from(ask_msg))
                storage.is_shutting = true
                return 1
            end
        end
    end,

    function () end
)
