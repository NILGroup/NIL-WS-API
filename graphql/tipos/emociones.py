import requests

from .comun import tipo_palabra, tipo_texto, Palabra

URL_EMOCION_MAYORITARIA = 'http://sesat.fdi.ucm.es/emociones/palabra/mayoritariaEmo?palabra=%s'
URL_EMOCION_CONSENSUADA = 'http://sesat.fdi.ucm.es/emociones/palabra/consensuadaEmo?palabra=%s'
URL_GRADOS_PALABRA = 'http://sesat.fdi.ucm.es/emociones/palabra/gradosEmo?palabra=%s'
URL_GRADOS_TEXTO = 'https://holstein.fdi.ucm.es/api-emociones/emociones/texto/gradosEmo'
URL_PALABRAS_EMOCIONALES = 'https://holstein.fdi.ucm.es/api-emociones/textosGuay/'

@tipo_palabra.field("emocionesMayoritarias")
def mayoritarias_de_palabra (palabra, *_):
    r = requests.get(URL_EMOCION_MAYORITARIA % palabra.s)
    return r.json()

@tipo_palabra.field("emocionConsensuada")
def consensuada_de_palabra (palabra, *_):
    r = requests.get(URL_EMOCION_CONSENSUADA % palabra.s)
    return r.json()['consensuada']

@tipo_palabra.field("gradosEmociones")
def grados_de_palabra (palabra, *_):
    r = requests.get(URL_GRADOS_PALABRA % palabra.s)
    return r.json()

@tipo_texto.field("gradosEmociones")
def grados_de_texto (texto, *_):
    r = requests.post(URL_GRADOS_TEXTO, data={'texto':texto.s})
    return r.json()

@tipo_texto.field("palabrasEmocionales")
def grados_de_texto (texto, *_):
    r = requests.post(URL_PALABRAS_EMOCIONALES, data={'a':texto.s})
    return [ Palabra(s=w) for w in r.json().get('palabras', []) ]
