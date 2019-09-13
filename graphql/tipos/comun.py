from ariadne import ObjectType

tipo_query = ObjectType("Query")

class Palabra:
    def  __init__ (self, s):
        self.s = s

@tipo_query.field("palabra")
def resolve_palabra (_, info, s):
    return Palabra(s)

class Texto:
    def  __init__ (self, s):
        self.s = s

@tipo_query.field("texto")
def resolve_texto (_, info, s):
    return Texto(s)

tipo_palabra = ObjectType("Palabra")

tipo_texto = ObjectType("Texto")

@tipo_texto.field("palabras")
def tokenizar (texto, info):
    return [ Palabra(w) for w in texto.s.split(' ') ]

