#!/bin/sh

VERSION=$1
DEBUG=$2
ZTS=$3
THIRTYTWO=$4
POSTFIX=
EXTRA_FLAGS=

if (test "${PREFIX}" = ""); then
	PREFIX="/usr/local/php";
fi

#sudo apt install -y make autoconf gcc bison locate pkg-config

NUMBERS=`echo $VERSION | sed -r 's/[^0-9.]+//'`
MINI_VERSION=`echo $VERSION | sed 's/^\([0-9]\.[0-9]\).*/\1/'`
echo $NUMBERS
echo $MINI_VERSION

if (test "${THIRTYTWO}" = "32bit"); then
	export CFLAGS="-m32"
	export PKG_CONFIG_PATH="/usr/lib/i386-linux-gnu/pkgconfig"
	
	POSTFIX="$POSTFIX-32bit"
	ARCH=":i386"
else
	POSTFIX="$POSTFIX-64bit"
	ARCH=""
fi
	
#sudo apt install -y libxml2-dev${ARCH} libicu-dev${ARCH} libz-dev${ARCH} libssl1.1${ARCH} libssl1.0.2${ARCH} libxslt1-dev${ARCH} libsasl2-dev${ARCH}
#if (test  "${MINI_VERSION}" = "5.5"); then
#	sudo apt install -y libssl1.0-dev${ARCH}
#elif (test  "${MINI_VERSION}" = "5.6"); then
#	sudo apt install -y libssl1.0-dev${ARCH}
#else
#	sudo apt install -y libssl-dev${ARCH}
#fi

if (test "${ZTS}" = "zts"); then
	EXTRA_FLAGS="$EXTRA_FLAGS --enable-maintainer-zts"
	POSTFIX="$POSTFIX-zts"
fi

if (test "${DEBUG}" = "nodebug"); then
	POSTFIX="$POSTFIX-nodebug"
else
	EXTRA_FLAGS="$EXTRA_FLAGS --enable-debug"
fi

if [ ! -f php-${VERSION}.tar.bz2 ]; then
	wget http://uk1.php.net/distributions/php-${VERSION}.tar.bz2 -O php-${VERSION}.tar.bz2
fi

rm -rf php-${VERSION}
tar -xjf php-${VERSION}.tar.bz2
cd php-${VERSION}

echo "Building ${VERSION}${POSTFIX} with ($EXTRA_FLAGS)"

make clean
rm -rf configure
./vcsclean
./buildconf --force

OPTIONS="--with-openssl --enable-pcntl --enable-hash --enable-opcache"

./configure --prefix=${PREFIX}/${VERSION}${POSTFIX} ${EXTRA_FLAGS} ${OPTIONS} || exit 5

PROC=`nproc`
make -j${PROC}
make install
