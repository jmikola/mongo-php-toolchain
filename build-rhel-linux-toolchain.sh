#!/bin/bash

set -o errexit
set -o pipefail
set -o xtrace
set -o nounset

# Where we're installing everything.
PROJECT_DIR=`pwd`
INSTALL_DIR=/opt/php

# PHP versions
PHP_ALL_RELEASES="
5.5.38
5.6.38
7.0.32
7.1.22
7.2.10
"

# PHP recent versions
PHP_LATEST_STABLE_RELEASES="
5.6.38
7.2.10
"

PHP_RELEASES=$PHP_ALL_RELEASES
EXTRA_OPTIONS=

ARCH=`uname -m`
BITNESS=32bit
if (test "${ARCH}" = "x86_64"); then
    BITNESS=64bit
fi
if (test "${ARCH}" = "s390x"); then
    BITNESS=64bit
    PHP_RELEASES=$PHP_LATEST_STABLE_RELEASES
    EXTRA_OPTIONS=--without-pcre-jit
fi
if (test "${ARCH}" = "aarch64"); then
    BITNESS=64bit
    PHP_RELEASES=$PHP_LATEST_STABLE_RELEASES
fi
if (test "${ARCH}" = "ppc64le"); then
    BITNESS=64bit
fi


for phprel in $PHP_RELEASES
do
    EXTRA_OPTIONS=${EXTRA_OPTIONS} PREFIX="$INSTALL_DIR" ./build-debian-single.sh "$phprel" debug nts ${BITNESS}
    EXTRA_OPTIONS=${EXTRA_OPTIONS} PREFIX="$INSTALL_DIR" ./build-debian-single.sh "$phprel" debug zts ${BITNESS}
done

cd /opt
tar -czf "$PROJECT_DIR/php.tar.gz" php
