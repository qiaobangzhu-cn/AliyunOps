#!/bin/bash

SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/mongodb/mongodb-linux-x86_64-2.6.3.tgz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/mongodb /alidata/mongodb.bak.$DATE &> /dev/null
mkdir -p /alidata/mongodb
mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

rm -rf mongodb-linux-x86_64-2.6.3/
tar vxf mongodb-linux-x86_64-2.6.3.tgz
mv mongodb-linux-x86_64-2.6.3/* /alidata/mongodb

#add PATH
if ! cat /etc/profile | grep 'export PATH=$PATH:/alidata/mongodb/bin' &> /dev/null;then
	echo 'export PATH=$PATH:/alidata/mongodb/bin' >> /etc/profile
fi

cd $DIR
source /etc/profile
bash