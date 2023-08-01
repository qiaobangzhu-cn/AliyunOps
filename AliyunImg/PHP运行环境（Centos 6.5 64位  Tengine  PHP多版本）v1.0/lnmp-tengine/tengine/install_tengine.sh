#!/bin/bash
mkdir /usr/local/openssl
 rm -rf openssl-1.0.2d
 if [ ! -f openssl-1.0.2a.tar.gz ];then
     wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/openssl/openssl-1.0.2d.tar.gz
 fi
tar zxvf openssl-1.0.2d.tar.gz
cd openssl-1.0.2d
./config --prefix=/usr/local/openssl
make
make install
cat >> /etc/profile <<EOF
export PATH=$PATH:/usr/local/openssl/bin
EOF
source /etc/profile
##########################
cd ..
mkdir /usr/local/pcre
 rm -rf pcre-8.36
 if [ ! -f pcre-8.36.tar.gz ] ;then
    wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/pcre/pcre-8.36.tar.gz
 fi
tar zxvf pcre-8.36.tar.gz
cd pcre-8.36
./configure --prefix=/usr/local/pcre
make && make install
##########################
cd ..
mkdir /usr/local/zlib
 rm -rf zlib-1.2.8
 if [ ! -f zlib-1.2.8.tar.gz ];then
    wget  http://zy-res.oss-cn-hangzhou.aliyuncs.com/zlib/zlib-1.2.8.tar.gz
 fi 
tar zxvf zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure --prefix=/usr/local/zlib
make
make install
##########################
cd ..
groupadd  www
useradd -g www www
mkdir /alidata/server/nginx/logs -p
 rm -rf  tengine-2.1.0 
 if [ ! -f tengine-2.1.0.tar.gz ];then
    wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/tengine/tengine-2.1.0.tar.gz
 fi
tar zxvf tengine-2.1.0.tar.gz
cd tengine-2.1.0
./configure --prefix=/alidata/server/nginx     
  --user=www \
  --group=www \
  --with-http_stub_status_module \
  --with-http_ssl_module \
  --with-http_gzip_static_module \
  --with-http_concat_module=shared \
  --with-http_flv_module \
  --with-openssl=/usr/local/src/openssl-1.0.1h \
  --with-zlib=/usr/local/src/zlib-1.2.8 \ 
  --with-pcre=/usr/local/src/pcre-8.36
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ $CPU_NUM -gt 1 ];then
    make -j $CPU_NUM
else
    make
fi
 make install
cd ..
chmod 775 /alidata/server/nginx/logs
chown -R www:www /alidata/server/nginx/logs
chmod -R 775 /alidata/www
chown -R www:www /alidata/www
cd /root/lnmp-tengine/tengine
chown www:www  /alidata/www/default/index.php 
cp -fR ./config-tengine/*  /alidata/server/nginx/conf
cp  ./config-tengine/index.php  /alidata/www/default/
mv /alidata/server/nginx/conf/nginx  /etc/init.d/
chmod +x /etc/init.d/nginx
chkconfig nginx on 
/etc/init.d/nginx start
