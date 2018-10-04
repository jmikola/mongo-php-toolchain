#!/bin/bash

set -o errexit
set -o pipefail
set -o xtrace
set -o nounset

# First argument is the architecture (32bit, when empty: x86_64)
ARCH=$1
PKG_ARCH=""

# Add 32bit architecture if needed
if (test "${ARCH}" = "32bit"); then
    sudo dpkg --add-architecture i386
    PKG_ARCH=":i386"
fi

# Install required packages
sudo apt-get update
sudo apt-get install -y g++-multilib make autoconf gcc bison locate pkg-config

# Install architecture dependent packages, but Ubuntu has different libssl versions
sudo apt-get install -y libxml2-dev${PKG_ARCH} libicu-dev${PKG_ARCH} libz-dev${PKG_ARCH} libxslt1-dev${PKG_ARCH} libsasl2-dev${PKG_ARCH}

VARIANT=`cat /etc/*-release | grep ID= | sed 's/ID=//'`
if (test "${VARIANT}" = "ubuntu"); then
	sudo apt-get install -y libssl1.0.0${PKG_ARCH}
else
	sudo apt-get install -y libssl1.1${PKG_ARCH}
fi
sudo apt-get install -y libssl-dev${ARCH}


# Where we're installing everything.
INSTALL_DIR=$(pwd)/php

# PHP versions that support OpenSSL 1.0.2
PHP_RELEASES_FOR_STABLE_OPENSSL="
5.5.38
5.6.38
"

# PHP versions that support OpenSSL >= 1.1.0
PHP_RELEASES_FOR_MODERN_OPENSSL="
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
fi

if (test "${ARCH}" = "32bit"); then
    BITNESS=32bit
else
    BITNESS=64bit
fi

for phprel in $PHP_RELEASES
do
    PREFIX="$INSTALL_DIR" ./build-debian-single.sh "$phprel" debug nts ${BITNESS}
    PREFIX="$INSTALL_DIR" ./build-debian-single.sh "$phprel" debug zts ${BITNESS}
done

tar -czf php.tar.gz php
