#!/bin/bash
# install zabbix_proxy(centos 6+,debian,ubuntu)
# auth:fanjun
# date:2018-07-24

prefix="/usr/local/zabbix-proxy"
name=`hostname`

init()
{
        if [ -d "$prefix" ]
        then
                echo "$prefix existed"
                exit
        fi
        if grep -q -i centos /etc/issue;then
                yum install -y gcc mysql mysql-server curl-devel mysql-devel wget java-1.7.0-openjdk-devel java-1.7.0-openjdk
                /etc/init.d/mysqld start
                mysql -e "create database zabbix;grant all on zabbix.* to zabbix@localhost identified by '3PVv3b7S'"
        else
                export DEBIAN_FRONTEND=noninteractive
                apt-get update
                apt-get install -y build-essential mysql-server libmysqld-dev libmysqlclient-dev wget libmysqld-dev
                m_pass=`grep password /etc/mysql/debian.cnf |awk '{print $3}'|head -n 1`
                mysql -udebian-sys-maint -p -e "create database zabbix character set utf8 collate utf8_bin;grant all on zabbix.* to zabbix@localhost identified by '3PVv3b7S';"
        fi

        #check mysql
        mysql_process=`ps -ef|grep mysql|grep -v grep |wc -l`
        if [ $mysql_process = 0 ];then
                echo "Mysql is not install"
                exit 1
        fi

        #create user 
        if ! grep -q zabbix /etc/passwd
        then
                groupadd zabbix
                useradd -g zabbix zabbix -M -s /sbin/nologin
        fi
}
install()
{
        cd /opt
        if [ ! -f  "zabbix-3.2.1.tar.gz" ];then
                wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/server/zabbix-3.2.1.tar.gz -O zabbix-3.2.1.tar.gz
        fi
        if [ -d "zabbix-3.2.1" ];then
                rm -rf zabbix-3.2.1
        fi
        tar xf  zabbix-3.2.1.tar.gz
        cd zabbix-3.2.1
        ./configure --enable-agent --enable-java --enable-proxy --with-mysql --prefix=${prefix}
        if [ $? != 0 ];then
                echo "./configure failed,please check"
                echo "#########################"
        fi
        make -j
        make install
        #import db      
        mysql -uzabbix -p3PVv3b7S zabbix < database/mysql/schema.sql
}
config()
{
        #config zabbix_server,zabbix_agent
        if  grep -q -i centos /etc/issue
        then
            cd /opt/zabbix-3.2.1
            cp misc/init.d/fedora/core/* /etc/init.d/
            chmod 755 /etc/init.d/zabbix*
            sed -i "s#BASEDIR=/usr/local#BASEDIR=${prefix}#" /etc/init.d/zabbix_server
            sed -i "s#BINARY_NAME=zabbix_server#BINARY_NAME=zabbix_proxy#" /etc/init.d/zabbix_server
            sed -i "s#BASEDIR=/usr/local#BASEDIR=${prefix}#" /etc/init.d/zabbix_agentd
            echo "/etc/init.d/mysqld start" >> /etc/rc.local
            echo "/etc/init.d/zabbix_server start" >> /etc/rc.local
            echo "/etc/init.d/zabbix_agentd start" >> /etc/rc.local
        else
            cd /opt/zabbix-3.2.1
            cp misc/init.d/debian/* /etc/init.d/
            chmod 755 /etc/init.d/zabbix*
            sed -i "s#DAEMON=/usr/local/sbin/${NAME}#DAEMON=/usr/local/zabbix-proxy/sbin/${NAME}#" /etc/init.d/zabbix-server
            sed -i "s#NAME=zabbix_server#NAME=zabbix_proxy#" /etc/init.d/zabbix-server
            sed -i "s#DAEMON=/usr/local/sbin/${NAME}#DAEMON=/usr/local/zabbix-proxy/sbin/${NAME}#" /etc/init.d/zabbix-agent
            echo "/etc/init.d/mysqld start" >> /etc/rc.local
            echo "/etc/init.d/zabbix-server start" >> /etc/rc.local
            echo "/etc/init.d/zabbix-agent start" >> /etc/rc.local
        fi
            
        #config zabbix_proxy.conf
        cp ${prefix}/etc/zabbix_proxy.conf ${prefix}/etc/zabbix_proxy.conf-old
        sed -i "s/Server=127.0.0.1/Server=hz-monitor.jiagouyun.com/" ${prefix}/etc/zabbix_proxy.conf
        sed -i "s/Hostname=Zabbix proxy/Hostname=${name}/" ${prefix}/etc/zabbix_proxy.conf
        sed -i "s?# Include=/usr/local/etc/zabbix_proxy.conf.d/? Include=${prefix}/etc/zabbix_proxy.conf.d/?"  ${prefix}/etc/zabbix_proxy.conf
        sed -i "s/DBName=zabbix_proxy/DBName=zabbix/"  ${prefix}/etc/zabbix_proxy.conf
        sed -i "s/DBUser=root/DBUser=zabbix/"  ${prefix}/etc/zabbix_proxy.conf
        sed -i "s/Timeout=4/Timeout=30/"  ${prefix}/etc/zabbix_proxy.conf
        sed -i "s/# DBPassword=/DBPassword=3PVv3b7S/"  ${prefix}/etc/zabbix_proxy.conf
        sed -i "s/# ProxyMode=0/ProxyMode=0/" ${prefix}/etc/zabbix_proxy.conf
        sed -i "s?# ConfigFrequency=3600?ConfigFrequency=300?"  ${prefix}/etc/zabbix_proxy.conf
        sed -i "s?# StartPollers=5?StartPollers=10?" ${prefix}/etc/zabbix_proxy.conf
        #config zabbix_agentd.conf
        cp ${prefix}/etc/zabbix_agentd.conf $/usr/local/zabbix-proxy/sbin/zabbix_proxy -c /usr/local/zabbix-proxy/etc/zabbix_proxy.conf{prefix}/etc/zabbix_agentd.conf-old
        sed -i "s/Hostname=Zabbix server/Hostname=${name}/" ${prefix}/etc/zabbix_agentd.conf
        sed -i "s/# Timeout=3/Timeout=30/" ${prefix}/etc/zabbix_agentd.conf
        sed -i "s?# Include=/usr/local/etc/zabbix_agentd.conf.d/\*.conf? Include=${prefix}/etc/zabbix_agentd.conf.d/\*.conf?"  ${prefix}/etc/zabbix_agentd.conf
        sed -i "s?# StartAgents=3?StartAgents=10?" ${prefix}/etc/zabbix_agentd.conf
        echo "#########################"
        echo "Congratulations! Zabbix_proxy has been installed."
        echo "Start Zabbix Proxy & Zabbix Agent ..."
}
start()
{
    if  grep -q -i centos /etc/issue
    then
        /etc/init.d/zabbix_server start
        /etc/init.d/zabbix_agentd start
    else
        /etc/init.d/zabbix-server start
        /etc/init.d/zabbix-agent start
    fi
}
init
install
config
start