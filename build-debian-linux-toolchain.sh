#!/bin/bash

set -o errexit
set -o pipefail
set -o xtrace
set -o nounset

FORCE_ARCH=
# If the first argument is set, we force that architecture
if [ $# == 1 ]; then
    FORCE_ARCH=$1
fi

# Where we're installing everything.
PROJECT_DIR=`pwd`
INSTALL_DIR=/opt/php

# PHP versions that support OpenSSL 1.0.2
PHP_RELEASES_FOR_STABLE_OPENSSL="
5.5.38
5.6.38
"

# PHP versions that support OpenSSL >= 1.1.0
PHP_RELEASES_FOR_MODERN_OPENSSL="
7.0.32
7.1.31
7.2.21
7.3.8
7.4.7
"

OPENSSL_MAJOR_VERSION=$(openssl version | cut -d' ' -f2 | cut -b1)
OPENSSL_MINOR_VERSION=$(openssl version | cut -d. -f2)
OPENSSL_PATCH_VERSION=$(openssl version | cut -d. -f3 | cut -b1)
OPENSSL_PATCH_LETTER=$(openssl version | cut -d. -f3 | cut -b2)
if [ $OPENSSL_MINOR_VERSION = "1" ]; then
    PHP_RELEASES=$PHP_RELEASES_FOR_MODERN_OPENSSL
elif [[ $OPENSSL_MINOR_VERSION = "0" && $OPENSSL_PATCH_VERSION = "2" ]]; then
    PHP_RELEASES=$PHP_RELEASES_FOR_STABLE_OPENSSL
fi

ARCH=`uname -m`
BITNESS=32bit
if (test "${ARCH}" = "x86_64"); then
    BITNESS=64bit
fi
if (test "${ARCH}" = "s390x"); then
    BITNESS=64bit
    PHP_RELEASES=$PHP_RELEASES_FOR_MODERN_OPENSSL
fi
if (test "${ARCH}" = "aarch64"); then
    BITNESS=64bit
    PHP_RELEASES=$PHP_RELEASES_FOR_MODERN_OPENSSL
fi
if (test "${ARCH}" = "ppc64le"); then
    BITNESS=64bit
    PHP_RELEASES=$PHP_RELEASES_FOR_MODERN_OPENSSL
fi
if (test "${FORCE_ARCH}" != ""); then
    BITNESS=${FORCE_ARCH}
fi

for phprel in $PHP_RELEASES
do
    PREFIX="$INSTALL_DIR" ./build-single.sh "$phprel" debug nts ${BITNESS}
    PREFIX="$INSTALL_DIR" ./build-single.sh "$phprel" debug zts ${BITNESS}
done

cd /opt
tar -czf "$PROJECT_DIR/php.tar.gz" php
