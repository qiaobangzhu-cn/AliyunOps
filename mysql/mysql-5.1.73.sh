#!/bin/bash

DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/mysql /alidata/mysql.bak.$DATE &> /dev/null
mkdir -p /alidata/mysql
mkdir -p /alidata/mysql/log
mkdir -p /alidata/install
cd /alidata/install
if [ `uname -m` == "x86_64" ];then
  rm -rf mysql-5.1.73-linux-x86_64-glibc23
  if [ ! -f mysql-5.1.73-linux-x86_64-glibc23.tar.gz ];then
	 wget http://oss.aliyuncs.com/aliyunecs/onekey/mysql/mysql-5.1.73-linux-x86_64-glibc23.tar.gz
  fi
  tar -xzvf mysql-5.1.73-linux-x86_64-glibc23.tar.gz
  mv mysql-5.1.73-linux-x86_64-glibc23/* /alidata/mysql
else
  rm -rf mysql-5.1.73-linux-i686-glibc23
  if [ ! -f mysql-5.1.73-linux-i686-glibc23.tar.gz ];then
    wget http://oss.aliyuncs.com/aliyunecs/onekey/mysql/mysql-5.1.73-linux-i686-glibc23.tar.gz
  fi
  tar -xzvf mysql-5.1.73-linux-i686-glibc23.tar.gz
  mv mysql-5.1.73-linux-i686-glibc23/* /alidata/mysql
fi

#install mysql
groupadd mysql
useradd -g mysql -s /sbin/nologin mysql
/alidata/mysql/scripts/mysql_install_db --datadir=/alidata/mysql/data/ --basedir=/alidata/mysql --user=mysql
chown -R mysql:mysql /alidata/mysql/
chown -R mysql:mysql /alidata/mysql/data/
chown -R mysql:mysql /alidata/mysql/log
\cp -f /alidata/mysql/support-files/mysql.server /etc/init.d/mysqld
sed -i 's#^basedir=$#basedir=/alidata/mysql#' /etc/init.d/mysqld
sed -i 's#^datadir=$#datadir=/alidata/mysql/data#' /etc/init.d/mysqld
\cp -f /alidata/mysql/support-files/my-medium.cnf /etc/my.cnf
sed -i 's#skip-locking#skip-external-locking\nlog-error=/alidata/mysql/log/error.log#' /etc/my.cnf
chmod 755 /etc/init.d/mysqld
/etc/init.d/mysqld start

#add PATH
if ! cat /etc/profile | grep "export PATH=\$PATH:/alidata/mysql/bin" &> /dev/null;then
	echo "export PATH=\$PATH:/alidata/mysql/bin" >> /etc/profile
fi
source /etc/profile
cd $DIR
bash