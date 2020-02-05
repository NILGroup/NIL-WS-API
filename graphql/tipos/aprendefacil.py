import requests

from .comun import tipo_palabra, Palabra, Texto

niveles = { None: '1', 'FACIL': '1', 'MEDIO': '2', 'AVANZADO': '3' }

URL_APRENDEFACIL = 'https://holstein.fdi.ucm.es/tfg-analogias/%s/json/'
QUERY = 'word=%s&level=%s'
URL_HIPERONIMOS = (URL_APRENDEFACIL % 'easyhyperonym') + QUERY
URL_HIPONIMOS = (URL_APRENDEFACIL % 'easyhyponym') + QUERY
URL_METAFORAS = (URL_APRENDEFACIL % 'metaphor') + QUERY
URL_SIMILES = (URL_APRENDEFACIL % 'simil') + QUERY
URL_EJEMPLOS = (URL_APRENDEFACIL % 'def_example') + QUERY

def generico (URL, clave, palabra, nivel, objeto):
    r = requests.get(URL % (palabra.s, niveles[nivel]))
    return [objeto(s) for resp in r.json() for s in resp.get(clave, [])]

@tipo_palabra.field("hiperonimos")
def hiperonimos (palabra, *_, nivel):
    return generico(URL_HIPERONIMOS, "hyperonyms", palabra, nivel, Palabra)

@tipo_palabra.field("hiponimos")
def hiponimos (palabra, *_, nivel):
    return generico(URL_HIPONIMOS, "hyponyms", palabra, nivel, Palabra)

@tipo_palabra.field("metaforas")
def metaforas (palabra, *_, nivel):
    return generico(URL_METAFORAS, "metaphor", palabra, nivel, Texto)

@tipo_palabra.field("similes")
def similes (palabra, *_, nivel):
    return generico(URL_SIMILES, "simil", palabra, nivel, Texto)

@tipo_palabra.field("ejemplos")
def ejemplos (palabra, *_, nivel):
    r = requests.get(URL_EJEMPLOS % (palabra.s, niveles[nivel]))
    resp = r.json()
    return ([Texto(s) for meta in resp[1].get('metaphor') for s in meta.get('example', [])] +
            [Texto(s) for simil in resp[2].get('simil') for s in simil.get('example', [])])
