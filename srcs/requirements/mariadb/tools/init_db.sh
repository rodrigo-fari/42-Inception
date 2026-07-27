#!/bin/sh
# ------------------------------| init_db.sh - Init DB Script |

set -e

# Support both naming conventions: new (MYSQL_*) and current (.env: DB_*)
MYSQL_DATABASE="${DB_NAME:-${MYSQL_DATABASE}}"
MYSQL_USER="${DB_USER:-${MYSQL_USER}}"
MYSQL_PASSWORD="${DB_PASS:-${MYSQL_PASSWORD}}"
MYSQL_ROOT_PASSWORD="${DB_ROOT_PASS:-${MYSQL_ROOT_PASSWORD}}"
MYSQL_SOCKET="/run/mysqld/mysqld.sock"

: "${MYSQL_DATABASE:?MYSQL_DATABASE/DB_NAME is required}"
: "${MYSQL_USER:?MYSQL_USER/DB_USER is required}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD/DB_PASS is required}"
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD/DB_ROOT_PASS is required}"

wait_for_mysql() {
	max_retries=60
	retry=0

	until mysqladmin --protocol=socket --socket="${MYSQL_SOCKET}" ping --silent; do
		retry=$((retry + 1))
		if [ "$retry" -ge "$max_retries" ]; then
			echo "MariaDB did not become ready after ${max_retries} seconds"
			exit 1
		fi
		echo "Waiting for MariaDB startup (${retry}/${max_retries})..."
		sleep 1
	done
}

MYSQLD_PID=""
cleanup_temp_mysql() {
	if [ -n "$MYSQLD_PID" ] && [ -d "/proc/${MYSQLD_PID}" ]; then
		echo "Stopping temporary MariaDB process..."
		kill "$MYSQLD_PID"
		wait "$MYSQLD_PID" || true
	fi
}

trap cleanup_temp_mysql EXIT

DB_ALREADY_INITIALIZED=0
# ----------| Check if database is already initialized |
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing database for the first time..."
	DB_ALREADY_INITIALIZED=0

	# ----------| Install base system tables |
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
else
	DB_ALREADY_INITIALIZED=1
fi

# ----------| Start temporary MySQL instance without networking for configuration |
echo "Starting temporary MariaDB instance for configuration..."
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket="${MYSQL_SOCKET}" &
MYSQLD_PID=$!

# ----------| Wait for MySQL to be ready |
wait_for_mysql
echo "MariaDB ready for configuration"

# ----------| Execute SQL commands to ensure proper database/user setup (idempotent) |
if [ "$DB_ALREADY_INITIALIZED" -eq 1 ]; then
	mysql --protocol=socket --socket="${MYSQL_SOCKET}" -uroot -p"${MYSQL_ROOT_PASSWORD}" << EOF
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
FLUSH PRIVILEGES;

-- Ensure database exists
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- Ensure application user exists with correct permissions
DROP USER IF EXISTS '${MYSQL_USER}'@'%';
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- Keep the configured root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
else
	mysql --protocol=socket --socket="${MYSQL_SOCKET}" -uroot << EOF
-- Clean up anonymous users
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
FLUSH PRIVILEGES;

-- Ensure database exists
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- Ensure application user exists with correct permissions
DROP USER IF EXISTS '${MYSQL_USER}'@'%';
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
fi

echo "Database configuration complete"

# ----------| Shutdown temp instance |
if [ "$DB_ALREADY_INITIALIZED" -eq 1 ]; then
	mysqladmin --protocol=socket --socket="${MYSQL_SOCKET}" -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
else
	mysqladmin --protocol=socket --socket="${MYSQL_SOCKET}" -uroot shutdown
fi
wait "$MYSQLD_PID" || true
trap - EXIT
sleep 2

# ----------| Start MariaDB in foreground for Docker (PID 1) |
echo "Starting MariaDB in foreground..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 --port=3306