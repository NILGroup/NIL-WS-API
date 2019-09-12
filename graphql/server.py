from ariadne import make_executable_schema, QueryType, gql
from ariadne.asgi import GraphQL

from caa import tipo_pictograma, get_pictograma

type_defs = gql("""
    type Palabra {
        pictograma: Pictograma
    }
    type Query {
        palabra(s: String!): Palabra!
    }
""")

class Palabra:
    def __init__(self, s):
        self.s = s

    def pictograma (self, info):
        return get_pictograma(self.s)

query = QueryType()

@query.field("palabra")
def resolve_palabra (_, info, s):
    return Palabra(s)

schema = make_executable_schema([tipo_pictograma, type_defs], query)

app = GraphQL(schema, debug=True)
