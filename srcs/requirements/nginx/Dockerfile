# ----------| Debian Bullseye - Penultimate stable version |
FROM debian:bullseye-slim

# ----------| Install NGINX and OpenSSL for TLS certificate generation |
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# ----------| Create necessary directories for NGINX runtime and SSL |
RUN mkdir -p /run/nginx /var/www/html /etc/nginx/ssl

# ----------| Generate self-signed SSL certificate (valid for 365 days) |
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=PT/ST=Porto/L=Porto/O=42/CN=${DOMAIN_NAME}"

# ----------| Remove default NGINX configuration |
RUN rm -f /etc/nginx/sites-enabled/default \
    && rm -f /etc/nginx/sites-available/default

# ----------| Copy custom NGINX site configuration |
COPY conf/nginx.conf /etc/nginx/sites-available/default

# ----------| Enable custom site configuration |
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# ----------| Expose HTTPS port only (TLSv1.2/TLSv1.3) |
EXPOSE 443

# ----------| Start NGINX in foreground (PID 1) - no infinite loops |
CMD ["nginx", "-g", "daemon off;"]