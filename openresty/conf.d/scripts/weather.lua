cjson = require("cjson")
local http = require("resty.http")

function make_request(url, data, method)

    local httpc = http.new()
    -- Single-shot requests use the `request_uri` interface.
    local res, err = httpc:request_uri(url,
    {
        method = method,
        body = cjson.encode(data),
        ssl_verify = false,
    })
    if not res then
        ngx.log(ngx.ERR, "request failed: ", err)
        return
    end

    
    local status = res.status
    local length = res.headers["Content-Length"]
    local body   = res.body

    return body

end

function get_weather (city)
    local url = string.format("https://api.openweathermap.org/data/2.5/weather?q=%s&APPID=2a4ff86f9aaa70041ec8e82db64abf56", city)
    local weather_body = make_request(url, nil, "GET")

    local data = cjson.decode(weather_body)

    return data['weather'][1]["main"]

end

local args = ngx.req.get_uri_args()

local city_ru = args.city
local city_en = city_ru

-- city_ru = request.rel_url.query['city']
-- city_en = get_translation(city_ru, 'ru', 'en')

local redis = require "resty.redis" -- подключим библиотеку по работе с redis
local red = redis:new()
red:set_timeout(1000) -- 1 sec

local ok, err = red:connect("10.5.0.4", 6379)
res, err = red:get(city_en); -- получим данные из redis

local weather = ""
local date = os.time(os.date("!*t"))

local from_cache = false
local result = {city=city_ru, weather="", date=date, from_cache=from_cache}

if res ~= ngx.null then
    local _res = cjson.decode(res)    
    if (date - _res["date"]) > 10 then
        weather = get_weather(city_en)
    else
        weather = _res["weather"]
        from_cache=true
    end
else
    weather = get_weather(city_en)    
end

result["weather"]=weather
result["from_cache"]=from_cache

local enc_result = cjson.encode(result)
if not from_cache then
    red:set(city_en, enc_result)
end

ngx.header["Content-type"] = 'application/json'
ngx.say(enc_result)