divert(-1)

dnl Fichero de configuración de un gateway NGINX para servir como portal de
dnl todos los servicios de Idilyco

define(`SERVIDOR', mistela.fdi.ucm.es)
define(`PATH_API', idilyco-api/v1)

define(`PROXY',
    location /$1 {
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

define(`IDY_API',PROXY(PATH_API()/$1,$2,$3))
    
divert

server {

    listen 80 default_server;
    
    server_name SERVIDOR();

    root /var/www;
    index index.html;

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

    dnl PT4 (emociones)
    
    define(`EMOCION_PALABRA_API', IDY_API(emocion/$1,
        http://sesat.fdi.ucm.es,
        `rewrite ^.+/([^/]+)$ /emociones/palabra/$2?palabra=``$''1 break;'
    ))
    EMOCION_PALABRA_API(mayoritaria, mayoritariaEmo) 
    EMOCION_PALABRA_API(consensuada, consensuadaEmo) 
    EMOCION_PALABRA_API(grados, gradosEmo) 

}

