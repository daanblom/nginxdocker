# Secure Nginx Web Server with SSL

This is a Docker-based setup for a secure Nginx web server with SSL support using Let's Encrypt certificates.

## Features

- Lightweight Nginx server based on Alpine Linux
- Automatic SSL certificate management with Let's Encrypt
- Modern SSL configuration with strong security headers
- HTTP/2 support
- Gzip compression with optimal settings
- OCSP Stapling for improved SSL performance
- Comprehensive static file caching
- Rate limiting and request size restrictions
- Fine-tuned timeout settings
- Security headers including HSTS, CSP, and Permissions-Policy
- Hidden file access protection
- Health checks
- Automatic Nginx reload every 6 hours

## Prerequisites

- Docker and Docker Compose installed
- A domain name pointing to your server
- Ports 80 and 443 open on your server

## Setup Instructions

1. Clone this repository
2. Create the required directories:
   ```bash
   mkdir -p www nginx/conf.d certbot/conf certbot/www
   ```

3. Update the configuration:
   - Edit `nginx/conf.d/app.conf` and replace `example.com` with your domain
   - Edit `docker-compose.yml` and update the `DOMAIN` and `EMAIL` environment variables

4. Place your website files in the `www` directory

5. Start the container:
   ```bash
   docker-compose up -d
   ```

6. The first time you run the container, you'll need to obtain SSL certificates. Run:
   ```bash
   docker-compose exec webserver certbot --nginx -d your-domain.com --email your-email@example.com --agree-tos --non-interactive
   ```

## Directory Structure

- `www/`: Your website files
- `nginx/conf.d/`: Nginx configuration files
- `certbot/conf/`: SSL certificates
- `certbot/www/`: Let's Encrypt verification files

## Security Features

- Automatic HTTP to HTTPS redirection
- Modern SSL configuration (TLSv1.2 & TLSv1.3) with strong ciphers
- OCSP Stapling for improved certificate validation
- Comprehensive security headers:
  - Strict-Transport-Security (HSTS)
  - X-Frame-Options (clickjacking protection)
  - X-XSS-Protection (cross-site scripting protection)
  - X-Content-Type-Options (MIME-type sniffing protection)
  - Referrer-Policy (controls outgoing referrer information)
  - Content-Security-Policy (restricts resource loading)
  - Permissions-Policy (restricts browser feature usage)
- Hidden file access protection
- Request size limitations (10MB max)
- Optimized timeout settings to prevent abuse

## Performance Optimizations

- HTTP/2 support for faster loading
- Session cache optimization
- Gzip compression with optimal settings for various content types
- Static file caching with:
  - Browser cache directives (7-day expiration)
  - Disabled access logging for static files
  - TCP optimizations
  - Nginx open file cache configuration
- Regular Nginx reloads for certificate updates

## Maintenance

- SSL certificates will auto-renew
- Nginx configuration is automatically reloaded every 6 hours
- Logs are available in the container at `/var/log/nginx/`
- Optimized logging with buffer settings

## Troubleshooting

1. Check container logs:
   ```bash
   docker-compose logs webserver
   ```

2. Check Nginx configuration:
   ```bash
   docker-compose exec webserver nginx -t
   ```

3. Restart the container:
   ```bash
   docker-compose restart webserver
   ```

4. Check SSL certificate status:
   ```bash
   docker-compose exec webserver certbot certificates
   ``` 