# Use a specific version for stability
FROM dunglas/frankenphp:1.1-alpine AS builder

# Set working directory
WORKDIR /app

# Copy laravel project to working directory
COPY . .

# Install PHP extensions
RUN install-php-extensions \
 @composer \
 pdo_mysql \
 gd \
 intl \
 zip \
 opcache

# Enable PHP production settings
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Install Composer dependencies first (without code)
RUN composer install --no-cache --prefer-dist --no-dev --optimize-autoloader --ignore-platform-req=ext-bcmath --no-scripts

# Install Node.js using Alpine packages
RUN apk add --no-cache nodejs npm

# Install npm dependencies (without code)
RUN npm ci --production

# Run composer scripts after code is copied
RUN composer dump-autoload --optimize

# Build assets
RUN npm run build && \
 npm cache clean --force

# Remove node_modules after build
RUN rm -rf node_modules

# Production image
FROM dunglas/frankenphp:1.1-alpine AS runner

WORKDIR /app

# Install only the PHP extensions needed for runtime (not for building)
RUN install-php-extensions \
 pdo_mysql \
 gd \
 intl \
 zip \
 pcntl \
 opcache

# Enable PHP production settings
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Copy only what's needed to run the application
COPY --from=builder /app/app ./app
COPY --from=builder /app/composer.json ./composer.json
COPY --from=builder /app/composer.lock ./composer.lock
COPY --from=builder /app/bootstrap ./bootstrap
COPY --from=builder /app/config ./config
COPY --from=builder /app/database ./database
COPY --from=builder /app/public ./public
COPY --from=builder /app/resources ./resources
COPY --from=builder /app/routes ./routes
COPY --from=builder /app/storage ./storage
COPY --from=builder /app/vendor ./vendor
COPY --from=builder /app/artisan ./artisan
COPY --from=builder /app/.env.example ./.env.example
COPY --from=builder /app/.env ./.env
COPY --from=builder /app/public/build ./public/build

# Set permissions for storage and cache
RUN chmod -R 775 /app/storage /app/bootstrap/cache && \
 chown -R www-data:www-data /app

# Server configuration
# Be sure to replace "your-domain-name.example.com" by your domain name
#ENV SERVER_NAME=your-domain-name.example.com
# If you want to disable HTTPS, use this value instead:
ENV SERVER_NAME=:80

# Expose port
EXPOSE 80

ENTRYPOINT ["php", "artisan", "octane:frankenphp", "--host=localhost", "--port=8000", "--log-level=info"]
