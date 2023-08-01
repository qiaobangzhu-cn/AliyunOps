#!/bin/bash
SRC_URI="http://t-down.oss-cn-hangzhou.aliyuncs.com/jboss-as-7.1.1.Final.zip" 
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/jboss-as-7.1.1.Final /alidata/jboss-as-7.1.1.Final.$DATE

mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
    wget -c $SRC_URI
fi

unzip jboss-as-7.1.1.Final.zip

mv jboss-as-7.1.1.Final /alidata

cd $DIR
bash
