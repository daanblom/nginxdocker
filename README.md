# Secure Nginx Web Server with SSL

This is a Docker-based setup for a secure Nginx web server with SSL support using Let's Encrypt certificates.

## Features

- Lightweight Nginx server based on Debian Bullseye
- Dynamic Nginx configuration generation
- Automatic SSL certificate management with Let's Encrypt
- Daily automatic certificate renewal via cron
- Modern SSL configuration with strong security headers
- HTTP/2 support
- Gzip compression with optimal settings
- OCSP Stapling for improved SSL performance
- Comprehensive static file caching
- Rate limiting and request size restrictions
- Fine-tuned timeout settings
- Security headers including HSTS
- Hidden file access protection
- Health checks

## Prerequisites

- Docker and Docker Compose installed
- A domain name pointing to your server
- Ports 80 and 443 open on your server

## Setup Instructions

1. Clone this repository
2. Create the required directories:
   ```bash
   mkdir -p www certbot/conf certbot/www
   ```

3. Update the configuration in `docker-compose.yml`:
   - Set your `DOMAIN` environment variable
   - Set your `EMAIL` environment variable for Let's Encrypt notifications

4. Place your website files in the `www` directory

5. Start the container:
   ```bash
   docker-compose up -d
   ```

The container will automatically:
- Generate the Nginx configuration
- Obtain SSL certificates if they don't exist
- Set up HTTP to HTTPS redirection
- Configure all security headers and optimizations
- Set up daily certificate renewal via cron

## Directory Structure

- `www/`: Your website files
- `certbot/conf/`: SSL certificates
- `certbot/www/`: Let's Encrypt verification files

## Security Features

- Automatic HTTP to HTTPS redirection
- Modern SSL configuration (TLSv1.2 & TLSv1.3) with strong ciphers
- OCSP Stapling for improved certificate validation
- Security headers:
  - Strict-Transport-Security (HSTS)
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

## Maintenance

- SSL certificates are automatically renewed daily via cron
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

5. Manually trigger certificate renewal:
   ```bash
   docker-compose exec webserver certbot renew
   ```

6. Check cron job status:
   ```bash
   docker-compose exec webserver cat /etc/cron.d/certbot
   ``` 