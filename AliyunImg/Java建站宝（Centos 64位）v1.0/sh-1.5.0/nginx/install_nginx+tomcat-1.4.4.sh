#!/bin/bash

ifrpm=$(cat /proc/version | grep -E "redhat|centos")
ifdpkg=$(cat /proc/version | grep -Ei "ubuntu|debian")
ifgentoo=$(cat /proc/version | grep -i gentoo)
ifsuse=$(cat /proc/version | grep -i suse)

rm -rf nginx-1.4.4
if [ ! -f nginx-1.4.4.tar.gz ];then
  wget http://oss.aliyuncs.com/aliyunecs/onekey/nginx/nginx-1.4.4.tar.gz
fi
tar zxvf nginx-1.4.4.tar.gz
cd nginx-1.4.4
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
cp -fR ./nginx/config-nginx-tomcat/* /alidata/server/nginx/conf/
sed -i 's/worker_processes  2/worker_processes  '"$CPU_NUM"'/' /alidata/server/nginx/conf/nginx.conf
chmod 755 /alidata/server/nginx/sbin/nginx
#/alidata/server/nginx/sbin/nginx
mv /alidata/server/nginx/conf/nginx /etc/init.d/
if [ "$ifrpm" != "" ];then
	mv /alidata/server/nginx/conf/centos_tomcat7 /etc/init.d/tomcat7
fi
if [ "$ifdpkg" != "" ] || [ "$ifgentoo" != "" ];then
	mv /alidata/server/nginx/conf/ubuntu_tomcat7 /etc/init.d/tomcat7
fi
if [ "$ifsuse" != "" ];then
	mv /alidata/server/nginx/conf/opensuse_tomcat7 /etc/init.d/tomcat7
fi
chmod +x /etc/init.d/nginx
chmod +x /etc/init.d/tomcat7
/etc/init.d/nginx start