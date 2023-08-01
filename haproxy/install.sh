#!/bin/bash

SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/haproxy/haproxy-1.5.9.tar.gz"    #下载的包的http路径，此路径规范为OSS路径
PKG_NAME=`basename $SRC_URI`     #下载包的名
DIR=`pwd`                        #安装前当前主目录
DATE=`date +%Y%m%d%H%M%S`

#脚本安装前，会统一将之前的安装目录备份
\mv /alidata/softname /alidata/softname.bak.$DATE

#创建软件主目录。软件的主目录，统一在/alidata下，比如tomcat主目录为：/alidata/tomcat。
mkdir -p /alidata/haproxy
mkdir -p /alidata/haproxy/logs

#脚本的编译目录为/alidata/install
mkdir -p /alidata/install
cd /alidata/install

#下载软件安装包
if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

#安装haproxy过程
tar -zxvf $PKG_NAME
cd haproxy-1.5.9
make TARGET=linux26 PREFIX=/alidata/haproxy
make install PREFIX=/alidata/haproxy
cp examples/haproxy.cfg /alidata/haproxy/
cd /alidata/haproxy/
cp haproxy.cfg haproxy.cfg.bak
cp $DIR/haproxy.cfg /alidata/haproxy/
cp $DIR/haproxy /etc/rc.d/init.d/
chmod  +x /etc/rc.d/init.d/haproxy

#安装nginx
bash $DIR/nginx-1.6.0.sh

#/etc/init.d/haproxy start

#添加开机自启动，我们统一规范添加到/etc/rc.local
#if ! cat /etc/rc.local | grep "/etc/init.d/haproxy  start" &> /dev/null ;then
#   echo "/etc/init.d/haproxy  start" >> /etc/rc.local
#fi

#返回安装前的当前主目录
#cd $DIR

