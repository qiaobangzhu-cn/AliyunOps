#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/mongo-1.5.7.tgz" 
PKG_NAME=`basename $SRC_URI`
PHP_INI=/alidata/php/etc/php.ini
DIR=`pwd`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi
rm -rf mongo-1.5.7
tar zxvf $PKG_NAME
cd ./mongo-1.5.7/
/alidata/php/bin/phpize
./configure --with-php-config=/alidata/php/bin/php-config

if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install

if ! cat $PHP_INI | grep  'extension=mongo.so' &> /dev/null;then
        echo 'extension=mongo.so' >>$PHP_INI
fi

cd $DIR
bash
