#!/bin/bash

#ifcentos=$(cat /proc/version | grep centos)
ifubuntu=$(cat /proc/version | grep ubuntu)

userdel www
groupadd www
if [ "$ifubuntu" != "" ];then
useradd -g www -M -d /alidata/www -s /usr/sbin/nologin www &> /dev/null
else
useradd -g www -M -d /alidata/www -s /sbin/nologin www &> /dev/null
fi

#if [ "$ifcentos" != "" ];then
#useradd -g www -M -d /alidata/www -s /sbin/nologin www &> /dev/null
#elif [ "$ifubuntu" != "" ];then
#useradd -g www -M -d /alidata/www -s /usr/sbin/nologin www &> /dev/null
#fi

mkdir -p /alidata
mkdir -p /alidata/server
mkdir -p /alidata/www
mkdir -p /alidata/www/default
mkdir -p /alidata/log
mkdir -p /alidata/log/php
mkdir -p /alidata/log/mysql
mkdir -p /alidata/log/nginx
mkdir -p /alidata/log/nginx/access
chown -R www:www /alidata/log

mkdir -p /alidata/server/${mysql_dir}
ln -s /alidata/server/${mysql_dir} /alidata/server/mysql

mkdir -p /alidata/server/${web_dir}
ln -s /alidata/server/${web_dir} /alidata/server/nginx

for php_dir in $php52_dir $php53_dir $php54_dir $php55_dir
do
    mkdir -p /alidata/server/${php_dir}
done



