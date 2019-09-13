from ariadne import gql
import requests
import regex

URL_SERVICIO_PICTOGRAMAS = "http://sesat.fdi.ucm.es:8080/servicios/rest/pictograma/palabra/%s"  

tipo_pictograma = gql('''
    """
    Un pictograma es una representación gráfica de un concepto: ver
    [wikipedia](https://es.wikipedia.org/wiki/Pictograma).
    """
    type Pictograma {

        "URL donde se puede encontrar la imagen del pictograma."
        url: String!

        "Identificador único del pictograma."
        id: String!
    }
''')

# type Palabra {
campos_palabra = '''
    "Un pictograma asociado al significado de la palabra."
    pictograma: Pictograma
'''

regex_pictograma = regex.compile(r"<img src=['\"](.+Pictos/)(.+)['\"]>")

def get_pictograma (Palabra, *_):
    r = requests.get(URL_SERVICIO_PICTOGRAMAS % Palabra["s"])
    match = regex_pictograma.search(r.text)
    if match:
        return {
            'url': match.group(1)+match.group(2),
            'id': match.group(2)
        }
    else:
        return None

def decorar (Esquema):
    Esquema["tipos"].append(tipo_pictograma)
    Esquema["campos_palabra"].append(campos_palabra)
    Esquema["palabra"].set_field("pictograma", get_pictograma)
