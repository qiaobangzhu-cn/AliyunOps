#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/java/jdk-7u71-linux-x64.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/server/java1.7 /alidata/server/java1.7.bak.$DATE &> /dev/null
mkdir -p /alidata/server/java1.7 && mkdir -p /alidata/install && cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

tar zxf $PKG_NAME
mv jdk1.7.0_71/*  /alidata/server/java1.7
rm -rf jdk1.7.0_71
#add PATH
sed -i '/JRE_HOME/d' /etc/profile
sed -i '/JAVA_HOME/d' /etc/profile
if ! cat /etc/profile | grep 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH' &> /dev/null;then
	echo "export JAVA_HOME=/alidata/server/java1.7" >> /etc/profile
	echo "export JRE_HOME=/alidata/server/java1.7/jre" >> /etc/profile
	echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH' >> /etc/profile
	echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
fi

cd $DIR
unset JAVA_HOME
unset JRE_HOME
source /etc/profile
bash
