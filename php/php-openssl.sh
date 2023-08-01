#!/bin/bash
PHP_DIR=`which php | xargs dirname`
PHP_INI_DIR=`which php | xargs dirname | xargs dirname`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
PHP_VERSION=$(php -v |sed -n '1p;1q'| awk '{print $2}')
PHP_DIR_install=/alidata/install/php-$PHP_VERSION

cd $PHP_DIR_install/ext/openssl/
$PHP_DIR/phpize
mv config0.m4 config.m4
$PHP_DIR/phpize
./configure --with-openssl --with-php-config=$PHP_DIR/php-config
if $CPU_NUM -gt 1 ;then
    make -j$CPU_NUM
else
    make
fi
make install

SO_DIR=$(dirname `find /alidata/php/ -name openssl.so`)
echo "extension = $SO_DIR/openssl.so" >> $PHP_INI_DIR/etc/php.ini

php  -m  | grep openssl
if [ "$?" -eq "0" ];then
echo "success"
else
echo "no success"
fi

ps -ef | grep nginx | grep -v grep
if [ "$?" -eq "0" ];then
/etc/init.d/php-fpm restart
else
/etc/init.d/httpd restart
fi

cd $DIR
bash