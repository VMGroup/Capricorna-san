ai = {}
function ai.register_handler(checker, action)
    ai[#ai + 1] = { checker = checker, action = action }
end

require 'ai/greeter'

return function (logger)
    local i
    for i = 1, #ai do
        logger:register_handler(ai[i].checker, ai[i].action)
    end
end
