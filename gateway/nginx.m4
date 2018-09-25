m4_divert(-1)

m4_define(`PROXY',
    location $1 {
        proxy_pass $2;
        proxy_http_version 1.1;
        $3
    }
)

m4_define(`SERVICIO_PALABRA',PROXY(~ ^API_PATH()/palabra/([^/]+)/$1$,$2,$3))

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
        proxy_pass $4;
    }
)

m4_divert

server {

    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;
    
    server_name SERVIDOR();

    ssl_certificate SSL_CERT();
    ssl_certificate_key SSL_KEY();

    root /var/www;
    index index.html;

    m4_ifelse(ENVIRONMENT, `dev', `lua_code_cache off;')

    # PT1 (simplificacion)

    m4_define(`SIMPLIFICATION_API', `SERVICIO_PALABRA($1,
        http://sesat.fdi.ucm.es:8080/servicios/rest/$2/json/$`1'
    )')

    SIMPLIFICATION_API(es_sencilla, palabras)
    SIMPLIFICATION_API(sinonimos, sinonimos)
    SIMPLIFICATION_API(antonimos, antonimos)
    SIMPLIFICATION_API(definiciones, definicion)
    SIMPLIFICATION_API(traducciones, ingles)
    SIMPLIFICATION_API(conversion_a_facil, conversion)

    # PT2 (resumenes)

    PATCH_JSON(`texto/resumen', `resumenes.lua', `grafeno/', `https://sesat.fdi.ucm.es/grafeno/')

    # PT3 (caa)

    PATCH_JSON(`palabra/([^/]+)/pictograma', `caa_picto.lua', `picto/', `http://sesat.fdi.ucm.es:8080/servicios/rest/pictograma/palabra/')
    PATCH_JSON(`texto/pictogramas', `caa_traducir.lua', `traducir/', `http://hypatia.fdi.ucm.es:5223/PICTAR/traducir/')

    # PT4 (emociones)
    
    m4_define(`EMOCION_PALABRA_API', `SERVICIO_PALABRA($1,
        http://sesat.fdi.ucm.es,
        `rewrite ^.*/palabra/([^/]+).*$ /emociones/palabra/$2?palabra=`$'1 break;'
    )')

    EMOCION_PALABRA_API(emocion_mayoritaria, mayoritariaEmo) 
    EMOCION_PALABRA_API(emocion_consensuada, consensuadaEmo) 
    EMOCION_PALABRA_API(emocion_grados, gradosEmo) 

    # SERVICIOS COMPUESTOS
    
    location ~ API_PATH()/texto/pictoresumen {
        default_type "application/json";
        content_by_lua_file LUA_DEPLOY_PATH()/pictoresumen.lua;
    }

}

