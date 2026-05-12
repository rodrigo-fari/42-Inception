# ----------| Debian Bullseye - Penultimate stable version |
FROM debian:bullseye-slim

# ----------| Install MariaDB and required packages |
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# ----------| Create runtime directory for MariaDB |
RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld && \
    chmod 777 /run/mysqld

# ----------| Copy database initialization script |
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

# ----------| Declare volume for persistent database storage |
VOLUME ["/var/lib/mysql"]

# ----------| Expose default MariaDB/MySQL port |
EXPOSE 3306

# ----------| Start MariaDB in foreground (PID 1) - no infinite loops |
ENTRYPOINT ["/usr/local/bin/init_db.sh"]