from ariadne import ObjectType
import functools
import spacy

from .pln import morfo

nlp = spacy.load("es")

class lazy_property(object):
    '''
    https://stackoverflow.com/questions/3012421/python-memoising-deferred-lookup-property-decorator

    Meant to be used for lazy evaluation of an object attribute.
    Property should represent non-mutable data, as it replaces itself.
    '''

    def __init__(self, fget):
        self.fget = fget
        # copy the getter function's docstring and other attributes
        functools.update_wrapper(self, fget)

    def __get__(self, obj, cls):
        if obj is None:
            return self
        value = self.fget(obj)
        setattr(obj, self.fget.__name__, value)
        return value


tipo_query = ObjectType("Query")

class Palabra:
    def  __init__ (self, s=None, token=None):
        if s is not None:
            self.s = s
            self.token = nlp(s)[0]
        if token is not None:
            self.token = token
            self.s = token.text
        self.lema = self.token.lemma_

    @lazy_property
    def morfo (self):
        return morfo(self.token)


@tipo_query.field("palabra")
def resolve_palabra (_, info, s):
    return Palabra(s)

class Texto:
    def  __init__ (self, s):
        self.s = s

    @lazy_property
    def nlp (self):
        return nlp(self.s)

@tipo_query.field("texto")
def resolve_texto (_, info, s):
    return Texto(s)

tipo_palabra = ObjectType("Palabra")

@tipo_palabra.field("pos")
def persona_pos (palabra, info):
    return palabra.morfo.get("pos")

@tipo_palabra.field("genero")
def palabra_genero (palabra, info):
    return palabra.morfo.get("genero")

@tipo_palabra.field("numero")
def palabra_numero (palabra, info):
    return palabra.morfo.get("numero")


tipo_texto = ObjectType("Texto")

@tipo_texto.field("palabras")
def tokenizar (texto, info):
    return [ Palabra(token=token) for token in texto.nlp ]

