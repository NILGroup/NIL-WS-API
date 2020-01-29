from ariadne import load_schema_from_path, make_executable_schema
from ariadne.asgi import GraphQL

from tipos import tipos

schema = make_executable_schema(
        load_schema_from_path('esquema'),
        tipos
        )

# To run e.g.: daphne -p port server:app
app = GraphQL(schema, debug=False)
