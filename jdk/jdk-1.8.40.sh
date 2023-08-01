#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/jdk/jdk-8u40-linux-x64.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/java1.8 /alidata/java1.8.bak.$DATE &> /dev/null
mkdir -p /alidata/java1.8 
mkdir -p /alidata/install && cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

tar zxf $PKG_NAME
mv jdk1.8.0_40/*  /alidata/java1.8
rm -rf jdk1.8.0_40
#add PATH
sed -i '/JRE_HOME/d' /etc/profile
sed -i '/JAVA_HOME/d' /etc/profile
if ! cat /etc/profile | grep 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH' &> /dev/null;then
	echo "export JAVA_HOME=/alidata/java1.8" >> /etc/profile
	echo "export JRE_HOME=/alidata/java1.8/jre" >> /etc/profile
	echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH' >> /etc/profile
	echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
fi

cd $DIR
source /etc/profile
bash
