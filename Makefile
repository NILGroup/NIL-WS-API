DIST:=dist
ALL:=index.html swagger-ui.css api main.js redoc.html

all: $(addprefix $(DIST)/, $(ALL)) | $(DIST)
	rm -rf /var/www/idilyco-api/*
	cp -R dist/* /var/www/idilyco-api

$(DIST)/main.js: web/main.js | $(DIST)
	webpack web/main.js --mode=production

$(DIST)/index.html: web/index.html | $(DIST)
	cp $< $@

$(DIST)/swagger-ui.css: node_modules/swagger-ui/dist/swagger-ui.css | $(DIST)
	cp $< $@

$(DIST)/api: $(wildcard api/**) | $(DIST)
	rm -rf $@
	cp -R api $@

$(DIST)/redoc.html: $(wildcard api/**) | $(DIST)
	npx redoc-cli bundle api/openapi.yaml
	mv redoc-static.html $@

$(DIST):
	mkdir -p $(DIST)

.PHONY: clean nginx

nginx:
	m4 gateway/nginx.m4 > /etc/nginx/sites-available/idilyco-gateway
	systemctl reload nginx

clean:
	rm -rf $(DIST)
