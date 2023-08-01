#!/bin/bash
groupadd www &> /dev/null
useradd -g www -M -d /alidata/www -s /sbin/nologin www &> /dev/null

SRC_URI="http://t-down.oss-cn-hangzhou.aliyuncs.com/apache-tomcat-7.0.54.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/tomcat /alidata/tomcat.bak.$DATE &> /dev/null
mkdir -p /alidata/tomcat
mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

rm -rf apache-tomcat-7.0.54
tar zxvf $PKG_NAME
\mv apache-tomcat-7.0.54/*  /alidata/tomcat
chmod u+x -R /alidata/tomcat/bin
chown www:www -R /alidata/tomcat
chmod 777 -R /alidata/tomcat/logs
chmod 777 -R /alidata/tomcat/work

#Optimization
sed -i 's/redirectPort="8443"/redirectPort="8443"\n\t\tmaxThreads="2000"\n\t\tminSpareThreads="100"\n\t\tmaxSpareThreads="1000"\n\t\tacceptCount="1000"/' /alidata/tomcat/conf/server.xml
#start tomcat
su -s /bin/sh -c /alidata/tomcat/bin/startup.sh www
#add rc.local
if ! cat /etc/rc.local | grep "su -s /bin/sh -c /alidata/tomcat/bin/startup.sh www" &> /dev/null;then
    echo "su -s /bin/sh -c /alidata/tomcat/bin/startup.sh www" >> /etc/rc.local
fi
cd $DIR
echo "
Please run Tomcat to not root users:
       Command : su -s /bin/sh -c /alidata/tomcat/bin/startup.sh www
"
