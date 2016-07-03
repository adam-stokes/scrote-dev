MODULES_DIR ?= $(shell pwd)/node_modules
MODULES_BIN ?= $(MODULES_DIR)/.bin
NODE_ENV ?= dev

# BINS
MOCHA := $(MODULES_BIN)/mocha
UGLIFYJS := $(MODULES_BIN)/uglifyjs
NODE_SASS := $(MODULES_BIN)/node-sass
JADE := $(MODULES_BIN)/jade
HTTP_SERVER := $(MODULES_BIN)/http-server

# ASSETS
BOOTSTRAP_SASS := $(MODULES_DIR)/bootstrap-sass/assets
JQUERY := $(MODULES_DIR)/jquery/dist
ASSETS_DIR := $(shell pwd)/assets
JS_DIR := $(ASSETS_DIR)/javascripts
CSS_DIR := $(ASSETS_DIR)/stylesheets
FONTS_DIR := $(ASSETS_DIR)/fonts
IMAGES_DIR := $(ASSETS_DIR)/images
UPLOADS_DIR := $(ASSETS_DIR)/uploads

PUBLIC_DIR := $(shell pwd)/public

# bootswatch theme
# change the theme by:
#  BOOTSWATCH_THEME = flatly
#  include node_modules/scrote-dev/Makefile
BOOTSWATCH := $(MODULES_DIR)/bootswatch
BOOTSWATCH_THEME ?= simplex

test:
	NODE_ENV=$(NODE_ENV) $(MOCHA)

vendor-sync:
	@rsync -avz $(BOOTSTRAP_SASS)/stylesheets/* $(CSS_DIR)/.
	@rsync -avz $(BOOTSWATCH)/$(BOOTSWATCH_THEME)/*.scss $(CSS_DIR)/.
	@rsync -avz $(BOOTSTRAP_SASS)/fonts/bootstrap $(FONTS_DIR)
	@rsync -avz $(BOOTSTRAP_SASS)/javascripts/bootstrap.js $(JS_DIR)/.
	@rsync -avz $(JQUERY)/jquery.js $(JS_DIR)/.

clean:
	@if [ -d $(PUBLIC_DIR) ]; then rm -rf $(PUBLIC_DIR); fi

assets: clean
	@mkdir -p $(PUBLIC_DIR)/javascripts
	@mkdir -p $(PUBLIC_DIR)/stylesheets
	@mkdir -p $(PUBLIC_DIR)/fonts
	@mkdir -p $(PUBLIC_DIR)/images
	@mkdir -p $(UPLOADS_DIR)

	@$(NODE_SASS) --output-style compressed $(CSS_DIR)/app.scss $(PUBLIC_DIR)/stylesheets/app.css
	@cat $(JS_DIR)/jquery.js $(JS_DIR)/bootstrap.js $(JS_DIR)/app.js | $(UGLIFYJS) -c -o $(PUBLIC_DIR)/javascripts/app.min.js
	@rsync -avz $(FONTS_DIR)/. $(PUBLIC_DIR)/fonts/.
	@rsync -avz $(IMAGES_DIR)/. $(PUBLIC_DIR)/images/.

serve: assets
	DEBUG=$(NODE_ENV) NODE_ENV=$(NODE_ENV) node index
help:
	@echo
	@echo "  assets - builds assets"
	@echo "  serve  - webserver"
	@echo

setup:
	@echo
	@echo " Setting up project structure: $(shell pwd)"
	@echo
	@mkdir -p $(shell pwd)/test || true
	@mkdir -p $(CSS_DIR) $(JS_DIR) $(FONTS_DIR) || true


.PHONY: test serve assets scss vendor-sync help setup
all: assets
