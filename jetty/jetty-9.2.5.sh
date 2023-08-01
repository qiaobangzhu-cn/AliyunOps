#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/jetty/jetty-distribution-9.2.5.v20141112.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

if [ -d /alidata/jetty9 ]; then
mv /alidata/jetty9 /alidata/jetty9.bak.$DATE &> /dev/null
fi

cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

rm -rf jetty-distribution-9.2.5.v20141112
tar zxf $PKG_NAME 
mv jetty-distribution-9.2.5.v20141112  /alidata/jetty9
cd /alidata/jetty9 && cp -rf demo-base/webapps/ROOT webapps/
bash
