# Developer Documentation

## Environment setup

Make sure the following tools are installed on the machine before starting:

- Docker
- Docker Compose
- GNU Make

From a fresh clone, create the root `.env` file with the configuration expected by the stack. The current scripts and compose file use these values:

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

The WordPress and MariaDB setup scripts accept both the `DB_*` variables used by this project and the `MYSQL_*` naming convention.

## Build and launch

The root `Makefile` is the main entry point.

Build and launch the stack with:

```bash
make
```

This runs Docker Compose with `--build --detach` against `srcs/docker-compose.yml`.

Other useful commands:

```bash
make down
make clean
make fclean
make re
make status
make mysql
```

Command summary:

- `make down` stops and removes the containers.
- `make clean` stops the stack and prunes unused Docker resources.
- `make fclean` removes the stack and its project volumes.
- `make re` performs a full cleanup followed by a rebuild.
- `make status` shows the running containers.
- `make mysql` opens a MySQL client session inside the MariaDB container.

## Containers and volumes

The stack runs three containers:

- `nginx`
- `wordpress`
- `mariadb`

Persistent project data is stored on the host through bind mounts defined in `srcs/docker-compose.yml`:

- WordPress files: `~/data/wordpress`
- MariaDB data: `~/data/mariadb`

Inside the containers, these map to:

- `/var/www/html`
- `/var/lib/mysql`

The Makefile creates `~/data` before starting the stack. The bind-mounted directories are what make the website files and database survive container recreation.

## Data persistence

Project data persists because the application and database directories are mounted from the host instead of living only inside the containers. Rebuilding or stopping the stack does not delete the content stored in those host paths.

To fully reset the project state, run:

```bash
make fclean
```

Then delete `~/data/wordpress` and `~/data/mariadb` if you also want to remove the stored host data.