inspect = inspect or require('./libs/inspect')
require 'saver'

ai = { handlers = {} }
-- AI的核心就是这里辣
-- module:  模块名称，用于读取存储的数据
-- init:    初始化方法
-- checker: 检查器方法，返回 1 表示匹配，可以处理；返回 2 表示匹配且优先级高（用于连续对话）
-- action:  动作方法
-- 在三个函数里通过 self.members[uin] 可以得到发送者的信息（主要就是QQ号和昵称。。）
-- 每一条消息都会经过 checker，无论前面其他的模块是否返回过 1 或者 2，可以以此识别并进行连续的对话；
-- 但是只有按顺序第一个返回 true 的对应动作会被执行。
function ai.register_handler(module, init, checker, action)
    ai.handlers[#ai.handlers + 1] =
        { module = module, init = init, checker = checker, action = action }
end

-- A helper function
function ai.rand_from(t)
    return t[math.floor(math.random() * #t) + 1]
end
function ai.update_time()
    ai.date = os.date('*t')
    ai.date.day_id = ai.date.year * 370 + ai.date.yday
    ai.date.time_id = ai.date.hour * 10000 + ai.date.min * 100 + ai.date.sec
end
ai.update_time()

require 'ai/greeter'
require 'ai/dot_counter'

-- self_info:    机器人帐号的资料，一个 table
-- members_info: 群成员的资料，以 uin 作为索引，一个 number -> table 的 table
function ai.create(self, self_info, members_info, ticket)
    local ret = {}
    ret.storage = nil
    ret.self_info = self_info
    ret.member_info = members_info  -- 为了方便扩展编写以及语义，成员中省略“s” - -（有问题嘛？）
    ret.send_message = ticket       -- 用于发送消息的方法

    ret.init_storage = self.init_storage
    ret.save_storage = self.save_storage
    ret.handle = self.handle

    ret:init_storage()
    ret.storage = ret.storage or {}
    local i, t
    for i = 1, #ai.handlers do
        t = ret.storage[ai.handlers[i].module] or {}
        ai.handlers[i].init(ret, t)
        ret.storage[ai.handlers[i].module] = t
    end
    return ret
end

-- 加载AI存储的数据
function ai.init_storage(self)
    self.storage = saver.load('./ai_storage.txt')
end
-- 把AI存储的数据写入到文件
function ai.save_storage(self)
    saver.save('./ai_storage.txt', self.storage)
end

function ai.handle(self, uin, message)
    local i, t
    local one_idx, two_idx = -1, -1
    for i = 1, #ai.handlers do
        t = ai.handlers[i].checker(self, uin, message, self.storage[ai.handlers[i].module])
        if t == 2 and two_idx == -1 then two_idx = i
        elseif t == 1 and one_idx == -1 then one_idx = i
        end
    end
    if two_idx ~= -1 then
        ai.handlers[two_idx].action(self, uin, message, self.storage[ai.handlers[two_idx].module])
    elseif one_idx ~= -1 then
        ai.handlers[one_idx].action(self, uin, message, self.storage[ai.handlers[one_idx].module])
    end
    -- 如果没有一个handler匹配的话就会窥屏
    -- TODO: 要不要加一个default_handler用于取代窥屏的动作。。？
    self:save_storage()
end
