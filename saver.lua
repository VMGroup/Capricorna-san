inspect = inspect or require('./libs/inspect')

saver = saver or {}
saver.prefix = './data/'
os.execute('mkdir ' .. saver.prefix)

function saver.load(filename)
    local f, e = loadfile(saver.prefix .. filename)
    if f then return f()
    else return {} end
end

function saver.save(filename, table)
    local f = io.open(saver.prefix .. filename, 'w')
    f:write('return ')
    f:write(inspect(table))
    f:close()
end
