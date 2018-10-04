#!/bin/bash

ARCH=$1
PKG_ARCH=""

if (test "${ARCH}" = "32bit"); then
    sudo dpkg --add-architecture i386
    PKG_ARCH=":i386"
fi

sudo apt-get update
sudo apt-get install -y g++-multilib make autoconf gcc bison locate pkg-config

sudo apt-get install -y libxml2-dev${PKG_ARCH} libicu-dev${PKG_ARCH} libz-dev${PKG_ARCH} libssl1.1${PKG_ARCH} libssl1.0.2${PKG_ARCH} libxslt1-dev${PKG_ARCH} libsasl2-dev${PKG_ARCH}
