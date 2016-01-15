http = {}
http.cookie_jar = 'cookies.txt'

function http.get(url)
    local handle = io.popen('curl -q -k -s -b ' .. http.cookie_jar .. ' -c ' .. http.cookie_jar .. ' -X GET '
        .. '-e "http://d1.web2.qq.com/proxy.html?v=20151105001&callback=1&id=2" '
        .. '-m 10 "' .. url .. '"', 'r')
    local response = handle:read('*a')
    handle:close()
    return response
end

function http.post(url, content)
    local handle = io.popen('curl -q -k -s -b ' .. http.cookie_jar .. ' -c ' .. http.cookie_jar .. ' -X POST '
        .. '-e "http://d1.web2.qq.com/proxy.html?v=20151105001&callback=1&id=2" '
        .. '-m 10 "' .. url .. '" -d "' .. string.gsub(content, '"', '\\\"') .. '"', 'r')
    local response = handle:read('*a')
    handle:close()
    return response
end

function http.download(url, path)
    local handle = io.popen('curl -q -k -s -b ' .. http.cookie_jar .. ' -c ' .. http.cookie_jar .. ' -X GET '
        .. '-e "http://d1.web2.qq.com/proxy.html?v=20151105001&callback=1&id=2" '
        .. '-o "' .. path .. '" "' .. url .. '"', 'r')
    handle:close()
end
