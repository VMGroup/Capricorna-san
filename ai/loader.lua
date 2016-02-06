inspect = inspect or require('./libs/inspect')
require 'saver'

ai = { handlers = {}, timers = {} }
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

-- module:   模块名称
-- min_intv: 两次触发的最小时间间隔（秒），一般可以设为触发执行间隔的一半左右。。（随便啦
ai.times = { season = 7884000, month = 2592000, week = 604800, day = 86400, hour = 3600, minute = 60, second = 1 }
-- checker:  检查器，返回 true/false
-- action:   执行的动作
-- XXX: 初始化。。还需要嘛。。？？
function ai.register_timer(module, min_intv, checker, action)
    ai.timers[#ai.timers + 1] =
        { module = module, min_intv = min_intv, checker = checker, action = action, last_triggered = 0 }
end

-- A helper function
function ai.rand_from(t)
    return t[math.floor(math.random() * #t) + 1]
end
function ai.update_time()
    ai.date = os.date('*t')
    ai.date.day_id = ai.date.year * 370 + ai.date.yday
    ai.date.time_id = ai.date.hour * 10000 + ai.date.min * 100 + ai.date.sec
    ai.date.epoch = os.time()
end
ai.update_time()

-- Pure triggers
require 'ai/shutter'
require 'ai/dot_counter'
require 'ai/weather'
require 'ai/wiki'

-- Hybrid
require 'ai/greeter'
require 'ai/advertise'

-- Pure timers
require 'ai/welcomer'
require 'ai/wakeup'

-- self_info:    机器人帐号的资料，一个 table
-- members_info: 群成员的资料，以 uin 作为索引，一个 number -> table 的 table
function ai.create(self, self_info, members_info, ticket)
    local ret = {}
    ret.storage = nil
    ret.self_info = self_info
    ret.member_info = members_info  -- 为了方便扩展编写以及语义，成员中省略“s” - -（有问题嘛？）
    ret.last_sent = 0               -- 上次发送消息的时间
    ret.message_flyer = ticket      -- 用于发送消息的方法
    ret.send_message = function (self, ...)
        self.last_sent = ai.date.epoch
        self.message_flyer(...)
    end

    ret.init_storage = self.init_storage
    ret.save_storage = self.save_storage
    ret.update_member_list = self.update_member_list
    ret.handle = self.handle
    ret.check_time = self.check_time

    ret:init_storage()
    ret.storage = ret.storage or {}
    local i, t
    for i = 1, #ai.handlers do
        t = ret.storage[ai.handlers[i].module] or {}
        ai.handlers[i].init(ret, t)
        ret.storage[ai.handlers[i].module] = t
    end
    for i = 1, #ai.timers do
        t = ret.storage[ai.timers[i].module] or {}
        ret.storage[ai.timers[i].module] = t
    end
    return ret
end

-- 加载AI存储的数据
-- 在创建时自动调用
function ai.init_storage(self)
    self.storage = saver.load('./ai_storage.txt')
end
-- 把AI存储的数据写入到文件
-- 需要手动调用。。。（这个设计模式似乎略乱诶QAQ）
function ai.save_storage(self)
    saver.save('./ai_storage.txt', self.storage)
end

function ai.update_member_list(self, new_list)
    self.member_info = new_list
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
end

function ai.check_time(self)
    ai.update_time()
    local i, t
    for i = 1, #ai.timers do
        t = ai.timers[i]
        if (ai.date.epoch >= t.last_triggered + t.min_intv)
            and t.checker(self, self.storage[ai.timers[i].module])
        then
            t.action(self, self.storage[ai.timers[i].module])
            t.last_triggered = ai.date.epoch
        end
    end
end
