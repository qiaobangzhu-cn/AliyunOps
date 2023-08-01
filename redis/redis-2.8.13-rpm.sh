#!/bin/bash

SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/server/redis-2.8.13-1.el6.remi.x86_64.rpm"
DIR=`pwd`

mkdir -p /alidata/redis
mkdir -p /alidata/redis/log
mkdir -p /alidata/install
cd /alidata/install

if [ ! -s `basename $SRC_URI` ]; then
  wget -c $SRC_URI
fi
# check redis installation
rpm -qa | grep redis > /dev/null
if [ $? = 1 ];then
  # install redis
  yum install jemalloc.x86_64 -y
  rpm -ivh redis-2.8.13-1.el6.remi.x86_64.rpm
else
  echo "redis already install, please clean the old version first.";exit 1
fi

# config redis data path
sed -i 's/dir \/var\/lib\/redis\//dir \/alidata\/redis\//g' /etc/redis.conf
sed -i 's/logfile.*/logfile \/alidata\/redis\/log\/redis.log/g' /etc/redis.conf
if ! cat /etc/sysctl.conf | grep "vm.overcommit_memory = 1" &> /dev/null;then
	echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
fi
sysctl -p 2>&1 /dev/null

chown redis.redis /alidata/redis/ -R
chown redis.redis /alidata/redis/log/ -R

#add rc.local
if ! cat /etc/rc.local | grep "/etc/init.d/redis start" &> /dev/null;then
    echo "/etc/init.d/redis start" >> /etc/rc.local
fi
/etc/init.d/redis start

cd $DIR
