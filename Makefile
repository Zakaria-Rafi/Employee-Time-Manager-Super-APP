SHELL := /bin/bash

ENV ?= dev

ifeq ($(ENV), prod)
    DOCKER_COMPOSE_FILE := docker-compose.yaml
else ifeq ($(ENV), local)
    DOCKER_COMPOSE_FILE := docker-compose.local.yaml
else
    DOCKER_COMPOSE_FILE := docker-compose.dev.yaml
endif

.PHONY: build
build:
	docker compose -f $(DOCKER_COMPOSE_FILE) up --build -d
ifneq (,$(filter $(ENV),prod local))
	echo "Waiting for run migrations..."
	sleep 90
	docker compose exec elixir mix ecto.migrate
endif

.PHONY: down
down:
	docker compose -f $(DOCKER_COMPOSE_FILE) down --remove-orphans -v --rmi all

.PHONY: re-build
re-build:
	$(MAKE) down
	$(MAKE) build

.PHONY: logs
logs:
	docker compose -f $(DOCKER_COMPOSE_FILE) logs -f

.PHONY: bash
bash:
	docker compose -f $(DOCKER_COMPOSE_FILE) exec -it elixir /bin/sh

.PHONY: test
test:
	docker compose -f docker-compose.dev.yaml exec elixir sh -c 'MIX_ENV=test mix test'

.PHONY: seeds
seeds:
	docker container exec t-poo-700-nan_6-elixir-1 sh -c 'mix run priv/repo/seeds.exs'