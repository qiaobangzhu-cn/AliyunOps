#!/bin/bash
SRC_URI="http://t-down.oss-cn-hangzhou.aliyuncs.com/apache-tomcat-7.0.54.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/server/tomcat7 /alidata/server/tomcat7.bak.$DATE &> /dev/null
mkdir -p /alidata/server/tomcat7
mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

rm -rf apache-tomcat-7.0.54
tar zxf $PKG_NAME
\mv apache-tomcat-7.0.54/*  /alidata/server/tomcat7
chmod u+x -R /alidata/server/tomcat7/bin
chmod 777 -R /alidata/server/tomcat7/logs
chmod 777 -R /alidata/server/tomcat7/work

#Optimization
sed -i 's/redirectPort="8443"/redirectPort="8443"\n\t\tmaxThreads="2000"\n\t\tminSpareThreads="100"\n\t\tmaxSpareThreads="1000"\n\t\tacceptCount="1000"/' /alidata/server/tomcat7/conf/server.xml
#start tomcat
killall java
rm -rf /alidata/www/default
unset JAVA_HOME
unset JRE_HOME
source /etc/profile
/bin/sh /alidata/server/tomcat7/bin/startup.sh
#add rc.local
sed -i '/startup.sh/d' /etc/rc.local
if ! cat /etc/rc.local | grep "/bin/sh /alidata/server/tomcat" &> /dev/null;then
    echo "/bin/sh  /alidata/server/tomcat7/bin/startup.sh" >> /etc/rc.local
fi
cd $DIR
echo "
Please run Tomcat:
       Command : /bin/sh  /alidata/server/tomcat7/bin/startup.sh 启动成功!
"
ln -s /alidata/server/tomcat7/webapps/ROOT/ /alidata/www/default
