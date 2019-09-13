from ariadne import gql, EnumType
import requests

URL_EMOCION_MAYORITARIA = 'http://sesat.fdi.ucm.es/emociones/palabra/mayoritariaEmo?palabra=%s'
URL_EMOCION_CONSENSUADA = 'http://sesat.fdi.ucm.es/emociones/palabra/consensuadaEmo?palabra=%s'
URL_GRADOS_PALABRA = 'http://sesat.fdi.ucm.es/emociones/palabra/gradosEmo?palabra=%s'

tipos_emociones = gql("""
    type GradosEmociones {
        Tristeza: Float!
        Miedo: Float!
        Alegria: Float!
        Enfado: Float!
        Asco: Float!
    }
    type EmocionesMayoritarias {
        emociones: [String]!
        grado: Float!
    }
""")

# type Palabra {
campos_palabra = '''
    emocionesMayoritarias: EmocionesMayoritarias
    emocionConsensuada: String
    gradosEmociones: GradosEmociones
'''

def mayoritarias_de_palabra (Palabra, *_):
    r = requests.get(URL_EMOCION_MAYORITARIA % Palabra["s"])
    return r.json()

def consensuada_de_palabra (Palabra, *_):
    r = requests.get(URL_EMOCION_CONSENSUADA % Palabra["s"])
    return r.json()['consensuada']

def grados_de_palabra (Palabra, *_):
    r = requests.get(URL_GRADOS_PALABRA % Palabra["s"])
    return r.json()

# type Texto {
#    gradosEmociones: GradosEmociones
#    palabrasEmocionales: [Palabra]
# }

def decorar (Esquema):
    Esquema["tipos"].append(tipos_emociones)
    Esquema["campos_palabra"].append(campos_palabra)
    Esquema["palabra"].set_field("emocionesMayoritarias", mayoritarias_de_palabra)
    Esquema["palabra"].set_field("emocionConsensuada", consensuada_de_palabra)
    Esquema["palabra"].set_field("gradosEmociones", grados_de_palabra)
