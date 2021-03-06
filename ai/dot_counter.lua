local dct_groupmsg = {
    '本群句号数量已经达到 %d 啦！少灌水多讨论有助于涨姿势哟～',
    '欢迎本群第 %d 个句号的粗线！（鼓掌）',
    '这似乎是第 %d 个句号了。。本群是不是水得有点厉害啊QwQ',
    '%d 个句号。。这里真是热闹呢'
}
local dct_membermsg = {
    '%s さん的句号数量刚刚突破 %d！',
    '祝贺 %s 发出了ta的第 %d 个句号～（大雾',
    '%s 发送的句号数达到了 %d。水太多不好的啦。。多讨论才是正解ww'
}

ai.register_handler('dot_counter',
    function (self, storage)
        storage.total = storage.total or 0
        storage.members = storage.members or {}
    end,

    function (self, uid, message, storage)
        -- Perfect! http://stackoverflow.com/questions/11152220
        local _, ct = string.gsub(message, '。', '')
        local l1, l2 = math.floor(storage.total / 500), math.floor((storage.members[uid] or 0) / 200)
    
        if ct > 3 then return end

        storage.total = storage.total + ct
        storage.members[uid] = (storage.members[uid] or 0) + ct
        if math.floor(storage.total / 500) > l1 then
            self:send_message(string.format(ai.rand_from(dct_groupmsg), storage.total - storage.total % 500))
        end
        if math.floor(storage.members[uid] / 200) > l2 then
            self:send_message(string.format(ai.rand_from(dct_membermsg),
                self.member_info[uid]['card'], storage.members[uid] - storage.members[uid] % 200))
        end
        
        return 0
    end,

    function () end
)
