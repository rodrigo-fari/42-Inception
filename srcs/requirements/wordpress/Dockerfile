# ----------| Debian Bullseye - Penultimate stable version |
FROM debian:bullseye-slim

# ----------| Install PHP-FPM, required extensions, and utilities |
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-xml \
    php7.4-mbstring \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# ----------| Create document root directory for WordPress |
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html

# ----------| Download and extract latest WordPress |
RUN wget https://wordpress.org/latest.zip -O /tmp/wordpress.zip && \
    unzip /tmp/wordpress.zip -d /tmp/ && \
    cp -r /tmp/wordpress/* /var/www/html/ && \
    rm -rf /tmp/wordpress.zip /tmp/wordpress

# ----------| Copy PHP-FPM pool configuration |
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# ----------| Copy WordPress setup script |
COPY tools/setup_wp.sh /usr/local/bin/setup_wp.sh
RUN chmod +x /usr/local/bin/setup_wp.sh

# ----------| Change ownership of WordPress files to www-data user |
RUN chown -R www-data:www-data /var/www/html

# ----------| Expose PHP-FPM port (NGINX will connect here) |
EXPOSE 9000

# ----------| Start PHP-FPM in foreground (PID 1) - no infinite loops |
CMD ["/usr/local/bin/setup_wp.sh"]