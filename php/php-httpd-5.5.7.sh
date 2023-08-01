#!/bin/bash

SRC_URI="http://oss.aliyuncs.com/aliyunecs/onekey/php/php-5.5.7.tar.gz"
PKG_NAME=`basename $SRC_URI`
PKG_NAME_DIR=php-5.5.7
DIR=`pwd`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/php /alidata/php.bak.$DATE &> /dev/null
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
  yum -y install libtool autoconf patch libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl libmcrypt libmcrypt-devel freetype-devel libpng libpng-devel libjpeg-devel libaio*
elif [ "$(cat /proc/version | grep ubuntu)" != "" ];then
  sed -i 's/exit 0//' /etc/rc.local
  apt-get -y update
  apt-get -y install libmcrypt-dev build-essential libncurses5-dev libfreetype6-dev libxml2-dev libssl-dev libjpeg62-dev libpng12-dev libfreetype6-dev libsasl2-dev autoconf libperl-dev libtool libaio*
elif [ "$(cat /proc/version | grep -i debian)" != "" ];then
  apt-get -y update
  apt-get -y install psmisc libmcrypt-dev build-essential libncurses5-dev libfreetype6-dev libxml2-dev libssl-dev libjpeg62-dev libpng12-dev libfreetype6-dev libsasl2-dev autoconf libperl-dev libtool libaio*
fi
####---- install dependencies ----end####

#######<<<php install>>>begin#######
#####httpd.conf settings#####
if ! cat /alidata/httpd/conf/httpd.conf | grep "^LoadModule php5_module modules/libphp5.so";then
	sed -i "s#LoadModule rewrite_module modules/mod_rewrite.so#LoadModule rewrite_module modules/mod_rewrite.so\nLoadModule php5_module modules/libphp5.so#" /alidata/httpd/conf/httpd.conf
fi
mkdir -p /alidata/www/default/
cat > /alidata/www/default/info.php << EOF
<?php
phpinfo();
?>
EOF
chown www:www /alidata/www/default/info.php
sed -i "s;DirectoryIndex index.html;DirectoryIndex index.html index.htm index.php;" /alidata/httpd/conf/httpd.conf
####php install####
rm -rf $PKG_NAME_DIR
tar zxvf $PKG_NAME
cd $PKG_NAME_DIR
./configure --prefix=/alidata/php \
--with-config-file-path=/alidata/php/etc \
--with-apxs2=/alidata/httpd/bin/apxs \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
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
--disable-fileinfo

if [ $CPU_NUM -gt 1 ];then
    make ZEND_EXTRA_LIBS='-liconv' -j$CPU_NUM
else
    make ZEND_EXTRA_LIBS='-liconv'
fi
make install
cd ..
cp ./$PKG_NAME_DIR/php.ini-production /alidata/php/etc/php.ini
#adjust php.ini
sed -i 's#; extension_dir = \"\.\/\"#extension_dir = "/alidata/php/lib/php/extensions/no-debug-non-zts-20121212/"#'  /alidata/php/etc/php.ini
if ! cat /alidata/httpd/conf/httpd.conf | grep "AddType application/x-httpd-php .php" &> /dev/null;then
	echo "AddType application/x-httpd-php .php" >> /alidata/httpd/conf/httpd.conf
fi
sed -i 's/post_max_size = 8M/post_max_size = 64M/g' /alidata/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' /alidata/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /alidata/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /alidata/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /alidata/php/etc/php.ini
#######<<<php install>>>end#######

#add PATH
if ! cat /etc/profile | grep "export PATH=\$PATH:/alidata/php/bin:/alidata/php/sbin" &> /dev/null;then
	echo "export PATH=\$PATH:/alidata/php/bin:/alidata/php/sbin" >> /etc/profile
fi
source /etc/profile

#add ZendGuardLoader
mkdir -p /alidata/php/lib/php/extensions/no-debug-non-zts-20121212/
sed -i 's#\[opcache\]#\[opcache\]\nzend_extension=opcache.so#' /alidata/php/etc/php.ini
sed -i 's#;opcache.enable=0#opcache.enable=1#' /alidata/php/etc/php.ini
cd $DIR
/etc/init.d/httpd stop
/etc/init.d/httpd start
bash