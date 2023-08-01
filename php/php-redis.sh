#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/ext/phpredis.zip" 
PKG_NAME=`basename $SRC_URI`
PHP_INI=/alidata/php/etc/php.ini
DIR=`pwd`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi
rm -rf phpredis
unzip $PKG_NAME
cd ./phpredis/
/alidata/php/bin/phpize
./configure --with-php-config=/alidata/php/bin/php-config

if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install

if ! cat $PHP_INI | grep  'extension=redis.so' &> /dev/null;then
        echo 'extension=redis.so' >>$PHP_INI
fi

cd $DIR
bash
