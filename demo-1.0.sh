#!/bin/bash

SRC_URI=""                       #下载的包的http路径，此路径规范为OSS路径
PKG_NAME=`basename $SRC_URI`     #下载包的名
DIR=`pwd`                        #安装前当前主目录
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)  #备注：获取CPU核数

#脚本安装前，会统一将之前的安装目录备份
\mv /alidata/softname /alidata/softname.bak.$DATE

#创建软件主目录。软件的主目录，统一在/alidata下，比如tomcat主目录为：/alidata/tomcat。
mkdir -p /alidata/softname

#脚本的编译目录为/alidata/install
mkdir -p /alidata/install
cd /alidata/install

#下载软件安装包
if [ -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

#根据对应的系统安装对应的依赖包，比如安装php，需要对应安装相应的依赖包。此步非必须！
if [ "$(cat /proc/version | grep redhat)" != "" ];then
  #如果在redhat下需要安装依赖包，redhat默认是没有源的，记得下载安装源。
  wget http://sourceforge.net/p/zhuyun/svn/HEAD/tree/linux/redhat/CentOS-Base.repo?format=raw -O /etc/yum.repos.d/CentOS-Base.repo
  yum makecache
  yum -y install packetName
elif [ "$(cat /proc/version | grep centos)" != "" ];then
#如果是64位centos 5 系列的，yum安装会把一大堆32位包安装系统中，在此我们需要过滤掉32位的安装包。
  if [ `uname -m` == "x86_64" ];then
	  if cat /etc/issue |grep "5\." &> /dev/null;then
		 if ! cat /etc/yum.conf |grep "exclude=\*\.i?86" &> /dev/null;then
			sed -i 's;\[main\];\[main\]\nexclude=*.i?86;' /etc/yum.conf
		 fi
		 rpm --import /etc/pki/rpm-gpg/RPM*
	  fi
  fi
  yum makecache
  yum -y install packetName
elif [ "$(cat /proc/version | grep ubuntu)" != "" ];then
  apt-get -y update
  apt-get -y install packetName 
elif [ "$(cat /proc/version | grep -i debian)" != "" ];then
  apt-get -y update
  apt-get -y install packetName
fi

#删除之前安装的编译目录
rm -rf PKG_NAME_DIR
#解压安装包
tar xvf PKG_NAME
#进入安装目录
cd PKG_NAME_DIR

#指定安装目录
./configure --prefix=/alidata/softname
#启用多线程编译/提升编译速度
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make  install      

#添加环境变量（并且避免二次安装导致添加多余环境变量设置）
if ! cat /etc/profile | grep "/alidata/softname/bin" &> /dev/null ;then
   echo "export PATH=\$PATH:/alidata/softname/bin" >> /etc/profile
fi
source /etc/profile

#添加开机自启动，我们统一规范添加到/etc/rc.local
if ! cat /etc/rc.local | grep "/etc/init.d/softname start" &> /dev/null ;then
   echo "/etc/init.d/softname start" >> /etc/rc.local
fi

#返回安装前的当前主目录
cd $DIR

#让环境变量生效
bash