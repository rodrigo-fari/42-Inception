#!/bin/sh
# ------------------------------| setup_wp.sh - Setup WordPress Script |

# ----------| Wait MariaDB to be ready |
echo "Waiting on MariaDB to be fully setup..."
while ! mysqladmin ping -h mariadb --silent; do
	sleep 2
done

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
chown -R nobody:nobody /var/www/html

# ----------| Init PHP-FPM foregrounded (PID1) |
exec php-fpm83 -F