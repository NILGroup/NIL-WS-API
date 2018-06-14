all: dist/index.html dist/swagger-ui.css dist/api dist/main.js | dist
	rm -rf /var/www/idilyco-api/*
	cp -R dist/* /var/www/idilyco-api

dist/main.js: web/main.js | dist
	webpack web/main.js --mode=production

dist/index.html: web/index.html | dist
	cp $< $@

dist/swagger-ui.css: node_modules/swagger-ui/dist/swagger-ui.css | dist
	cp $< $@

dist/api: $(wildcard api/**) | dist
	rm -rf $@
	cp -R api $@

dist:
	mkdir -p dist

.PHONY: clean nginx

nginx:
	m4 gateway/nginx.m4 > /etc/nginx/sites-available/idilyco-gateway
	systemctl reload nginx

clean:
	rm -rf dist
