inspect = inspect or require('./libs/inspect')
require 'saver'

ai = { handlers = {}, timers = {}, filters = {} }
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

-- 安检！尤其是防止自己刷屏！！（是群里的乃们逼窝这么做的啊 QAQ）
-- module: 模块名称
-- init:   初始化，接收参数 (self, storage)
-- filter: 动作。接收参数 (self, message [string], storage)，返回一个 string 作为最终要发送的内容或者 nil 表示不更改。
function ai.register_secchk(module, init, filter)
    ai.filters[#ai.filters + 1] =
        { module = module, init = init, filter = filter }
end

-- A helper function
function ai.rand_from(t)
    local r = t[math.floor(math.random() * #t) + 1]
    if type(r) == 'table' then return table.unpack(r)
    else return r end
end
function ai.trim_query(s)
    return ('x ' .. s):match('.+ (.+)')
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
require 'ai/nominator_head'
require 'ai/learn_head'
require 'ai/dot_counter'
require 'ai/weather'
require 'ai/wiki'

-- Hybrid
require 'ai/greeter'
require 'ai/advertise'

-- Pure timers
require 'ai/welcomer'
require 'ai/learn_tail'
require 'ai/nominator_tail'

-- self_info:    机器人帐号的资料，一个 table
-- members_info: 群成员的资料，以 uin 作为索引，一个 number -> table 的 table
function ai.create(self, self_info, members_info, ticket)
    local ret = {}
    ret.storage = nil
    ret.self_info = self_info
    ret.member_info = members_info  -- 为了方便扩展编写以及语义，成员中省略“s” - -（有问题嘛？）
    ret.last_sent_time = 0          -- 上次发送消息的时间
    ret.messages_sent = 0
    ret.message_flyer = ticket      -- 用于发送消息的方法
    ret.send_message = function (self, ...)
        self.last_sent_time = ai.date.epoch
        local args = {...}
        local final_msgs = {}
        for i = 1, #args do
            local r = args[i]
            for j = 1, #ai.filters do
                r = ai.filters[j].filter(self, r, self.storage[ai.filters[j].module]) or r
            end
            if r:len() ~= 0 then final_msgs[#final_msgs + 1] = r end
        end
        if #final_msgs == 0 then return end
        self.message_flyer(final_msgs[1])
        self.messages_sent = self.messages_sent + 1
        for i = 2, #final_msgs do
            zzz(2)
            self.message_flyer(final_msgs[i])
            self.messages_sent = self.messages_sent + 1
        end
    end

    ret.get_status = self.get_status
    ret.process_commands = self.process_commands

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
    for i = 1, #ai.filters do
        t = ret.storage[ai.filters[i].module] or {}
        ai.filters[i].init(ret, t)
        ret.storage[ai.filters[i].module] = t
    end

    return ret
end

-- 加载AI存储的数据
-- 在创建时自动调用
function ai.init_storage(self)
    self.storage = saver.load('ai_storage.txt')
    self.messages_sent = self.storage._messages_sent or 0
    self.last_sent_time = self.storage._last_sent_time or 0
end
-- 把AI存储的数据写入到文件
-- 需要手动调用。。。（这个设计模式似乎略乱诶QAQ）
function ai.save_storage(self)
    self.storage._messages_sent = self.messages_sent
    self.storage._last_sent_time = self.last_sent_time
    saver.save('ai_storage.txt', self.storage)
end

-- Web API 用。主循环（main.lua）中会把这里返回的东西写入 status.txt
-- 然后 HTTP listener 会从 status.txt 读取数据返回给调用者
function ai.get_status(self)
    return {
        self_info = self.self_info,
        last_sent_time = self.last_sent_time,
        messages_sent = self.messages_sent,
        is_muted = self.storage['shutter'].is_shut,
        timestamp = ai.date.epoch
    }
end
-- Web API 用。如果有来自 Web API 的命令（比如静音/取消静音），将会被写入 commands.txt，最后作为 data 进入这里处理（详见 main.lua）
-- 此次处理过后，commands.txt 会由主循环删除，所以不用判重啦～
-- 似乎说得不是很清楚的样子。。嘛感觉代码还是挺好理解的 =w=
function ai.process_commands(self, data)
    if data['MUTE'] then
        self.storage['shutter'].is_shut = true
        self.storage['shutter'].confirming = 0
    elseif data['UNMUTE'] then
        self.storage['shutter'].is_shut = false
        self.storage['shutter'].confirming = 0
    end
end

function ai.update_member_list(self, new_list)
    self.member_info = new_list
end

function ai.handle(self, uin, message)
    local i, t
    local max_prio, slct_idx = 0, -1
    for i = 1, #ai.handlers do
        t = ai.handlers[i].checker(self, uin, message, self.storage[ai.handlers[i].module])
        if t and t > max_prio then
            max_prio = t
            slct_idx = i
        end
    end
    if max_prio > 0 then
        ai.handlers[slct_idx].action(self, uin, message, self.storage[ai.handlers[slct_idx].module])
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
