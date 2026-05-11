# ------------------------------| MAKEFILE |

# ----------| Colors for terminal output |
RED    := \033[0;31m
GREEN  := \033[0;32m
YELLOW := \033[0;33m
BLUE   := \033[0;34m
CYAN   := \033[0;36m
RESET  := \033[0m
BOLD   := \033[1m

# ----------| Variables |
DOCKER_COMPOSE := docker compose -f ./srcs/docker-compose.yml
DOCKER_VOLUMES := wordpress_files mariadb_data

# ----------| Default target |
all:
	@echo "$(BOLD)$(CYAN)╔════════════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(BOLD)$(CYAN)║$(RESET)             $(GREEN)🚀 INCEPTION - BUILDING CONTAINERS$(RESET)             $(CYAN)║$(RESET)"
	@echo "$(BOLD)$(CYAN)╚════════════════════════════════════════════════════════════╝$(RESET)"
	@echo "$(YELLOW)📦 Building and starting all containers...$(RESET)"
	@$(DOCKER_COMPOSE) up --build

# ----------| Stop and remove containers (but keep volumes) |
down:
	@echo "$(YELLOW)🛑 Stopping and removing containers...$(RESET)"
	@$(DOCKER_COMPOSE) down
	@echo "$(GREEN)✅ Containers stopped and removed.$(RESET)"

# ----------| Stop containers, remove unused images/networks/containers |
clean: down
	@echo "$(YELLOW)🧹 Cleaning unused Docker resources...$(RESET)"
	@docker system prune -f
	@echo "$(GREEN)✅ Cleanup completed.$(RESET)"

# ----------| Full cleanup: remove containers, networks, AND named volumes |
fclean: clean
	@echo "$(RED)🕐 Performing full cleanup (including volumes)...$(RESET)"
	@$(DOCKER_COMPOSE) down -v 2>/dev/null || true
	@docker volume rm $(DOCKER_VOLUMES) 2>/dev/null || true
	@echo "$(GREEN)✅ Full cleanup completed.$(RESET)"

# ----------| Rebuild everything from scratch |
re: fclean all
	@echo "$(GREEN)✅ Rebuild completed successfully!$(RESET)"

# ----------| Show status of running containers |
status:
	@echo "$(BLUE)📊 Container status:$(RESET)"
	@$(DOCKER_COMPOSE) ps

# ----------| Show live logs from all containers |
logs:
	@echo "$(BLUE)📜 Following logs (Ctrl+C to exit):$(RESET)"
	@$(DOCKER_COMPOSE) logs -f

# ----------| Access NGINX container shell |
shell-nginx:
	@echo "$(CYAN)🕐 Entering NGINX container shell...$(RESET)"
	@docker exec -it nginx sh

# ----------| Access WordPress container shell |
shell-wp:
	@echo "$(CYAN)🕐 Entering WordPress container shell...$(RESET)"
	@docker exec -it wordpress sh

# ----------| Access MariaDB container shell |
shell-db:
	@echo "$(CYAN)🕐 Entering MariaDB container shell...$(RESET)"
	@docker exec -it mariadb sh

# ----------| Access MySQL CLI inside MariaDB container |
mysql:
	@echo "$(CYAN)🕐 Connecting to MySQL...$(RESET)"
	@docker exec -it mariadb mysql -u root -p

# ----------| Check if containers are healthy |
health:
	@echo "$(BLUE)🕐 Checking container health...$(RESET)"
	@for container in nginx wordpress mariadb; do \
		STATUS=$$(docker inspect --format='{{.State.Status}}' $$container 2>/dev/null); \
		if [ "$$STATUS" = "running" ]; then \
			echo "$(GREEN)✅ $$container is running$(RESET)"; \
		elif [ "$$STATUS" = "" ]; then \
			echo "$(RED)❌ $$container does not exist$(RESET)"; \
		else \
			echo "$(RED)❌ $$container is $$STATUS$(RESET)"; \
		fi \
	done

# ----------| Display disk usage of Docker (images, containers, volumes) |
df:
	@echo "$(YELLOW)💾 Docker disk usage:$(RESET)"
	@docker system df

# ----------| Prune everything aggressively (use with caution) |
prune:
	@echo "$(RED)⚠️  WARNING: This will remove ALL unused containers, networks, images, AND volumes!$(RESET)"
	@read -p "Are you sure? Type 'yes' to continue: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		docker system prune -a --volumes -f; \
		echo "$(GREEN)✅ Prune completed.$(RESET)"; \
	else \
		echo "$(YELLOW)❌ Prune cancelled.$(RESET)"; \
	fi

# ----------| Show help menu (default for unknown commands) |
help:
	@echo "$(BOLD)$(CYAN)╔═══════════════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(BOLD)$(CYAN)║$(RESET)              $(BOLD)INCEPTION PROJECT - COMMANDS$(RESET)                      $(CYAN)║$(RESET)"
	@echo "$(BOLD)$(CYAN)╚═══════════════════════════════════════════════════════════════╝$(RESET)"
	@echo ""
	@echo "$(GREEN)📦 Core Commands:$(RESET)"
	@echo "  $(YELLOW)make$(RESET)          - Build and start all containers"
	@echo "  $(YELLOW)make down$(RESET)      - Stop and remove containers"
	@echo "  $(YELLOW)make clean$(RESET)     - Stop containers + prune unused resources"
	@echo "  $(YELLOW)make fclean$(RESET)    - Full cleanup (removes volumes too)"
	@echo "  $(YELLOW)make re$(RESET)        - Rebuild everything from scratch"
	@echo ""
	@echo "$(BLUE)📊 Monitoring:$(RESET)"
	@echo "  $(YELLOW)make status$(RESET)    - Show container status"
	@echo "  $(YELLOW)make logs$(RESET)      - Follow live logs"
	@echo "  $(YELLOW)make health$(RESET)    - Check if containers are healthy"
	@echo "  $(YELLOW)make df$(RESET)        - Show Docker disk usage"
	@echo ""
	@echo "$(CYAN)🕐 Shell Access:$(RESET)"
	@echo "  $(YELLOW)make shell-nginx$(RESET) - Open shell in NGINX container"
	@echo "  $(YELLOW)make shell-wp$(RESET)    - Open shell in WordPress container"
	@echo "  $(YELLOW)make shell-db$(RESET)    - Open shell in MariaDB container"
	@echo "  $(YELLOW)make mysql$(RESET)       - Connect to MySQL CLI"
	@echo ""
	@echo "$(RED)⚠️  Dangerous:$(RESET)"
	@echo "  $(YELLOW)make prune$(RESET)      - Remove EVERYTHING unused (asks confirmation)"
	@echo ""
	@echo "$(BOLD)$(CYAN)═══════════════════════════════════════════════════════════════$(RESET)"

# ----------| Catch-all rule: show help if user types unknown command |
%:
	@echo "$(RED)❌ Error: '$@' is not a valid command.$(RESET)"
	@echo ""
	@$(MAKE) -s help

# ----------| Declare phony targets (not actual files) |
.PHONY: all down clean fclean re status logs shell-nginx shell-wp shell-db mysql health df prune help