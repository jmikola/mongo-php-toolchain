#!/bin/bash

set -o errexit
set -o pipefail
set -o xtrace
set -o nounset

# Where we're installing everything.
PROJECT_DIR=`pwd`
INSTALL_DIR=/opt/php

# Note: PHP 8.1.0 requires OpenSSL 1.0.2+. Several RHEL hosts only have 1.0.1e
# available to PHP 8.1 will be intentionally excluded.

# PHP versions
PHP_ALL_RELEASES="
5.5.38
5.6.40
7.0.33
7.1.33
7.2.34
7.3.33
7.4.26
8.0.13
"

# PCRE's JIT disabling only works on PHP 7.0.12+
PHP_RELEASES_WITH_JIT_DISABLE="
7.0.33
7.1.33
7.2.34
7.3.33
7.4.26
8.0.13
"

# PHP recent versions
PHP_LATEST_STABLE_RELEASES="
5.6.40
7.0.33
7.1.33
7.2.34
7.3.33
7.4.26
8.0.13
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
