MAKEFLAGS += -s

up:
	docker-compose -f srcs/docker-compose.yml up -d --build

down:
	docker-compose -f srcs/docker-compose.yml down
	docker-compose -f srcs/docker-compose.yml up -d --build

re:
	docker-compose -f srcs/docker-compose.yml down

clean:
	docker system prune -af

.PHONY: up down re clean
