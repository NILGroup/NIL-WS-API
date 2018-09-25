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
body = json:decode(ngx.req.get_body_data())

resumen = call_api('/texto/resumen?longitud=1', body.texto)
pictos = call_api('/texto/pictogramas', resumen.resumen)

reply{ ok=true, pictoresumen=pictos.traduccion }

-- vi: ft=lua
