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

