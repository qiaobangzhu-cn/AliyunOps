#!/bin/bash

SRC_URI_RPM="http://zy-res.oss-cn-hangzhou.aliyuncs.com/git/gitlab-ce-8.13.3-ce.0.el6.x86_64.rpm"
SRC_URI_DEB="http://zy-res.oss-cn-hangzhou.aliyuncs.com/git/gitlab-ce_8.13.3-ce.0_amd64.deb"
PKG_NAME_RPM=`basename $SRC_URI_RPM`
PKG_NAME_DEB=`basename $SRC_URI_DEB`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`



mkdir -p /alidata/install
cd /alidata/install



##install gitlab
if [ -f /etc/redhat-release ]
        then

        if [ ! -s `basename $SRC_URI_RPM` ]; then
          wget -c $SRC_URI_RPM
        fi
                yum install -y curl openssh-server openssh-clients postfix cronie
                service postfix start
                chkconfig postfix on
                lokkit -s http -s ssh
                rpm -ivh $PKG_NAME_RPM
else

                if [ ! -s `basename $SRC_URI_DEB` ]; then
                  wget -c $SRC_URI_DEB
                fi
                apt-get update
                apt-get install -y curl gawk openssh-server postfix ca-certificates
                dpkg -i $PKG_NAME_DEB
fi




gitlab-ctl reconfigure

##configure gitlab
#gitlab-ctl stop unicorn
#gitlab-ctl stop sidekiq

##rc.local
if ! grep "gitlab-ctl start" /etc/rc.local;then
echo "gitlab-ctl start" >> /etc/rc.local
fi