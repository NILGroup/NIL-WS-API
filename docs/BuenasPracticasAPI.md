# Buenas prácticas para la API de Servicios Web NiL

* Autor: Antonio F. G. Sevilla <afgs@ucm.es>
* Versión: 0.1
* Fecha: 2018-11-05

Este documento recoge una serie de buenas prácticas para el diseño e
implementación de servicios web en el grupo NiL. Estas buenas prácticas sirven
como punto de encuentro, de forma que los servicios que las sigan puedan
interoperar con facilidad y ser integrados dentro del ecosistema general del
grupo. Al final del documento se encuentra un ejemplo de cómo implementar un
servicio web acorde a estas prácticas con `python` y `bottle`.

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
  una palabra suelta, pero no una frase o un texto. Ver sección `URLs`.
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

Las URLs deben estar organizadas bajo un sistema lógico que tenga sentido para
el cliente, más que atadas a la implementación. Es decir, las urls no tienen que
ser reflejo uno-a-uno de los métodos del código del servicio sino de los usos
que de ellos puede hacer un usuario. Para ello, lo mejor es subdividir las URLs
en función primero del tipo de recurso/objeto sobre el que operan (e.g. palabra,
texto) y luego según la función que realizan (e.g. sinónimos, pictograma,
resumen).

- `GET`. Las operaciones que sean isomórficas (es decir, siempre devuelvan el
    mismo resultado con los mismos parámetros, y no modifican nada en el
    servidor) y suficientemente sencillas, deben ser de tipo `get`. Sólo reciben
    parámetros en la URL. Si el parámetro es un objeto o recurso "principal",
    debe ir en el path. Si es una configuración opcional, un parámetro de
    configuración, debe ir en la "query string".
- `POST`. Si la operación cambia algún estado en el servidor, recibe parámetros
    muy complejos, o requiere de algún cálculo no determinista, debe ser de tipo
    `post`. En este caso, recibirán parámetros en formato `JSON` como se ha
    explicado en la sección anterior.

Ejemplos:

* **GET** `/pictograma/<palabra>`
* **GET** `/pictograma/<id del pictograma>?alternativa=<forma alternativa>`
* **GET** `/palabra/<palabra>/sinonimos`
* **POST** `/palabra/anadir-al-diccionario` recibe: `{ "palabra":
    "casa", "sinonimos": [ "mansion", "edificio" ] }`
* **POST** `/texto/resumen` recibe: `{ "texto": "el texto a resumir",
    "longitud": "100" }`

## Ejemplo de Servicio Web

Ejemplo de servicio web usando `python` y `bottle`. También disponible en
[EjemploWS.py](EjemploWS.py).

```python
#!/usr/bin/env python3
'''Este módulo es un ejemplo de cómo hacer un servicio web python con bottle y
adaptado al estilo NiL.

Este código se puede ejecutar, y recomendamos al alumno hacerlo para
familiarizarse con el uso de bottle.

@author agarsev <afgs@ucm.es>
@date   05/11/2018
'''

class mi_libreria:
    '''Clase de ejemplo que emula una librería que hemos importado.'''

    def get_lema (x):
        return x

import json
import bottle

@bottle.get('/palabra/<palabra>/lema')
def lema_palabra (palabra):
    '''Un método get puede recibir parámetros en la URL, en este caso <palabra>.
    Si devolvemos un diccionario python, bottle automáticamente lo convierte por
    nosotros en JSON.'''
    return {
        'lema': mi_libreria.get_lema(palabra)
    }

@bottle.post('/texto/lemas')
def lemas_texto ():
    '''Un método post recibe los parámetros en el `body`, en este caso como
    JSON. Si el JSON que hemos recibido es incorrecto, `abort`amos con un código
    de error apropiado y un mensaje.'''
    try:
        parametros = bottle.request.json
        return {
            'lemas': [ mi_libreria.get_lema(palabra)
                for palabra in parametros.get('texto').split() ]
        }
    except AttributeError:
        bottle.abort(400, 'Petición json incorrecta.')

@bottle.error(400)
def custom400 (error):
    '''Cuando ocurre un error, bottle no lo convierte en JSON automáticamente,
    así que lo hacemos nosotros. Primero ponemos el `content_type`, y luego
    hacemos el `json.dumps` del diccionario. En el error 400, decimos que ha
    habido un error y en los detalles ponemos la explicación para que el usuario
    sepa qué ha hecho mal.'''
    bottle.response.content_type = 'application/json'
    return json.dumps({
        'error': 'Error en el uso de la aplicación.',
        'detalles': error.body
    })

@bottle.error(404)
def custom404 (error):
    '''El error 404 no necesita demasiada información.'''
    bottle.response.content_type = 'application/json'
    return json.dumps({
        'error': 'No existe el recurso solicitado.'
    })

@bottle.error(500)
def custom500 (error):
    '''En el caso del error 500, no le damos información al usuario porque son
    detalles de nuestro servidor y puede ser un fallo de seguridad. Estos
    errores ocurren cuando nuestro código python ha fallado, por lo que habrá
    que mirar la salida de error del programa para verlos.'''
    bottle.response.content_type = 'application/json'
    return json.dumps({
        'error': 'Ha habido un problema imprevisto.',
    })

if __name__ == '__main__':
    '''Con la opción reloader, si nuestro programa tiene un error
    automáticamente se vuelve a lanzar.'''
    print(__doc__)
    bottle.run(host='localhost', port=3000, reloader=True)
```
