#!/bin/bash

SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/java/jdk-6u45-linux-x64.bin"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/server/java1.6 /alidata/server/java1.6.bak.$DATE &> /dev/null
mkdir -p /alidata/server/java1.6
mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi
rm -rf jdk1.6.0_45
chmod u+x $PKG_NAME
./jdk-6u45-linux-x64.bin &> /dev/null
mv jdk1.6.0_45/*  /alidata/server/java1.6

#add PATH
sed -i '/JRE_HOME/d' /etc/profile
sed -i '/JAVA_HOME/d' /etc/profile
if ! cat /etc/profile | grep 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH' &> /dev/null;then
	echo "export JAVA_HOME=/alidata/server/java1.6" >> /etc/profile
	echo "export JRE_HOME=/alidata/server/java1.6/jre" >> /etc/profile
	echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH' >> /etc/profile
	echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
fi

cd $DIR
unset JAVA_HOME
unset JRE_HOME
source /etc/profile
bash
