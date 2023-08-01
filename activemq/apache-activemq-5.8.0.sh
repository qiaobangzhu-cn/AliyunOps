#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/activeMQ/apache-activemq-5.8.0-bin.tar.gz"
PREFIX=/alidata/activemq
PKG_NAME='basename $SRC_URI'
DIR='pwd'
DATE='date +%Y%m%d%H%M%S'
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
\mv $PREFIX ${PREFIX}.bak.$DATE &> /dev/null

mkdir -p $PREFIX
mkdir -p /alidata/install
cd /alidata/install
if [ ! -s apache-activemq-5.8.0-bin.tar.gz ]; then
  wget -c $SRC_URI
fi
tar -xzvf apache-activemq-5.8.0-bin.tar.gz -C /alidata/
mv /alidata/apache-activemq-5.8.0/* /alidata/activemq
rm -rf /alidata/apache-activemq-5.8.0
if ! cat /etc/rc.local | grep '/alidata/activemq/bin/activemq start' &> /dev/null;then
        echo '/alidata/activemq/bin/activemq start' >> /etc/rc.local
fi
/alidata/activemq/bin/activemq start

if free -g = 0 &> /dev/null;then
  echo "Please increase the system memory OR vim /alidata/activemq/bin/activemq----->'#Set jvm memory configuration' about  ACTIVEMQ_OPTS_MEMORY="-Xms1G -Xmx1G""
fi
