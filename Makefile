.PHONY: help validate start logs stop compose clean get-version bump-version backup docs changelog

help:
	@echo "make help         -- show this help"
	@echo "make validate	 -- validate docker-compose files"
	@echo "make start        -- start docker-compose services"
	@echo "make logs         -- show docker-compose logs for all services"
	@echo "make stop         -- stop docker-compose services"
	@echo "make compose      -- run docker-compose with arguments"
	@echo "make clean        -- clean leftovers and build files"
	@echo "make get-version  -- get current version"
	@echo "make bump-version -- bump version"
	@echo "make backup       -- backup storage data"
	@echo "make docs         -- generate documentation"
	@echo "make changelog    -- update changelog"


validate:
	./compose.sh validate

start:
	./compose.sh start -l

logs:
	./compose.sh logs

stop:
	./compose.sh down

compose:
	./compose.sh $(MAKEFLAGS)

clean:
	./scripts/clean.sh $(MAKEFLAGS)

get-version:
	./scripts/get-version.sh

bump-version:
	./scripts/bump-version.sh $(MAKEFLAGS)

backup:
	./scripts/backup.sh

docs:
	./scripts/docs.sh $(MAKEFLAGS)

changelog:
	./scripts/changelog.sh $(MAKEFLAGS)
