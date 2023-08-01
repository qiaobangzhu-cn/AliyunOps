#!/bin/bash
SRC_URI=http://zy-res.oss-cn-hangzhou.aliyuncs.com/server  #下载包的http路径，为OSS中的路径
PKG_NAME=zabbix-2.2.3.tar.gz				#下载包的名字
PREFIX=/alidata/zabbix	#软件的安装主目录
PKG_NAME_INSTALL_DIR=/alidata/install	#软件的安装目录
PKG_NAME_DIR=/alidata/install/zabbix-2.2.3
DIR=`pwd`							#安装前当前的主目录
DATE=`date +%Y%m%d%H%M%S`
WEB_DIR=/alidata/www
mv $PREFIX ${PREFIX}.bak.$DATE &> /dev/null			#如果之前有此目录，对目录重命名
rm -rf $PKG_NAME_DIR &> /dev/null
mkdir -p $PREFIX	#创建软件的主目录
mkdir -p $PKG_NAME_INSTALL_DIR	#创建软件的安装目录
yum -y remove httpd
yum install -y libxml2-devel net-snmp-devel libcurl-devel mysql-devel mysql-server	#安装一系列的依赖包
yum install -y httpd php php-bcmath php-gd php-mbstring php-mysql php-pdo php-xml	#安装lamp的环境
service mysqld start	#启动mysql
if [ ! -s $PKG_NAME ]; then
	wget -c $SRC_URI/$PKG_NAME
	tar -xzvf zabbix-2.2.3.tar.gz -C /alidata/install	#将安装包解压到软件安装的目录
else
	rm -rf $PKG_NAME_DIR
	tar -xzvf zabbix-2.2.3.tar.gz -C /alidata/install       #将安装包解压到软件安装的目录
fi
cd $PKG_NAME_DIR
./configure --prefix=$PREFIX --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
make
make install
if id zabbix &> /dev/null; then
userdel zabbix &> /dev/null && groupdel zabbix &> /dev/null && rm -rf /home/zabbix && rm -rf /var/spool/mail/zabbix &> /dev/null
fi
groupadd zabbix &> /dev/null
useradd -g zabbix zabbix &> /dev/null
usermod -s /sbin/nologin zabbix &> /dev/null
mysql -e "drop database zabbix" &> /dev/null
mysql -e "create database zabbix"	#创建zabbix的数据库
#导入数据到zabbix库中
mysql zabbix < $PKG_NAME_DIR/database/mysql/schema.sql
mysql zabbix < $PKG_NAME_DIR/database/mysql/images.sql
mysql zabbix < $PKG_NAME_DIR/database/mysql/data.sql
#修改配置文件
cp $PREFIX/etc/zabbix_server.conf $PREFIX/etc/zabbix_server.conf.bak
sed -i "s/# DBHost=localhost/DBHost=localhost/g" $PREFIX/etc/zabbix_server.conf
#添加启动脚本
cp $PKG_NAME_DIR/misc/init.d/fedora/core5/zabbix_server /etc/init.d/zabbix_server
sed -i 's/\/usr\/local/\/alidata\/zabbix/g' /etc/init.d/zabbix_server
chmod 700 /etc/init.d/zabbix_server
/etc/init.d/zabbix_server start		#启动zabbix_server
#添加开机自启动
if ! cat /etc/rc.local | grep "/etc/init.d/zabbix_server" > /dev/null;then 
     echo "/etc/init.d/zabbix_server  start" >> /etc/rc.local
fi
mkdir -p $WEB_DIR/zabbix
cp -r $PKG_NAME_DIR/frontends/php/* $WEB_DIR/zabbix/
sed -i 's/DocumentRoot "\/var\/www\/html"/#DocumentRoot "\/var\/www\/html"/g' /etc/httpd/conf/httpd.conf
sed -i 's/<Directory "\/var\/www\/html">/<Directory "\/alidata\/www\/zabbix">/g' /etc/httpd/conf/httpd.conf
sed -i 's/DirectoryIndex/DirectoryIndex index.php/g' /etc/httpd/conf/httpd.conf
sed -i 's/post_max_size = 8M/post_max_size = 16M/g' /etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php.ini
sed -i 's/max_input_time = 60/max_input_time = 300/g' /etc/php.ini
sed -i 's/;date.timezone =/date.timezone = Asia\/Shanghai/g' /etc/php.ini
/etc/init.d/httpd start
