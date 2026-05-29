FROM php:8.3-fpm-bullseye

RUN apt-get update && apt-get install -y \
    nginx libpng-dev libonig-dev libxml2-dev libpq-dev zip unzip curl \
    && docker-php-ext-install pdo pdo_pgsql mbstring exif pcntl bcmath gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN echo '[www]\nlisten = /var/run/php-fpm.sock\nlisten.owner = www-data\nlisten.group = www-data\nlisten.mode = 0666' \
    > /usr/local/etc/php-fpm.d/zz-socket.conf

WORKDIR /var/www/html
COPY . .

# Fix permissions for Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV LOG_CHANNEL=stderr

RUN composer install --no-dev --optimize-autoloader

COPY conf/nginx/nginx-site.conf /etc/nginx/sites-available/default

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

CMD ["sh", "-c", "php-fpm -D && sleep 2 && php artisan config:cache; php artisan route:cache; php artisan migrate --force; nginx -g 'daemon off;'"]
