# Developer Documentation

## Environment setup

Before running the project, make sure the following are available on your machine:

- Docker
- Docker Compose
- GNU Make

The project expects a root `.env` file with the required secrets and configuration values. The stack reads this file through `srcs/docker-compose.yml`.

At minimum, the environment should define the values used by the services, such as:

- `DOMAIN_NAME`
- database name
- MariaDB root password
- WordPress database user and password
- WordPress admin user, password, and email-related values
- the extra WordPress user credentials

The WordPress and MariaDB containers both read the same environment file, and the setup scripts support both `DB_*` and `MYSQL_*` variable names.

## Build and launch

The main workflow is driven by the Makefile at the repository root.

Build and start the stack with:

```bash
make
```

This runs Docker Compose with `--build --detach` against `./srcs/docker-compose.yml`.

Useful lifecycle commands:

```bash
make down
make clean
make fclean
make re
make status
make mysql
```

Command summary:

- `make down` stops and removes containers.
- `make clean` stops containers and prunes unused Docker resources.
- `make fclean` removes containers, networks, and the project volumes.
- `make re` performs a full cleanup and rebuild.
- `make status` shows the current container state.
- `make mysql` opens a MySQL client session inside the MariaDB container.

## Containers and volumes

The stack contains three containers:

- `nginx`
- `wordpress`
- `mariadb`

Persistent data is stored on the host through bind-mounted Docker volumes configured in `srcs/docker-compose.yml`:

- WordPress files: `${HOME}/data/wordpress`
- MariaDB data: `${HOME}/data/mariadb`

These directories are what make the site content and database survive container recreation.

## Data persistence

The important persistent paths inside the containers are:

- `/var/www/html` for WordPress files
- `/var/lib/mysql` for MariaDB data

Those container paths are backed by the host directories listed above, so data remains available after `make down`, container rebuilds, and restarts.

If you want to fully reset the project data, use:

```bash
make fclean
```

and then remove the host directories if you want to clear the bind-mounted data completely.