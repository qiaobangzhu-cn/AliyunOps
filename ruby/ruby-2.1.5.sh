#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/ruby/ruby-2.1.5.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
mkdir -p /alidata/ruby
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

tar zxvf $PKG_NAME
cd ruby-2.1.5
./configure --prefix=/alidata/ruby
make && make install
\mv /usr/bin/ruby /usr/bin/ruby.bak &> /dev/null
ln -s /alidata/ruby/bin/ruby /usr/bin/ruby
echo "ruby version:"
/alidata/ruby/bin/ruby -v
cd $DIR
bash
