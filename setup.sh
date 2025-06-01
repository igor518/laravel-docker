#!/bin/bash

# Create necessary directories
mkdir -p src

# Copy .env.example to .env if it doesn't exist
if [ ! -f .env ]; then
    cat > .env << EOL
DB_CONNECTION=pgsql
DB_HOST=db
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=postgres
DB_PASSWORD=secret
EOL
fi

# Clean up existing containers and volumes
docker compose down -v

# Build and start containers
docker compose up -d --build

# Wait for containers to be ready
echo "Waiting for containers to be ready..."
sleep 10

# Create new Laravel project
docker compose exec app composer create-project --prefer-dist laravel/laravel .

# Set proper permissions
docker compose exec app chown -R www:www /var/www

# Create Laravel .env file
docker compose exec app bash -c 'cat > .env << EOL
APP_NAME="Laravel Vue App"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8080

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=pgsql
DB_HOST=db
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=postgres
DB_PASSWORD=secret

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="\${APP_NAME}"
EOL'

# Install Node.js dependencies and build assets
docker compose exec app composer install
docker compose exec app php artisan key:generate
docker compose exec app php artisan storage:link
docker compose exec app php artisan migrate

# Install and build frontend assets
docker compose exec node npm install
docker compose exec node npm run build

echo "Setup completed! Your Laravel application is ready at http://localhost:8080" 