FROM php:8.2-apache

RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN docker-php-ext-install pdo pdo_mysql mysqli

RUN apt-get update && apt-get install -y \
    libfreetype-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libicu-dev \
    libbz2-dev \
    libzip-dev \
    libldap2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd intl bz2 zip ldap exif

RUN a2enmod rewrite

RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

RUN echo '<Directory /var/www/html/public/>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' > /etc/apache2/conf-available/docker-php.conf \
    && a2enconf docker-php

RUN sed -i 's/session.cookie_httponly =/session.cookie_httponly = on/g' $PHP_INI_DIR/php.ini

WORKDIR /var/www/html
EXPOSE 80