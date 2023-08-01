#!/bin/bash
rm -rf php-5.2.17
if [ ! -f php-5.2.17.tar.gz ];then
  wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php-5.2/php-5.2.17.tar.gz
fi
tar zxvf php-5.2.17.tar.gz
cd php-5.2.17
./configure --prefix=/alidata/server/php-2 \
--with-config-file-path=/alidata/server/php-2/etc \
--with-apxs2=/alidata/server/httpd-2/bin/apxs \
--with-mysql=/alidata/server/mysql \
--with-mysqli=/alidata/server/mysql/bin/mysql_config \
--with-pdo-mysql=/alidata/server/mysql \
--enable-static \
--enable-maintainer-zts \
--enable-zend-multibyte \
--enable-inline-optimization \
--enable-sockets \
--enable-wddx \
--enable-zip \
--enable-calendar \
--enable-bcmath \
--enable-soap \
--with-zlib \
--with-iconv \
--with-gd \
--with-xmlrpc \
--enable-mbstring \
--with-curl \
--enable-ftp \
--with-mcrypt \
--with-freetype-dir=/usr/local/freetype.2.1.10 \
--with-jpeg-dir=/usr/local/jpeg.6 \
--with-png-dir=/usr/local/libpng.1.2.50 \
--disable-ipv6 \
--disable-debug \
--disable-maintainer-zts \
--disable-safe-mode \

make ZEND_EXTRA_LIBS='-liconv'
make install
cd ..
cp ./php-5.2.17/php.ini-recommended /alidata/server/php-2/etc/php.ini
#adjust php.ini
sed -i 's#; extension_dir = \"\.\/\"#extension_dir = "/alidata/server/php-2/lib/php/extensions/no-debug-non-zts-20090626/"#'  /alidata/server/php-2/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 64M/g' /alidata/server/php-2/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' /alidata/server/php-2/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /alidata/server/php-2/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /alidata/server/php-2/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /alidata/server/php-2/etc/php.ini

#/etc/init.d/httpd restart
sleep 5
