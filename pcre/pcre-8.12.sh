#!/bin/sh
SRC_URI="http://oss.aliyuncs.com/aliyunecs/onekey/pcre-8.12.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

rm -rf pcre-8.12
tar zxvf pcre-8.12.tar.gz
cd pcre-8.12
./configure
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
cd $DIR

#load /usr/local/lib .so
touch /etc/ld.so.conf.d/usrlib.conf
if ! cat /etc/ld.so.conf.d/usrlib.conf | grep '/usr/local/lib' &> /dev/null;then
echo "/usr/local/lib" > /etc/ld.so.conf.d/usrlib.conf
fi
/sbin/ldconfig