import requests

from .comun import tipo_texto, Texto

URL_RESUMEN_ES = 'https://holstein.fdi.ucm.es/grafeno/run/summary_es'

@tipo_texto.field("resumen")
def resumen (texto, *_, longitud):
    r = requests.post(URL_RESUMEN_ES, json={
            'text': texto.s,
            'linearizer_args': {
                'summary_length': longitud
            }
        })
    return Texto(r.json().get('result'))
