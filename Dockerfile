FROM php:8.2-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip curl util-linux \
    libpng-dev libjpeg-dev libzip-dev libonig-dev libcurl4-openssl-dev \
    libxml2-dev libicu-dev libssh2-1-dev \
 && docker-php-ext-configure gd --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" mysqli pdo pdo_mysql gd zip mbstring bcmath intl soap \
 && (pecl install ssh2-1.4.1 && docker-php-ext-enable ssh2 || true) \
 && a2enmod rewrite headers \
 && rm -rf /var/lib/apt/lists/* /tmp/pear

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# سورس رسمی میرزا بات موقع بیلد گرفته می‌شود
RUN rm -rf /var/www/html/* \
 && git clone --depth 1 https://github.com/mahdiMGF2/mirzabot.git /tmp/mirzabot \
 && cp -a /tmp/mirzabot/. /var/www/html/ \
 && rm -rf /tmp/mirzabot /var/www/html/.git /var/www/html/.github \
 && cd /var/www/html \
 && composer install --no-dev --no-interaction --optimize-autoloader \
 && rm -rf /var/www/html/install \
 && mkdir -p /var/www/html/storage/cache \
 && chown -R www-data:www-data /var/www/html

# .htaccess پروژه باید کار کند
RUN printf '<Directory /var/www/html>\n    AllowOverride All\n</Directory>\n' > /etc/apache2/conf-available/allow-override.conf \
 && a2enconf allow-override

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

CMD ["/usr/local/bin/docker-entrypoint.sh"]
