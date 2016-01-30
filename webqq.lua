inspect = inspect or require('./libs/inspect')
json = json or require('./libs/JSON')
require './http'
require 'zzz'
require './ai/loader'

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

    ret.group_name = 'VOCALOID学习制作群'
    ret.group_gid = -1
    ret.members = {}
    ret.account_with_uin = nil

    ret.retrieve_qrcode = self.retrieve_qrcode
    ret.is_logged_in = self.is_logged_in
    ret.get_pass = self.get_pass
    ret.digest = ret.digest
    ret.find_group = self.find_group
    ret.login = self.login
    ret.check_message = self.check_message
    ret.send_message = self.send_message
    ret.get_friend_info = self.get_friend_info
    ret.get_user_account = self.get_user_account

    ret.ai = nil
    ret.init_ai = self.init_ai
    ret.handle_message = self.handle_message
    ret.check_time = self.check_time
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
        http.download('https://ssl.ptlogin2.qq.com/ptqrshow?appid=' .. appid
            .. '&e=0&l=L&s=8&d=72&v=4&t=' .. tostring(math.random()), 'login.png',
            'https://ui.ptlogin2.qq.com/cgi-bin/login?daid=164&target=self&style=16&mibao_css=m_webqq&appid=501004106&enable_qlogin=0&no_verifyimg=1&s_url=http%3A%2F%2Fw.qq.com%2Fproxy.html&f_url=loginerroralert&strong_login=1&login_state=10&t=20131024001')
        -- TODO: 增加其他系统的支持 (http://stackoverflow.com/questions/264395/)
        print('Scan the QR code (login.png) with QQ for Mobile to finish the log-in process')
        -- TODO: 根据操作系统确定打开方式
        -- https://github.com/keplerproject/luarocks/blob/master/src/luarocks/cfg.lua#L79
        --os.execute('open login.png')  -- OS X 下使用

        -- 66: 未失效；67: 验证中；65: 失效；0: 验证完成
        local status = 66, status_text
        local verifying_message_shown = false
        while status ~= 0 and status ~= 65 do
            -- 循环检查二维码状态
            zzz(3)
            status_text = http.get('https://ssl.ptlogin2.qq.com/ptqrlogin?webqq_type=10&remember_uin=1&login2qq=1&aid=' .. appid
                .. '&u1=http%3A%2F%2Fw.qq.com%2Fproxy.html%3Flogin2qq%3D1%26webqq_type%3D10&ptredirect=0&ptlang=2052&daid=164&from_ui=1&pttype=1&dumy=&fp=loginerroralert&action=0-0-' .. tostring((os.time() - start_time) * 1000)
                .. '&mibao_css=' .. pwsecur_css .. '&t=1&g=1&js_type=0&js_ver=' .. js_ver .. '&login_sig=' .. login_sig,
                'https://ui.ptlogin2.qq.com/cgi-bin/login?daid=164&target=self&style=16&mibao_css=m_webqq&appid=501004106&enable_qlogin=0&no_verifyimg=1&s_url=http%3A%2F%2Fw.qq.com%2Fproxy.html&f_url=loginerroralert&strong_login=1&login_state=10&t=20131024001')
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
            one_more_url = string.gsub(one_more_url,
                    'http%%3A%%2F%%2Fw%.qq%.com%%2Fproxy%.html%%3Flogin2qq%%3D1',
                    'http%%3A%%2F%%2Fw.qq.com%%2Fproxy.html%%3Flogin2qq%%3D1%%26webqq_type%%3D10')
            http.get(one_more_url, '')
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
    local cookie_jar_contents = cookie_jar:read('*a')
    cookie_jar:close()
    self.ptwebqq = string.match(cookie_jar_contents, 'ptwebqq%G(%w+)')
    local r1_text = http.get(
        string.format('http://s.web2.qq.com/api/getvfwebqq?ptwebqq=%s&clientid=%d&psessionid=%s&t=%d',
            self.ptwebqq, self.clientid, self.psessionid, os.time() * 1000),
            'http://s.web2.qq.com/proxy.html?v=20130916001&callback=1&id=1')
    local r1 = json:decode(r1_text)
    if r1['retcode'] ~= 0 then
        return false
    else
        self.vfwebqq = r1['result']['vfwebqq']
    end
    local r2_text = http.post('http://d1.web2.qq.com/channel/login2',
        {r = string.format('{"ptwebqq":"%s","clientid":%d,"psessionid":"%s","status":"online"}', self.ptwebqq, self.clientid, self.psessionid)},
        'http://d1.web2.qq.com/proxy.html?v=20151105001&callback=1&id=2')
    local r2 = json:decode(r2_text)
    if r2['retcode'] ~= 0 then
        return false
    else
        self.psessionid = r2['result']['psessionid']
        self.uin = r2['result']['uin']
        return true
    end
end

-- Extracted from http://0.web.qstatic.com/webqqpic/pubapps/0/50/eqq.all.js
-- P = function (b, j)   without whitespaces
-- 如果哪天提示“无法获取群数据”大概就是服务器的算法变咯。。重新翻译一遍就好辣~
-- digest(1786762946, 'cf13469ce5da24d724dda471303dc64a13a0dc5002ac10475f3e3af474c730ee')
-- > '552F063C0E990189'
function webqq.digest(b, j)
    local a, i = {[0] = 0, 0, 0, 0}
    for i = 1, j:len() do
        a[(i - 1) % 4] = bit32.bxor(a[(i - 1) % 4], j:byte(i))
    end
    local w, d = {69, 67, 79, 75}, {}
    d[1] = bit32.bxor(math.floor(b / (2^24)) % 256, w[1])
    d[2] = bit32.bxor(math.floor(b / (2^16)) % 256, w[2])
    d[3] = bit32.bxor(math.floor(b / (2^8)) % 256, w[3])
    d[4] = bit32.bxor(b % 256, w[4])
    w = {a[0], d[1], a[1], d[2], a[2], d[3], a[3], d[4]}
    a = {[0] = '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'}
    local ret = ''
    for i = 1, 8 do ret = ret .. a[math.floor(w[i] / (2^4)) % 16] .. a[w[i] % 16] end
    return ret
end
function webqq.find_group(self)
    local resp_obj = json:decode(http.post('http://s.web2.qq.com/api/get_group_name_list_mask2',
        {r = string.format('{"vfwebqq":"%s","hash":"%s"}', self.vfwebqq, webqq.digest(tonumber(self.uin), self.ptwebqq))},
        'http://s.web2.qq.com/proxy.html?v=20130916001&callback=1&id=1'))
    print(inspect(resp_obj))
    if not resp_obj or not resp_obj['result']['gnamelist'] then return false end
    local list = resp_obj['result']['gnamelist']
    local i, idx = -1
    for i = 1, #list do
        if list[i]['name'] == self.group_name then
            idx = i; break
        end
    end
    if idx == -1 then print('Group "' .. self.group_name .. '"not found. Exiting'); return false end
    self.group_gid = list[idx]['gid']
    
    print('Retrieving group info...')
    local account_map = saver.load('webqq_cache.txt') or {}
    -- 取得成员列表！
    local resp_obj2 = json:decode(http.post('http://s.web2.qq.com/api/get_group_info_ext2',
        {gcode = list[idx]['code'], vfwebqq = self.vfwebqq, t = os.time() * 1000 }))
    if not resp_obj2 or resp_obj2['retcode'] ~= 0 then
        print('[WARN] Cannot retrieve member list :( Some functionalities may not work')
    else
        local cards = {}
        local card_list = resp_obj2['result']['cards']
        local member_list = resp_obj2['result']['minfo']
        local i, t, p
        for i = 1, #card_list do
            cards[card_list[i]['muin']] = card_list[i]['card']
        end
        for i = 1, #member_list do
            t = member_list[i]['uin']
            if cards[t] == nil then
                cards[t] = member_list[i]['nick']
            end
            if account_map[t] == nil then
                -- 取得用户QQ帐号
                p = self:get_user_account(t)
                print(string.format('%d / %d', i, #member_list))
                member_list[i]['account'] = p
                account_map[t] = p
            else
                member_list[i]['account'] = account_map[t]
            end
            self.members[member_list[i]['account']] = member_list[i]
        end
        for i, t in pairs(cards) do
            self.members[account_map[i]]['card'] = t
        end
        saver.save('webqq_cache.txt', account_map)
    end
    self.account_with_uin = account_map
    return true
end

function webqq.login(self)
    print('Logging in')
    while not self:is_logged_in() do self:retrieve_qrcode() end
    while not self:get_pass() do print('Cannot get the passport T^T Retrying') end
    while not self:find_group() do print('Cannot retrieve group data T^T Retrying') end
    print('Log in successful! （≧∇≦）')
    self:init_ai()
    print('AI is up! ☆*:.｡. o(≧▽≦)o .｡.:*☆')
end

function webqq.check_message(self)
    -- 只看这一个群的消息，机器人知道太多对主板不好（大雾
    -- 本方法内进行单次请求，可以用一个 while true 之类的玩意对它不停进行调用
    -- 然后，关于下面这个 request 的内容……窝也不说什么了……
    -- 原来用的是 string.format……会炸……似乎参数的顺序会影响服务器识别……
    -- 真是。害得窝音乐会候场那一个多小时心神不宁 =^=
    local resp_text = http.post('http://d1.web2.qq.com/channel/poll2',
        {r = '{"ptwebqq":"' .. self.ptwebqq .. '","clientid":' .. tostring(self.clientid)
            .. ',"psessionid":"' .. self.psessionid .. '","key":""}'},
        'http://d1.web2.qq.com/proxy.html?v=20030916001&callback=1&id=2')
    -- 防止服务器发抽
    --   <html><body><h1>502 Bad Gateway</h1>
    --   The server returned an invalid or incomplete response.
    --   </body></html>
    if string.find(resp_text, '<html>', 1, true) then print('Oops :('); return end
    local resp_obj = json:decode(resp_text)
    if resp_obj ~= nil then
        local ret_code = resp_obj['retcode']
        if ret_code == 0 then
            local messages = resp_obj['result'], i, j, t, content
            if messages ~= nil and #messages > 0 then
                --print(inspect(messages))
                for i = 1, #messages do
                    if messages[i]['poll_type'] == 'group_message'
                        and messages[i]['value']['group_code'] == self.group_gid
                    then
                        t = messages[i]['value']
                        -- 取得发送者的信息（主要是QQ号和昵称）
                        self:handle_message(t['time'], self.account_with_uin[t['send_uin']], t['content'], t)
                    elseif messages[i]['poll_type'] == 'message' then
                        -- TODO: 自动回复好友信息 = =
                        -- TODO: 还要自动回复临时会话 = =
                        t = messages[i]['value']
                        --print(inspect(t))
                    end
                end
            end
        elseif ret_code == 116 then
            self.ptwebqq = resp_obj['p']
            print('(INFO) /channel/poll2: Value of ptwebqq updated')
        else
            print('(INFO) /channel/poll2: Unknown return code ' .. tostring(ret_code))
        end
    end
    -- ……然后抬头望向挂钟……
    self:check_time()
    self.ai:save_storage()
end

function webqq.send_message(self, text)
    print('[SENT]', inspect(text))
    local req_body = '{"group_uin":' .. self.group_gid .. ',"content":"['
    if type(text) == 'string' then
        req_body = req_body .. '\\"' .. text:gsub('\n', '\\n') .. '\\",'
    else
        for i = 1, #text do
            req_body = req_body .. '\\"' .. text[i]:gsub('\n', '\\n') .. '\\",'
        end
    end
    req_body = req_body
        .. '[\\"font\\",{\\"name\\":\\"宋体\\",\\"size\\":10,\\"style\\":[0,0,0],\\"color\\":\\"000000\\"}]]","face":522,"clientid":'
        .. self.clientid .. ',"msg_id":' .. tostring(math.floor(math.random() * 300000 + 200000))
        .. ',"psessionid":"' .. self.psessionid .. '"}'
    local resp_text = http.post('http://d1.web2.qq.com/channel/send_qun_msg2', {r = req_body}, 'http://d1.web2.qq.com/proxy.html?v=20151105001&callback=1&id=2')
    print(resp_text)
end

-- 一定要是好友
-- 这个暂时并没有用的样子。。所有群成员的信息在登录的时候就取回了。。
function webqq.get_friend_info(self, id)
    local resp = json:decode(http.get(string.format(
        'http://s.web2.qq.com/api/get_friend_info2?tuin=%d&vfwebqq=%s&clientid=%d&psessionid=%s&t=%d',
        id, self.vfwebqq, self.clientid, self.psessionid, tostring(os.time() * 1000))))
    if not resp or resp['retcode'] ~= 0 then
        return nil
    else
        return resp['result']
    end
end

function webqq.get_user_account(self, uin)
    local resp = json:decode(http.get('http://s.web2.qq.com/api/get_friend_uin2?tuin='
        .. uin .. '&verifysession=&type=1&code=&vfwebqq=' .. self.vfwebqq .. '&t=' .. tostring(os.time() * 1000),
        'http://s.web2.qq.com/proxy.html?v=20110412001&callback=1&id=3'))
    if not resp or resp['retcode'] ~= 0 then
        return nil
    else
        return resp['result']['account']
    end
end

-- 加载AI
function webqq.init_ai(self)
    self.ai = ai:create(self.full_info, self.members, function (m) self:send_message(m) end)
end

function webqq.handle_message(self, send_time, account, messages, full_data)
    local i
    local concat = ''
    for i = 1, #messages do
        if type(messages[i]) == 'string' then 
            concat = concat .. messages[i]
        end
    end
    print(send_time, os.time(), account, concat)
    --self.members[1786762946] = nil
    if account and self.members[account] ~= nil then
        self.ai:handle(account, concat)
    else
        -- 似乎有新人？（或者是系统消息之类的。。）
        local i
        local old_members = {}
        for i, _ in pairs(self.members) do old_members[i] = true end
        print('Updating members list')
        while not self:find_group() do print('Cannot retrieve group data T^T Retrying') end
        for i, _ in pairs(self.members) do
            if not old_members[i] then self.members[i].is_newcomer = true end
        end
        self.ai:update_member_list(self.members)
        -- 额如果是系统消息就不管了 -, -
        account = self.account_with_uin[full_data['send_uin']]
        if account ~= nil then self.ai:handle(account, concat) end
    end
end

function webqq.check_time(self)
    self.ai:check_time()
end
