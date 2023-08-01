#!/bin/bash

PHP_DIR=/alidata/server/php-5.6.8

if [ `uname -m` == "x86_64" ];then
   machine=x86_64
else
   machine=i686
fi


rm -rf php-5.6.8
if [ ! -f php-5.6.8.tar.gz ];then
  wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/php-5.6.8.tar.gz
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
--enable-fastcgi \
--enable-static \
--enable-inline-optimization \
--enable-sockets \
--enable-wddx \
--enable-zip \
--enable-calendar \
--enable-bcmath \
--enable-soap \
--with-zlib \
--with-iconv=/usr/local \
--with-gd \
--with-xmlrpc \
--enable-mbstring \
--without-sqlite \
--with-curl \
--enable-ftp \
--with-mcrypt  \
--with-freetype-dir=/usr/local/freetype.2.1.10 \
--with-jpeg-dir=/usr/local/jpeg.6 \
--with-png-dir=/usr/local/libpng.1.2.50 \
--disable-ipv6 \
--disable-debug \
--with-openssl \
--disable-maintainer-zts \
--disable-safe-mode \
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

#Xcache
rm -rf xcache-3.2.0
if [ ! -f xcache-3.2.0.tar.gz ];then
   wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/xcache/xcache-3.2.0.tar.gz
fi
tar xf xcache-3.2.0.tar.gz
cd xcache-3.2.0
/alidata/server/php-5.6.8/bin/phpize
./configure --enable-xcache --with-php-config=/alidata/server/php-5.6.8/bin/php-config
make && make install

cpu_count=`cat /proc/cpuinfo |grep -c processor`
echo "
;xcache
[xcache-common]
extension = xcache.so

[xcache.admin]
xcache.admin.enable_auth = On

[xcache]
xcache.shm_scheme =        "mmap"
xcache.size  =               50M
; set to cpu count (cat /proc/cpuinfo |grep -c processor)
xcache.count =                 ${cpu_count}
xcache.slots =                8K
xcache.ttl   =                 0
xcache.gc_interval =           0
xcache.var_size  =            4M
xcache.var_count =             1
xcache.var_slots =            8K
xcache.var_ttl   =             0
xcache.var_maxttl   =          0
xcache.var_gc_interval =     300
xcache.readonly_protection = Off
; for *nix, xcache.mmap_path is a file path, not directory. (auto create/overwrite)
; Use something like "/tmp/xcache" instead of "/dev/*" if you want to turn on ReadonlyProtection
; different process group of php won't share the same /tmp/xcache
xcache.mmap_path =    "/tmp/xcache"
xcache.coredump_directory =   ""
xcache.experimental =        Off
xcache.cacher =               On
xcache.stat   =               On
xcache.optimizer =           Off

[xcache.coverager]
; enabling this feature will impact performance
; enable only if xcache.coverager == On && xcache.coveragedump_directory == "non-empty-value"
; enable coverage data collecting and xcache_coverager_start/stop/get/clean() functions
xcache.coverager =          Off
xcache.coveragedump_directory = ""
;xcache end
">>/alidata/server/php-5.6.8/etc/php.ini
cd ..
install -v -m755 ./php-5.6.8/sapi/fpm/init.d.php-fpm  /etc/init.d/php-fpm56
#/etc/init.d/php-fpm start
sleep 5
