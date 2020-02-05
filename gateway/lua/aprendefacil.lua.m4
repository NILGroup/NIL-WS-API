local json = require "LUA_DEPLOY_PATH()/JSON"
local reply = function (tabla) ngx.say(json:encode(tabla)) end

servicios = { hiperonimos_faciles = 'hiper' }
respuestas = { hiperonimos_faciles = 'hyperonyms' }
soluciones = { hiperonimos_faciles = 'hiperonimos' }
niveles = { facil = '1', medio = '2', avanzado = '3' }

nivel = "facil"

args = ngx.req.get_uri_args()
for key, val in pairs(args) do
    if key=="nivel" then nivel = val end
end

palabra, servicio = ngx.var.uri:match"palabra/([^/]+)/([^/]+)"

response = ngx.location.capture('INTERNAL_API_PATH()/aprendefacil_'..servicios[servicio]..'/word='..palabra..'&level='..niveles[nivel])

body = json:decode(response.body)
sol = {}
respuesta = respuestas[servicio]
for i = 2, #body do
    acc = body[i][respuesta]
    if acc ~= nil then
        for j = 1, #acc do
            sol[#sol+1] = acc[j]
        end
    end
end

reply{ ok=true, [soluciones[servicio]]=sol }

-- vi: ft=lua
