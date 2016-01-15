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

    ret.uin = 0
    ret.name = ''

    ret.try_login = self.try_login
    ret.retrieve_qrcode = self.retrieve_qrcode
    ret.login = self.login
    return ret
end

function webqq.try_login(self)
    -- 尝试根据目前 self 内的几项信息进行登录
    local r1_text = http.post('http://d1.web2.qq.com/channel/login2',
        [[{'r': '{"ptwebqq":"","clientid":53233233,"psessionid":"","status":"online"}'}]])
    local r2_text = http.get(
        string.format('http://s.web2.qq.com/api/getvfwebqq?ptwebqq=%s&clientid=%d&psessionid=%s&t=%d',
            self.ptwebqq, self.clientid, self.psessionid, os.time() * 1000))
    local r1 = json:decode(r1_text)
    local r2 = json:decode(r2_text)
    if r1['retcode'] ~= 0 or r2['retcode'] ~= 0 then
        return false
    else
        self.psessionid = r1['result']['psessionid']
        self.uin = r1['result']['uin']
        self.vfwebqq = r2['result']['vfwebqq']
        return true
    end
end

function webqq.retrieve_qrcode(self)
    -- 取得 Smart QQ 页面的真实内容（w.qq.com 上有一个 iframe）
    local entry_html = http.get('http://w.qq.com/login.html')
    -- 结尾是 "... &f_qr=" + f_qr，窝们把 f_qr = '0' 塞进去
    local redirect_url = string.match(entry_html, '%.src = "(.-)"') .. '0'
    local real_content = http.get(redirect_url)
    local appid = string.match(real_content, '<input type="hidden" name="aid" value="(%d-)"')
    -- 下载二维码
    http.download('https://ssl.ptlogin2.qq.com/ptqrshow?appid=' .. appid .. '&e=0&l=L&s=8&d=72&v=4', 'login.jpg')
    -- TODO: 增加其他系统的支持 (http://stackoverflow.com/questions/264395/)
    os.execute('open login.jpg')
end

function webqq.login(self)
    print('Logging in')
    if not self:try_login() then
        local logged_in = false
        while not logged_in do
            self:retrieve_qrcode()
            break   -- Debug use
            for i = 1, 10 do
                if self:try_login() then logged_in = true; break end
            end
        end
    end
end
