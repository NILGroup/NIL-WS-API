local json = require "LUA_DEPLOY_PATH()/JSON"
local reply = function (tabla) ngx.say(json:encode(tabla)) end

ngx.req.read_body()
palabra = ngx.var.uri:match"palabra/([^/]+)"
response = ngx.location.capture('INTERNAL_API_PATH()/picto/'..palabra)

picto_url = response.body:match"<img src='([^']+)'>"
picto_id = picto_url and picto_url:match('Pictos/([^\'"/]+)') or nil

if picto_id then
    reply{ ok=true, pictograma=tonumber(picto_id), url=picto_url, palabra=palabra }
else
    reply{ ok=false, error="no hay pictograma" }
end

-- vi: ft=lua
