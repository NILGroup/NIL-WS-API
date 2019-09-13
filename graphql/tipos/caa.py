import requests
import regex

from .comun import palabra

URL_SERVICIO_PICTOGRAMAS = "http://sesat.fdi.ucm.es:8080/servicios/rest/pictograma/palabra/%s"  

regex_pictograma = regex.compile(r"<img src=['\"](.+Pictos/)(.+)['\"]>")

@palabra.field("pictograma")
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
