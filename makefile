#
#   Biesel Co website
#

#frontend
FRONTEND_SRC=.
BUILD_DIR=build

NPM_DIR=$(FRONTEND_SRC)/node_modules/.bin
JADE=$(NPM_DIR)/jade
BROWSERIFY=$(NPM_DIR)/browserify
UGLIFYJS=$(NPM_DIR)/uglifyjs
UGLIFYCSS=$(NPM_DIR)/uglifycss
LESS=$(NPM_DIR)/lessc
WATCH=$(NPM_DIR)/wr
UNCSS=$(NPM_DIR)/uncss
CLOSURE=$(NPM_DIR)/ccjs
RESUME=$(NPM_DIR)/resume

init:
	(cd $(FRONTEND_SRC) && npm install)

watch:
	nohup sh -c '\
	$(WATCH) --exec "make dev-styles" $(FRONTEND_SRC)/styles && \
	$(WATCH) --exec "make dev-templates" $(FRONTEND_SRC)/templates && \
	$(WATCH) --exec "make dev-scripts" $(FRONTEND_SRC)/scripts && \
	$(WATCH) --exec "make dev-images" $(FRONTEND_SRC)/img && \
	$(WATCH) --exec "make dev-fonts" $(FRONTEND_SRC)/fonts \
	'
	
shitty-watch:
	$(WATCH) --exec 'make dev' $(FRONTEND_SRC)/templates $(FRONTEND_SRC)/scripts $(FRONTEND_SRC)/styles

reset:
	mkdir -p $(BUILD_DIR) && \
	rm -rf $(BUILD_DIR)/* && \
	mkdir $(BUILD_DIR)/js $(BUILD_DIR)/css $(BUILD_DIR)/img $(BUILD_DIR)/fonts && \
	mkdir $(BUILD_DIR)/css/fonts

dev: reset resume dev-templates dev-scripts dev-styles fonts dev-images

dev-templates:
	$(JADE) -o $(BUILD_DIR) -O $(FRONTEND_SRC)/templates/models.json -P $(FRONTEND_SRC)/templates/main.jade

dev-scripts:
	$(BROWSERIFY) --debug $(FRONTEND_SRC)/scripts/main.js > $(BUILD_DIR)/js/bundle.js
	
dev-styles:
	$(LESS) --source-map-less-inline --source-map-map-inline --clean-css $(FRONTEND_SRC)/styles/main.less $(BUILD_DIR)/css/bundle.css

dev-images:
	cp -a $(FRONTEND_SRC)/images/. $(BUILD_DIR)/img

fonts:
	cp $(FRONTEND_SRC)/node_modules/bootstrap/fonts/* $(BUILD_DIR)/fonts && \
	cp $(FRONTEND_SRC)/node_modules/font-awesome/fonts/* $(BUILD_DIR)/fonts	
#cp $(FRONTEND_SRC)/fonts/* $(BUILD_DIR)/fonts && \

resume:
	$(RESUME) export $(BUILD_DIR)/resume.html -t classy

prod: reset resume fonts
	$(JADE) -o $(BUILD_DIR) -O $(FRONTEND_SRC)/templates/models.json $(FRONTEND_SRC)/templates/main.jade && \
	$(BROWSERIFY) $(FRONTEND_SRC)/scripts/main.js | $(UGLIFYJS) > $(BUILD_DIR)/js/prebundle.js && \
	$(CLOSURE) $(BUILD_DIR)/js/prebundle.js > $(BUILD_DIR)/js/bundle.js && \
	rm $(BUILD_DIR)/js/prebundle.js && \
	$(LESS) -clean-css $(FRONTEND_SRC)/styles/main.less | $(UGLIFYCSS) > $(BUILD_DIR)/css/bundle.css && \
	cp -a $(FRONTEND_SRC)/images/* $(BUILD_DIR)/img
#$(UNCSS) $(BUILD_DIR)/css/bundle.css > $(BUILD_DIR)/css/bundle.css && \
#cp server/config/prod.ini combat2college/config/config.ini

.PHONY: dev
