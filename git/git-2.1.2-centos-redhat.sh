#!/bin/bash

SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/git/v2.1.2.tar.gz"                       
PKG_NAME=`basename $SRC_URI`     
DIR=`pwd`                       
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)  

mkdir -p /alidata/git

mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

if [ "$(cat /proc/version | grep redhat)" != "" ];then
  wget http://sourceforge.net/p/zhuyun/svn/HEAD/tree/linux/redhat/CentOS-Base.repo?format=raw -O /etc/yum.repos.d/CentOS-Base.repo
  yum makecache
  yum -y install asciidoc xmlto gettext tk
  yum -y remove git 
elif [ "$(cat /proc/version | grep centos)" != "" ];then
  if [ `uname -m` == "x86_64" ];then
	  if cat /etc/issue |grep "5\." &> /dev/null;then
		 if ! cat /etc/yum.conf |grep "exclude=\*\.i?86" &> /dev/null;then
			sed -i 's;\[main\];\[main\]\nexclude=*.i?86;' /etc/yum.conf
		 fi
		 rpm --import /etc/pki/rpm-gpg/RPM*
	  fi
  fi
  yum makecache
  yum -y install asciidoc xmlto gettext tk
  yum -y remove git
elif [ "$(cat /proc/version | grep ubuntu)" != "" ];then
  apt-get -y update
  apt-get -y install asciidoc xmlto gettext tk
elif [ "$(cat /proc/version | grep -i debian)" != "" ];then
  apt-get -y update
  apt-get -y install asciidoc xmlto gettext tk
fi

tar xvf $PKG_NAME

cd /alidata/install/git-2.1.2/

make configure
./configure --prefix=/alidata/git
make all doc -j$CPU_NUM
make install install-doc install-html

if ! cat /etc/profile | grep "/alidata/git/bin" &> /dev/null ;then
   echo "export PATH=\$PATH:/alidata/git/bin" >> /etc/profile.d/git.sh
fi
source /etc/profile.d/git.sh

cd $DIR

bash
