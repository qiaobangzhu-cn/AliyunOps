#!/bin/bash

SRC_URI1="http://zy-res.oss-cn-hangzhou.aliyuncs.com/cacti/cacti-0.8.8b.tar.gz"
SRC_URI2="http://zy-res.oss-cn-hangzhou.aliyuncs.com/cacti/rrdtool-1.4.9.tar.tar"
PKG_NAME1=`basename $SRC_URI1`
PKG_NAME2=`basename $SRC_URI2`
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

mkdir -p /alidata/rrdtool

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
  yum -y install net-snmp net-snmp-devel net-snmp-libs net-snmp-utils cairo-devel libxml2-devel pango-devel pango libpng-devel freetype freetype-devel libart_lgpl-devel perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker  
  yum -y install mysql mysql-server php-mysql php php-fpm
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
  yum -y install net-snmp net-snmp-devel net-snmp-libs neit-snmp-utils cairo-devel libxml2-devel pango-devel pango libpng-devel freetype freetype-devel libart_lgpl-devel perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker
  yum -y install mysql mysql-server php-mysql php php-fpm
fi

cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.$DATE
sed  -i 's/com2sec notConfigUser  default       public/com2sec notConfigUser  127.0.0.1       public/g'  /etc/snmp/snmpd.conf
sed -i 's/access  notConfigGroup ""      any       noauth    exact  systemview none none/access  notConfigGroup ""      any       noauth    exact  all  none none/g' /etc/snmp/snmpd.conf
sed -i 's/#view all    included  .1                               80/view all    included  .1                               80/g' /etc/snmp/snmpd.conf

/etc/init.d/mysqld start
/etc/init.d/snmpd start
/etc/init.d/php-fpm start

rm -rf cacti-0.8.8b
rm -rf rrdtool-1.4.9
tar xvf $PKG_NAME1
tar xvf $PKG_NAME2
cd rrdtool-1.4.9
./configure --prefix=/alidata/rrdtool

if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make  install      

wget http://git.jiagouyun.com/operation/operation/raw/master/nginx/nginx-1.4.7.sh
echo " " >> nginx-1.4.7.sh
echo "exit" >> nginx-1.4.7.sh
bash nginx-1.4.7.sh
mv /alidata/nginx/conf/vhosts/default.conf /alidata/nginx/conf/vhosts/default.conf.$DATE
cat > /alidata/nginx/conf/vhosts/default.conf << EOF
    server {
    listen       80 default;
    server_name  _;
	#index.php or index.jsp ???
    index index.html index.htm index.php;
    root /alidata/www/default;
	####<<<PHP settings>>>####
	location ~ .*\.(php|php5)?$
	{
		fastcgi_pass  127.0.0.1:9000;
		fastcgi_index index.php;
		include fastcgi.conf;
	}
    ####<<<Cache settings>>>####
	location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
	{
		expires 1d;
	}
	location ~ .*\.(js|css)?$
	{
		expires 1d;
	}
	####<<<The log path set>>>####
	access_log  $LOGS/default.log;
}
EOF
/etc/init.d/nginx reload

cd /alidata/install
mv cacti-0.8.8b /alidata/www/default/cacti
cat > sql.sql << EOF
create database cacti;
grant all on cacti.* to cacti@localhost identified by 'cacti';
grant all on cacti.* to cacti@127.0.0.1 identified by 'cacti';
flush privileges;
EOF
mysql < sql.sql
useradd cacti
echo "cacti" | passwd --stdin cacti
cd /alidata/www/default/
chown -R root:root cacti/
chown -R www.www cacti/rra/
chown -R www.www cacti/log/
chown -R www.www cacti/scripts/
cd /alidata/www/default/cacti
mysql -u cacti -pcacti cacti < cacti.sql

sed  -i 's/$database_username = "cactiuser";/$database_username = "cacti";/g'  include/config.php
sed  -i 's/$database_password = "cactiuser";/$database_password = "cacti";/g'  include/config.php

#if ! cat /etc/profile | grep "/alidata/softname/bin" &> /dev/null ;then
#   echo "export PATH=\$PATH:/alidata/softname/bin" >> /etc/profile
#fi
#source /etc/profile
cd $DIR
bash
