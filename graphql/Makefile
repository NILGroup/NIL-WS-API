include ../local.conf

all:
	pipenv run daphne -p $(GRAPHQL_PORT) server:app

install:
	pipenv install
	pipenv run python -m spacy download es
