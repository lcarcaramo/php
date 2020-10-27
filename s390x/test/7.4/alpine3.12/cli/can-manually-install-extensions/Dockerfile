FROM quay.io/ibmz/php:7.4-cli
RUN apk add --no-cache \
	 pkgconf \
         zlib-dev \
         libmemcached-dev \
    && curl -fsSL 'https://pecl.php.net/get/memcached-3.1.5.tgz' -o memcached.tgz \
    && mkdir -p memcached \
    && tar -xf memcached.tgz -C memcached --strip-components=1 \
    && rm memcached.tgz \
    && ( \
        cd memcached \
        && phpize \
        && ./configure --enable-memcached \
        && make -j "$(nproc)" \
        && make install \
    ) \
    && rm -r memcached \
    && docker-php-ext-enable memcached
