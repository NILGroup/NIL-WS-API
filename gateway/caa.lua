-- en nginx, usar ngx.location.capture

local json = require "lib/JSON"
local reply = function (tabla) print(json:encode(tabla)) end

if arg[1] == 'picto' then

    http = io.popen('http sesat.fdi.ucm.es:8080/servicios/rest/pictograma/palabra/'..arg[2])
    response = http:read('a')

    picto_url = response:match("<img src='([^']+)'>")
    picto_id = picto_url and picto_url:match('Pictos/([^\'"/]+)') or nil

    if picto_id then
        reply{ ok=true, pictograma=tonumber(picto_id), url=picto_url }
    else
        reply{ ok=false, error="no hay pictograma" }
    end

elseif arg[1] == 'traducir' then

    http = io.popen('http hypatia.fdi.ucm.es:5223/PICTAR/traducir/'..arg[2])
    response = http:read('a')
    palabras = json:decode(response)
    traduccion = {}
    for i = 1, #palabras do
        pos, picto_array, lema = palabras[i]:match("0 (%g+)(%[[^]]+%]) (%g+)")
        pictos = json:decode(picto_array)
        traduccion[i] = { lema=lema, pictogramas=pictos, pos=pos }
    end
    reply{ ok=true, traduccion=traduccion }

end
