all:
	mkdir -p dist
	cp web/index.html dist
	cp node_modules/swagger-ui/dist/swagger-ui.css dist
	cp -R api/* dist
	webpack web/main.js --mode=production

.PHONY: clean
	rm -rf dist
