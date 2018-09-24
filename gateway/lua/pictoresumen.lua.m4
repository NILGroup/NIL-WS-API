local json = require "LUA_DEPLOY_PATH()/JSON"
local reply = function (tabla) ngx.say(json:encode(tabla)) end

ngx.req.read_body()
body = json:decode(ngx.req.get_body_data())

grafeno_response = ngx.location.capture('INTERNAL_API_PATH()/grafeno/run/summary', {
    method=ngx.HTTP_POST,
    body=json:encode({
        text=body.texto,
        transformer_args={ lang='es' },
        linearizer_args={ summary_length=1, summary_margin=100 }
    })
})

resumen = json:decode(grafeno_response.body)

response = ngx.location.capture('INTERNAL_API_PATH()/traducir/'..resumen.result)

palabras = json:decode(response.body)
traduccion = {}
for i = 1, #palabras do
    pos, picto_array, lema = palabras[i]:match("0 (%g+)(%[[^]]+%]) (%g+)")
    pictos = json:decode(picto_array)
    traduccion[i] = { lema=lema, pictogramas=pictos, pos=pos }
end
reply{ ok=true, pictoresumen=traduccion }


-- vi: ft=lua
