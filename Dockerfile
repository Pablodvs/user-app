#Use the base PHP image with version 8.1.12
FROM php:8.1.12-apache

# Install dependencies required by Laravel
RUN apt-get update && apt-get install -y \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Configure the web server's Document Root
WORKDIR /var/www/html

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy the environment file
COPY . .

# Copia el archivo de entorno
COPY .env.example .env

# Install Laravel application dependencies
RUN composer install --optimize-autoloader --no-dev

# Generate a Laravel application key
RUN php artisan key:generate

# Run database migrations
RUN php artisan migrate --force

# Configure storage permissions
RUN chown -R www-data:www-data \
    /var/www/html/storage \
    /var/www/html/bootstrap/cache
RUN chmod -R 775 storage
RUN chmod -R 775 bootstrap/cache
RUN chown -R www-data:www-data /var/www/html

# Expose port 80 for the web server
EXPOSE 80

# Command to start the Apache web server
CMD ["apache2-foreground"]