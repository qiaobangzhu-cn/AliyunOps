#!/bin/bash

SRC_URI="http://oss.aliyuncs.com/aliyunecs/onekey/php/php-5.3.18.tar.gz"
PKG_NAME=`basename $SRC_URI`
PKG_NAME_DIR=php-5.3.18
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
cat > /alidata/www/default/info.php << EOF
<?php
phpinfo();
?>
EOF
chown www:www /alidata/www/default/info.php
cat > /alidata/nginx/conf/fastcgi.conf << EOF
if (\$request_filename ~* (.*)\.php) {
    set \$php_url \$1;
}
if (!-e \$php_url.php) {
    return 403;
}
fastcgi_param  SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;
fastcgi_param  QUERY_STRING       \$query_string;
fastcgi_param  REQUEST_METHOD     \$request_method;
fastcgi_param  CONTENT_TYPE       \$content_type;
fastcgi_param  CONTENT_LENGTH     \$content_length;

fastcgi_param  SCRIPT_NAME        \$fastcgi_script_name;
fastcgi_param  REQUEST_URI        \$request_uri;
fastcgi_param  DOCUMENT_URI       \$document_uri;
fastcgi_param  DOCUMENT_ROOT      \$document_root;
fastcgi_param  SERVER_PROTOCOL    \$server_protocol;

fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx/\$nginx_version;

fastcgi_param  REMOTE_ADDR        \$remote_addr;
fastcgi_param  REMOTE_PORT        \$remote_port;
fastcgi_param  SERVER_ADDR        \$server_addr;
fastcgi_param  SERVER_PORT        \$server_port;
fastcgi_param  SERVER_NAME        \$server_name;

# PHP only, required if PHP was built with --enable-force-cgi-redirect
fastcgi_param  REDIRECT_STATUS    200;
EOF
\mv /alidata/nginx/conf/vhosts/default.conf /alidata/nginx/conf/vhosts/default.conf.$DATE
cat > /alidata/nginx/conf/vhosts/default.conf << EOF
server {
    listen       80 default;
    server_name  _;
	index index.html index.htm index.php;
	root /alidata/www/default;
	location ~ .*\.(php|php5)?$
	{
		fastcgi_pass  127.0.0.1:9000;
		fastcgi_index index.php;
		include fastcgi.conf;
	}
	
	location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
	{
		expires 1d;
	}
	location ~ .*\.(js|css)?$
	{
		expires 1d;
	}
	access_log  /alidata/nginx/logs/default.log;
}
EOF
rm -rf $PKG_NAME_DIR
tar zxvf $PKG_NAME
cd $PKG_NAME_DIR
./configure --prefix=/alidata/php \
--with-config-file-path=/alidata/php/etc \
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
sed -i 's#; extension_dir = \"\.\/\"#extension_dir = "/alidata/php/lib/php/extensions/no-debug-non-zts-20090626/"#'  /alidata/php/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 64M/g' /alidata/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' /alidata/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /alidata/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /alidata/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /alidata/php/etc/php.ini
#adjust php-fpm
mkdir -p /alidata/php/log/
\cp /alidata/php/etc/php-fpm.conf.default /alidata/php/etc/php-fpm.conf
sed -i 's,user = nobody,user=www,g'   /alidata/php/etc/php-fpm.conf
sed -i 's,group = nobody,group=www,g'   /alidata/php/etc/php-fpm.conf
sed -i 's,^pm.min_spare_servers = 1,pm.min_spare_servers = 5,g'   /alidata/php/etc/php-fpm.conf
sed -i 's,^pm.max_spare_servers = 3,pm.max_spare_servers = 35,g'   /alidata/php/etc/php-fpm.conf
sed -i 's,^pm.max_children = 5,pm.max_children = 100,g'   /alidata/php/etc/php-fpm.conf
sed -i 's,^pm.start_servers = 2,pm.start_servers = 20,g'   /alidata/php/etc/php-fpm.conf
sed -i 's,;pid = run/php-fpm.pid,pid = run/php-fpm.pid,g'   /alidata/php/etc/php-fpm.conf
sed -i 's,;error_log = log/php-fpm.log,error_log = /alidata/php/log/php-fpm.log,g'   /alidata/php/etc/php-fpm.conf
sed -i 's,;slowlog = log/$pool.log.slow,slowlog = /alidata/php/log/\$pool.log.slow,g'   /alidata/php/etc/php-fpm.conf
#self start
install -v -m755 ./$PKG_NAME_DIR/sapi/fpm/init.d.php-fpm  /etc/init.d/php-fpm
#######<<<php install>>>end#######

#add PATH
if ! cat /etc/profile | grep "export PATH=\$PATH:/alidata/php/bin:/alidata/php/sbin" &> /dev/null;then
	echo "export PATH=\$PATH:/alidata/php/bin:/alidata/php/sbin" >> /etc/profile
fi
source /etc/profile
#add rc.local
if ! cat /etc/rc.local | grep "/etc/init.d/php-fpm start" &> /dev/null;then
    echo "/etc/init.d/php-fpm start" >> /etc/rc.local
fi

#add ZendGuardLoader
mkdir -p /alidata/php/lib/php/extensions/no-debug-non-zts-20090626/
if [ `uname -m` == "x86_64" ];then
  if [ ! -f ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz ];then
	wget http://oss.aliyuncs.com/aliyunecs/onekey/php_extend/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
  fi
  tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
  mv ./ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /alidata/php/lib/php/extensions/no-debug-non-zts-20090626/
else
  if [ ! -f ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz ];then
	wget http://oss.aliyuncs.com/aliyunecs/onekey/php_extend/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
  fi
  tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
  mv ./ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so /alidata/php/lib/php/extensions/no-debug-non-zts-20090626/
fi
echo "zend_extension=/alidata/php/lib/php/extensions/no-debug-non-zts-20090626/ZendGuardLoader.so" >> /alidata/php/etc/php.ini
echo "zend_loader.enable=1" >> /alidata/php/etc/php.ini
echo "zend_loader.disable_licensing=0" >> /alidata/php/etc/php.ini
echo "zend_loader.obfuscation_level_support=3" >> /alidata/php/etc/php.ini
echo "zend_loader.license_path=" >> /alidata/php/etc/php.ini
cd $DIR
/etc/init.d/nginx stop
/etc/init.d/nginx start
/etc/init.d/php-fpm start
bash