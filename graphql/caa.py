from ariadne import gql
import requests
import regex

URL_SERVICIO_PICTOGRAMAS = "http://sesat.fdi.ucm.es:8080/servicios/rest/pictograma/palabra/%s"  

tipo_pictograma = gql("""
    type Pictograma {
        url: String!
        id: String!
    }
""")

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
    Esquema["tipos"] += [tipo_pictograma]
    Esquema["campos_palabra"] += ['pictograma: Pictograma']
    Esquema["palabra"].set_field("pictograma", get_pictograma)
