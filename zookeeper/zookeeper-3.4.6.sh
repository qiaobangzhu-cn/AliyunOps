#!/bin/bash

SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/zookeeper/zookeeper-3.4.6.tar.gz"                       
PKG_NAME=`basename $SRC_URI`     
DIR=`pwd`                        
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l) 

\mv /alidata/zookeeper /alidata/zookeeper.bak.$DATE

mkdir -p /alidata/zookeeper
mkdir -p /alidata/zoodata
mkdir -p /alidata/install

cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

#install java
which java
if [ "$?" -ne "0" ];then
wget http://git.jiagouyun.com/operation/operation/raw/master/jdk/jdk-1.7.71.sh -O /alidata/install/jdk-1.7.71.sh
chmod +x /alidata/install/jdk-1.7.71.sh
sed -i '$d' jdk-1.7.71.sh
cd /alidata/install
./jdk-1.7.71.sh
fi

cd /alidata/install
tar xvf $PKG_NAME
mv zookeeper-3.4.6/* /alidata/zookeeper/
rm -rf zookeeper-3.4.6/
cp -a /alidata/zookeeper/conf/zoo_sample.cfg /alidata/zookeeper/conf/zoo.cfg
sed -i 's#dataDir=/tmp/zookeeper#dataDir=/alidata/zoodata#g' /alidata/zookeeper/conf/zoo.cfg

#start zookeeper
#. /alidata/zookeeper/bin/zkServer.sh start

#/etc/rc.local
#if ! cat /etc/rc.local | grep "/alidata/zookeeper/bin/zkServer.sh start" &> /dev/null ;then
#   echo "bash /alidata/zookeeper/bin/zkServer.sh start" >> /etc/rc.local
#fi

#cd $DIR
#bash