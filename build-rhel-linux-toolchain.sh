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
7.1.31
7.2.21
7.3.8
7.4.7
"

# PCRE's JIT disabling only works on PHP 7
PHP_RELEASES_WITH_JIT_DISABLE="
7.1.31
7.2.21
7.3.8
7.4.7
"

# PHP recent versions
PHP_LATEST_STABLE_RELEASES="
5.6.38
7.2.21
7.4.7
"

PHP_RELEASES=$PHP_ALL_RELEASES
EXTRA_OPTIONS=

ARCH=`uname -m`
BITNESS=64bit
if (test "${ARCH}" = "s390x"); then
    PHP_RELEASES=$PHP_RELEASES_WITH_JIT_DISABLE
    EXTRA_OPTIONS=--without-pcre-jit
fi
if (test "${ARCH}" = "aarch64"); then
    PHP_RELEASES=$PHP_LATEST_STABLE_RELEASES
fi

for phprel in $PHP_RELEASES
do
    EXTRA_OPTIONS=${EXTRA_OPTIONS} PREFIX="$INSTALL_DIR" ./build-single.sh "$phprel" debug nts ${BITNESS}
    EXTRA_OPTIONS=${EXTRA_OPTIONS} PREFIX="$INSTALL_DIR" ./build-single.sh "$phprel" debug zts ${BITNESS}
done

cd /opt
tar -czf "$PROJECT_DIR/php.tar.gz" php
