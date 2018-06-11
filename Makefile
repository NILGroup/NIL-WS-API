all:
	npx redoc-cli bundle api/openapi.yaml
	@mkdir -p dist
	mv redoc-static.html dist/index.html
