http = {}

function http.get(url)
    local handle = io.popen('curl -q -k -s -X GET '
        .. '-e "http://d1.web2.qq.com/proxy.html?v=20151105001&callback=1&id=2" '
        .. '-m 10 ' .. url, 'r')
    local result = handle:read('*a')
    handle:close()
    return result
end

function http.post(url, content)
    local handle = io.popen('curl -q -k -s -X POST '
        .. '-e "http://d1.web2.qq.com/proxy.html?v=20151105001&callback=1&id=2" '
        .. '-m 10 ' .. url .. ' -d "' .. string.gsub(content, '"', '\\\"') .. '"', 'r')
    local result = handle:read('*a')
    handle:close()
    return result
end
