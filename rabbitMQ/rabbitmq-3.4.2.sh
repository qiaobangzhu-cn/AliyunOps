#/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/rabbitMQ/rabbitmq-server-generic-unix-3.4.2.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

mkdir -p /alidata/rabbitmq
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

tar zxvf $PKG_NAME

mv rabbitmq_server-3.4.2/* /alidata/rabbitmq/
/alidata/rabbitmq/sbin/rabbitmq-server -detached

if ! cat /etc/rc.d/rc.local | grep '/alidata/rabbitmq/sbin/rabbitmq-server' &> /dev/null;then
echo "/alidata/rabbitmq/sbin/rabbitmq-server -detached" >> /etc/rc.d/rc.local
fi
