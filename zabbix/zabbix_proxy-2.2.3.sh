#!/bin/bash
# for centos 6.5 and debian ubuntu

prefix="/usr/local/zabbix-proxy"
name=`hostname`
if  grep -q -i centos /etc/issue
then
	echo "os is centos "
elif grep -q -i ubuntu /etc/issue
then
	echo "os is ubnutu"
elif grep -q -i debian /etc/issue
then
	echo "os is debian"
else
	echo "is not centos or ubuntu.exit.."
	exit 1
fi
#
init()
{
	if [ -d "$prefix" ]
	then
		echo "$prefix existed"
		exit 
	fi
	if grep -q -i centos /etc/issue;then
		yum install -y gcc mysql mysql-server mysql-devel wget  java-1.7.0-openjdk-devel java-1.7.0-openjdk
		/etc/init.d/mysqld start
		mysql -e "create database zabbix;grant all on zabbix.* to zabbix@localhost identified by 'zabbix'"
	else
		export DEBIAN_FRONTEND=noninteractive
		apt-get install -y build-essential mysql-server-5.5 wget libmysqld-dev
		m_pass=`grep password /etc/mysql/debian.cnf |awk '{print $3}'|head -n 1`
		mysql -udebian-sys-maint -p$m_pass -e "create database zabbix;grant all on zabbix.* to zabbix@localhost identified by 'zabbix'"	
	fi
	
#	create user 
	if ! grep -q zabbix /etc/passwd 
	then
		groupadd zabbix
		useradd -g zabbix zabbix -M
	fi
	
}
install()
{		
	cd /opt
	if [ ! -f  "zabbix-2.2.3.tar.gz" ];then
		wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/server/zabbix-2.2.3.tar.gz -O zabbix-2.2.3.tar.gz
	fi
	if [ -d "zabbix-2.2.3" ];then
		rm -rf zabbix-2.2.3
	fi
	tar xf  zabbix-2.2.3.tar.gz
	cd zabbix-2.2.3
	./configure --enable-agent --enable-java --enable-proxy --with-mysql --prefix=${prefix}
	make -j 
	make install
# import db	
	mysql -uzabbix -pzabbix zabbix < database/mysql/schema.sql
	


}
config()
{
	cd /opt/zabbix-2.2.3
	if grep -q -i centos /etc/issue;then
		cp misc/init.d/fedora/core/zabbix_server /etc/init.d/
		chmod +x /etc/init.d/zabbix_server
		sed -i "s#BASEDIR=/usr/local#BASEDIR=${prefix}#" /etc/init.d/zabbix_server
		sed -i "s#BINARY_NAME=zabbix_server#BINARY_NAME=zabbix_proxy#" /etc/init.d/zabbix_server
		chkconfig zabbix_server --add
		chkconfig zabbix_server on

		cp misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
                chmod +x /etc/init.d/zabbix_agentd
                sed -i "s#BASEDIR=/usr/local#BASEDIR=${prefix}#" /etc/init.d/zabbix_agentd
                chkconfig zabbix_agentd --add
                chkconfig zabbix_agentd on
	else
		cp  misc/init.d/debian/zabbix-server /etc/init.d/
		chmod +x /etc/init.d/zabbix-server
		sed -i "s#DAEMON=/usr/local#DAEMON=${prefix}#" /etc/init.d/zabbix-server
                sed -i "s#NAME=zabbix_server#NAME=zabbix_proxy#" /etc/init.d/zabbix-server
		update-rc.d zabbix-server defaults	
		
		cp misc/init.d/debian/zabbix-agent /etc/init.d/
                chmod +x /etc/init.d/zabbix-agent
        #       sed -i "s#BASEDIR=/usr/local#BASEDIR=${prefix}#" /etc/init.d/zabbix-agent
                sed -i "s#DAEMON=/usr/local/sbin#DAEMON=${prefix}/sbin#" /etc/init.d/zabbix-agent
                update-rc.d zabbix-agent defaults

	fi
	cp ${prefix}/etc/zabbix_proxy.conf ${prefix}/etc/zabbix_proxy.conf-old

	sed -i "s/Server=127.0.0.1/Server=zabbix.jiagouyun.com/" ${prefix}/etc/zabbix_proxy.conf
	sed -i "s/Hostname=Zabbix proxy/Hostname=${name}/" ${prefix}/etc/zabbix_proxy.conf
	sed -i "s/ServerActive=127.0.0.1/#ServerActive=127.0.0.1/" ${prefix}/etc/zabbix_proxy.conf
	sed -i "s?# Include=/usr/local/etc/zabbix_proxy.conf.d/? Include=${prefix}/etc/zabbix_proxy.conf.d/?"  ${prefix}/etc/zabbix_proxy.conf
	sed -i "s?# ConfigFrequency=3600? ConfigFrequency=300?"  ${prefix}/etc/zabbix_proxy.conf
	sed -i "s/DBName=zabbix_proxy/DBName=zabbix/"  ${prefix}/etc/zabbix_proxy.conf
	sed -i "s/DBUser=root/DBUser=zabbix/"  ${prefix}/etc/zabbix_proxy.conf
	sed -i "s/# DBPassword=/ DBPassword=zabbix/"  ${prefix}/etc/zabbix_proxy.conf
#	sed -i "s/# ProxyMode=0/  ProxyMode=1/" ${prefix}/etc/zabbix_proxy.conf
#	sed -i "s?LogFile=/tmp/zabbix_proxy.log?#LogFile=/tmp/zabbix_proxy.log?" ${prefix}/etc/zabbix_proxy.conf
	# for agent
	cp ${prefix}/etc/zabbix_agentd.conf ${prefix}/etc/zabbix_agentd.conf-old
#        sed -i "s?LogFile=/tmp/zabbix_agentd.log?#LogFile=/tmp/zabbix_agentd.log?" ${prefix}/etc/zabbix_agentd.conf
        sed -i "s/Hostname=Zabbix server/Hostname=${name}/" ${prefix}/etc/zabbix_agentd.conf
        sed -i "s?# Include=/usr/local/etc/zabbix_agentd.conf.d/? Include=${prefix}/etc/zabbix_agentd.conf.d/?"  ${prefix}/etc/zabbix_agentd.conf
#
	
}
init
install
config
#end