import requests

from .comun import tipo_palabra, Palabra, Texto

URL_SIMPLIFICACION = 'http://sesat.fdi.ucm.es:8080/servicios/rest/%s/json/'

URL_PALABRA_SENCILLA = URL_SIMPLIFICACION % 'palabras'
URL_SINONIMOS = URL_SIMPLIFICACION % 'sinonimos'
URL_ANTONIMOS = URL_SIMPLIFICACION % 'antonimos'
URL_DEFINICIONES = URL_SIMPLIFICACION % 'definicion'
URL_TRADUCCIONES = URL_SIMPLIFICACION % 'ingles'
URL_CONVERSION_A_FACIL = URL_SIMPLIFICACION % 'conversion'

@tipo_palabra.field("esSencilla")
def palabra_sencilla (palabra, *_):
    r = requests.get(URL_PALABRA_SENCILLA + palabra.s)
    return r.json().get("palabraSencilla")

@tipo_palabra.field("sinonimos")
def sinonimos (palabra, *_):
    r = requests.get(URL_SINONIMOS + palabra.s)
    return [Palabra(s["sinonimo"]) for s in
            r.json().get("sinonimos", [])]

@tipo_palabra.field("antonimos")
def antonimos (palabra, *_):
    r = requests.get(URL_ANTONIMOS + palabra.s)
    return [Palabra(a["antonimo"]) for a in
            r.json().get("antonimos", [])]

@tipo_palabra.field("definiciones")
def definiciones (palabra, *_):
    r = requests.get(URL_DEFINICIONES + palabra.s)
    return [Texto(d["definicion"]) for d in
            r.json().get("definiciones", [])]

@tipo_palabra.field("ingles")
def traducciones (palabra, *_):
    r = requests.get(URL_TRADUCCIONES + palabra.s)
    return [Palabra(t["traduccion"]) for d in
            r.json().get("traducciones", [])]

@tipo_palabra.field("facil")
def conversion_a_facil (palabra, *_):
    r = requests.get(URL_CONVERSION_A_FACIL + palabra.s)
    facil = r.json().get("conversion")
    return Palabra(facil) if facil is not None else None
