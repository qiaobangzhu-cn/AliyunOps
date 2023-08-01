#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/erlang/otp_src_17.3.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
mkdir -p /alidata/erlang
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

yum makecache
yum -y install unixODBC unixODBC-devel gcc gcc-c++ /usr/bin/wx-config  *OpenGL fop libxslt ncurses-devel openssl openssl-devel 
yum -y update bash

tar zxvf $PKG_NAME
cd otp_src_17.3
./configure --prefix=/alidata/erlang --with-opengl --without-javac
make  && make install
\mv /usr/bin/erl /usr/bin/erl.bak &> /dev/null
ln -s /alidata/erlang/bin/erl /usr/bin/erl
cd $DIR
bash
