#!/bin/bash
MEMCACHE="http://zy-res.oss-cn-hangzhou.aliyuncs.com/memcache/memcache-2.2.7.tgz"
MEMCACHE_NAME=`basename $MEMCACHE`
PHP_DIR=`which php | xargs dirname`
PHP_INI_DIR=`which php | xargs dirname | xargs dirname`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $MEMCACHE_NAME ]; then
    wget -c $MEMCACHE
fi

rm -rf memcache-2.2.7
tar xvf $MEMCACHE_NAME
cd memcache-2.2.7

$PHP_DIR/phpize
./configure --with-php-config=$PHP_DIR/php-config
if $CPU_NUM -gt 1 ;then
    make -j$CPU_NUM
else
    make
fi
make install
SO_DIR=$(dirname `find /alidata/server/ -name memcache.so`)
echo "extension = $SO_DIR/memcache.so" >> $PHP_INI_DIR/etc/php.ini

ps -ef | grep nginx | grep -v grep
if [ "$?" -eq "0" ];then
/etc/init.d/php-fpm restart
else
/etc/init.d/httpd restart
fi

cd $DIR
bash