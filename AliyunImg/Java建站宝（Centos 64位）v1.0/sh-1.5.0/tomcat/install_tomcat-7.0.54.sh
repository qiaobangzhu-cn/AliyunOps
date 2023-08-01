#!/bin/bash
#userdel tomcat7
#groupadd tomcat7
#useradd -g tomcat7 -M -s /usr/sbin/nologin tomcat7 &> /dev/null
rm -rf apache-tomcat-7.0.54
if [ ! -f apache-tomcat-7.0.54.tar.gz ];then
  wget http://t-down.oss-cn-hangzhou.aliyuncs.com/apache-tomcat-7.0.54.tar.gz
fi
tar zxvf apache-tomcat-7.0.54.tar.gz
mv apache-tomcat-7.0.54/*  /alidata/server/tomcat7
chmod u+x -R /alidata/server/tomcat7/bin
chown www:www -R /alidata/server/tomcat7/
chmod 777 -R /alidata/server/tomcat7/logs
chmod 777 -R /alidata/server/tomcat7/work
export JAVA_HOME=/alidata/server/java
/etc/init.d/tomcat7 start