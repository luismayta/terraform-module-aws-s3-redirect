#
# See ./CONTRIBUTING.rst
#

export README_FILE ?= README.md
export README_YAML ?= README.yaml
export README_INCLUDES ?= $(file://$(shell pwd)/?type=text/plain)

OS := $(shell uname)
.PHONY: help
.DEFAULT_GOAL := help

PROJECT=terraform-aws-s3-redirect

PYTHON_VERSION=3.6.4
PYENV_NAME="${PROJECT}"

# Configuration.
SHELL := /bin/bash
ROOT_DIR=$(shell pwd)
MESSAGE:=🍺️
MESSAGE_HAPPY:="${MESSAGE} Happy Coding"
REQUIREMENTS_DIR=$(ROOT_DIR)/requirements
README_TEMPLATE:=$(ROOT_DIR)/templates/README.md

pip_install := pip install -r

include extras/make/*.mk

help:
	@echo '${MESSAGE} Makefile for ${PROJECT}'
	@echo ''
	@echo 'Usage:'
	@echo '    environment               create environment with pyenv'
	@echo '    clean                     remove files of build'
	@echo '    setup                     install requirements'
	@echo '    readme                    build README'
	@echo ''

## Create README.md by building it from README.yaml
readme:
	@gomplate --file $(README_TEMPLATE) \
		--out $(README_FILE)

clean:
	@echo "Cleaning up"
ifneq (Darwin,$(OS))
	@sudo rm -rf .tox *.egg *.egg-info dist build .coverage .eggs .mypy_cache
	@sudo rm -rf docs/build
	@sudo find . -name '__pycache__' -delete -print -o -name '*.pyc' -delete -print -o -name '*.pyo' -delete -print -o -name '*~' -delete -print -o -name '*.tmp' -delete -print
else
	@rm -rf .tox *.egg *.egg-info dist build .coverage .eggs .mypy_cache
	@rm -rf docs/build
	@find . -name '__pycache__' -delete -print -o -name '*.pyc' -delete -print -o -name '*.pyo' -delete -print -o -name '*~' -delete -print -o -name '*.tmp' -delete -print
endif
	@echo

setup: clean
	$(pip_install) "${REQUIREMENTS_DIR}/setup.txt"
	@if [ -e "${REQUIREMENTS_DIR}/private.txt" ]; then \
			$(pip_install) "${REQUIREMENTS_DIR}/private.txt"; \
	fi
	pre-commit install
	cp -rf .hooks/prepare-commit-msg .git/hooks/

environment: clean
	@echo "=====> loading virtualenv ${PYENV_NAME}..."
	@pyenv virtualenv ${PYTHON_VERSION} ${PYENV_NAME} >> /dev/null 2>&1; \
	@pyenv activate ${PYENV_NAME} >> /dev/null 2>&1 || echo $(MESSAGE_HAPPY)
