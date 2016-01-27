json = json or require('./libs/JSON')
require './http'

local api_key = '21b1550dccd8e2b660b7bed89deb2fd1'

-- 东南西北
local dirs = {
    '北', '北-东北', '东北', '东北-东', '东', '东-东南', '东南', '东南-南',
    '南', '南-西南', '西南', '西南-西', '西', '西-西北', '西北', '西北-北'
}
local dir_desc = function (deg)
    return dirs[math.floor(math.fmod(deg + 11.25, 360) / (360 / 16)) + 1]
end
local weather_report = function (d)
    local s = d.orig_name .. '[' .. d.name .. '] 天气（' .. os.date('%Y-%m-%d %H:%M', d.dt) .. ' 更新）：\n'
        .. d.weather[1].description .. ' 温度：' .. d.main.temp .. '℃；\n'
        .. '气压：' .. d.main.pressure .. ' hPa；相对湿度：' .. d.main.humidity .. '%；\n'
        .. '风力：' .. d.wind.speed .. '级'
    if d.wind.deg then
        s = s .. '；风向：' .. dir_desc(d.wind.deg) .. '（' .. d.wind.deg .. '°）'
    end
    s = s .. '\n数据来源：OpenWeatherMap'
    return s
end
local weather_forecast = function (d)
    local s = d.orig_name .. '[' .. d.city.name .. '] 天气预报：\n'
    local i, last_disp, cur = 0, 0, nil
    for i = 1, #d.list do if d.list[i].dt >= last_disp + 86400 then
        cur = d.list[i]
        last_disp = cur.dt
        s = s .. os.date('%Y-%m-%d', last_disp) .. '：'
            .. cur.weather[1].description .. ' '
            .. math.floor(cur.main.temp_min) .. '℃ ~ ' .. math.floor(cur.main.temp_max) .. '℃ 风力' .. cur.wind.speed .. '级\n'
    end end
    return s .. '数据来源：OpenWeatherMap'
end
local chn_trim = function (s)
    if s:sub(-3) == '的' then s = s:sub(1, -4) end
    if s:sub(-6) == '今天' or s:sub(-6) == '现在' or s:sub(-6) == '明天' or s:sub(-6) == '后天'
        or s:sub(-6) == '下周' or s:sub(-6) == '一周' then s = s:sub(1, -7) end
    return s
end
ai.register_handler('weather',
    function () end,

    function (self, uin, message)
        local p = message:find('天气')
        if p and p <= 24 then return 1
        else return 0 end
    end,

    function (self, uin, message)
        local i, resp
        local city_name = chn_trim(message:sub(1, message:find('天气') - 1))
        local is_forecast = ((message:find('预报') or message:find('未来') or message:find('明天')
            or message:find('后天') or message:find('下周') or message:find('一周')) ~= nil)
        while resp == nil do
            print('Retrieving weather data...')
            if is_forecast then
                resp = json:decode(http.get(
                    'http://api.openweathermap.org/data/2.5/forecast?q=' .. city_name .. '&units=metric&lang=zh_cn&appid=' .. api_key))
            else
                resp = json:decode(http.get(
                    'http://api.openweathermap.org/data/2.5/weather?q=' .. city_name .. '&units=metric&lang=zh_cn&appid=' .. api_key))
            end
        end
        if type(resp) ~= 'table' then return end
        if tonumber(resp.cod) == 200 then
            resp.orig_name = city_name
            if is_forecast then
                self.send_message(weather_forecast(resp))
            else
                self.send_message(weather_report(resp))
            end
        elseif tonumber(resp.cod) == 404 then
            self.send_message('并不知道泥在说哪个城市啊。。试下“北京天气”这样的说法')
        else
            self.send_message('无法取得' .. city_name .. '的天气数据（Return code: ' .. tostring(resp.cod) .. '）T^T')
        end
    end
)

local sunrise_sunset_report = function (d)
    return d.orig_name .. '[' .. d.name .. '] ' .. os.date('%Y-%m-%d') .. '\n'
        .. '日出时间：' .. os.date('%H:%M', d.sys.sunrise) .. '；日落时间：' .. os.date('%H:%M', d.sys.sunset)
        .. '\n数据来源：OpenWeatherMap'
end
ai.register_handler('weather',
    function () end,

    function (self, uin, message)
        local p = message:find('日出') or message:find('日落')
        if p and p <= 24 then return 1
        else return 0 end
    end,

    function (self, uin, message)
        local i, resp
        local city_name = chn_trim(message:sub(1, (message:find('日出') or message:find('日落')) - 1))
        while resp == nil do
            print('Retrieving weather data...')
            resp = json:decode(http.get(
                'http://api.openweathermap.org/data/2.5/weather?q=' .. city_name .. '&units=metric&lang=zh_cn&appid=' .. api_key))
        end
        if type(resp) ~= 'table' then return end
        if tonumber(resp.cod) == 200 then
            resp.orig_name = city_name
            self.send_message(sunrise_sunset_report(resp))
        elseif tonumber(resp.cod) == 404 then
            self.send_message('并不知道泥在说哪个城市啊。。试下“北京日出日落”这样的说法')
        else
            self.send_message('无法取得' .. city_name .. '的天气数据（Return code: ' .. tostring(resp.cod) .. '）T^T')
        end
    end
)
