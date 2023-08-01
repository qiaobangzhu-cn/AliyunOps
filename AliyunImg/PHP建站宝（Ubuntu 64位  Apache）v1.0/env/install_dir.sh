#!/bin/bash
userdel www
groupadd www

useradd -g www -M -d /alidata/www -s /usr/sbin/nologin www &> /dev/null

mkdir -p /alidata
mkdir -p /alidata/server
mkdir -p /alidata/vhosts
mkdir -p /alidata/www
mkdir -p /alidata/init
mkdir -p /alidata/log
mkdir -p /alidata/log/php
mkdir -p /alidata/log/mysql
chown -R www:www /alidata/log

mkdir -p /alidata/server/mysql5.6
ln -s /alidata/server/mysql5.6 /alidata/server/mysql

mkdir -p /alidata/server/httpd-2
mkdir -p /alidata/server/httpd-3
mkdir -p /alidata/server/httpd-4
mkdir -p /alidata/server/httpd-5


mkdir -p /alidata/www/default
mkdir -p /alidata/log/httpd
mkdir -p /alidata/log/httpd/access
ln -s /alidata/server/httpd-4 /alidata/server/httpd
mkdir -p /alidata/log/php
mkdir -p /alidata/server/php-2
mkdir -p /alidata/server/php-3
mkdir -p /alidata/server/php-4
mkdir -p /alidata/server/php-5

ln -s /alidata/server/php-4 /alidata/server/php

