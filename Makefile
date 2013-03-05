TESTS = test/*_spec.js
REPORTER = dot

#
# Node Module
#

node_modules: package.json
	@npm install

#
# Browser Build
# 

openxjs.js: node_modules src/*
	@printf "\n  ==> [Browser :: build]\n"
	@./node_modules/coffee-script/bin/coffee \
		-o ./ \
		-c src/openxjs.coffee

#
# Tests
# 

test: test-browser

test-compile: node_modules src/*
	@printf "\n  ==> [Test :: build]\n"
	@./node_modules/coffee-script/bin/coffee \
		-b \
		-c test/*_spec.coffee

test-browser: openxjs.js test-compile has-phantomjs
	@printf "\n  ==> [Test :: Browser Build via PhantomJS]\n"
	@./node_modules/.bin/mocha-phantomjs \
		--reporter $(REPORTER) \
		./test/browser/index.html

#
# Clean up
# 

clean: clean-node clean-browser clean-test-compile

clean-node:
	@rm -rf node_modules

clean-browser:
	@rm -f openxjs.js

clean-test-compile:
	@rm -f $(TESTS)

#
# Utils
#

has-phantomjs:
ifeq ($(shell which phantomjs),)
	$(error PhantomJS is not installed. Download from http://phantomjs.org or Homebrew)
endif

#
# Instructions
#

.PHONY: all test text-compile test-browser test-cov clean clean-node clean-browser clean-cov has-phantomjs has-jscoverage 