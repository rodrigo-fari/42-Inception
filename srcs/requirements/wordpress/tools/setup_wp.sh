#!/bin/sh
set -e

# Support both naming conventions: new (MYSQL_*) and current (.env: DB_*)
MYSQL_DATABASE="${DB_NAME:-${MYSQL_DATABASE}}"
MYSQL_USER="${DB_USER:-${MYSQL_USER}}"
MYSQL_PASSWORD="${DB_PASS:-${MYSQL_PASSWORD}}"
MYSQL_ROOT_PASSWORD="${DB_ROOT_PASS:-${MYSQL_ROOT_PASSWORD}}"
WP_ADMIN_USER="${WP_ADMIN:-${WP_ADMIN_USER}}"
WP_ADMIN_PASSWORD="${WP_ADMIN_PASS:-${WP_ADMIN_PASSWORD}}"
WP_ADMIN_EMAIL="${WP_ADMIN}@${DOMAIN_NAME}"
WP_USER="${WP_USER}"
WP_USER_EMAIL="${WP_USER_EMAIL}"
WP_USER_PASSWORD="${WP_USER_PASS:-${WP_USER_PASSWORD}}"

: "${MYSQL_DATABASE:?MYSQL_DATABASE/DB_NAME is required}"
: "${MYSQL_USER:?MYSQL_USER/DB_USER is required}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD/DB_PASS is required}"
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD/DB_ROOT_PASS is required}"
: "${DOMAIN_NAME:?DOMAIN_NAME is required}"
: "${WP_ADMIN_USER:?WP_ADMIN/WP_ADMIN_USER is required}"
: "${WP_ADMIN_PASSWORD:?WP_ADMIN_PASS/WP_ADMIN_PASSWORD is required}"
: "${WP_USER:?WP_USER is required}"
: "${WP_USER_EMAIL:?WP_USER_EMAIL is required}"
: "${WP_USER_PASSWORD:?WP_USER_PASS/WP_USER_PASSWORD is required}"

wait_for_db_ping() {
	max_retries=60
	retry=0

	until mysqladmin -h mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" ping --silent; do
		retry=$((retry + 1))
		if [ "$retry" -ge "$max_retries" ]; then
			echo "MariaDB did not respond to ping after ${max_retries} retries"
			exit 1
		fi
		echo "Waiting for MariaDB (${retry}/${max_retries})..."
		sleep 2
	done
}

wait_for_app_user() {
	max_retries=60
	retry=0

	until mysql -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "SELECT 1"; do
		retry=$((retry + 1))
		if [ "$retry" -ge "$max_retries" ]; then
			echo "WordPress DB user failed to connect after ${max_retries} retries"
			exit 1
		fi
		echo "WordPress DB user not ready yet (${retry}/${max_retries})..."
		sleep 2
	done
}

# Create .my.cnf for MySQL client authentication
cat > ~/.my.cnf << EOF
[client]
host=mariadb
user=${MYSQL_USER}
password=${MYSQL_PASSWORD}
EOF
chmod 600 ~/.my.cnf

# ----------| Wait MariaDB to be ready |
echo "Waiting for MariaDB..."
wait_for_db_ping
echo "MariaDB is ready!"

# ----------| Verify WordPress user can connect |
echo "Verifying WordPress user credentials..."
wait_for_app_user
echo "WordPress user can connect!"

# ----------| Download wp-cli (WP's command line tool) |
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp
chmod +x /usr/local/bin/wp

# ----------| If doesn't exists already, create wp-config.php file |
if [ ! -f /var/www/html/wp-config.php ]; then
	/usr/local/bin/wp core config \
		--dbhost=mariadb:3306 \
		--dbname=${MYSQL_DATABASE} \
		--dbuser=${MYSQL_USER} \
		--dbpass=${MYSQL_PASSWORD} \
		--path=/var/www/html \
		--allow-root
fi

# ----------| Install WordPress if isn't already installed |
if ! /usr/local/bin/wp core is-installed --path=/var/www/html --allow-root; then
	/usr/local/bin/wp core install \
		--url=https://${DOMAIN_NAME} \
		--title="Inception Project" \
		--admin_user=${WP_ADMIN_USER} \
		--admin_password=${WP_ADMIN_PASSWORD} \
		--admin_email=${WP_ADMIN_EMAIL} \
		--path=/var/www/html \
		--allow-root

# ----------| Create second user |
	/usr/local/bin/wp user create \
		${WP_USER} ${WP_USER_EMAIL} \
		--role=subscriber \
		--user_pass=${WP_USER_PASSWORD} \
		--path=/var/www/html \
		--allow-root
fi

# ----------| Check permitions |
chown -R www-data:www-data /var/www/html

# ----------| Ensure PHP-FPM runtime directory exists |
mkdir -p /run/php
chown -R www-data:www-data /run/php

# ----------| Init PHP-FPM foregrounded (PID1) |
exec php-fpm7.4 -F