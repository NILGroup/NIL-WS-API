from ariadne import ObjectType

query = ObjectType("Query")

@query.field("palabra")
def resolve_palabra (_, info, s):
    return { "s": s }

palabra = ObjectType("Palabra")
