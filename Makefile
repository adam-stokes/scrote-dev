MODULES_DIR ?= $(shell pwd)/node_modules
MODULES_BIN ?= $(MODULES_DIR)/.bin
NODE_ENV ?= dev

# BINS
MOCHA := $(MODULES_BIN)/mocha
UGLIFY := $(MODULES_BIN)/uglifyjs
NODE_SASS := $(MODULES_BIN)/node-sass

# ASSETS
BOOTSTRAP_SASS := $(MODULES_DIR)/bootstrap-sass/assets
JQUERY := $(MODULES_DIR)/jquery/dist
ASSETS_DIR := $(shell pwd)/assets
JS_DIR := $(ASSETS_DIR)/javascripts
CSS_DIR := $(ASSETS_DIR)/stylesheets
FONTS_DIR := $(ASSETS_DIR)/fonts

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
	@rsync -avz $(BOOTSTRAP_SASS)/fonts/bootstrap/* $(FONTS_DIR)/.
	@rsync -avz $(BOOTSTRAP_SASS)/javascripts/bootstrap.js $(JS_DIR)/.
	@rsync -avz $(JQUERY)/jquery.js $(JS_DIR)/.

scss:
	@$(NODE_SASS) --output-style compressed $(CSS_DIR)/main.scss $(PUBLIC_DIR)/stylesheets/app.css

assets: scss
	@mkdir -p $(PUBLIC_DIR)/javascripts
	@mkdir -p $(PUBLIC_DIR)/stylesheets
	@mkdir -p $(PUBLIC_DIR)/fonts
	@mkdir -p $(PUBLIC_DIR)/images
	@cat $(JS_DIR)/jquery.js $(JS_DIR)/bootstrap.js | uglifyjs -c -o $(PUBLIC_DIR)/javascripts/app.min.js
	@rsync -avz $(FONTS_DIR)/. $(PUBLIC_DIR)/fonts/.

serve: assets
	DEBUG=$(NODE_ENV) NODE_ENV=$(NODE_ENV) node index
help:
	@echo
	@echo "  assets - builds assets"
	@echo "  serve  - webserver"
	@echo


.PHONY: test serve assets scss vendor-sync help
