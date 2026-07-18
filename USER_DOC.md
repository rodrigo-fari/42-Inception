# User Documentation

## What this stack provides

This project runs three services:

- **NGINX**: the HTTPS web server that receives browser requests.
- **WordPress + PHP-FPM**: the application layer that generates the website.
- **MariaDB**: the database that stores WordPress content, users, and settings.

The services are connected through a private Docker network, and the website is served over HTTPS on port `443`.

## Start and stop the project

From the repository root, start the stack with:

```bash
make
```

This builds the containers and launches them in the background.

To stop the project, run:

```bash
make down
```

This stops and removes the containers while keeping the persistent data.

## Access the website and administration panel

Open the website in a browser with:

```text
https://<your_domain_name>
```

The domain name is defined in the repository root `.env` file.

The WordPress administration panel is available at:

```text
https://<your_domain_name>/wp-admin
```

If the browser shows a certificate warning, accept it for local development. The stack uses a self-signed TLS certificate.

## Manage credentials

All credentials are defined in the root `.env` file and used when the containers start.

Typical values include:

- the database name
- the MariaDB root password
- the WordPress database user and password
- the WordPress administrator account and password
- the additional WordPress user account and password

Keep the `.env` file private and do not commit it to version control.

If you need to inspect the MariaDB account from the host machine, you can use:

```bash
make mysql
```

## Check that services are running correctly

Use this command to see the container status:

```bash
make status
```

You can also confirm the stack is healthy by checking that:

- `nginx` is running and reachable on HTTPS.
- `wordpress` is running and can serve the WordPress site.
- `mariadb` is running and the site loads without database errors.

If the site does not load, check the container logs with Docker Compose.