local json = require "LUA_DEPLOY_PATH()/JSON"
local reply = function (tabla) ngx.say(json:encode(tabla)) end

-- Nombre del servicio interno de nginx
servicios = { hiperonimos_faciles = 'hiper',
              hiponimos_faciles = 'hipo',
              metaforas = 'meta',
              similes = 'simil',
            }
-- Clave con que responde el servicio de AprendeFácil
respuestas = { hiperonimos_faciles = 'hyperonyms',
               hiponimos_faciles = 'hyponyms',
               metaforas = 'metaphor',
               similes = 'simil',
             }
-- Clave con que respondemos nosotros en la OpenAPI
soluciones = { hiperonimos_faciles = 'hiperonimos',
               hiponimos_faciles = 'hiponimos',
               metaforas = 'metaforas',
               similes = 'similes',
             }
niveles = { facil = '1', medio = '2', avanzado = '3' }

nivel = "facil"

args = ngx.req.get_uri_args()
for key, val in pairs(args) do
    if key=="nivel" then nivel = val end
end

palabra, servicio = ngx.var.uri:match"palabra/([^/]+)/([^/]+)"

if servicios[servicio] == nil or niveles[nivel] == nil then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

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
