#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/java/jdk-7u71-linux-x64.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/java /alidata/java.bak.$DATE &> /dev/null
mkdir -p /alidata/java

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

mv jdk1.7.0_71 jdk1.7.0_71_bak.$DATE &> /dev/null

tar zxvf $PKG_NAME
mv jdk1.7.0_71/*  /alidata/java
rm -rf jdk1.7.0_71
#add PATH
if ! cat /etc/profile | grep 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH' &> /dev/null;then
	echo "export JAVA_HOME=/alidata/java" >> /etc/profile
	echo "export JRE_HOME=/alidata/java/jre" >> /etc/profile
	echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH' >> /etc/profile
	echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
fi

cd $DIR
source /etc/profile
bash
