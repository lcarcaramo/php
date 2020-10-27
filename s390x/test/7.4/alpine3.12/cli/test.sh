#!/bin/bash

set -e

export ANSI_YELLOW_BOLD="\e[1;33m"
export ANSI_GREEN="\e[32m"
export ANSI_YELLOW_BACKGROUND="\e[1;7;33m"
export ANSI_GREEN_BACKGROUND="\e[1;7;32m"
export ANSI_CYAN="\e[36m"
export ANSI_RESET="\e[0m"
export DOCKERFILE_TOP="**************************************** DOCKERFILE ******************************************"
export DOCKERFILE_BOTTOM="**********************************************************************************************"
export TEST_SUITE_START="**************************************** SMOKE TESTS *****************************************"
export TEST_SUITE_END="************************************** TEST SUCCESSFUL ***************************************"

# Pass in path to folder where Dockerfile lives
print_dockerfile () {
        echo -e "\n$ANSI_CYAN$DOCKERFILE_TOP\n$(<$1/Dockerfile)\n$DOCKERFILE_BOTTOM $ANSI_RESET\n"
}

# Pass in test case message
print_test_case () {
        echo -e "\n$ANSI_YELLOW_BOLD$1 $ANSI_RESET"
}

print_success () {
        echo -e "\n $ANSI_GREEN$1 $ANSI_RESET \n"

}

# Pass in path to folder where Dockerfile lives
build () {
        print_dockerfile $1
        docker build -q -t $1 $1
}

cleanup () {
        docker rmi $1
}

suite_start () {
        echo -e "\n$ANSI_YELLOW_BACKGROUND$TEST_SUITE_START$ANSI_RESET \n"
}

suite_end () {
        echo -e "\n$ANSI_GREEN_BACKGROUND$TEST_SUITE_END$ANSI_RESET \n"
}


suite_start
        print_test_case "It can run a PHP script:"
                build "runs-php-scripts"
                docker run --rm --name runs-php-scripts "runs-php-scripts"
                cleanup "runs-php-scripts"

        print_test_case "It can install PECL extensions:"
                build "can-install-pecl-extensions"
                print_success "Success! Image was built and PECL extensions were installed."
                cleanup "can-install-pecl-extensions"

        print_test_case "It can extract and delete docker-php-source:"
                build "can-extract-delete-docker-php-source"
                print_success "Success! Extensions provided in docker-php-source were extracted and deleted."
                cleanup "can-extract-delete-docker-php-source"

        print_test_case "It can install Core extensions:"
                build "can-install-core-extensions"
                print_success "Success! Image was built and Core extensions were installed."
                cleanup "can-install-core-extensions"

        print_test_case "It can install extensions manually:"
                build "can-manually-install-extensions"
                print_success "Success! Image was built and extensions were installed manually."
                cleanup "can-manually-install-extensions"

        print_test_case "It can install extensions manually with helpers:"
                build "can-manually-install-extensions-with-helpers"
                print_success "Success! Image was built and extensions were installed manually using helpers."
                cleanup "can-manually-install-extensions-with-helpers"
suite_end
