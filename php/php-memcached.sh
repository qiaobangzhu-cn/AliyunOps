#!/bin/bash
MEMCACHED="http://zy-res.oss-cn-hangzhou.aliyuncs.com/memcache/memcached-2.2.0.tgz" 
LIBMEMCACHED="http://zy-res.oss-cn-hangzhou.aliyuncs.com/libmemcached/libmemcached-1.0.18.tar.gz" 
MEMCACHED_NAME=`basename $MEMCACHED`
LIBMEMCACHED_NAME=`basename $LIBMEMCACHED`
PHP_DIR=`which php | xargs dirname`
PHP_INI_DIR=`which php | xargs dirname | xargs dirname`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

if [ ! -s $LIBMEMCACHED_NAME ]; then
    wget -c $LIBMEMCACHED
fi

rm -rf libmemcached-1.0.18
tar xvf $LIBMEMCACHED_NAME
cd libmemcached-1.0.18
./configure
if [ $CPU_NUM -gt 1 ] ;then
    make -j$CPU_NUM
else
    make
fi
make install

if [ ! -s $MEMCACHED_NAME ]; then
    wget -c $MEMCACHED
fi

rm -rf memcached-2.2.0
tar xvf $MEMCACHED_NAME
cd memcached-2.2.0
$PHP_DIR/phpize
./configure  --with-php-config=$PHP_DIR/php-config
if $CPU_NUM -gt 1 ;then
    make -j$CPU_NUM
else
    make
fi
make install
SO_DIR=$(dirname `find /alidata/server/ -name memcached.so`)
echo "extension = $SO_DIR/memcached.so" >> $PHP_INI_DIR/etc/php.ini


ps -ef | grep nginx | grep -v grep
if [ "$?" -eq "0" ];then
/etc/init.d/php-fpm restart
else
/etc/init.d/httpd restart
fi

cd $DIR
bash