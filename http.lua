http = {}
http.cookie_jar = 'cookies.txt'
local inspect = require('./libs/inspect')

function http.get(url, referer)
    referer = referer or 'http://s.web2.qq.com/proxy.html?v=20130916001&callback=1&id=1'
    --print('[GET]  ' .. url)
    local handle = io.popen('curl -q -k -s -b ' .. http.cookie_jar .. ' -c ' .. http.cookie_jar .. ' -X GET '
        .. '-e "' .. referer .. '" '
        .. '-m 10 "' .. url .. '"', 'r')
    local response = handle:read('*a')
    handle:close()
    return response
end

function http.post(url, content, referer)
    referer = referer or 'http://s.web2.qq.com/proxy.html?v=20130916001&callback=1&id=1'
    --print('[POST] ' .. url)
    --print(inspect(content))
    local handle = io.popen('curl -q -k -s -b ' .. http.cookie_jar .. ' -c ' .. http.cookie_jar .. ' -X POST '
        .. '-e "' .. referer .. '" '
        .. '-H "Content-Type: application/x-www-form-urlencoded" '
        .. '-m 10 "' .. url .. '" -d "' .. http.urlencode(content) .. '"', 'r')
    local response = handle:read('*a')
    handle:close()
    return response
end

function http.download(url, path, referer)
    referer = referer or 'http://s.web2.qq.com/proxy.html?v=20130916001&callback=1&id=1'
    local handle = io.popen('curl -q -k -s -b ' .. http.cookie_jar .. ' -c ' .. http.cookie_jar .. ' -X GET '
        .. '-e "' .. referer .. '" '
        .. '-o "' .. path .. '" "' .. url .. '"', 'r')
    handle:close()
end

-- http.urlencode({a = '%%%%""""膜膜膜膜', b = '＊＊＊＊'})
-- > 'a=%25%25%25%25%22%22%22%22%E8%86%9C%E8%86%9C%E8%86%9C%E8%86%9C&b=%EF%BC%8A%EF%BC%8A%EF%BC%8A%EF%BC%8A'
function http.urlencode(table)
    local ret = '', k, v, i, t
    for k, v in pairs(table) do
        ret = ret .. '&' .. k .. '='
        v = tostring(v)
        for i = 1, v:len() do
            t = v:byte(i)
            if (t >= 48 and t <= 57) or (t >= 65 and t <= 90) or (t >= 97 and t <= 122) then
                ret = ret .. v:sub(i, i)
            else ret = ret .. string.format('%%%2X', t) end
        end
    end
    return ret:sub(2)
end
