# COLORS
GREEN := "\033[32m"
YELLOW := "\033[33m"
BLUE := "\033[34m"
NC := "\033[0m"

# COMMANDS
all:
	@echo $(BLUE)🐋 Docker containers are starting... $(NC)
	@docker compose up --build
	@echo $(GREEN)✅ Successfully started! $(NC)
.PHONY: all

dev: stop
	@echo $(BLUE)🚧 Development containers are starting... $(NC)
	@docker compose -f ./docker-compose.dev.yml up --build
.PHONY: dev

submodule:
	@echo $(BLUE)🚚 Updating submodules... $(NC)
	@git submodule update --remote

down:
	@docker-compose -f ./docker-compose.yml down
.PHONY: down

re: prune
	make all
.PHONY: re

prune: stop
	@echo $(BLUE)"docker system prune will be executed"$(NC)
	@docker system prune -a -f --volumes
.PHONY: prune

stop:
	@if [ $$(docker ps -q | wc -l) -gt 0 ]; then \
		echo $(BLUE)🛑 Stopping containers... $(NC); \
		docker stop $$(docker ps -q); \
	else \
		echo $(YELLOW)No running containers found. $(NC); \
	fi
.PHONY: stop

main:
	cd backend && git fetch origin && git switch "chore/deploying-dockerfile-217"
	cd backend/nginx && git switch main
	cd frontend && git switch main
	cd env && git switch main
.PHONY: main
