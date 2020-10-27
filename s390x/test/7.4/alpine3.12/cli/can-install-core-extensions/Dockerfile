FROM quay.io/ibmz/php:7.4-cli
RUN apk add --no-cache \
	freetype-dev \
	libjpeg-turbo-dev \
	libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd
