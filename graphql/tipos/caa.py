import requests
import regex

from ariadne import ObjectType
from .comun import Palabra, tipo_palabra, tipo_query

URL_PICTOGRAMA = 'http://hypatia.fdi.ucm.es/conversor/Pictos/%s'

URL_SERVICIO_PICTOGRAMAS = "http://sesat.fdi.ucm.es:8080/servicios/rest/pictograma/palabra/%s"  
regex_pictograma = regex.compile(r"<img src=['\"].+Pictos/(.+)['\"]>")

URL_PICT2TEXT = 'https://holstein.fdi.ucm.es/tfg-pict2text/picto/getPictoTranslate?pictoId=%s'

class Pictograma:

    def __init__ (self, id):
        self.id = id
        self.url = URL_PICTOGRAMA % id 

    def palabras (self, info):
        r = requests.get(URL_PICT2TEXT % self.id)
        return [ Palabra(s) for s in r.json().get('meanings', []) ]


@tipo_query.field("pictograma")
def resolve_picto (_, info, id):
    return Pictograma(id)

tipo_picto = ObjectType("Pictograma")

@tipo_palabra.field("pictograma")
def get_pictograma (palabra, *_):
    r = requests.get(URL_SERVICIO_PICTOGRAMAS % palabra.s)
    match = regex_pictograma.search(r.text)
    if match:
        return Pictograma(match.group(1))
    else:
        return None

