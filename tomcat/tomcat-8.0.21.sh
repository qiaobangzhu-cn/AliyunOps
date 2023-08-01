#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/tomcat/apache-tomcat-8.0.21.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/tomcat8 /alidata/tomcat8.bak.$DATE &> /dev/null
mkdir -p /alidata/tomcat8
mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

rm -rf apache-tomcat-8.0.21
tar zxf $PKG_NAME
\mv apache-tomcat-8.0.21/*  /alidata/tomcat8/
chmod u+x -R /alidata/tomcat8/bin
chmod 777 -R /alidata/tomcat8/logs
chmod 777 -R /alidata/tomcat8/work

#Optimization
sed -i 's/redirectPort="8443"/redirectPort="8443"\n\t\tmaxThreads="2000"\n\t\tminSpareThreads="100"\n\t\tmaxSpareThreads="1000"\n\t\tacceptCount="1000"/' /alidata/tomcat8/conf/server.xml
#start tomcat
killall java
/bin/sh /alidata/tomcat8/bin/startup.sh
#add rc.local
sed -i '/startup.sh/d' /etc/rc.local
if ! cat /etc/rc.local | grep "/bin/sh  /alidata/tomcat" &> /dev/null;then
    echo "/bin/sh  /alidata/tomcat8/bin/startup.sh" >> /etc/rc.local
fi
cd $DIR
echo "
Please run Tomcat with it:
       Command : /bin/sh  /alidata/tomcat8/bin/startup.sh
"
