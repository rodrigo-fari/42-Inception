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
DOCKER_VOLUMES := wordpress_data mariadb_data
DATA_DIR := $(HOME)/data/wordpress $(HOME)/data/mariadb

# ----------| Default target |
up:
	@mkdir -p $(DATA_DIR)
	@echo "$(BOLD)$(CYAN)╔════════════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(BOLD)$(CYAN)║$(RESET)             $(GREEN)🚀 INCEPTION - BUILDING CONTAINERS$(RESET)             $(CYAN)║$(RESET)"
	@echo "$(BOLD)$(CYAN)╚════════════════════════════════════════════════════════════╝$(RESET)"
	@echo "$(YELLOW)📦 Building and starting all containers...$(RESET)"
	@$(DOCKER_COMPOSE) up --build --detach

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
re: fclean up
	@echo "$(GREEN)✅ Rebuild completed successfully!$(RESET)"

# ----------| Show status of running containers |
status:
	@echo "$(BLUE)📊 Container status:$(RESET)"
	@$(DOCKER_COMPOSE) ps

# ----------| Access MySQL CLI inside MariaDB container |
mysql:
	@echo "$(CYAN)🕐 Connecting to MySQL...$(RESET)"
	@docker exec -it mariadb mysql -u root -p

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
	@echo "$(BOLD)$(CYAN)║$(RESET)                $(BOLD)INCEPTION PROJECT - COMMANDS$(RESET)                   $(CYAN)║$(RESET)"
	@echo "$(BOLD)$(CYAN)╚═══════════════════════════════════════════════════════════════╝$(RESET)"
	@echo ""
	@echo "$(GREEN)📦 Core Commands:$(RESET)"
	@echo "  $(YELLOW)make$(RESET)             - Build and start all containers"
	@echo "  $(YELLOW)make down$(RESET)        - Stop and remove containers"
	@echo "  $(YELLOW)make clean$(RESET)       - Stop containers + prune unused resources"
	@echo "  $(YELLOW)make fclean$(RESET)      - Full cleanup (removes volumes too)"
	@echo "  $(YELLOW)make re$(RESET)          - Rebuild everything from scratch"
	@echo ""
	@echo "$(BLUE)📊 Monitoring:$(RESET)"
	@echo "  $(YELLOW)make status$(RESET)      - Show container status"
	@echo ""
	@echo "$(CYAN)🕐 Shell Access:$(RESET)"
	@echo "  $(YELLOW)make mysql$(RESET)       - Connect to MySQL CLI"
	@echo ""
	@echo "$(RED)⚠️  Dangerous:$(RESET)"
	@echo "  $(YELLOW)make prune$(RESET)       - Remove EVERYTHING unused (asks confirmation)"
	@echo ""
	@echo "$(BOLD)$(CYAN)═══════════════════════════════════════════════════════════════$(RESET)"

# ----------| Catch-all rule: show help if user types unknown command |
%:
	@echo "$(RED)❌ Error: '$@' is not a valid command.$(RESET)"
	@echo ""
	@$(MAKE) -s help

# ----------| Declare phony targets (not actual files) |
.PHONY: up down clean fclean re status mysql prune help