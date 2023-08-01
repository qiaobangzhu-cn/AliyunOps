#!/bin/bash

SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/php-5.2/php-5.2.17.tar.gz"
PKG_NAME=`basename $SRC_URI`
PKG_NAME_DIR=php-5.2.17
PATCH_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/php-5.2/php-5.2.17-fpm-0.5.14.diff.gz"
PATCH_PKG=`basename $PATCH_URI`
PATCH_FILE=php-5.2.17-fpm-0.5.14.diff
DIR=`pwd`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
DATE=`date +%Y%m%d%H%M%S`
PHP_DIR=/alidata/php
NGINX_DIR=/alidata/nginx

\mv $PHP_DIR $PHP_DIR.bak.$DATE &> /dev/null
mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

if [ ! -s $PATCH_FILE ]; then
  wget -c $PATCH_URI
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
  apt-get -y install psmisc libmcrypt-dev build-essential libncurses5-dev libfreetype6-dev libxml2-dev mysql-client libmysqld-dev  libssl-dev libjpeg62-dev libpng12-dev libfreetype6-dev libsasl2-dev autoconf libperl-dev libtool libaio* 
  
  ##soft link for php compile##
  ln -s /usr/lib/x86_64-linux-gnu/libpng.so /usr/lib/libpng.so
  ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/libjpeg.so
  ln -s /usr/lib/x86_64-linux-gnu/libmysqlclient_r.so /usr/lib/libmysqlclient_r.so
  ln -s /usr/lib/x86_64-linux-gnu/libmysqlclient.so /usr/lib/libmysqlclient.so
fi
####---- install dependencies ----end####

#######<<<php install>>>begin#######

rm -fr $PATCH_FILE
gunzip $PATCH_PKG

rm -rf $PKG_NAME_DIR
tar zxvf $PKG_NAME
patch -d $PKG_NAME_DIR -p1 < $PATCH_FILE
cd $PKG_NAME_DIR
./configure --prefix=$PHP_DIR \
--with-config-file-path=$PHP_DIR/etc \
--with-mysql=/usr/bin/mysql \
--with-mysqli=/usr/bin/mysql_config \
--with-pdo-mysql=/usr/bin/mysql \
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
--disable-safe-mode 


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
sed -i "s,logs/slow.log,$PHP_DIR/log/slow.log,"  $PHP_DIR/etc/php-fpm.conf
#self start
install -v -m755 ./$PKG_NAME_DIR/sapi/cgi/fpm/php-fpm  /etc/init.d/php-fpm
#######<<<php install>>>end#######


###start config fastcgi&nginx#######
cat > /alidata/www/default/info.php << EOF
<?php
phpinfo();
?>
EOF
chown www:www /alidata/www/default/info.php
cat > $NGINX_DIR/conf/fastcgi.conf << EOF
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
\mv $NGINX_DIR/conf/vhosts/default.conf $NGINX_DIR/conf/vhosts/default.conf.$DATE
cat > $NGINX_DIR/conf/vhosts/default.conf << EOF
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
  access_log  $NGINX_DIR/logs/default.log;
}
EOF
###end config fastcgi&nginx#######



#add PATH
if ! cat /etc/profile | grep "export PATH=\$PATH:$PHP_DIR/bin:$PHP_DIR/sbin" &> /dev/null;then
	echo "export PATH=\$PATH:$PHP_DIR/bin:$PHP_DIR/sbin" >> /etc/profile
fi
source /etc/profile
#add rc.local
if ! cat /etc/rc.local | grep "/etc/init.d/php-fpm start" &> /dev/null;then
    echo "/etc/init.d/php-fpm start" >> /etc/rc.local
fi

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

/etc/init.d/nginx stop
/etc/init.d/nginx start
/etc/init.d/php-fpm start
bash
