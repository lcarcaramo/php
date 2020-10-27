FROM quay.io/ibmz/php:7.4-cli

RUN pecl channel-update pecl.php.net

RUN pecl install redis-5.3.2RC2 \
    && docker-php-ext-enable redis
