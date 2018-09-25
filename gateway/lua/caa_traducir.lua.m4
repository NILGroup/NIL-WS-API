local json = require "LUA_DEPLOY_PATH()/JSON"
local reply = function (tabla) ngx.say(json:encode(tabla)) end

ngx.req.read_body()
body = json:decode(ngx.req.get_body_data())
response = ngx.location.capture('INTERNAL_API_PATH()/traducir/'..body.texto)

palabras = json:decode(response.body)
traduccion = {}
for i = 1, #palabras do
    palabra_error = palabras[i]:match("Word not found: (.+)")
    if palabra_error == nil then
        pos, picto_array, lema = palabras[i]:match("0 (%g+)(%[[^]]+%]) (%g+)")
        if picto_array == nil then
            traduccion[i] = { lema=lema, pictogramas={} }
        else
            pictos = json:decode(picto_array)
            traduccion[i] = { lema=lema, pictogramas=pictos, pos=pos }
        end
    else
        traduccion[i] = { lema=palabra_error, pictogramas={} }
    end
end
reply{ ok=true, traduccion=traduccion }

-- vi: ft=lua
