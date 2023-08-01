#!/bin/bash
SRC_URI="http://t-down.oss-cn-hangzhou.aliyuncs.com/openssl-1.0.1h.tar.gz"
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

mkdir -p /alidata/install
cd /alidata/install
####---- install dependencies ----begin####

yum makecache
yum install zlib -y

####---- install dependencies ----end####

if ls /usr/local/ssl > /dev/null ;then
	if openssl version -a |grep "OpenSSL 1.0.1h"  > /dev/null;then 
		exit 0
	fi
fi
rm -rf openssl-1.0.1h
if [ ! -s openssl-1.0.1h.tar.gz ]; then
  wget -c $SRC_URI
fi
tar zxvf openssl-1.0.1h.tar.gz
\mv /usr/local/ssl /usr/local/ssl.OFF
cd openssl-1.0.1h
./config shared zlib
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
\mv /usr/bin/openssl /usr/bin/openssl.OFF
\mv /usr/include/openssl /usr/include/openssl.OFF
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/ssl/include/openssl /usr/include/openssl
if ! cat /etc/ld.so.conf| grep "/usr/local/ssl/lib" >> /dev/null;then
	echo "/usr/local/ssl/lib" >> /etc/ld.so.conf
fi
ldconfig -v
openssl version -a
cd $DIR
