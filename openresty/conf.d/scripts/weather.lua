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

local city = args.city

local redis = require "resty.redis" -- подключим библиотеку по работе с redis
local red = redis:new()
red:set_timeout(1000) -- 1 sec

local ok, err = red:connect("10.5.0.4", 6379)
local weather = ""
local date = os.time(os.date("!*t"))

local result = {city=city, weather="", date=date, from_cache=false}

local ttl = -2
ttl, err = red:ttl(city); -- получим ttl по ключу

if ttl < 0 then 
    -- Если ttl меньше 0, то считаем, что данные устарели (ttl = -1) или были добавлены без expire (ttl = -2).
    -- В любом случае имеет смысл получить новые данные
    weather = get_weather(city)
    red:set(city, cjson.encode({ weather=weather, date=date }))
    red:expire(city, 10)
end

res, err = red:get(city)

res = cjson.decode(res)

result["ttl"] = ttl
result["weather"] = res["weather"]
result["date"] = res["date"]
result["from_cache"] = ttl > 0

ngx.header["Content-type"] = 'application/json'
ngx.say(cjson.encode(result))