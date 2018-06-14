divert(-1)

dnl Fichero de configuración de un gateway NGINX para servir como portal de
dnl todos los servicios de Idilyco

define(`SERVIDOR', mistela.fdi.ucm.es)

define(`PROXY',
    location /$1 {
        proxy_pass $2;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
)

define(`IDAPI',PROXY(idilyco-api/v1/$1,$2))
    
divert

server {

    listen 80 default_server;
    
    server_name SERVIDOR();

    root /var/www;
    index index.html;

    dnl PT1 (simplificacion)

    IDAPI(sencilla, http://sesat.fdi.ucm.es:8080/servicios/rest/palabras/json)
    IDAPI(sinonimos, http://sesat.fdi.ucm.es:8080/servicios/rest/sinonimos/json)
    IDAPI(antonimos, http://sesat.fdi.ucm.es:8080/servicios/rest/antonimos/json)
    IDAPI(definiciones, http://sesat.fdi.ucm.es:8080/servicios/rest/definicion/json)
    IDAPI(traducciones, http://sesat.fdi.ucm.es:8080/servicios/rest/ingles/json)
    IDAPI(conversion, http://sesat.fdi.ucm.es:8080/servicios/rest/conversion/json)

    dnl PT2 (resumenes)

    IDAPI(resumen/es, https://sesat.fdi.ucm.es/grafeno/run/summary_es)

}

