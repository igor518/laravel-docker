# Laravel local env Project

A Laravel + Vue.js application with PostgreSQL database and HTTPS support.

## Prerequisites

Before you begin, ensure you have the following installed on your system:
- Docker
- Docker Compose
- mkcert (for SSL certificates)
- Git

### System Requirements
- Minimum 4GB RAM
- 10GB free disk space
- Docker Engine 20.10.0 or newer
- Docker Compose 2.0.0 or newer
- PHP 8.3 (for local development tools)
- Node.js 20.x (for local development tools)

### macOS Setup

1. **Install Prerequisites**
   ```bash
   # Install Homebrew if not already installed
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

   # Install Docker Desktop for Mac
   brew install --cask docker

   # Install mkcert and its root certificate
   brew install mkcert nss
   mkcert -install

   # Install PHP (optional, for local tools)
   brew install php@8.3

   # Install Node.js
   brew install node@20
   ```

2. **Performance Optimization**
   - In Docker Desktop preferences:
     - Allocate at least 4GB of RAM
     - Allocate at least 2 CPU cores
     - Enable VirtioFS for better file sharing performance

3. **Known macOS Issues and Solutions**
   - If you experience slow file system performance:
     ```bash
     # Add this to your .env file
     COMPOSE_DOCKER_CLI_BUILD=1
     DOCKER_BUILDKIT=1
     ```
   - If you have port conflicts:
     - Check if ports 80, 443, or 5432 are in use
     - Use Activity Monitor to find and stop conflicting services
   - For M1/M2 Macs:
     - Use ARM64 images where possible
     - Some PHP extensions might need special configuration

4. **Alternative Installation Methods**
   ```bash
   # Using MacPorts instead of Homebrew
   sudo port install mkcert
   sudo port install php83
   sudo port install nodejs20
   ```

## Getting Started

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd <repository-name>
```

### 2. SSL Certificate Setup

Install mkcert and generate SSL certificates:

```bash
# Install mkcert (Ubuntu/Debian)
sudo apt install -y mkcert libnss3-tools

# For other operating systems, visit:
# https://github.com/FiloSottile/mkcert#installation

# Install the local CA
mkcert -install

# Generate certificates
mkdir -p docker/nginx/ssl
mkcert movieye.local
mv movieye.local.pem docker/nginx/ssl/certificate.pem
mv movieye.local-key.pem docker/nginx/ssl/certificate-key.pem
```

### 3. Configure Local Domain

Add the following entry to your `/etc/hosts` file:

```bash
sudo echo "127.0.0.1 movieye.local" | sudo tee -a /etc/hosts
```

### 4. Environment Setup

Create a `.env` file in the project root with the following content:

```env
# Database Configuration
DB_CONNECTION=pgsql
DB_HOST=db
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=postgres
DB_PASSWORD=secret

# Application Configuration
APP_NAME=Movieye
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=https://movieye.local

# Docker Configuration
DOCKER_PHP_VERSION=8.3
DOCKER_POSTGRES_VERSION=16
DOCKER_NODE_VERSION=20
```

### 5. Start the Application

```bash
# Make the setup script executable
chmod +x setup.sh

