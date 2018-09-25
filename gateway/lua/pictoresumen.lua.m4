local json = require "LUA_DEPLOY_PATH()/JSON"
local reply = function (tabla) ngx.say(json:encode(tabla)) end
local call_api = function (api, texto)
    result = ngx.location.capture('API_PATH()'..api, {
        method=ngx.HTTP_POST,
        body=json:encode({ texto=texto })
    })
    return json:decode(result.body)
end

ngx.req.read_body()
texto = json:decode(ngx.req.get_body_data()).texto

long = math.floor(string.len(texto)*0.04)

resumen = call_api('/texto/resumen?longitud='..long, texto).resumen

pictoresumen = {}
for frase in resumen:gmatch("([^\n]+)") do
    pictos = call_api('/texto/pictogramas', frase).traduccion
    pictoresumen[#pictoresumen+1] = pictos
end

reply{ ok=true, pictoresumen=pictoresumen }

-- vi: ft=lua
