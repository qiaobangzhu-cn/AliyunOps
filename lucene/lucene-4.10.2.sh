#/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/lucene/lucene-4.10.2.tar"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/lucene /alidata/lucene.bak.$DATE

mkdir -p /alidata/lucene
mkdir -p /alidata/install

#install java
which java
if [ "$?" -ne "0" ];then
wget http://git.jiagouyun.com/operation/operation/raw/master/jdk/jdk-1.7.71.sh -O /alidata/install/jdk-1.7.71.sh
chmod +x /alidata/install/jdk-1.7.71.sh
cd /alidata/install
sed -i '$d' jdk-1.7.71.sh
./jdk-1.7.71.sh
fi

#install tomcat
wget http://git.jiagouyun.com/operation/operation/raw/master/tomcat/tomcat-7.0.54.sh -O /alidata/install/tomcat-7.0.54.sh
chmod +x /alidata/install/tomcat-7.0.54.sh
cd /alidata/install
./tomcat-7.0.54.sh

cd /alidata/install
if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi
rm -rf lucene-4.10.2
tar zxvf $PKG_NAME
\mv lucene-4.10.2/*  /alidata/lucene
echo "export LUCENE_HOME=/alidata/lucene" >> /etc/profile
echo 'export CLASSPATH=.:$LUCENE_HOME/analysis/common/lucene-analyzers-common-4.10.2.jar:$LUCENE_HOME/core/lucene-core-4.10.2.jar:$LUCENE_HOME/demo/lucene-demo-4.10.2.jar:$LUCENE_HOME/queryparser/lucene-queryparser-4.10.2.jar:$CLASSPATH' >> /etc/profile
source /etc/profile
cp /alidata/lucene/demo/lucene-xml-query-demo.war /alidata/tomcat/webapps
sleep 15
cp /alidata/lucene/analysis/common/lucene-analyzers-common-4.10.2.jar /alidata/tomcat/webapps/lucene-xml-query-demo/WEB-INF/lib/
cp /alidata/lucene/sandbox/lucene-sandbox-4.10.2.jar /alidata/tomcat/webapps/lucene-xml-query-demo/WEB-INF/lib/
sed -i 's/org.apache.lucene.xmlparser.webdemo.FormBasedXmlQueryDemo/org.apache.lucene.demo.xmlparser.FormBasedXmlQueryDemo/' /alidata/tomcat/webapps/lucene-xml-query-demo/WEB-INF/web.xml

killall java
su -s /bin/sh -c /alidata/tomcat/bin/startup.sh www
