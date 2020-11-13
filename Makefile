#!/usr/bin/env make
DOCKER_COMPOSE_DIR=.
DOCKER_COMPOSE=docker-compose --env-file $(DOCKER_COMPOSE_DIR)/.env


DEFAULT_GOAL := help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-27s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: create-env load-env server-up server-down db-backup

create-env:
ifeq (,$(wildcard ./.env))
	cp $(DOCKER_COMPOSE_DIR)/.env-example $(DOCKER_COMPOSE_DIR)/.env
	@echo "created .env from .env-example"
endif

load-env: create-env
ifneq (,$(wildcard ./.env))
	$(eval include $(DOCKER_COMPOSE_DIR)/.env)
	@echo "$(DOCKER_COMPOSE_DIR)/.env included"
endif


server-up: load-env ## Start all docker containers.
	@$(DOCKER_COMPOSE) up -d --force-recreate


server-down: db-backup load-env ## Stop all docker containers and delete all volumes.
	@$(DOCKER_COMPOSE) down
	@docker volume ls --filter=name=$(COMPOSE_PROJECT_NAME) | awk 'NR > 1 {print $2}' | xargs docker volume rm --force
#	docker volume prune --force


db-backup: ## Stop all docker containers.
	@docker exec -it mysql backup-databases.sh


#docker-prune: ## Remove unused docker resources via 'docker system prune -a -f --volumes'
#	docker system prune -a -f --volumes


#.PHONY: docker-build-from-scratch
#docker-build-from-scratch: ## docker-init ## Build all docker images from scratch, without cache etc. Build a specific image by providing the service name via: make docker-build CONTAINER=<service>
#	$(DOCKER_COMPOSE) rm -fs $(CONTAINER) && \
#	$(DOCKER_COMPOSE) build --pull --no-cache --parallel $(CONTAINER) && \
#	$(DOCKER_COMPOSE) up -d --force-recreate $(CONTAINER)

#.PHONY: docker-test
#docker-test: ## docker-init docker-up ## Run the infrastructure tests for the docker setup
#	sh $(DOCKER_COMPOSE_DIR)/docker-test.sh

#.PHONY: docker-build
#docker-build: docker-init ## Build all docker images. Build a specific image by providing the service name via: make docker-build CONTAINER=<service>
#	$(DOCKER_COMPOSE) build --parallel $(CONTAINER) && \
#	$(DOCKER_COMPOSE) up -d --force-recreate $(CONTAINER)

