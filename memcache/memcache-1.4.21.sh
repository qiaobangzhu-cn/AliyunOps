#!/bin/bash

SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/memcache/memcached-1.4.21.tar.gz"
LIBEVENT_URL="http://zy-res.oss-cn-hangzhou.aliyuncs.com/libevent/libevent-2.0.21-stable.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

\mv /alidata/memcached /alidata/memcached.bak.$DATE &> /dev/null

mkdir -p /alidata/memcached
mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

install_libevent(){
  if [ ! -s libevent-2.0.21-stable.tar.gz ]; then
     wget -c $LIBEVENT_URL
  fi
  rm -rf libevent-2.0.21-stable
  tar vxf libevent-2.0.21-stable.tar.gz
  cd libevent-2.0.21-stable
  ./configure
  if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
  else
	make
  fi
  make  install
}

useradd memcached -s /sbin/nologin
if [ "$(cat /proc/version | grep redhat)" != "" ];then
  wget http://sourceforge.net/p/zhuyun/svn/HEAD/tree/linux/redhat/CentOS-Base.repo?format=raw -O /etc/yum.repos.d/CentOS-Base.repo
  yum makecache
  yum -y install libevent-devel
elif [ "$(cat /proc/version | grep centos)" != "" ];then
  if [ `uname -m` == "x86_64" ];then
	  if cat /etc/issue |grep "5\." &> /dev/null;then
		 if ! cat /etc/yum.conf |grep "exclude=\*\.i?86" &> /dev/null;then
			sed -i 's;\[main\];\[main\]\nexclude=*.i?86;' /etc/yum.conf
		 fi
		 rpm --import /etc/pki/rpm-gpg/RPM*
	  fi
  fi
  yum makecache
  yum -y install libevent-devel
elif [ "$(cat /proc/version | grep ubuntu)" != "" ];then
  #apt-get -y update
  #apt-get -y install libevent-devel   ###can't apt-get install 
  install_libevent
elif [ "$(cat /proc/version | grep -i debian)" != "" ];then
  #apt-get -y update
  #apt-get -y install libevent-devel ###can't apt-get install 
  install_libevent
fi

cd /alidata/install
rm -rf memcached-1.4.21
tar xvf $PKG_NAME
cd memcached-1.4.21

./configure --prefix=/alidata/memcached
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make  install      

if ! cat /etc/profile | grep "/alidata/memcached/bin" &> /dev/null ;then
   echo "export PATH=\$PATH:/alidata/memcached/bin" >> /etc/profile
fi
source /etc/profile

if ! cat /etc/rc.local | grep "memcached -d -p" &> /dev/null ;then
   echo "/alidata/memcached/bin/memcached -d -p 11211 -u memcached  -m 64 -c 60000 -P /alidata/memcached/memcached.pid -l 0.0.0.0" >> /etc/rc.local
fi
/alidata/memcached/bin/memcached -d -p 11211 -u memcached  -m 64 -c 60000 -P /alidata/memcached/memcached.pid -l 0.0.0.0
cd $DIR
bash