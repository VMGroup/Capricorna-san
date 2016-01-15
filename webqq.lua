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
    print('Bring your phone. You\'ll need it ;)')
    -- 取得 Smart QQ 页面的真实内容（w.qq.com 上有一个 iframe）
    local entry_html = http.get('http://w.qq.com/login.html')
    -- 结尾是 "... &f_qr=" + f_qr，窝们把 f_qr = '0' 塞进去
    local redirect_url = string.match(entry_html, '%.src = "(.-)"') .. '0'
    local real_content = http.get(redirect_url)
    local appid = string.match(real_content, '<input type="hidden" name="aid" value="(%d-)"')
    -- 三个确认二维码状态时用到的参数
    local pwsecur_css = string.match(real_content, 'g_mibao_css=encodeURIComponent%("(.-)"%)')
    local js_ver = string.match(real_content, 'g_pt_version=encodeURIComponent%("(.-)"%)')
    local login_sig = string.match(real_content, 'g_login_sig=encodeURIComponent%("(.-)"%)')

    local attempts = 0
    while attempts < 10 do
        local start_time = os.time()
        -- 下载二维码
        http.download('https://ssl.ptlogin2.qq.com/ptqrshow?appid=' .. appid .. '&e=0&l=L&s=8&d=72&v=4', 'login.jpg')
        -- TODO: 增加其他系统的支持 (http://stackoverflow.com/questions/264395/)
        print('Scan the QR code (login.jpg) with QQ for Mobile to finish the log-in process')
        --os.execute('open login.jpg')

        -- 66: 未失效；67: 验证中；65: 失效；0: 验证完成
        local status = 66, status_text
        local verifying_message_shown = false
        while status ~= 0 and status ~= 65 do
            -- 循环检查二维码状态
            status_text = http.get('https://ssl.ptlogin2.qq.com/ptqrlogin?webqq_type=10&remember_uin=1&login2qq=1&aid=' .. appid
                .. '&u1=http%3A%2F%2Fw.qq.com%2Fproxy.html%3Flogin2qq%3D1%26webqq_type%3D10&ptredirect=0&ptlang=2052&daid=164&from_ui=1&pttype=1&dumy=&fp=loginerroralert&action=0-0-' .. tostring((os.time() - start_time) * 1000)
                .. '&mibao_css=' .. pwsecur_css .. '&t=undefined&g=1&js_type=0&js_ver=' .. js_ver .. '&login_sig=' .. login_sig)
            -- status_text: ptuiCB('66','0','','0','二维码未失效。(3616543552)', '');
            status = tonumber(string.match(status_text, "ptuiCB%('(%d-)'"))
            if status == 67 and not verifying_message_shown then
                verifying_message_shown = true
                print('Nearly there! I can see you\'re holding your phone ←_←')
            end
        end
        if status == 0 then
            print('QR code verified! Just a few more seconds!')
            local one_more_url = string.match(status_text, "ptuiCB%('%d-',.-'%d-',.-'(.-)'")
            http.get(one_more_url)
            break
        else
            print('QR code expired. Getting another...')
        end
        attempts = attempts + 1
    end
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
    print('Log in successful! （≧∇≦）')
    local info_resp = json:decode(http.get('http://s.web2.qq.com/api/get_self_info2'))
    if info_resp['retcode'] ~= 0 then
        print('Failed to retrieve account information... I don\'t know what to do either >^<')
        return false
    end
    local my_info = info_resp['result']
    print("Hello. I'm " .. my_info['nick'] .. ' (' .. tostring(my_info['uin']) .. ')')
    local today = os.date('%Y %m %d')
    local y, m, d = string.match(today, '(%d-) (%d-) (%d*)')
    if m == my_info['birthday']['month'] and d == my_info['birthday']['day'] then
        print('Happy birthday ' .. tostring(y - my_info['birthday']['year']) .. '-year-old ' .. my_info['nick'] .. '!! ☆*:.｡. o(≧▽≦)o .｡.:*☆')
    end
    return true
end
