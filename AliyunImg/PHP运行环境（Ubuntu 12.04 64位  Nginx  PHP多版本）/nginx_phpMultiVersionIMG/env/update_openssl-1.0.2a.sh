#!/bin/bash
if ls /usr/local/ssl > /dev/null ;then
	if openssl version -a |grep "OpenSSL 1.0.2a"  > /dev/null;then 
		exit 0
	fi
fi
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
rm -rf openssl-1.0.2a
if [ ! -f openssl-1.0.2a.tar.gz ];then
	wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/openssl/openssl-1.0.2a.tar.gz
fi
tar zxvf openssl-1.0.2a.tar.gz
cd openssl-1.0.2a
\mv /usr/local/ssl /usr/local/ssl.OFF
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
