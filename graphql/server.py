from ariadne import make_executable_schema, ObjectType, gql
from ariadne.asgi import GraphQL

import caa

Esquema = {
    "tipos": [],
    "palabra": ObjectType("Palabra"),
    "campos_palabra": []
}

caa.decorar(Esquema)

Esquema["tipos"] += [
    gql("""
        type Palabra {
          %s 
        }
    """ % "\n".join(Esquema["campos_palabra"])),
    gql("""
        type Query {
            palabra(s: String!): Palabra!
        }
    """)
    ]

query = ObjectType("Query")

@query.field("palabra")
def resolve_palabra (_, info, s):
    return { "s": s }

schema = make_executable_schema(
    Esquema["tipos"],
    [query, Esquema["palabra"]]
    )

app = GraphQL(schema, debug=True)
