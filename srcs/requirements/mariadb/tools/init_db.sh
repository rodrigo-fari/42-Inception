#!/bin/sh
# ------------------------------| init_db.sh - Init DB Script |

# ----------| Verify db already initialized |
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing database..."

	# ----------| Install db |
	mysql_install_db --user=mysql --datadir=/var/lib/mysql

	# ----------| Init db temporarily |
	mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
	sleep 5

	# ----------| Execute SQL commands to create and init tables, users and permissions |
	mysql -u root << EOF
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

	# ----------| Kill previously created temp process  |
	mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
	sleep 2
fi

# ----------| Init foreground Mdb (PID 1) |
exec mysqld --user=mysql --datadir=/var/lib/mysql