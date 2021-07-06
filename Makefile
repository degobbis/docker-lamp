#!/usr/bin/env make
DOCKER_COMPOSE_BASEDIR:=.
DOCKER_COMPOSE_DIR:=$(shell echo $(shell cd $(DOCKER_COMPOSE_BASEDIR); pwd))
empty:=
space:= $(empty) $(empty)
DOCKER_COMPOSE:=docker-compose --env-file $(DOCKER_COMPOSE_DIR)/.env
MINICA_DEFAULT_DOMAINS:=localdomains,localhost,joomla.local,joomla.test,*.joomla.local,*.joomla.test,wp.local,wp.test,*.wp.local,*.wp.test,wpms.local,wpms.test,*.wpms.local,*.wpms.test


DEFAULT_GOAL := help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-27s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: create-certs server-up server-down db-backup update-images delete-obsolete-images


create-env:
ifeq (,$(wildcard $(DOCKER_COMPOSE_DIR)/.env))
	@cp $(DOCKER_COMPOSE_DIR)/.env-example $(DOCKER_COMPOSE_DIR)/.env
	$(info "created .env from .env-example")
endif


load-env: create-env
ifneq (,$(wildcard $(DOCKER_COMPOSE_DIR)/.env))
	$(eval include $(DOCKER_COMPOSE_DIR)/.env)
	$(info $(DOCKER_COMPOSE_DIR)/.env included)
endif


create-certs: load-env
	$(eval MINICA_BASEDIR:=$(shell echo $(shell cd $(APP_BASEDIR)/ca; pwd)))
	$(eval MINICA_DEFAULT_DOMAINS:=$(shell [ -z "$(SSL_LOCALDOMAINS)" ] && echo $(MINICA_DEFAULT_DOMAINS) || echo $(MINICA_DEFAULT_DOMAINS),$(SSL_LOCALDOMAINS)))
	$(eval MINICA_DEFAULT_DOMAINS:=$(shell [ -z "$(SSL_DOMAINS)" ] && echo $(MINICA_DEFAULT_DOMAINS) || echo $(MINICA_DEFAULT_DOMAINS)$(space)$(SSL_DOMAINS)))
	@for domain in $(MINICA_DEFAULT_DOMAINS) ; do \
		docker run --user $(APP_USER_ID) -it --rm \
			-v "$(MINICA_BASEDIR):/certs" \
			degobbis/minica \
			--ca-cert minica-root-ca.pem \
			--ca-key minica-root-ca-key.pem \
			--domains $$domain ; \
	done ; true


server-up: create-certs ## Start all docker containers, creating new certificates before.
	@$(DOCKER_COMPOSE) up -d --force-recreate


server-down: db-backup ## Stops all docker containers and delete all volumes, saving all databases before.
	@$(DOCKER_COMPOSE) down
	@docker volume ls --filter=name=$(COMPOSE_PROJECT_NAME) | awk 'NR > 1 {print $2}' | xargs docker volume rm --force
#	docker volume prune --force


db-backup: load-env ## Saving all databases.
	@docker exec -it --privileged $(COMPOSE_PROJECT_NAME)_mysql sh -c "/usr/local/bin/backup-databases"


update-images: ## Update all images from docker-compose.yml to the latest build.
	@$(DOCKER_COMPOSE) pull


delete-obsolete-images: ## Delete all obsolete images.
	$(eval OBSOLETE_IMAGES:=$(shell docker images -f "dangling=true" -q))
	@echo $(shell [ ! -z "$(OBSOLETE_IMAGES)" ] && echo "Found obsolete Images: $(OBSOLETE_IMAGES)" || echo "No obsolete images found.")
	$(eval ERROR_DELETE_OBSOLETE:=$(shell [ ! -z "$(OBSOLETE_IMAGES)" ] && { docker rmi $(OBSOLETE_IMAGES) 1>/dev/null; } 2>&1))
	@echo $(shell if [ -z "$(ERROR_DELETE_OBSOLETE)" ] && [ ! -z "$(OBSOLETE_IMAGES)" ]; then echo "Obsolete images deleted."; else echo "'$(ERROR_DELETE_OBSOLETE)'"; fi)

