#!/bin/bash

#for ubuntu 
#mongo 2.6.5

DIR=`pwd`
mkdir -p /alidata/mongodb/data
mkdir -p /alidata/mongodb/log
mkdir -p /alidata/install
cd /alidata/install

if [ "$(cat /proc/version |grep -iE 'ubuntu|debian')" == "" ];then
   echo "system is not ubuntu or debian"
fi

if [ ! -s mongodb-org-mongos_2.6.5_amd64.deb ]; then
	wget -c http://zy-res.oss-cn-hangzhou.aliyuncs.com/mongodb/ubuntu/mongodb-org-mongos_2.6.5_amd64.deb
	wget -c http://zy-res.oss-cn-hangzhou.aliyuncs.com/mongodb/ubuntu/mongodb-org_2.6.5_amd64.deb
	wget -c http://zy-res.oss-cn-hangzhou.aliyuncs.com/mongodb/ubuntu/mongodb-org-server_2.6.5_amd64.deb
	wget -c http://zy-res.oss-cn-hangzhou.aliyuncs.com/mongodb/ubuntu/mongodb-org-shell_2.6.5_amd64.deb
	wget -c http://zy-res.oss-cn-hangzhou.aliyuncs.com/mongodb/ubuntu/mongodb-org-tools_2.6.5_amd64.deb
fi
dpkg -i mongodb-org*
/etc/init.d/mongod stop

