json = json or require('./libs/json')
require './http'

--local api_key = 'f6a3c950db757b5268a621dfc2ad4e7c'
--local api_key = '21b1550dccd8e2b660b7bed89deb2fd1'
local api_key = '44db6a862fba0b067b1930da0d769e98'
-- Extracted from http://bulk.openweathermap.org/sample/city.list.json.gz
local cities = {
    {'拉萨', 1280737},
    {'郑州', 1784658},
    {'仙居', 1790413},
    {'上海', 1796236},
    {'攀枝花', 6929460}
}

-- http://openweathermap.org/weather-conditions
local weather_desc = {
    [500] = '小雨',
    [501] = '中雨',
    [502] = '大雨',
    [503] = '炒鸡大雨',
    [504] = '极限大雨QAQ',

    [600] = '小雪',
    [601] = '中雪',
    [602] = '大雪',
    [611] = '雨夹雪',
    [612] = '大雨夹雪',
    [615] = '小雨夹雪',
    [616] = '雨夹雪',
    [620] = '小型炒鸡大雪',
    [621] = '中型炒鸡大雪',
    [622] = '大型炒鸡大雪',

    [701] = '薄雾',
    [711] = '烟雾（窝也不知道是什么）',
    [721] = '霾QAQ',
    [731] = 'sand, dust whirls',
    [741] = '雾',
    [751] = '沙尘',
    [761] = '沙尘',
    [762] = '沙尘/火山灰',
    [771] = '暴风',
    [781] = '龙卷风',

    [800] = '晴空万里',
    [801] = '晴（少云）',
    [802] = '疏云',
    [803] = '多云',
    [804] = '阴云'
}
-- 东南西北
local dirs = {
    '北', '北-东北', '东北', '东北-东', '东', '东-东南', '东南', '东南-南',
    '南', '南-西南', '西南', '西南-西', '西', '西-西北', '西北', '西北-北'
}
local dir_desc = function (deg)
    return dirs[math.floor(math.fmod(deg + 11.25, 360) / (360 / 16)) + 1]
end
local weather_report = function (d)
    return d.orig_name .. '[' .. d.name .. '] 天气（' .. os.date('%Y-%m-%d %H:%M', d.dt) .. ' 更新）：\n'
        .. (weather_desc[d.weather[1].id] or d.weather[1].description) .. '\n'
        .. '温度：' .. d.main.temp .. '℃（' .. d.main.temp_min .. '℃ ~ ' .. d.main.temp_max .. '℃）；\n'
        .. '气压：' .. d.main.pressure .. ' hPa；相对湿度：' .. d.main.humidity .. '%；\n'
        .. '风力：' .. d.wind.speed .. '级；风向：' .. dir_desc(d.wind.deg) .. '（' .. d.wind.deg .. '°）\n'
end
ai.register_handler('weather',
    function () end,

    function (self, uin, message)
        if message:find('天气') ~= nil then return 1
        else return 0 end
    end,

    function (self, uin, message)
        local i
        for i = 1, #cities do
            if message:find(cities[i][1]) then
                resp = json:decode(http.get(
                    'http://api.openweathermap.org/data/2.5/weather?id=' .. cities[i][2] .. '&units=metric&appid=' .. api_key))
                if resp.cod ~= 200 then
                    print(inspect(resp))
                    self.send_message('无法取得' .. cities[i][1] .. '的天气数据（Return code: ' .. tostring(resp.cod) .. '）T^T')
                else
                    resp.orig_name = cities[i][1]
                    self.send_message(weather_report(resp))
                end
                return
            end
        end
        self.send_message('并不知道泥在说哪个城市啊。。试下“北京天气”这样的说法')
    end
)

local sunrise_sunset_report = function (d)
    return d.orig_name .. '[' .. d.name .. '] ' .. os.date('%Y-%m-%d') .. '\n'
        .. '日出时间：' .. os.date('%H:%M', d.sys.sunrise) .. '；日落时间：' .. os.date('%H:%M', d.sys.sunset)
end
ai.register_handler('weather',
    function () end,

    function (self, uin, message)
        if message:find('日出') ~= nil or message:find('日落') ~= nil then return 1
        else return 0 end
    end,

    function (self, uin, message)
        local i
        for i = 1, #cities do
            if message:find(cities[i][1]) then
                resp = json:decode(http.get(
                    'http://api.openweathermap.org/data/2.5/weather?id=' .. cities[i][2] .. '&units=metric&appid=' .. api_key))
                if resp.cod ~= 200 then
                    print(inspect(resp))
                    self.send_message('无法取得' .. cities[i][1] .. '的天气数据（Return code: ' .. tostring(resp.cod) .. '）T^T')
                else
                    resp.orig_name = cities[i][1]
                    self.send_message(sunrise_sunset_report(resp))
                end
                return
            end
        end
        self.send_message('并不知道泥在说哪个城市啊。。试下“北京日出日落”这样的说法')
    end
)
