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

local orig_send_message
local dummy_send_message = function (msg) print('[SHUT]', msg) end

ai.register_handler('shutter',
    function (self, storage)
        -- 每次程序开始运行的时候都不保持沉默
        storage.is_shut = false
        storage.confirming = 0
    end,

    function (self, uin, message, storage)
        message = message:lower()
        orig_send_message = orig_send_message or self.message_flyer
        if storage.confirming > 0 then
            if string_list_match(message, confirm_triggers) then
                if storage.is_shut then
                    self.message_flyer = orig_send_message
                    orig_send_message(ai.rand_from(revived_msg))
                else
                    orig_send_message(ai.rand_from(shut_msg))
                    self.message_flyer = dummy_send_message
                end
                storage.is_shut = not storage.is_shut
                storage.confirming = 0
                return 2
            else
                storage.confirming = storage.confirming + 1
                if storage.confirming > confirm_dur then
                    orig_send_message(ai.rand_from(cancel_msg))
                    storage.confirming = 0
                end
                return 0
            end
        elseif storage.is_shut then
            if string_list_match(message, revive_triggers) then
                orig_send_message(ai.rand_from(ask_msg))
                storage.confirming = 1
                return 1
            end
            return 2
        else
            if string_list_match(message, shutup_triggers) then
                orig_send_message(ai.rand_from(ask_msg))
                storage.confirming = 1
                return 1
            elseif message:find('阿绫') then
                return 2
            end
            return 0
        end
    end,

    function () end
)

-- 熔断机制（大雾
local initiative_shut_msg = {
    '哼。。不理你们了 ＞^＜',
    '刷屏太多了啦',
    'QAQ',
    '不玩了不玩了 (´Д` )'
}
ai.register_secchk('shutter',
    function (self, storage)
        storage.last_minute = storage.last_minute or 0
        storage.last_minute_ct = storage.last_minute_ct or 0
    end,

    function (self, message, storage)
        local cur_minute = math.floor(ai.date.epoch / 60)
        if cur_minute == storage.last_minute then
            storage.last_minute_ct = storage.last_minute_ct + 1
            if storage.last_minute_ct > 5 then
                if storage.last_minute_ct % 8 == 0 then
                    return ai.rand_from(initiative_shut_msg)
                else return '' end
            end
        else
            storage.last_minute = cur_minute
            storage.last_minute_ct = 1
        end
    end
)
