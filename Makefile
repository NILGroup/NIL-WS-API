include local.conf

SHELL:=/bin/bash

DIST:=dist
M4:=m4 -P - <<<'m4_divert(-1) m4_patsubst(m4_include(local.conf),`\(.+\):=\(.+\)'"'"',`m4_define(\1,\2)'"'"') m4_divert'

WEB_DIST:=$(DIST)/web
WEB_SRCS:=index.html swagger-ui.css api main.js redoc.html
WEB_ALL:=$(addprefix $(WEB_DIST)/, $(WEB_SRCS))

LUA_DIST:=$(DIST)/lua
LUA_SRC_DIR:=gateway/lua
LUA_SRCS:=$(wildcard $(LUA_SRC_DIR)/*)
LUA_ALL:=$(patsubst $(LUA_SRC_DIR)/%.lua,$(LUA_DIST)/%.lua, $(LUA_SRCS)) \
		 $(patsubst $(LUA_SRC_DIR)/%.lua.m4,$(LUA_DIST)/%.lua, $(LUA_SRCS))

NGINX_SITE:=$(DIST)/nil-gateway-nginx
GATEWAY_ALL:=$(NGINX_SITE) $(LUA_ALL)


all: $(WEB_ALL) $(GATEWAY_ALL)

# ==============
#    ALIASES
# ==============

web: $(WEB_ALL)
gateway: $(GATEWAY_ALL)

deploy_all: deploy_web deploy_gateway


# ==============
#     WEB UI
# ==============

$(WEB_DIST)/main.js: web/main.js | $(WEB_DIST)
	webpack web/main.js --mode=production -o $@

$(WEB_DIST)/index.html: web/index.html | $(WEB_DIST)
	cp $< $@

$(WEB_DIST)/swagger-ui.css: node_modules/swagger-ui/dist/swagger-ui.css | $(DIST)
	cp $< $@

$(WEB_DIST)/api: $(wildcard api/**) | $(WEB_DIST)
	rm -rf $@
	cp -R api $@

$(WEB_DIST)/redoc.html: $(wildcard api/**) | $(WEB_DIST)
	npx redoc-cli bundle api/openapi.yaml
	mv redoc-static.html $@


# =============
#    GATEWAY
# =============

$(NGINX_SITE): gateway/nginx.m4 | $(DIST)
	$(M4) $< > $@

$(LUA_DIST)/%.lua: $(LUA_SRC_DIR)/%.lua | $(LUA_DIST)
	cp $< $@

$(LUA_DIST)/%.lua: $(LUA_SRC_DIR)/%.lua.m4 | $(LUA_DIST)
	$(M4) $< > $@


# =============
#     OTROS
# =============

$(DIST) $(LUA_DIST) $(WEB_DIST):
	mkdir -p $@

.PHONY: clean deploy_web deploy_gateway

clean:
	rm -rf $(DIST)

deploy_web: $(WEB_ALL)
	cp -R $(WEB_DIST)/* $(WEB_DEPLOY_PATH)

deploy_gateway: $(GATEWAY_ALL)
	cp $(NGINX_SITE) $(NGINX_DEPLOY_PATH)
	cp $(LUA_DIST)/* $(LUA_DEPLOY_PATH)
	sudo systemctl reload-or-restart nginx
