#!/bin/bash

SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/php-5.2/php-5.2.17.tar.gz"
PKG_NAME=`basename $SRC_URI`
PKG_NAME_DIR=php-5.2.17

DIR=`pwd`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
DATE=`date +%Y%m%d%H%M%S`
PHP_DIR=/alidata/php
HTTPD_DIR=/alidata/httpd



\mv $PHP_DIR $PHP_DIR.bak.$DATE &> /dev/null
mkdir -p /alidata/install
cd /alidata/install



if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi



####---- install dependencies ----begin####
if [ "$(cat /proc/version | grep redhat)" != "" ];then
  wget http://git.jiagouyun.com/operation/operation/raw/master/linux/redhat/CentOS-Base.repo -O /etc/yum.repos.d/CentOS-Base.repo
  yum makecache
  yum -y install libtool autoconf patch fiex* libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl libmcrypt libmcrypt-devel freetype-devel libpng libpng-devel libjpeg-devel libaio*
elif [ "$(cat /proc/version | grep centos)" != "" ];then
#note : The CentOS 5 series, Yum will install 32 bit packet, then filter out 32.
  if [ `uname -m` == "x86_64" ];then
	  if cat /etc/issue |grep "5\." &> /dev/null;then
		 if ! cat /etc/yum.conf |grep "exclude=\*\.i?86" &> /dev/null;then
			sed -i 's;\[main\];\[main\]\nexclude=*.i?86;' /etc/yum.conf
		 fi
		 rpm --import /etc/pki/rpm-gpg/RPM*
	  fi
  fi
  yum makecache
  yum -y install libtool autoconf patch libxml2 libxml2-devel  mysql-devel mysql ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl libmcrypt libmcrypt-devel freetype-devel libpng libpng-devel libjpeg-devel libaio*

  ##soft link for php compile##
  ln -s /usr/lib64/libjpeg.so /usr/lib/libjpeg.so
  ln -s /usr/lib64/libpng.so /usr/lib/libpng.so
  ln -s /usr/lib64/mysql/libmysqlclient.so   /usr/lib/libmysqlclient.so
  ln -s /usr/lib64/mysql/libmysqlclient_r.so   /usr/lib/libmysqlclient_r.so

elif [ "$(cat /proc/version | grep ubuntu)" != "" ];then
  sed -i 's/exit 0//' /etc/rc.local
  apt-get -y update
  apt-get -y install libmcrypt-dev build-essential libncurses5-dev libfreetype6-dev libxml2-dev mysql-client libmysqld-dev  libssl-dev libjpeg62-dev  libpng12-dev libfreetype6-dev libsasl2-dev autoconf libperl-dev libtool libaio*
  
  
  ##soft link for php compile##
  ln -s /usr/lib/x86_64-linux-gnu/libpng.so /usr/lib/libpng.so
  ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/libjpeg.so
  ln -s /usr/lib/x86_64-linux-gnu/libmysqlclient_r.so /usr/lib/libmysqlclient_r.so
  ln -s /usr/lib/x86_64-linux-gnu/libmysqlclient.so /usr/lib/libmysqlclient.so

elif [ "$(cat /proc/version | grep -i debian)" != "" ];then
  apt-get -y update
  apt-get -y install psmisc libmcrypt-dev build-essential libncurses5-dev libfreetype6-dev  libxml2-dev mysql-client libmysqld-dev libssl-dev libjpeg62-dev libpng12-dev libfreetype6-dev libsasl2-dev autoconf libperl-dev libtool libaio* 

  ##soft link for php compile##
  ln -s /usr/lib/x86_64-linux-gnu/libpng.so /usr/lib/libpng.so
  ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/libjpeg.so
  ln -s /usr/lib/x86_64-linux-gnu/libmysqlclient_r.so /usr/lib/libmysqlclient_r.so
  ln -s /usr/lib/x86_64-linux-gnu/libmysqlclient.so /usr/lib/libmysqlclient.so
fi
####---- install dependencies ----end####

#######<<<php install>>>begin#######
#####httpd.conf settings#####
if ! cat $HTTPD_DIR/conf/httpd.conf | grep "^LoadModule php5_module modules/libphp5.so";then
	sed -i "s#LoadModule rewrite_module modules/mod_rewrite.so#LoadModule rewrite_module modules/mod_rewrite.so\nLoadModule php5_module modules/libphp5.so#" $HTTPD_DIR/conf/httpd.conf
fi
mkdir -p /alidata/www/default/
cat > /alidata/www/default/info.php << EOF
<?php
phpinfo();
?>
EOF
chown www:www /alidata/www/default/info.php
sed -i "s;DirectoryIndex index.html;DirectoryIndex index.html index.htm index.php;" $HTTPD_DIR/conf/httpd.conf
####php install####
rm -rf $PKG_NAME_DIR
tar zxvf $PKG_NAME
cd $PKG_NAME_DIR
./configure --prefix=$PHP_DIR \
--with-config-file-path=$PHP_DIR/etc \
--with-apxs2=$HTTPD_DIR/bin/apxs \
--with-mysql=/usr/bin/mysql \
--with-mysqli=/usr/bin/mysql_config \
--with-pdo-mysql=/usr/bin/mysql \
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
--without-sqlite \
--with-curl \
--enable-ftp \
--with-mcrypt  \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--disable-ipv6 \
--disable-debug \
--disable-maintainer-zts \
--disable-safe-mode \
#--disable-fileinfo

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
if ! cat $HTTPD_DIR/conf/httpd.conf | grep "AddType application/x-httpd-php .php" &> /dev/null;then
	echo "AddType application/x-httpd-php .php" >> $HTTPD_DIR/conf/httpd.conf
fi
sed -i 's/post_max_size = 8M/post_max_size = 64M/g' $PHP_DIR/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' $PHP_DIR/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' $PHP_DIR/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' $PHP_DIR/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' $PHP_DIR/etc/php.ini
#######<<<php install>>>end#######


#add PATH
if ! cat /etc/profile | grep "export PATH=\$PATH:$PHP_DIR/bin:$PHP_DIR/sbin" &> /dev/null;then
	echo "export PATH=\$PATH:$PHP_DIR/bin:$PHP_DIR/sbin" >> /etc/profile
fi
source /etc/profile

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
echo "zend_extension=/alidata/php/lib/php/extensions/no-debug-non-zts-20060613/ZendOptimizer.so" >> $PHP_DIR/etc/php.ini
##
cd $DIR

/etc/init.d/httpd stop
/etc/init.d/httpd start
bash
