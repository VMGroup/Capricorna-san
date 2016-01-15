local inspect = require('./libs/inspect')
local json = require('./libs/JSON')
require './http'

webqq = {}

function webqq.create(self)
    local ret = {}
    -- HTTP 请求用到的参数
    ret.ptwebqq = ''
    ret.clientid = 52333233
    ret.psessionid = ''
    ret.appid = 0
    ret.vfwebqq = ''
    ret.login = self.login
    return ret
end

function webqq.login(self)
    print('Logging in')
    local r1_text = http.post('http://d1.web2.qq.com/channel/login2',
        [[{'r': '{"ptwebqq":"","clientid":53233233,"psessionid":"","status":"online"}'}]])
    local r2_text = http.get(
        string.format('http://s.web2.qq.com/api/getvfwebqq?ptwebqq=%s&clientid=%d&psessionid=%s&t=%d',
            self.ptwebqq, self.clientid, self.psessionid, os.time() * 1000))
    local r1 = json:decode(r1_text)
    local r2 = json:decode(r2_text)
    print(inspect(r1))
    print(inspect(r2))
end
