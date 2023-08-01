#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/jetty/jetty-distribution-8.1.16.v20140903.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

if [ -d /alidata/jetty8 ]; then
mv /alidata/jetty8 /alidata/jetty8.bak.$DATE &> /dev/null
fi

cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

rm -rf jetty-distribution-8.1.16.v20140903
tar zxf $PKG_NAME 
mv jetty-distribution-8.1.16.v20140903  /alidata/jetty8
bash
