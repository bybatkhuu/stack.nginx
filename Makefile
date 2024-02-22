help:
	@echo "make help         -- show this help"
	@echo "make validate     -- validate compose.yml file"
	@echo "make start        -- start all services"
	@echo "make stop         -- stop all services"
	@echo "make get-version  -- get current version"
	@echo "make bump-version -- bump version"
	@echo "make build        -- build docker image"
	@echo "make clean        -- clean all"


validate:
	docker compose config

start:
	docker compose up -d --remove-orphans --force-recreate && \
		docker compose logs -f --tail 100

stop:
	docker compose down --remove-orphans

get-version:
	./scripts/get-version.sh

bump-version:
	./scripts/bump-version.sh -b=patch

build:
	./scripts/build.sh

clean:
	./scripts/clean.sh -a
