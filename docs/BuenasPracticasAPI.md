# Buenas prácticas para la API de Servicios Web NiL

Este documento recoge una serie de buenas prácticas para el diseño e
implementación de servicios web en el grupo NiL. Estas buenas prácticas sirven
como punto de encuentro, de forma que los servicios que las sigan puedan
interoperar con facilidad y ser integrados dentro del ecosistema general del
grupo.

## Entrada/Salida

Lo más importante a la hora de hacer servicios interoperables es la
entrada/salida de estos servicios. Se seguirán los siguientes puntos:

- La comunicación será mediante HTTP/2 sobre TCP. No se usará HTTPS (o no
  exclusivamente), pues esto es responsabilidad del gateway que da acceso a los
  servicios.
- El cuerpo de los mensajes HTTP, tanto de entrada como de salida, será JSON
  (`Content-type: application/json; charset=utf-8`). Más concretamente, será un
  *objeto JSON* con claves correspondientes a los valores de entrada o salida.
- Los servicios podrán recibir parámetros en la url (bien en el path, o como
  query parameters), sólo si son simples y singulares. Por ejemplo, un número, o
  una palabra suelta, pero no una frase o un texto.
- Se utilizarán los códigos de estado HTTP en la respuesta para indicar el
  resultado de la comunicación, por ejemplo:
  - `200`: Se ha podido ejecutar el servicio correctamente.
  - `400`: Hay algún error en los parámetros.
  - `404`: El recurso o servicio solicitado no existe.
  - `500`: El servidor ha tenido un problema inesperado que impide la generación
    de una respuesta adecuada.
- Los servicios devolverán siempre, además del código de estado, un objeto JSON
  con la información del resultado. En caso de error, habrá una clave `error`
  con un valor de tipo `string` que describe el error que ha ocurrido.

## URLs

*TODO*

## Ejemplo

Ejemplo de servicio web usando `python` y `bottle`.

```python

from bottle import get, post, error, run

@get('/palabra/<palabra>/lema')
def lema_palabra (palabra):
    return my_libreria.get_lema(palabra)

@post('/texto/lemas')
def lemas_texto ():
    try:
        parametros = request.json
    except ValueError:
        abort(400,"Invalid json request")
    return dict(palabras=[
        mi_libreria.get_lema(palabra)
        for palabra in parametros.palabras
        ])

@error(500)
def custom500 ():
    return dict(error="Este es mi error")

if __name__ == '__main__':
    run(host=localhost,port=3000,reloader=True)

```
