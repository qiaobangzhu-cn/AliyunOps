#!/bin/bash

DIR=`pwd`
mkdir -p /alidata/mongodb/data
mkdir -p /alidata/mongodb/log
mkdir -p /alidata/install
cd /alidata/install

if [ ! -s mongodb-org-mongos-2.6.3-1.x86_64.rpm ]; then
  wget -c http://zy-res.oss-cn-hangzhou.aliyuncs.com/server/mongodb-org-mongos-2.6.3-1.x86_64.rpm
  wget -c http://zy-res.oss-cn-hangzhou.aliyuncs.com/server/mongodb-org-2.6.3-1.x86_64.rpm
  wget -c http://zy-res.oss-cn-hangzhou.aliyuncs.com/server/mongodb-org-server-2.6.3-1.x86_64.rpm
  wget -c http://zy-res.oss-cn-hangzhou.aliyuncs.com/server/mongodb-org-shell-2.6.3-1.x86_64.rpm
  wget -c http://zy-res.oss-cn-hangzhou.aliyuncs.com/server/mongodb-org-tools-2.6.3-1.x86_64.rpm
fi
# check mongo installation
rpm -qa | grep mongo > /dev/null
if [ $? = 1 ];then
  # install mongodb
  # rpm -e mongodb-org-mongos-2.6.3-1.x86_64 mongodb-org-2.6.3-1.x86_64 mongodb-org-server-2.6.3-1.x86_64 mongodb-org-shell-2.6.3-1.x86_64 mongodb-org-tools-2.6.3-1.x86_64
  rpm -ivh mongodb-org-mongos-2.6.3-1.x86_64.rpm mongodb-org-2.6.3-1.x86_64.rpm mongodb-org-server-2.6.3-1.x86_64.rpm mongodb-org-shell-2.6.3-1.x86_64.rpm mongodb-org-tools-2.6.3-1.x86_64.rpm
else
  echo "mongodb already install, please clean the old version first.";exit 1
fi

# config mongodb data path
sed -i 's/dbpath.*/dbpath=\/alidata\/mongodb\/data/g' /etc/mongod.conf
sed -i 's/logpath.*/logpath=\/alidata\/mongodb\/log\/mongod.log/g' /etc/mongod.conf
#sed -i 's/bind_ip.*/bind_ip=0.0.0.0/g' /etc/mongod.conf
echo "master=true" >> /etc/mongod.conf

chown mongod.mongod /alidata/mongodb/ -R
chown mongod.mongod /alidata/mongodb/log -R

# start mongodb
/etc/init.d/mongod start
cd $DIR