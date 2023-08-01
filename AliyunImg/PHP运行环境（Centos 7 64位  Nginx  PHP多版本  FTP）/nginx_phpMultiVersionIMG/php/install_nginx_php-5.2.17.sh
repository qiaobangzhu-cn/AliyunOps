#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/php-5.2/php-5.2.17.tar.gz"
PKG_NAME=`basename $SRC_URI`
PKG_NAME_DIR=php-5.2.17
PATCH_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/php-5.2/php-5.2.17-fpm-0.5.14.diff.gz"
PATCH_PKG=`basename $PATCH_URI`
PATCH_FILE=php-5.2.17-fpm-0.5.14.diff
DIR=`pwd`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

PHP_DIR=/alidata/server/php-5.2.17

curl -o php-5.2.17.patch https://mail.gnome.org/archives/xml/2012-August/txtbgxGXAvz4N.txt

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

if [ ! -s $PATCH_FILE ]; then
  wget -c $PATCH_URI
fi


#######<<<php install>>>begin#######

rm -fr $PATCH_FILE
gunzip $PATCH_PKG

rm -rf $PKG_NAME_DIR
tar zxvf $PKG_NAME
patch -d $PKG_NAME_DIR -p1 < $PATCH_FILE
cd $PKG_NAME_DIR
patch -p0 -b <../php-5.2.17.patch 
patching file ext/dom/node.c
patching file 
ext/dom/documenttype.c
patching file ext/simplexml/simplexml.c
if [ "$(cat /proc/version | grep centos)" != "" ];then
./configure --prefix=$PHP_DIR \
--with-config-file-path=$PHP_DIR/etc \
--with-mysql=/alidata/server/mysql \
--with-mysqli=/alidata/server/mysql/bin/mysql_config \
--with-pdo-mysql=/alidata/server/mysql \
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
--with-iconv \
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
--disable-safe-mode
else
./configure --prefix=$PHP_DIR \
--with-config-file-path=$PHP_DIR/etc \
--with-mysql=/alidata/server/mysql \
--with-mysqli=/alidata/server/mysql/bin/mysql_config \
--with-pdo-mysql=/alidata/server/mysql \
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
--with-iconv \
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
--disable-maintainer-zts \
--disable-safe-mode
fi


if [ $CPU_NUM -gt 1 ];then
    make ZEND_EXTRA_LIBS='-liconv' -j$CPU_NUM
else
    make ZEND_EXTRA_LIBS='-liconv'
fi
make install
cd ..
cp ./$PKG_NAME_DIR/php.ini-recommended $PHP_DIR/etc/php.ini
#adjust php.ini
sed -i "s#extension_dir = \"\.\/\"#extension_dir = "$PHP_DIR/lib/php/extensions/no-debug-non-zts-20060613/"#"  $PHP_DIR/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 64M/g' $PHP_DIR/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' $PHP_DIR/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' $PHP_DIR/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' $PHP_DIR/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' $PHP_DIR/etc/php.ini
#adjust php-fpm
mkdir -p $PHP_DIR/log/
\cp /alidata/install/php-5.2.17/sapi/cgi/fpm/php-fpm.conf  $PHP_DIR/etc/php-fpm.conf
sed -ri 's,.*name="user".*,\t\t\t<value name="user">www</value> ,g'   $PHP_DIR/etc/php-fpm.conf
sed -ri 's,.*name="group".*,\t\t\t<value name="group">www</value>,g'   $PHP_DIR/etc/php-fpm.conf
sed -i 's,<value name="max_children">5,<value name="max_children">100,g'   $PHP_DIR/etc/php-fpm.conf
sed -i 's,<value name="error_log">.*,<value name="error_log">/alidata/log/php/php-fpm.log</value>,g'   $PHP_DIR/etc/php-fpm.conf
sed -i "s,logs/slow.log,$PHP_DIR/log/slow.log,"  $PHP_DIR/etc/php-fpm.conf
#self start
install -v -m755 ./$PKG_NAME_DIR/sapi/cgi/fpm/php-fpm  /etc/init.d/php-fpm52
#######<<<php install>>>end#######


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



##add ZendOptimizer##
zend_dir=$PHP_DIR/lib/php/extensions/no-debug-non-zts-20060613/
mkdir -p $zend_dir

if [ `uname -m` == "x86_64" ];then
  if [ ! -f ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz ];then
  wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php-5.2/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
  fi
  tar zxvf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
  mv ./ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so  $zend_dir
else
  if [ ! -f ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz ];then
  wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php-5.2/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
  fi
  tar zxvf ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
  mv ./ZendOptimizer-3.3.9-linux-glibc23-i386/data/5_2_x_comp/ZendOptimizer.so    $zend_dir
fi 

echo "[zend]" >> $PHP_DIR/etc/php.ini
echo "zend_optimizer.optimization_level=1023" >> $PHP_DIR/etc/php.ini
echo "zend_optimizer.encoder_loader=1"        >> $PHP_DIR/etc/php.ini
echo "zend_extension=$PHP_DIR/lib/php/extensions/no-debug-non-zts-20060613/ZendOptimizer.so" >> $PHP_DIR/etc/php.ini
##end config ZendOptimizer####
cd $DIR


