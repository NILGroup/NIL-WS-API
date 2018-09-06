include local.conf

DIST:=dist
M4:=m4

WEB_DIST:=$(DIST)/web
WEB_SRCS:=index.html swagger-ui.css api main.js redoc.html
WEB_ALL:=$(addprefix $(WEB_DIST)/, $(WEB_SRCS))

LUA_DIST:=$(DIST)/lua
LUA_SRC_DIR:=gateway/lua
LUA_SRCS:=$(wildcard $(LUA_SRC_DIR)/*)
LUA_ALL:=$(patsubst $(LUA_SRC_DIR)/%.lua,$(LUA_DIST)/%.lua, $(LUA_SRCS)) \
		 $(patsubst $(LUA_SRC_DIR)/%.lua.m4,$(LUA_DIST)/%.lua, $(LUA_SRCS))

NGINX_SITE:=$(DIST)/idilyco-nginx
GATEWAY_ALL:=$(NGINX_SITE) $(LUA_ALL)

PANDOC:=pandoc --resource-path=docs

DOC_INDEX := $(addprefix docs/,metadata.yaml $(shell cat docs/index.txt))
WHITEPAPER:= $(DIST)/Whitepaper.pdf


all: $(WEB_ALL) $(GATEWAY_ALL) $(WHITEPAPER)

# ==============
#    ALIASES
# ==============

web: $(WEB_ALL)
gateway: $(GATEWAY_ALL)
docs: $(WHITEPAPER)

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


# ===============
#  DOCUMENTACION
# ===============

$(DIST)/Whitepaper.pdf: $(DOC_INDEX) | $(DIST)
	$(PANDOC) -o $@ $^


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
