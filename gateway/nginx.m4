divert(-1)

dnl Fichero de configuración de un gateway NGINX para servir como portal de
dnl todos los servicios de Idilyco

define(`SERVIDOR', mistela.fdi.ucm.es)
define(`ENVIRONMENT', dev)

define(`PROXY',
    location $1 {
        proxy_pass $2;
        proxy_http_version 1.1;
        dnl
        dnl El servidor de emociones no acepta estos headers
        dnl
        dnl proxy_set_header Upgrade $http_upgrade;
        dnl proxy_set_header Connection "upgrade";
        dnl proxy_set_header Host $http_host;
        dnl proxy_set_header X-Forwarded-For $remote_addr;
        $3
    }
)

define(`IDY_API',PROXY(API_PATH()/$1,$2,$3))

divert

server {

    listen 80 default_server;
    
    server_name SERVIDOR();

    root /var/www;
    index index.html;

    ifelse(ENVIRONMENT, `dev', `lua_code_cache off;')

    dnl PT1 (simplificacion)

    define(`SIMPLE_REST_API', `http://sesat.fdi.ucm.es:8080/servicios/rest')
    IDY_API(sencilla, SIMPLE_REST_API()/palabras/json)
    IDY_API(sinonimos, SIMPLE_REST_API()/sinonimos/json)
    IDY_API(antonimos, SIMPLE_REST_API()/antonimos/json)
    IDY_API(definiciones, SIMPLE_REST_API()/definicion/json)
    IDY_API(traducciones, SIMPLE_REST_API()/ingles/json)
    IDY_API(conversion, SIMPLE_REST_API()/conversion/json)

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
            proxy_pass $4;
        }
    )
    PATCH_JSON(`picto/(.+)', `caa_picto.lua', `picto/', `http://sesat.fdi.ucm.es:8080/servicios/rest/pictograma/palabra/')
    PATCH_JSON(`traducir/(.+)', `caa_traducir.lua', `traducir/', `http://hypatia.fdi.ucm.es:5223/PICTAR/traducir/')

    dnl PT4 (emociones)
    
    define(`EMOCION_PALABRA_API', IDY_API(emocion/$1,
        http://sesat.fdi.ucm.es,
        `rewrite ^.+/([^/]+)$ /emociones/palabra/$2?palabra=``$''1 break;'
    ))
    EMOCION_PALABRA_API(mayoritaria, mayoritariaEmo) 
    EMOCION_PALABRA_API(consensuada, consensuadaEmo) 
    EMOCION_PALABRA_API(grados, gradosEmo) 

}

