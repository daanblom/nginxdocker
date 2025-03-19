FROM nginx:alpine

# Install certbot and its nginx plugin
RUN apk add --no-cache certbot certbot-nginx

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY nginx/conf.d/app.conf /etc/nginx/conf.d/

# Create directory for SSL certificates
RUN mkdir -p /etc/letsencrypt

# Create directory for web content
RUN mkdir -p /var/www/html

# Expose ports for HTTP and HTTPS
EXPOSE 80 443

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1 