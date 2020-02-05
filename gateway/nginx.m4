m4_divert(-1)

m4_define(`PROXY',
    location $1 {
        default_type "application/json";
        proxy_http_version 1.1;
        proxy_pass $2;
        $3
    }
)

m4_define(`SERVICIO_PALABRA',PROXY(~ ^API_PATH()/palabra/([^/]+)/$1$,$2,$3))
m4_define(`SERVICIO_PICTO',PROXY(~ ^API_PATH()/pictograma/([^/]+)/$1$,$2,$3))

m4_dnl 4 argumentos:
m4_dnl - path en la api
m4_dnl - fichero lua adaptador
m4_dnl - path api interna (location con proxy pass)
m4_dnl - url upstream (direccion del proxy_pass)
m4_define(`PATCH_JSON', 
    location ~ API_PATH()/$1 {
        default_type "application/json";
        content_by_lua_file LUA_DEPLOY_PATH()/$2;
    }
    location INTERNAL_API_PATH()/$3 {
        m4_ifelse(ENVIRONMENT, `prod', `internal;')
        default_type "application/json";
        proxy_set_header Accept "";
        proxy_http_version 1.1;
        proxy_pass $4;
        $5
    }
)
m4_dnl Añade otra ruta que reutiliza un fichero lua, reutiliza
m4_dnl los dos primeros parámetros anteriores
m4_define(`PATCH_JSON_2',
    location ~ API_PATH()/$1 {
        default_type "application/json";
        content_by_lua_file LUA_DEPLOY_PATH()/$2;
    }
)

m4_define(`SESAT',`147.96.80.187')
m4_define(`HYPATIA',`147.96.81.195')
m4_define(`HOLSTEIN',`holstein.fdi.ucm.es')

m4_divert

m4_ifelse(STANDALONE(),`yes',`
server {

    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;
    
    server_name SERVIDOR();

    ssl_certificate SSL_CERT();
    ssl_certificate_key SSL_KEY();

    root /var/www;
    index index.html;
')

    m4_ifelse(ENVIRONMENT, `dev', `lua_code_cache off;')

    # PT1 (simplificacion)

    m4_define(`SIMPLIFICATION_API', `SERVICIO_PALABRA($1,
        http://SESAT:8080/servicios/rest/$2/json/$`1'
    )')

    SIMPLIFICATION_API(es_sencilla, palabras)
    SIMPLIFICATION_API(sinonimos, sinonimos)
    SIMPLIFICATION_API(antonimos, antonimos)
    SIMPLIFICATION_API(definiciones, definicion)
    SIMPLIFICATION_API(traducciones, ingles)
    SIMPLIFICATION_API(conversion_a_facil, conversion)

    PATCH_JSON(`palabra/([^/]+)/hiperonimos_faciles', `aprendefacil.lua', `aprendefacil_hiper/', `https://HOLSTEIN/tfg-analogias/easyhyperonym/json/')

    # PT2 (resumenes)

    PATCH_JSON(`texto/resumen', `resumenes.lua', `grafeno/', `https://HOLSTEIN/grafeno/')

    # PT3 (caa)

    PATCH_JSON(`palabra/([^/]+)/pictograma', `caa_picto.lua', `picto/', `http://SESAT:8080/servicios/rest/pictograma/palabra/')
    PATCH_JSON(`texto/pictogramas', `caa_traducir.lua', `traducir/', `http://HYPATIA:5223/PICTAR/traducir/')

    SERVICIO_PICTO(`palabras', `https://HOLSTEIN',
        `rewrite ^.*/pictograma/([^/]+).*$ /tfg-pict2text/picto/getPictoTranslate?pictoId=`$'1 break;')

    # PT4 (emociones)
    
    m4_define(`EMOCION_PALABRA_API', `SERVICIO_PALABRA($1,
        http://SESAT,
        `proxy_set_header Host "sesat.fdi.ucm.es";
        rewrite ^.*/palabra/([^/]+).*$ /emociones/palabra/$2?palabra=`$'1 break;'
    )')

    EMOCION_PALABRA_API(emocion_mayoritaria, mayoritariaEmo) 
    EMOCION_PALABRA_API(emocion_consensuada, consensuadaEmo) 
    EMOCION_PALABRA_API(grados_emociones, gradosEmo) 

    PATCH_JSON(`texto/grados_emociones', `emociones.lua', `emociones/', `https://HOLSTEIN/api-emociones/emociones/texto/', `proxy_set_header "Content-Type" "application/x-www-form-urlencoded";')
    PATCH_JSON_2(`texto/emocion_mayoritaria', `emociones.lua')
    PATCH_JSON(`texto/palabras_emocionales', `emociones_palabras.lua', `emociones_palabras/', `https://HOLSTEIN/api-emociones/textosGuay/', `proxy_set_header "Content-Type" "application/x-www-form-urlencoded";')

    # SERVICIOS COMPUESTOS
    
    location ~ API_PATH()/texto/pictoresumen {
        default_type "application/json";
        content_by_lua_file LUA_DEPLOY_PATH()/pictoresumen.lua;
    }

    # API GRAPHQL

    PROXY(`GRAPHQL_PATH()/',`http://127.0.0.1:GRAPHQL_PORT()/')

m4_ifelse(STANDALONE(),`yes',`}')
