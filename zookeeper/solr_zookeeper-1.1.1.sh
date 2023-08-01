#!/bin/bash
JDKSRC_URI="http://t-down.oss-cn-hangzhou.aliyuncs.com/jdk-7u55-linux-x64.tar.gz"
ZOOKSRC_URI="http://t-down.oss.aliyuncs.com/zookeeper-3.4.7.tar.gz"
SOLRSRC_URI="http://t-down.oss.aliyuncs.com/solr-5.4.0.tgz"

JDKPKG_NAME=`basename $JDKSRC_URI`
ZOOKPKG_NAME=`basename $ZOOKSRC_URI`
SOLRPKG_NAME=`basename $SOLRSRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/jdk1.7.0_55 /alidata/jdk1.7.0_55.bak.$DATE
\mv /alidata/jdk /alidata/jdk.bak.$DATE
\mv /alidata/zookeeper-3.4.7 /alidata/zookeeper-3.4.7.bak.$DATE
\mv /alidata/zookeeper /alidata/zookeeper.bak.$DATE

if [ -s $JDKPKG_NAME ]; then
    wget -c $JDKSRC_URI
fi

if [ -s $ZOOKPKG_NAME ]; then
    wget -c $ZOOKSRC_URI
fi

if [ -s $SOLRPKG_NAME ]; then
    wget -c $SOLRSRC_URI
fi

test -f /alidata/ || mkdir /alidata/
tar zxvf jdk-7u55-linux-x64.tar.gz -C /alidata/
ln -s /alidata/jdk1.7.0_55/ /alidata/jdk

if ! cat /etc/profile | grep "/alidata/jdk" &> /dev/null ;then
cat >> /etc/profile << "EOF"
export JAVA_HOME=/alidata/jdk
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
export CLASSPATH=.:/alidata/jdk/lib:/alidata/jdk/jre/lib:$CLASSPATH
EOF
fi
source /etc/profile

tar zxvf zookeeper-3.4.7.tar.gz -C /alidata/
ln -s /alidata/zookeeper-3.4.7/ /alidata/zookeeper
/alidata/zookeeper/bin/zkServer.sh start

tar zxvf solr-5.4.0.tgz solr-5.4.0/bin/install_solr_service.sh --strip-components=2
./install_solr_service.sh solr-5.4.0.tgz -i /alidata/ -d /alidata/var/solr -u solr -s solr -p 8265
\mv /etc/default/solr.in.sh /alidata/var/solr/solr.in.sh
sed -i 's/#ZK_HOST.*/ZK_HOST="127.0.0.1:3762"/' /alidata/var/solr/solr.in.sh
sed -i 's#/etc/default/solr.in.sh#/alidata/var/solr/solr.in.sh#' /etc/init.d/solr
service solr start
bash