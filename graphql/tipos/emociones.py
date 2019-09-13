import requests

from .comun import tipo_palabra

URL_EMOCION_MAYORITARIA = 'http://sesat.fdi.ucm.es/emociones/palabra/mayoritariaEmo?palabra=%s'
URL_EMOCION_CONSENSUADA = 'http://sesat.fdi.ucm.es/emociones/palabra/consensuadaEmo?palabra=%s'
URL_GRADOS_PALABRA = 'http://sesat.fdi.ucm.es/emociones/palabra/gradosEmo?palabra=%s'

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

# type Texto {
#    gradosEmociones: GradosEmociones
#    palabrasEmocionales: [palabra]
# }
