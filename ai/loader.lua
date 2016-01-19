ai = {}
ai.storage = {}
ai.init_storage = {}
function ai.register_handler(checker, action)
    ai[#ai + 1] = { checker = checker, action = action }
end

require 'ai/greeter'
require 'ai/dot_counter'

return function (logger)
    ai.storage = logger.ai_storage or ai.init_storage
    local i
    for i = 1, #ai do
        logger:register_handler(ai[i].checker, ai[i].action)
    end
    logger.ai_storage = ai.storage  -- Lua table 记录的是引用 但是！logger.ai_storage 可能是 nil！
end
