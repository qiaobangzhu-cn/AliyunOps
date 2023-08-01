#!/bin/bash

SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/elasticsearch/elasticsearch-1.6.0.tar.gz"                       
PKG_NAME=`basename $SRC_URI`     
DIR=`pwd`                        
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l) 

\mv /alidata/elasticsearch /alidata/elasticsearch.bak.$DATE

mkdir -p /alidata/elasticsearch
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

source /etc/profile
cd /alidata/install
tar xvf $PKG_NAME
mv elasticsearch-1.6.0/* /alidata/elasticsearch/
rm -rf elasticsearch-1.6.0


#start es
/alidata/elasticsearch/bin/elasticsearch &

#/etc/rc.local
if ! cat /etc/rc.local | grep "./alidata/elasticsearch/bin/elasticsearch" &> /dev/null ;then
   echo "bash /alidata/elasticsearch/bin/elasticsearch" >> /etc/rc.local
fi

cd $DIR
bash
