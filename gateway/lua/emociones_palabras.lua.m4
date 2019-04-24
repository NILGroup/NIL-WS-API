local json = require "LUA_DEPLOY_PATH()/JSON"
local reply = function (tabla) ngx.say(json:encode(tabla)) end

ngx.req.read_body()
body = json:decode(ngx.req.get_body_data())
response = ngx.location.capture('INTERNAL_API_PATH()/emociones_palabras/', {
    method=ngx.HTTP_POST,
    body=ngx.encode_args({
        a=body.texto
    })
})

result = json:decode(response.body)
reply{ emociones={ Tristeza=result.emociones[1],
    Miedo=result.emociones[2], Alegria=result.emociones[3],
    Enfado=result.emociones[4], Asco=result.emociones[5] },
    palabras=result.palabras }

-- vi: ft=lua
