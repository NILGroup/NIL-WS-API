local json = require "LUA_DEPLOY_PATH()/JSON"
local reply = function (tabla) ngx.say(json:encode(tabla)) end

servicios = { grados_emociones = 'gradosEmo',
              emocion_mayoritaria = 'mayoritariaEmo' }

servicio = ngx.var.uri:match"texto/([^/]+)"
ngx.req.read_body()
body = json:decode(ngx.req.get_body_data())
response = ngx.location.capture('INTERNAL_API_PATH()/emociones/'..servicios[servicio], {
    method=ngx.HTTP_POST,
    body=ngx.encode_args({
        texto=body.texto
    })
})


if servicio=='grados_emociones' then
    ngx.say(response.body)
else
    result = json:decode(response.body)
    reply{ emociones=result.emocion, grado=result.grado }
end

-- vi: ft=lua
