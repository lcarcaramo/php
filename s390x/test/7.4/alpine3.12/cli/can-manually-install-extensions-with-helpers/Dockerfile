FROM quay.io/ibmz/php:7.4-cli
RUN apk add --no-cache \
         pkgconf \
         zlib-dev \
         libmemcached-dev \
    && curl -fsSL 'https://pecl.php.net/get/memcached-3.1.5.tgz' -o memcached.tgz \
    && mkdir -p /tmp/memcached \
    && tar -xf memcached.tgz -C /tmp/memcached --strip-components=1 \
    && rm memcached.tgz \
    && docker-php-ext-configure /tmp/memcached --enable-memcached \
    && docker-php-ext-install /tmp/memcached \
    && rm -r /tmp/memcached
