divert(-1)

define(`PROXY',
    location $1 {
        proxy_pass $2;
        proxy_http_version 1.1;
        $3
    }
)

define(`IDY_API',PROXY(API_PATH()/$1,$2,$3))

define(`SERVICIO_PALABRA',PROXY(~ ^API_PATH()/palabra/([^/]+)/$1$,$2,$3))

divert

server {

    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;
    
    server_name SERVIDOR();

    ssl_certificate SSL_CERT();
    ssl_certificate_key SSL_KEY();

    root /var/www;
    index index.html;

    ifelse(ENVIRONMENT, `dev', `lua_code_cache off;')

    dnl PT1 (simplificacion)

    define(`SIMPLIFICATION_API', `SERVICIO_PALABRA($1,
        http://sesat.fdi.ucm.es:8080/servicios/rest/$2/json/$`1'
    )')

    SIMPLIFICATION_API(es_sencilla, palabras)
    SIMPLIFICATION_API(sinonimos, sinonimos)
    SIMPLIFICATION_API(antonimos, antonimos)
    SIMPLIFICATION_API(definiciones, definicion)
    SIMPLIFICATION_API(traducciones, ingles)
    SIMPLIFICATION_API(conversion_a_facil, conversion)

    dnl PT2 (resumenes)

    IDY_API(resumen/es, https://sesat.fdi.ucm.es/grafeno/run/summary_es)

    dnl PT3 (caa)
    
    dnl 4 argumentos:
    dnl - path en la api
    dnl - fichero lua adaptador
    dnl - path api interna (location con proxy pass)
    dnl - url upstream (direccion del proxy_pass)
    define(`PATCH_JSON', 
        location ~ API_PATH()/$1 {
            default_type "application/json";
            content_by_lua_file LUA_DEPLOY_PATH()/$2;
        }
        location INTERNAL_API_PATH()/$3 {
            ifelse(ENVIRONMENT, `prod', `internal;')
            proxy_pass_request_headers off;
            proxy_pass $4;
        }
    )
    PATCH_JSON(`palabra/([^/]+)/pictograma', `caa_picto.lua', `picto/', `http://sesat.fdi.ucm.es:8080/servicios/rest/pictograma/palabra/')
    PATCH_JSON(`texto/pictogramas', `caa_traducir.lua', `traducir/', `http://hypatia.fdi.ucm.es:5223/PICTAR/traducir/')

    dnl PT4 (emociones)
    
    define(`EMOCION_PALABRA_API', `SERVICIO_PALABRA($1,
        http://sesat.fdi.ucm.es,
        `rewrite ^.*/palabra/([^/]+).*$ /emociones/palabra/$2?palabra=`$'1 break;'
    )')

    EMOCION_PALABRA_API(emocion_mayoritaria, mayoritariaEmo) 
    EMOCION_PALABRA_API(emocion_consensuada, consensuadaEmo) 
    EMOCION_PALABRA_API(emocion_grados, gradosEmo) 

}

