# User Documentation

## Services provided

This stack includes three services:

- NGINX: receives browser requests and serves the site over HTTPS.
- WordPress + PHP-FPM: provides the website and admin interface.
- MariaDB: stores posts, users, settings, and other site data.

The services communicate through a private Docker network, and the public entry point is HTTPS on port 443.

## Start and stop

From the repository root, start everything with:

```bash
make up
```

This builds the images, creates the host data folders if needed, and starts the containers in the background.

To stop the stack while keeping the stored data, run:

```bash
make down
```

## Access the website

Open the site in a browser with:

```text
https://rde-fari.42.fr
```

The domain name comes from the root `.env` file.

The WordPress administration panel is available at:

```text
https://rde-fari.42.fr/wp-admin
```

If the browser shows a certificate warning, accept it for local development. The stack uses a self-signed certificate.

## Locate and manage credentials

All credentials are stored in the root `.env` file. The most important values are:

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

Do not commit the `.env` file.

If you need to open a MySQL shell inside the database container, use:

```bash
make mysql
```

## Check that services are running correctly

Use this command to inspect the containers:

```bash
make status
```

You can also verify that the stack is healthy by checking that:

- `nginx` is running and answering on HTTPS.
- `wordpress` is running and the homepage loads.
- `mariadb` is running and the WordPress database is available.

If something fails to load, check the container logs with Docker Compose and confirm that the `.env` file values match the expected credentials.