#!/bin/bash
rm -rf jdk1.7.0_55
if [ ! -f jdk-7u55-linux-x64.tar.gz ];then
  wget http://t-down.oss-cn-hangzhou.aliyuncs.com/jdk-7u55-linux-x64.tar.gz
fi

tar zxvf jdk-7u55-linux-x64.tar.gz
mv jdk1.7.0_55/*  /alidata/server/java

