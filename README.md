# Tags

> _Built from [`quay.io/ibmz/alpine:3.12`](https://quay.io/repository/ibmz/alpine?tab=info)_
-	[`7.4-cli`](https://github.com/lcarcaramo/php/blob/master/s390x/8.0-rc/alpine3.12/cli/Dockerfile) - [![Build Status](https://travis-ci.com/lcarcaramo/php.svg?branch=master)](https://travis-ci.com/lcarcaramo/php)

# What is PHP?

PHP is a server-side scripting language designed for web development, but which can also be used as a general-purpose programming language. PHP can be added to straight HTML or it can be used with a variety of templating engines and web frameworks. PHP code is usually processed by an interpreter, which is either implemented as a native module on the web-server or as a common gateway interface (CGI).

> [wikipedia.org/wiki/PHP](https://en.wikipedia.org/wiki/PHP)

![logo](https://raw.githubusercontent.com/docker-library/docs/01c12653951b2fe592c1f93a13b4e289ada0e3a1/php/logo.png)

# How to use this image

Note that we only provide the PHP runtime, PECL, and tooling to to assist in installing extensions. If you wish to use this image to run a web server, it is your responsibility to install the packages required for running a PHP based web server.

### Create a `Dockerfile` in your PHP project

```dockerfile
FROM quay.io/ibmz/php:7.4-cli
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp
CMD [ "php", "./your-script.php" ]
```

Then, run the commands to build and run the Docker image:

```console
$ docker build -t my-php-app .
$ docker run -it --rm --name my-running-app my-php-app
```

## How to install more PHP extensions

Many extensions are already compiled into the image, so it's worth checking the output of `php -m` or `php -i` before going through the effort of compiling more.

We provide the helper scripts `docker-php-ext-configure`, `docker-php-ext-install`, and `docker-php-ext-enable` to more easily install PHP extensions.

In order to keep the images smaller, PHP's source is kept in a compressed tar file. To facilitate linking of PHP's source with any extension, we also provide the helper script `docker-php-source` to easily extract the tar or delete the extracted source. Note: if you do use `docker-php-source` to extract the source, be sure to delete it in the same layer of the docker image.

```Dockerfile
FROM quay.io/ibmz/php:7.4-cli
RUN docker-php-source extract \
	# do important things \
	&& docker-php-source delete
```

### PHP Core Extensions

Write a `Dockerfile` like to following to get the 'gd' extension

```Dockerfile
FROM quay.io/ibmz/php:7.4-cli
RUN apk add --no-cache \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd
```

Remember, you must install dependencies for your extensions manually. If an extension needs custom `configure` arguments, you can use the `docker-php-ext-configure` script like this example. There is no need to run `docker-php-source` manually in this case, since that is handled by the `configure` and `install` scripts.

If you are having difficulty figuring out which Alpine packages need to be installed before `docker-php-ext-install`, then have a look at [the `install-php-extensions` project](https://github.com/mlocati/docker-php-extension-installer). This script builds upon the `docker-php-ext-*` scripts and simplifies the installation of PHP extensions by automatically adding and removing Debian (apt) and Alpine (apk) packages. For example, to install the GD extension you simply have to run `install-php-extensions gd`. This tool is contributed by community members and is not included in the images, please refer to their Git repository for installation, usage, and issues.

See also ["Dockerizing Compiled Software"](https://tianon.xyz/post/2017/12/26/dockerize-compiled-software.html) for a description of the technique Tianon uses for determining the necessary build-time dependencies for any bit of software (which applies directly to compiling PHP extensions).

### Default extensions

Some extensions are compiled by default. This depends on the PHP version you are using. Run `php -m` in the container to get a list for your specific version.

### PECL extensions

Some extensions are not provided with the PHP source, but are instead available through [PECL](https://pecl.php.net/). To install a PECL extension, use `pecl install` to download and compile it, then use `docker-php-ext-enable` to enable it:

```dockerfile
FROM quay.io/ibmz/php:7.4-cli
RUN pecl install redis-5.1.1 \
	&& pecl install xdebug-2.8.1 \
	&& docker-php-ext-enable redis xdebug
```

```dockerfile
FROM quay.io/ibmz/php:7.4-cli
RUN apt-get update && apt-get install -y libmemcached-dev zlib1g-dev \
	&& pecl install memcached-2.2.0 \
	&& docker-php-ext-enable memcached
```

It is __strongly__ recommended that users use an explicit version number in their `pecl install` invocations to ensure proper PHP version compatibility (PECL does not check the PHP version compatiblity when choosing a version of the extension to install, but does when trying to install it).

For example, [`memcached-2.2.0`](https://pecl.php.net/package/memcached/2.2.0) has no PHP version constraints, but [`memcached-3.1.4`](https://pecl.php.net/package/memcached/3.1.4) requires PHP 7.0.0 or newer. When doing `pecl install memcached` (no specific version) on PHP 5.6, PECL will try to install the latest release and fail.

Beyond the compatibility issue, it's also a good practice to ensure you know when your dependencies receive updates and can control those updates directly.

Unlike PHP core extensions, PECL extensions should be installed in series to fail properly if something went wrong. Otherwise errors are just skipped by PECL. For example, `pecl install memcached-3.1.4 && pecl install redis-5.1.1` instead of `pecl install memcached-3.1.4 redis-5.1.1`. However, `docker-php-ext-enable memcached redis` is fine to be all in one command.

### Other extensions

Some extensions are not provided via either Core or PECL; these can be installed too, although the process is less automated:

> _Note that the following examples use an extension that is able to be installed with PECL for illustration purposes._

```dockerfile
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
```

The `docker-php-ext-*` scripts *can* accept an arbitrary path, but it must be absolute (to disambiguate from built-in extension names), so the above example could also be written as the following:

```dockerfile
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
```

## Configuration

This image ships with the default [`php.ini-development`](https://github.com/php/php-src/blob/master/php.ini-development) and [`php.ini-production`](https://github.com/php/php-src/blob/master/php.ini-production) configuration files.

It is *strongly* recommended to use the production config for images used in production environments!

The default config can be customized by copying configuration files into the `$PHP_INI_DIR/conf.d/` directory.

### Example

```dockerfile
FROM quay.io/ibmz/php:7.4-cli

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
```

In many production environments, it is also recommended to (build and) enable the PHP core OPcache extension for performance. See [the upstream OPcache documentation](https://www.php.net/manual/en/book.opcache.php) for more details.

# License

View [license information](http://php.net/license/) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

Some additional license information which was able to be auto-detected might be found in [the `repo-info` repository's `php/` directory](https://github.com/docker-library/repo-info/tree/master/repos/php).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
