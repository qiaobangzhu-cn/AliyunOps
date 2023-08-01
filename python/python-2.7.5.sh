#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/python/Python-2.7.5.tgz"
PKG_NAME=`basename $SRC_URI`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

\mv /alidata/python /alidata/python.bak.$DATE &> /dev/null
mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

rm -rf Python-2.7.5
tar xvf $PKG_NAME
cd Python-2.7.5

./configure --prefix=/alidata/python
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make  install

\mv /usr/bin/python /usr/bin/python.bak &> /dev/null
echo "python version:"
/alidata/python/bin/python -V
#change yum
sed -i '1c #!/usr/bin/python.bak' /usr/bin/yum
#add PATH
if ! cat /etc/profile | grep "/alidata/python/bin" &> /dev/null ;then
   echo "export PATH=\$PATH:/alidata/python/bin" >> /etc/profile
fi
source /etc/profile
cd $DIR
bash