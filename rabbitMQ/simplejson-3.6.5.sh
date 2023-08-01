#/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/rabbitMQ/simplejson-3.6.5.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
mkdir -p /alidata/simplejson
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi
tar zxvf $PKG_NAME

mv simplejson-3.6.5/* /alidata/simplejson
cd /alidata/simplejson
python setup.py install