local json = require "LUA_DEPLOY_PATH()/JSON"
local reply = function (tabla) ngx.say(json:encode(tabla)) end

ngx.req.read_body()
body = json:decode(ngx.req.get_body_data())
args = ngx.req.get_uri_args()

lang = 'es'
long = 100

for key, val in pairs(args) do
    if key=="idioma" then lang = val end
    if key=="longitud" then long = tonumber(val) end
end

response = ngx.location.capture('INTERNAL_API_PATH()/grafeno/run/summary', {
    method=ngx.HTTP_POST,
    body=json:encode({
        text=body.texto,
        transformer_args={ lang=lang },
        linearizer_args={
            summary_length=long
        }
    })
})

-- TODO: error handling (500)
result = json:decode(response.body)
if result.ok then
    reply{ ok=true, resumen=result.result }
else
    reply(result)
end

-- vi: ft=lua
