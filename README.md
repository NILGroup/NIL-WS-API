# Idylico-API

Este repositorio contiene el desarrollo de la especificación de la **API de
Idylico**, así como código de apoyo.

## Estructura

Este repositorio contiene tres módulos lógicos. El primero es la especificación
formal de la API, en formato texto. Adicionalmente, contiene dos módulos
relacionados que apoyan esta API. El módulo web genera una documentación web de
la API que es más cómoda de leer y utilizar. El módulo gateway sirve como puerta
de acceso para proveer la API de la especificación, que da un acceso unificado a
los servicios de Idilyco.

### Contenidos

- `api`: Especificación de la API en texto. Está escrita conforme al estándar
  [OpenAPI], usando el formato [yaml].
- `web`: Código para la documentación web de la API, generada con [swagger-ui] a
  partir de la especificación.
- `gateway`: Plantilla [m4] para generar un servidor gateway con [nginx]. Este
  servidor expone una API unificada (especificada en este repositorio) que da
  acceso a los distintos servicios de Idilyco.
- `Makefile`: Fichero [make] de apoyo para:
  1. Generar documentación web: se crea una carpeta `dist` estática para
     desplegar en un servidor http compatible.
  2. Desplegar gateway: se genera un fichero de configuración para nginx y se
     reinicia el servicio.

## Uso

La API se puede leer directamente en formato texto, sin embargo es más cómodo
leerlo en la UI generada con [swagger-ui]. Si se despliega el gateway en el
mismo servidor que la UI, se puede además probar la API directamente en la web.

1. Instalar dependencias: [nodejs] para generar la web, [nginx] y [m4] para
   desplegar el gateway. Después, ejecutar `$ npm install` para que se bajen las
   dependencias adicionales.
2. Para generar la web estática: `$ make`. Esto genera la documentación y la
   instala en `/var/www/idilyco-api` por defecto.
3. Para lanzar el gateway: `$ make nginx`. Esto (re)genera el fichero de
   configuración en `/etc/nginx/sites-available/idilyco-gateway` y reinicia
   nginx. La primera vez, hay que crear el link apropiado en `sites-enabled`
   para que el sitio se cargue. Esta configuración también sirve la
   documentación estática si está instalada en el path por defecto.

## Autores

- Raquel Hervás <raquelhb@fdi.ucm.es>
- Antonio F. G. Sevilla <afgs@ucm.es>

[OpenAPI]: https://github.com/OAI/OpenAPI-Specification
[yaml]: http://yaml.org/
[swagger-ui]: https://swagger.io/tools/swagger-ui/
[m4]: https://www.gnu.org/software/m4/manual/m4.html
[nginx]: https://nginx.org/
[Make]: https://www.gnu.org/software/make/
[nodejs]: https://nodejs.org/en/
