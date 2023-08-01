#!/bin/bash

SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/glassfish/ogs-3.1.2.2.zip"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

if ! java -version &> /dev/null;then 
  echo "please install java !"
  exit
fi

\mv /alidata/glassfish /alidata/glassfish.bak.$DATE &> /dev/null
mkdir -p /alidata/glassfish
mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi
rm -rf glassfish3
unzip  ogs-3.1.2.2.zip
mv glassfish3/*  /alidata/glassfish

#add PATH
if ! cat /etc/profile | grep 'export PATH=$PATH:/alidata/glassfish/bin' &> /dev/null;then
	echo 'export PATH=$PATH:/alidata/glassfish/bin' >> /etc/profile
fi

cd /alidata/glassfish/bin
./asadmin start-domain domain1
echo "./asadmin start-domain domain1    start----glassfish"
echo "./asadmin start-domain domain1    stop-----glassfish"

cd $DIR
source /etc/profile
bash