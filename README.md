*This project has been created as part of the 42 curriculum by rde-fari.*

# Inception

## Description

This project deploys a small web stack with Docker to host a WordPress website secured with NGINX and backed by MariaDB.

The goal is to reproduce a production-like architecture using isolated services, persistent storage, and a controlled initialization flow. The stack is composed of:

- NGINX as the public HTTPS entry point.
- WordPress with PHP-FPM as the application layer.
- MariaDB as the database engine.

The project is designed to run locally with Docker Compose and to keep application data outside the containers so the website and database survive rebuilds and restarts.

## Instructions

### Requirements

- Docker
- Docker Compose
- GNU Make

### Configuration

Create a root `.env` file with the values used by the stack. The provided setup expects variables such as:

- `DOMAIN_NAME`
- `DB_NAME`
- `DB_USER`
- `DB_PASS`
- `DB_ROOT_PASS`
- `WP_ADMIN`
- `WP_ADMIN_PASS`
- `WP_USER`
- `WP_USER_PASS`
- `WP_USER_EMAIL`
- `DATA_PATH`

The services read this file through `srcs/docker-compose.yml`.

### Build and run

From the repository root:

```bash
make up
```

This creates the host data directories if needed and starts the full stack in detached mode.

Useful commands:

```bash
make down
make clean
make fclean
make re
make status
make mysql
```

## Project Description

The project uses Docker to isolate each service in its own container while keeping them connected through a private bridge network. NGINX exposes only HTTPS on port 443, WordPress runs as the application backend, and MariaDB stores the site data.

The source files included in the project are the `Makefile`, the Docker Compose configuration, the Dockerfiles for each service, the service configuration files, and the shell scripts that initialize WordPress and MariaDB.

Main design choices:

- One container per service to keep responsibilities separated.
- A private Docker network so only the stack services can talk to each other directly.
- Persistent host-mounted data directories under `~/data` so the database and WordPress files survive container recreation.
- Shell-based initialization scripts to make database and WordPress setup repeatable and idempotent.
- A self-signed certificate for local HTTPS access.

### Required comparisons

#### Virtual Machines vs Docker

Virtual machines virtualize a full operating system for each environment, which is heavier in CPU, memory, and startup time. Docker shares the host kernel and isolates applications at the container level, which makes the stack lighter, faster to start, and easier to reproduce for this project.

#### Secrets vs Environment Variables

Secrets are better for sensitive production workloads because they are designed to protect confidential data more strictly. Environment variables are simpler and are enough for this local educational project, where the credentials are loaded from a `.env` file and injected into the containers at startup.

#### Docker Network vs Host Network

A Docker network keeps the services isolated from the host and lets only the containers in the stack communicate with each other. Host networking would expose the containers directly on the host network stack, reducing isolation and making port management less controlled.

#### Docker Volumes vs Bind Mounts

Docker volumes are managed by Docker, while bind mounts map specific host paths into containers. This project uses bind mounts for the persistent data so the stored files are easy to inspect and remain available under `~/data/wordpress` and `~/data/mariadb`.

## Resources

Classic references:

- Docker documentation: https://docs.docker.com/
- Docker Compose documentation: https://docs.docker.com/compose/
- NGINX documentation: https://nginx.org/en/docs/
- WordPress documentation: https://wordpress.org/documentation/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/

AI usage:

- AI was used to help draft and polish the README, user documentation, and developer documentation.
- AI was used to align the text with the actual Docker Compose layout, the Makefile targets, and the initialization scripts.
- AI was not used to implement project runtime logic or to generate the container configuration itself.