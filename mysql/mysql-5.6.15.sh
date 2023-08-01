#!/bin/bash

DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/mysql /alidata/mysql.bak.$DATE &> /dev/null
mkdir -p /alidata/mysql
mkdir -p /alidata/mysql/log
mkdir -p /alidata/install
cd /alidata/install
if [ `uname -m` == "x86_64" ];then
  rm -rf mysql-5.6.15-linux-glibc2.5-x86_64
  if [ ! -f mysql-5.6.15-linux-glibc2.5-x86_64.tar.gz ];then
	 wget http://oss.aliyuncs.com/aliyunecs/onekey/mysql/mysql-5.6.15-linux-glibc2.5-x86_64.tar.gz
  fi
  tar -xzvf mysql-5.6.15-linux-glibc2.5-x86_64.tar.gz
  mv mysql-5.6.15-linux-glibc2.5-x86_64/* /alidata/mysql
else
  rm -rf mysql-5.6.15-linux-glibc2.5-i686
  if [ ! -f mysql-5.6.15-linux-glibc2.5-i686.tar.gz ];then
  wget http://oss.aliyuncs.com/aliyunecs/onekey/mysql/mysql-5.6.15-linux-glibc2.5-i686.tar.gz
  fi
  tar -xzvf mysql-5.6.15-linux-glibc2.5-i686.tar.gz
  mv mysql-5.6.15-linux-glibc2.5-i686/* /alidata/mysql

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
cat > /etc/my.cnf <<END
[client]
port            = 3306
socket          = /tmp/mysql.sock
[mysqld]
port            = 3306
socket          = /tmp/mysql.sock
skip-external-locking
log-error=/alidata/mysql/log/error.log
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M

log-bin=mysql-bin
binlog_format=mixed
server-id       = 1

sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
END

chmod 755 /etc/init.d/mysqld
/etc/init.d/mysqld start

#add PATH
if ! cat /etc/profile | grep "export PATH=\$PATH:/alidata/mysql/bin" &> /dev/null;then
	echo "export PATH=\$PATH:/alidata/mysql/bin" >> /etc/profile
fi
source /etc/profile
cd $DIR
bash