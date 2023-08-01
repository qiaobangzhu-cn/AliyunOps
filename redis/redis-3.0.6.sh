#!/bin/bash

SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/redis/redis-3.0.6.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`



mkdir -p /alidata/install
cd /alidata/install

if [ ! -s `basename $SRC_URI` ]; then
  wget -c $SRC_URI
fi


##install redis
if [ -f /etc/redhat-release ]
        then
                yum install -y tcl
        else
                apt-get update
                apt-get install -y tcl
        fi
rm -rf redis-3.0.6
tar xvf $PKG_NAME
cd redis-3.0.6
make
make install


if ! cat /etc/profile | grep "/usr/local/bin" &> /dev/null;then
echo "export PATH=/usr/local/bin:/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin" >> /etc/profile
. /etc/profile
fi

if ! cat /etc/sysctl.conf | grep "vm.overcommit_memory = 1" &> /dev/null;then
        echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
fi
sysctl -p 2>&1 /dev/null

cd utils && ./install_server.sh


cd $DIR