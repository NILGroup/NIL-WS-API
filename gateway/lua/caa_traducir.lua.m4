local json = require "LUA_DEPLOY_PATH()/JSON"
local reply = function (tabla) ngx.say(json:encode(tabla)) end

ngx.req.read_body()
body = json:decode(ngx.req.get_body_data())
response = ngx.location.capture('INTERNAL_API_PATH()/traducir/'..body.texto)

palabras = json:decode(response.body)
traduccion = {}
for i = 1, #palabras do
    pos, picto_array, lema = palabras[i]:match("0 (%g+)(%[[^]]+%]) (%g+)")
    pictos = json:decode(picto_array)
    traduccion[i] = { lema=lema, pictogramas=pictos, pos=pos }
end
reply{ ok=true, traduccion=traduccion }

-- vi: ft=lua
