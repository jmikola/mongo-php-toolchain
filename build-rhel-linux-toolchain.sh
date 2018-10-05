#!/bin/bash

set -o errexit
set -o pipefail
set -o xtrace
set -o nounset

# Where we're installing everything.
INSTALL_DIR=$(pwd)/php

# PHP versions that support OpenSSL 1.0.2
PHP_RELEASES_FOR_STABLE_OPENSSL="
5.5.38
5.6.38
7.0.32
7.1.22
7.2.10
"

# PHP versions that support OpenSSL >= 1.1.0
PHP_RELEASES_FOR_MODERN_OPENSSL="
5.5.38
5.6.38
7.0.32
7.1.22
7.2.10
"

OPENSSL_MAJOR_VERSION=$(openssl version | cut -d' ' -f2 | cut -b1)
OPENSSL_MINOR_VERSION=$(openssl version | cut -d. -f2)
OPENSSL_PATCH_VERSION=$(openssl version | cut -d. -f3 | cut -b1)
OPENSSL_PATCH_LETTER=$(openssl version | cut -d. -f3 | cut -b2)
if [ $OPENSSL_MINOR_VERSION = "1" ]; then
    PHP_RELEASES=$PHP_RELEASES_FOR_MODERN_OPENSSL
elif [[ $OPENSSL_MINOR_VERSION = "0" && $OPENSSL_PATCH_VERSION = "2" ]]; then
    PHP_RELEASES=$PHP_RELEASES_FOR_STABLE_OPENSSL
else
    PHP_RELEASES=$PHP_RELEASES_FOR_STABLE_OPENSSL
fi

BITNESS=64bit

for phprel in $PHP_RELEASES
do
    PREFIX="$INSTALL_DIR" ./build-debian-single.sh "$phprel" debug nts ${BITNESS}
    PREFIX="$INSTALL_DIR" ./build-debian-single.sh "$phprel" debug zts ${BITNESS}
done

tar -czf php.tar.gz php
