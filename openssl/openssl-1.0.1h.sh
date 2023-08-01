#!/bin/bash
SRC_URI="http://t-down.oss-cn-hangzhou.aliyuncs.com/openssl-1.0.1h.tar.gz"
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

mkdir -p /alidata/install
cd /alidata/install
####---- install dependencies ----begin####
if [ "$(cat /proc/version | grep redhat)" != "" ];then
  wget http://git.jiagouyun.com/operation/operation/raw/master/linux/redhat/CentOS-Base.repo -O /etc/yum.repos.d/CentOS-Base.repo
  yum makecache
  yum install zlib -y
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
  yum install zlib -y
elif [ "$(cat /proc/version | grep ubuntu)" != "" ];then
  sed -i 's/exit 0//' /etc/rc.local
elif [ "$(cat /proc/version | grep -i debian)" != "" ];then
  echo ""
fi
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
