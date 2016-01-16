local inspect = require('./libs/inspect')
local json = require('./libs/JSON')
require './http'

webqq = {}

function webqq.create(self)
    local ret = {}
    -- HTTP 请求用到的参数
    ret.ptwebqq = ''
    ret.clientid = 53999199
    ret.psessionid = ''
    ret.appid = 0
    ret.vfwebqq = ''

    ret.uin = 0
    ret.name = ''
    ret.full_info = nil

    -- 哎原来这玩意不是群号。。。。。(/_ ;)
    ret.listen_group = 2061323564

    ret.retrieve_qrcode = self.retrieve_qrcode
    ret.is_logged_in = self.is_logged_in
    ret.get_pass = self.get_pass
    ret.login = self.login
    ret.check_message = self.check_message
    return ret
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

function webqq.is_logged_in(self)
    local info_resp = json:decode(http.get('http://s.web2.qq.com/api/get_self_info2'))
    if info_resp['retcode'] ~= 0 then return false end
    local my_info = info_resp['result']
    print("Hello. I'm " .. my_info['nick'] .. ' (' .. tostring(my_info['uin']) .. ')')
    local today = os.date('%Y %m %d')
    local y, m, d = string.match(today, '(%d-) (%d-) (%d*)')
    if m == my_info['birthday']['month'] and d == my_info['birthday']['day'] then
        print('Happy birthday ' .. tostring(y - my_info['birthday']['year']) .. '-year-old ' .. my_info['nick'] .. '!! ☆*:.｡. o(≧▽≦)o .｡.:*☆')
    end
    self.uin = my_info['uin']
    self.name = my_info['nick']
    self.full_info = my_info
    return true
end

-- 获取发送/接收消息用的 session ID 等
function webqq.get_pass(self)
    -- Workaround. 直接从 cookies.txt 读取 Cookie……
    local cookie_jar = io.open(http.cookie_jar, 'r')
    local cookie_jar_contents = cookie_jar:read('a')
    cookie_jar:close()
    self.ptwebqq = string.match(cookie_jar_contents, 'ptwebqq%G(%w+)')
    local r1_text = http.post('http://d1.web2.qq.com/channel/login2',
        {r = string.format('{"ptwebqq":"%s","clientid":%d,"psessionid":"","status":"online"}', self.ptwebqq, self.clientid)})
    local r1 = json:decode(r1_text)
    if r1['retcode'] ~= 0 then
        return false
    else
        self.psessionid = r1['result']['psessionid']
        self.uin = r1['result']['uin']
    end
    local r2_text = http.get(
        string.format('http://s.web2.qq.com/api/getvfwebqq?ptwebqq=%s&clientid=%d&psessionid=%s&t=%d',
            self.ptwebqq, self.clientid, self.psessionid, os.time() * 1000))
    local r2 = json:decode(r2_text)
    if r2['retcode'] ~= 0 then
        return false
    else
        self.vfwebqq = r2['result']['vfwebqq']
        return true
    end
end

function webqq.login(self)
    print('Logging in')
    while not self:is_logged_in() do self:retrieve_qrcode() end
    while not self:get_pass() do print('Cannot get the passport T^T Retrying') end
    print('Log in successful! （≧∇≦）')
end

function webqq.check_message(self)
    -- 只看这一个群的消息，机器人知道太多对主板不好（大雾
    -- 本方法内进行单次请求，可以用一个 while true 之类的玩意对它不停进行调用
    -- 然后，关于下面这个 request 的内容……窝也不说什么了……
    -- 原来用的是 string.format……会炸……似乎参数的顺序会影响服务器识别……
    -- 真是。害得窝音乐会候场那一个多小时心神不宁 =^=
    local resp_text = http.post('http://d1.web2.qq.com/channel/poll2',
        {r = '{"ptwebqq":"' .. self.ptwebqq .. '","clientid":' .. tostring(self.clientid)
            .. ',"psessionid":"' .. self.psessionid .. '","key":""}'})
    local resp_obj = json:decode(resp_text)
    if resp_obj ~= nil then
        local ret_code = resp_obj['retcode']
        if ret_code == 0 then
            local messages = resp_obj['result'], i, t
            if messages ~= nil and #messages > 0 then
                print(inspect(t))
                for i = 1, #messages do if messages[i]['poll_type'] == 'group_message'
                    and messages[i]['value']['group_code'] == self.listen_group
                then
                    t = messages[i]['value']
                    --print(t['time'], t['send_uin'], inspect(t['content']))
                    print(inspect(t))
                end end
                for i = 1, #messages do if messages[i]['poll_type'] == 'message' then
                    t = messages[i]['value']
                    print(inspect(t))
                end end
            end
        elseif ret_code == 116 then
            self.ptwebqq = resp_obj['p']
            print('(INFO) /channel/poll2: Value of ptwebqq updated')
        else
            print('(INFO) /channel/poll2: Unknown return code ' .. tostring(ret_code))
        end
    end
end
