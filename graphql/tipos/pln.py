import re

tag_split = re.compile('^([^_]+)__(.*)$')

feat_map = {
    'Gender': 'genero',
    'Number': 'numero',
}

val_map = {
    'Fem': 'femenino',
    'Masc': 'masculino',
    'Sing': 'singular',
    'Plur': 'plural',
}

def tag_analisis (tag):
    '''Convierte un análisis morfológico Ancora en un diccionario de
    características.'''
    res = tag_split.match(tag)
    feats = res[2].split('|')
    r = dict()
    for f in feats:
        cv = f.split('=')
        if cv[0] in feat_map:
            r[feat_map[cv[0]]] = val_map[cv[1]] if cv[1] in val_map else cv[1]
    return r

def morfo (token):
    '''Devuelve parte del análisis morfológico de una palabra.'''
    return {
        'pos': token.pos_,
        **tag_analisis(token.tag_),
    }
