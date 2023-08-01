#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/perl/perl-5.20.1.tar.gz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
mkdir -p /alidata/perl
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi


tar zxvf $PKG_NAME
cd perl-5.20.1
./configure.gnu --prefix=/alidata/perl
make
make test &&make install

mv /usr/bin/perl /usr/bin/perl.bak
ln -s /alidata/perl/bin/perl  /usr/bin/perl

echo "perl version:"
/alidata/ruby/bin/perl -v
cd $DIR
bash
