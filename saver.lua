inspect = inspect or require('./libs/inspect')

saver = saver or {}

function saver.load(filename)
    local f, e = loadfile(filename)
    if f then return f()
    else return nil, e end
end

function saver.save(filename, table)
    local f = io.open(filename, 'w')
    f:write('return ')
    f:write(inspect(table))
    f:close()
end
