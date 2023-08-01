#!/bin/bash

SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/node/node-v0.10.29-linux-x64.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/node /alidata/node.bak.$DATE &> /dev/null

mkdir -p /alidata/node
mkdir -p /alidata/install
cd /alidata/install

if [ ! -f $PKG_NAME ];then
	wget -c $SRC_URI
fi

rm -rf node-v0.10.29-linux-x64
tar xzf $PKG_NAME
\mv node-v0.10.29-linux-x64/* /alidata/node

rm -rf /usr/bin/node
rm -rf /usr/bin/npm
ln -s /alidata/node/bin/node /usr/bin/node 
ln -s /alidata/node/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm

if ! cat /etc/profile | grep "export PATH=\$PATH:/alidata/node/bin" &> /dev/null ;then
    echo "export PATH=\$PATH:/alidata/node/bin" >> /etc/profile
fi
source /etc/profile

cd $DIR
bash