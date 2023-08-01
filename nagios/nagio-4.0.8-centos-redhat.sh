#!/bin/bash
SRC_URI1="http://zy-res.oss-cn-hangzhou.aliyuncs.com/nagios/nagios-4.0.8.tar.gz"
SRC_URI2="http://zy-res.oss-cn-hangzhou.aliyuncs.com/nagios/nagios-plugins-2.0.3.tar.gz"   
PKG_NAME1=`basename $SRC_URI1`    
PKG_NAME2=`basename $SRC_URI2`
DIR=`pwd`                        
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l) 

\mv /alidata/nagios /alidata/nagios.bak.$DATE
mkdir -p /alidata/nagios

mkdir -p /alidata/install
cd /alidata/install

if [ ! -s $PKG_NAME1 ]; then
  wget -c $SRC_URI1
fi

if [ ! -s $PKG_NAME2 ]; then
  wget -c $SRC_URI2
fi

if [ "$(cat /proc/version | grep redhat)" != "" ];then
  wget http://git.jiagouyun.com/operation/operation/raw/master/linux/redhat/CentOS-Base.repo -O /etc/yum.repos.d/CentOS-Base.repo
  yum makecache
  yum install -y wget httpd php gcc glibc glibc-common gd gd-devel make net-snmp
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
  yum install -y wget httpd php gcc glibc glibc-common gd gd-devel make net-snmp
  build_centos_redhat
fi

  useradd nagios
  groupadd nagcmd
  usermod -a -G nagcmd nagios
  tar zxvf $PKG_NAME1
  tar zxvf $PKG_NAME2
  cd nagios-4.0.8/
  ./configure --with-command-group=nagcmd --prefix=/alidata/nagios
  make all
  make install
  make install-init
  make install-config
  make install-commandmode
  make install-webconf
  cp -R contrib/eventhandlers/ /alidata/nagios/libexec/
  chown -R nagios:nagios /alidata/nagios/libexec/eventhandlers
  /alidata/nagios/bin/nagios -v /alidata/nagios/etc/nagios.cfg
  /etc/init.d/nagios start
  /etc/init.d/httpd start
#  htpasswd –c /usr/local/nagios/etc/htpasswd.users nagiosadmin
  touch 644 /alidata/nagios/etc/htpasswd.users
  htpasswd -b /alidata/nagios/etc/htpasswd.users nagios nagios
  cd /alidata/install/nagios-plugins-2.0.3
  ./configure --with-nagios-user=nagios --with-nagios-group=nagios --prefix=/alidata/nagios/
 if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
 else
    make
 fi
  make  install
  chkconfig --add nagios
  chkconfig --level 35 nagios on
  chkconfig --add httpd
  chkconfig --level 35 httpd on
cd $DIR
bash
