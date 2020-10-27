#!/bin/bash

set -e

export ANSI_YELLOW="\e[1;33m"
export ANSI_GREEN="\e[32m"
export ANSI_RESET="\e[0m"

echo -e "\n $ANSI_YELLOW *** FUNCTIONAL TEST(S) *** $ANSI_RESET \n"

echo -e "$ANSI_YELLOW It can run a PHP script: $ANSI_RESET"
docker build -t test/run-script/quay.io/ibmz/php runs-php-scripts
docker run --rm --name runs-php-scripts test/run-script/quay.io/ibmz/php
docker rmi test/run-script/quay.io/ibmz/php

echo -e "$ANSI_YELLOW It can install PECL extensions: $ANSI_RESET"
docker build -t test/pecl/quay.io/ibmz/php can-install-pecl-extensions
echo -e "\n $ANSI_GREEN Success! Image was built and PECL extensions were installed. $ANSI_RESET \n"
docker rmi test/pecl/quay.io/ibmz/php

echo -e "$ANSI_YELLOW It can extract and delete docker-php-source: $ANSI_RESET"
docker build -t test/docker-php-source/quay.io/ibmz/php can-extract-delete-docker-php-source
echo -e "\n $ANSI_GREEN Success! Extensions provided in docker-php-source were extracted and deleted. $ANSI_RESET \n"
docker rmi test/docker-php-source/quay.io/ibmz/php

echo -e "$ANSI_YELLOW It can install Core extensions: $ANSI_RESET"
docker build -t test/core/quay.io/ibmz/php can-install-core-extensions
echo -e "\n $ANSI_GREEN Success! Image was built and Core extensions were installed. $ANSI_RESET \n"
docker rmi test/core/quay.io/ibmz/php

echo -e "$ANSI_YELLOW It can install extensions manually: $ANSI_RESET"
docker build -t test/manual/quay.io/ibmz/php can-manually-install-extensions
echo -e "\n $ANSI_GREEN Success! Image was built and extensions were installed manually. $ANSI_RESET \n"
docker rmi test/manual/quay.io/ibmz/php

echo -e "$ANSI_YELLOW It can install extensions manually with helpers: $ANSI_RESET"
docker build -t test/manual-helpers/quay.io/ibmz/php can-manually-install-extensions-with-helpers
echo -e "\n $ANSI_GREEN Success! Image was built and extensions were installed manually using helpers. $ANSI_RESET \n"
docker rmi test/manual-helpers/quay.io/ibmz/php

echo -e "\n $ANSI_GREEN *** FUNCTIONAL TEST(S) COMPLETED SUCESSFULLY *** $ANSI_RESET \n"
