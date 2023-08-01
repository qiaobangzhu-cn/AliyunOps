#!/bin/bash
rm -rf  tengine-2.1.0
 if [ ! -f tengine-2.1.0.tar.gz ];then
    wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/tengine/tengine-2.1.0.tar.gz
 fi
tar zxvf tengine-2.1.0.tar.gz
cd tengine-2.1.0
./configure --user=www \
--group=www \
--prefix=/alidata/server/nginx \
--with-http_stub_status_module \
--without-http-cache \
--with-http_ssl_module \
--with-http_gzip_static_module
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
chmod 775 /alidata/server/nginx/logs
chown -R www:www /alidata/server/nginx/logs
chmod -R 775 /alidata/www
chown -R www:www /alidata/www
cd ..
cp -fR ./nginx/config-nginx/* /alidata/server/nginx/conf/
chmod 644 -R /alidata/server/nginx/conf
cp  ./nginx/config-nginx/index.php  /alidata/www/default/
chown www:www  /alidata/www/default/index.php 
chmod 644 /alidata/www/default/index.php 

sed -i 's/worker_processes  2/worker_processes  '"$CPU_NUM"'/' /alidata/server/nginx/conf/nginx.conf
chmod 755 /alidata/server/nginx/sbin/nginx
#/alidata/server/nginx/sbin/nginx
mv /alidata/server/nginx/conf/nginx /etc/init.d/
chmod +x /etc/init.d/nginx
/etc/init.d/nginx start