# Run the setup script
./setup.sh
```

The setup script will:
- Create necessary directories
- Build and start Docker containers
- Install Laravel dependencies
- Set up the database
- Install Node.js dependencies
- Generate application key
- Set proper permissions

### 6. Access the Application

Once everything is set up, you can access the application at:

- HTTPS: https://movieye.local
- HTTP will automatically redirect to HTTPS

## Docker Services

The application runs the following services:
- **Laravel (PHP 8.3)**: Main application server
- **PostgreSQL 16**: Database server
- **Nginx**: Web server with SSL support
- **Node.js**: For Vue.js frontend development

## Development

### Development Workflow

1. **Branch Management**
   ```bash
   # Create a new feature branch
   git checkout -b feature/your-feature-name

   # Create a new bugfix branch
   git checkout -b bugfix/issue-description
   ```

2. **Code Style**
   - PHP: Follow PSR-12 coding standards
   - Vue.js: Follow Vue.js Style Guide
   - Use ESLint and Prettier for JavaScript/Vue
   - Use PHP CS Fixer for PHP

3. **Hot Reload for Vue.js**
   ```bash
   # Start Vue.js development server with hot reload
   docker compose exec node npm run dev
   ```

4. **Database Management**
   ```bash
   # Create a new migration
   docker compose exec app php artisan make:migration create_your_table

   # Run migrations
   docker compose exec app php artisan migrate

   # Rollback migrations
   docker compose exec app php artisan migrate:rollback

   # Seed database
   docker compose exec app php artisan db:seed
   ```

5. **Cache Management**
   ```bash
   # Clear Laravel cache
   docker compose exec app php artisan cache:clear

   # Clear config cache
   docker compose exec app php artisan config:clear

   # Clear route cache
   docker compose exec app php artisan route:clear

   # Clear view cache
   docker compose exec app php artisan view:clear
   ```

### Testing

1. **PHP Unit Tests**
   ```bash
   # Run all tests
   docker compose exec app php artisan test

   # Run specific test file
   docker compose exec app php artisan test --filter=UserTest

   # Run tests with coverage report
   docker compose exec app php artisan test --coverage
   ```

2. **Vue.js Tests**
   ```bash
   # Run Vue.js unit tests
   docker compose exec node npm run test:unit

   # Run Vue.js e2e tests
   docker compose exec node npm run test:e2e
   ```

3. **Code Quality**
   ```bash
   # Run PHP CS Fixer
   docker compose exec app ./vendor/bin/php-cs-fixer fix

   # Run ESLint
   docker compose exec node npm run lint

   # Run Prettier
   docker compose exec node npm run format
   ```

### Debugging

1. **Laravel Debugging**
   - Use Laravel Telescope (if installed)
   - Check `storage/logs/laravel.log`
   - Enable Xdebug (instructions below)

2. **Vue.js Debugging**
   - Use Vue.js DevTools browser extension
   - Check browser console
   - Use source maps in development

3. **Xdebug Setup**
   ```bash
   # Update PHP container with Xdebug
   docker compose exec app install-php-extensions xdebug

   # Configure Xdebug (add to php.ini)
   xdebug.mode=debug
   xdebug.client_host=host.docker.internal
   xdebug.start_with_request=yes
   ```

## Deployment

### Production Setup

1. **Environment Preparation**
   - Use production-ready `.env` settings
   - Set `APP_ENV=production`
   - Set `APP_DEBUG=false`
   - Generate new APP_KEY
   - Use strong database passwords

2. **SSL Certificates**
   - Use Let's Encrypt or commercial SSL in production
   - Update Nginx configuration accordingly
   - Enable HSTS in production

3. **Performance Optimization**
   ```bash
   # Optimize Laravel
   php artisan optimize
   php artisan view:cache
   php artisan route:cache
   php artisan config:cache

   # Build Vue.js for production
   npm run build
   ```

4. **Security Checklist**
   - [ ] Update all dependencies
   - [ ] Enable HTTPS only
   - [ ] Set secure headers
   - [ ] Configure CORS properly
   - [ ] Set up proper backups
   - [ ] Configure logging
   - [ ] Set up monitoring

### Backup and Restore

1. **Database Backup**
   ```bash
   # Backup database
   docker compose exec db pg_dump -U postgres laravel > backup.sql

   # Restore database
   docker compose exec db psql -U postgres laravel < backup.sql
   ```

2. **Application Backup**
   ```bash
   # Backup uploads and storage
   tar -czf storage_backup.tar.gz src/storage/app/public/

   # Restore uploads and storage
   tar -xzf storage_backup.tar.gz -C src/storage/app/public/
   ```

## Maintenance

### Regular Tasks

1. **Updates**
   ```bash
   # Update Laravel dependencies
   docker compose exec app composer update

   # Update Node.js dependencies
   docker compose exec node npm update

   # Rebuild containers with latest images
   docker compose build --pull
   ```

2. **Monitoring**
   - Check Laravel logs regularly
   - Monitor database performance
   - Watch disk space usage
   - Monitor memory usage

3. **Cleanup**
   ```bash
   # Remove unused Docker resources
   docker system prune

   # Clear old logs
   docker compose exec app php artisan log:clear

   # Clean npm cache
   docker compose exec node npm cache clean --force
   ```

## Additional Resources

- [Laravel Documentation](https://laravel.com/docs)
- [Vue.js Documentation](https://vuejs.org/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)

## Support

For support and questions:
1. Check existing GitHub issues
2. Review the documentation
3. Create a new issue with:
   - Detailed description
   - Steps to reproduce
   - Expected vs actual behavior
   - Logs and screenshots

## Security

- SSL certificates are generated locally and trusted by your system
- Database credentials should be changed in production
- HTTPS is enforced by default
- Modern SSL protocols (TLSv1.2, TLSv1.3) are used

## Important Notes

1. **SSL Certificates**: 
   - The SSL certificates are generated locally and are not committed to the repository
   - Each developer needs to generate their own certificates
   - The certificates are trusted only on the machine where they were generated

2. **Environment Variables**:
   - The `.env` file contains sensitive information and is not committed to the repository
   - Each developer needs to create their own `.env` file using the template above
   - In production, use different credentials and secure values

3. **Database**:
   - The default database credentials are for local development only
   - Change these credentials in production
   - The database data is persisted in a Docker volume

## Troubleshooting

### Common Issues

1. **SSL Certificate Issues**
   - Ensure mkcert is properly installed
   - Run `mkcert -install` again
   - Check if certificates are in the correct location

2. **Database Connection Issues**
   - Verify PostgreSQL container is running
   - Check database credentials in .env
   - Wait a few seconds after container startup

3. **Permission Issues**
   - Run `docker compose exec app chown -R www:www /var/www`
   - Check file permissions in mounted volumes

### Getting Help

If you encounter any issues:
1. Check the logs: `docker compose logs`
2. Verify all containers are running: `docker compose ps`
3. Ensure all prerequisites are installed
4. Check the Laravel logs: `docker compose exec app cat storage/logs/laravel.log`

## Contributing

[Add your contribution guidelines here]

## License

[Add your license information here] 
