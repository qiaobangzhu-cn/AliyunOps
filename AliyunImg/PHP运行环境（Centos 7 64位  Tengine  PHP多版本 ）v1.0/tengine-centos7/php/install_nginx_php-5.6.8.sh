#!/bin/bash

PHP_DIR=/alidata/server/$php56_dir

if [ `uname -m` == "x86_64" ];then
   machine=x86_64
else
   machine=i686
fi


rm -rf php-5.6.8
if [ ! -f php-5.6.8.tar.gz ];then
 wget  http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/php-5.6.8.tar.gz
fi
tar zxvf php-5.6.8.tar.gz
cd php-5.6.8
./configure --prefix=$PHP_DIR \
--enable-opcache \
--with-config-file-path=$PHP_DIR/etc \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--enable-fpm \
--enable-static \
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
--without-sqlite3 \
--without-pdo-sqlite \
--with-curl \
--with-openssl \
--enable-ftp \
--with-mcrypt  \
--with-freetype-dir=/usr/local/freetype.2.1.10 \
--with-jpeg-dir=/usr/local/jpeg.6 \
--with-png-dir=/usr/local/libpng.1.2.50 \
--disable-ipv6 \
--disable-debug \
--disable-maintainer-zts \
--disable-fileinfo

CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ $CPU_NUM -gt 1 ];then
    make ZEND_EXTRA_LIBS='-liconv' -j$CPU_NUM
else
    make ZEND_EXTRA_LIBS='-liconv'
fi
make install
cd ..
cp ./php-5.6.8/php.ini-production $PHP_DIR/etc/php.ini
#adjust php.ini
sed -i "s#; extension_dir = \"\.\/\"#extension_dir = "$PHP_DIR/lib/php/extensions/no-debug-non-zts-20131226/"#" $PHP_DIR/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 64M/g' $PHP_DIR/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' $PHP_DIR/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' $PHP_DIR/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' $PHP_DIR/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' $PHP_DIR/etc/php.ini
#adjust php-fpm
cp $PHP_DIR/etc/php-fpm.conf.default $PHP_DIR/etc/php-fpm.conf
sed -i 's,user = nobody,user=www,g'   $PHP_DIR/etc/php-fpm.conf
sed -i 's,group = nobody,group=www,g'   $PHP_DIR/etc/php-fpm.conf
sed -i 's,^pm.min_spare_servers = 1,pm.min_spare_servers = 5,g'   $PHP_DIR/etc/php-fpm.conf
sed -i 's,^pm.max_spare_servers = 3,pm.max_spare_servers = 35,g'   $PHP_DIR/etc/php-fpm.conf
sed -i 's,^pm.max_children = 5,pm.max_children = 100,g'   $PHP_DIR/etc/php-fpm.conf
sed -i 's,^pm.start_servers = 2,pm.start_servers = 20,g'   $PHP_DIR/etc/php-fpm.conf
sed -i 's,;pid = run/php-fpm.pid,pid = run/php-fpm.pid,g'   $PHP_DIR/etc/php-fpm.conf
sed -i 's,;error_log = log/php-fpm.log,error_log = /alidata/log/php/php-fpm.log,g'   $PHP_DIR/etc/php-fpm.conf
sed -i 's,;slowlog = log/$pool.log.slow,slowlog = /alidata/log/php/\$pool.log.slow,g'   $PHP_DIR/etc/php-fpm.conf

###zend###
mkdir -p $PHP_DIR/lib/php/extensions/no-debug-non-zts-20131226/
sed -i 's#\[opcache\]#\[opcache\]\nzend_extension=opcache.so#' $PHP_DIR/etc/php.ini
sed -i 's#;opcache.enable=0#opcache.enable=1#' $PHP_DIR/etc/php.ini


#memcache
if [ ! -f memcache-3.0.6.tgz ];then
	wget http://oss.aliyuncs.com/aliyunecs/onekey/php_extend/memcache-3.0.6.tgz
fi
rm -rf memcache-3.0.6
tar -xzvf memcache-3.0.6.tgz
cd memcache-3.0.6
$PHP_DIR/bin/phpize
./configure --enable-memcache --with-php-config=$PHP_DIR/bin/php-config
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install

cd ..
echo "extension=memcache.so" >> $PHP_DIR/etc/php.ini

install -v -m755 ./php-5.6.8/sapi/fpm/init.d.php-fpm  /etc/init.d/php-fpm56
#/etc/init.d/php-fpm start
sleep 5