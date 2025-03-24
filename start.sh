#!/bin/bash
set -ex  # Add -x for verbose output

echo "[$(date)] Starting nginx setup..."

# Check if wget is installed (for healthcheck)
echo "[$(date)] Installing wget..."
apt-get update && apt-get install -y wget cron

# Create nginx configuration directories if they don't exist
mkdir -p /etc/nginx/sites-enabled
mkdir -p /etc/nginx/sites-available

# Remove default configurations if they exist
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default
rm -f /etc/nginx/conf.d/default.conf

# Create the HTTP configuration
echo "[$(date)] Creating HTTP configuration..."
cat > /etc/nginx/sites-available/app.conf << EOL
# HTTP Server - Redirect to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN};
    
    # Redirect all HTTP requests to HTTPS
    location / {
        return 301 https://\$host\$request_uri;
    }
}

# HTTPS Server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${DOMAIN};

    # Root directory
    root /var/www/html;
    index index.html;

    # Logging
    access_log /var/log/nginx/access.log combined buffer=512k flush=1m;
    error_log /var/log/nginx/error.log warn;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml application/json application/javascript application/rss+xml application/atom+xml image/svg+xml text/javascript application/x-javascript application/xml;
    gzip_min_length 1000;
    gzip_disable "msie6";

    # Cache static files
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 7d;
        add_header Cache-Control "public, no-transform";
        access_log off;
        tcp_nodelay off;
        open_file_cache max=1000 inactive=30s;
        open_file_cache_valid 60s;
        open_file_cache_min_uses 2;
        open_file_cache_errors on;
    }
    
    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
    
    # Limit request size to prevent abuse
    client_max_body_size 10M;
    
    # Timeouts
    client_body_timeout 12;
    client_header_timeout 12;
    keepalive_timeout 15;
    send_timeout 10;
}
EOL

# Check if certificates exist
echo "[$(date)] Checking for SSL certificates..."
if [ ! -f /etc/letsencrypt/live/${DOMAIN}/fullchain.pem ]; then
    echo "[$(date)] No SSL certificates found. Starting in HTTP mode..."
    
    # Create symlink for HTTP config
    ln -sf /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/
    
    # Test nginx configuration
    echo "[$(date)] Testing nginx configuration..."
    nginx -t
    
    # Start nginx in HTTP mode
    echo "[$(date)] Starting nginx in HTTP mode..."
    service nginx start
    
    echo "[$(date)] Waiting for nginx to start..."
    sleep 5
    
    # Obtain certificates
    echo "[$(date)] Obtaining SSL certificates..."
    certbot --nginx -d ${DOMAIN} --email ${EMAIL} --agree-tos --non-interactive
    
    # Stop nginx
    echo "[$(date)] Stopping nginx..."
    service nginx stop
    sleep 5
fi

# Create the SSL configuration
echo "[$(date)] Creating SSL configuration..."
cat > /etc/nginx/sites-available/ssl.conf << EOL
# SSL configuration
ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_session_tickets off;

# OCSP Stapling
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;

# Modern SSL configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

# HSTS
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
EOL

# Create symlinks for both configurations
ln -sf /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/ssl.conf /etc/nginx/sites-enabled/

# Test the configuration
echo "[$(date)] Testing final nginx configuration..."
nginx -t

# Start nginx in foreground
echo "[$(date)] Starting nginx in HTTPS mode..."
exec nginx -g 'daemon off;' 
