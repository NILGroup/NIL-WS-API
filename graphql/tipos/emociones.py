import requests

from .comun import palabra

URL_EMOCION_MAYORITARIA = 'http://sesat.fdi.ucm.es/emociones/palabra/mayoritariaEmo?palabra=%s'
URL_EMOCION_CONSENSUADA = 'http://sesat.fdi.ucm.es/emociones/palabra/consensuadaEmo?palabra=%s'
URL_GRADOS_PALABRA = 'http://sesat.fdi.ucm.es/emociones/palabra/gradosEmo?palabra=%s'

@palabra.field("emocionesMayoritarias")
def mayoritarias_de_palabra (Palabra, *_):
    r = requests.get(URL_EMOCION_MAYORITARIA % Palabra["s"])
    return r.json()

@palabra.field("emocionConsensuada")
def consensuada_de_palabra (Palabra, *_):
    r = requests.get(URL_EMOCION_CONSENSUADA % Palabra["s"])
    return r.json()['consensuada']

@palabra.field("gradosEmociones")
def grados_de_palabra (Palabra, *_):
    r = requests.get(URL_GRADOS_PALABRA % Palabra["s"])
    return r.json()

# type Texto {
#    gradosEmociones: GradosEmociones
#    palabrasEmocionales: [Palabra]
# }
