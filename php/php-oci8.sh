#!/bin/bash
OCI8_URL1="http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/ext/oci8/oracle-instantclient11.2-basic-11.2.0.3.0-1.x86_64.rpm"
OCI8_URL2="http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/ext/oci8/oracle-instantclient11.2-devel-11.2.0.3.0-1.x86_64.rpm"
OCI8_URL3="http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/ext/oci8/oracle-instantclient11.2-sqlplus-11.2.0.3.0-1.x86_64.rpm"
PHP_DIR=`which php | xargs dirname`
PHP_INI_DIR=`which php | xargs dirname | xargs dirname`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
PHP_VERSION=$(php -v |sed -n '1p;1q'| awk '{print $2}')
PHP_DIR_install=/alidata/install/php-$PHP_VERSION

mkdir /alidata/install
cd /alidata/install
wget $OCI8_URL1

wget $OCI8_URL2

wget $OCI8_URL3


rpm  -ivh  oracle-instantclient11.2-basic-11.2.0.3.0-1.x86_64.rpm  oracle-instantclient11.2-devel-11.2.0.3.0-1.x86_64.rpm  oracle-instantclient11.2-sqlplus-11.2.0.3.0-1.x86_64.rpm


cd $PHP_DIR_install/ext/oci8/
$PHP_DIR/phpize

./configure --with-php-config=$PHP_DIR/php-config
if $CPU_NUM -gt 1 ;then
    make -j$CPU_NUM
else
    make
fi
make install

SO_DIR=$(dirname `find /alidata/php/ -name oci8.so`)
echo "extension = $SO_DIR/oci8.so" >> $PHP_INI_DIR/etc/php.ini

php  -m  | grep oci8
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