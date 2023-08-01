#!/bin/bash

prefix="/usr/local/zabbix-proxy"
name=`hostname`
#
init()
{
        if [ -d "$prefix" ]
        then
                echo "$prefix existed"
                exit
        fi
                yum install -y gcc mariadb mariadb-server mariadb-devel wget  java-1.7.0-openjdk-devel java-1.7.0-openjdk
                systemctl start mariadb
                mysql -e "create database zabbix;grant all on zabbix.* to zabbix@localhost identified by 'zabbix'"

#       create user
        if ! grep -q zabbix /etc/passwd
        then
                groupadd zabbix
                useradd -g zabbix zabbix -M
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
        make -j
        make install
# import db
        mysql -uzabbix -pzabbix zabbix < database/mysql/schema.sql



}
config()
{
        cd /opt/zabbix-3.2.1
                cp misc/init.d/fedora/core/zabbix_server /etc/init.d/
                chmod +x /etc/init.d/zabbix_server
                sed -i "s#BASEDIR=/usr/local#BASEDIR=${prefix}#" /etc/init.d/zabbix_server
                sed -i "s#BINARY_NAME=zabbix_server#BINARY_NAME=zabbix_proxy#" /etc/init.d/zabbix_server
                #chkconfig zabbix_server --add
                #chkconfig zabbix_server on
                echo "/etc/init.d/zabbix_server start" >> /etc/rc.local
                echo "systemctl start mariadb" >> /etc/rc.local

                cp misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
                chmod +x /etc/init.d/zabbix_agentd
                sed -i "s#BASEDIR=/usr/local#BASEDIR=${prefix}#" /etc/init.d/zabbix_agentd
                #chkconfig zabbix_agentd --add
                #chkconfig zabbix_agentd on
                echo "/etc/init.d/zabbix_agentd start" >> /etc/rc.local
        cp ${prefix}/etc/zabbix_proxy.conf ${prefix}/etc/zabbix_proxy.conf-old

        sed -i "s/Server=127.0.0.1/Server=bj-monitor.jiagouyun.com/" ${prefix}/etc/zabbix_proxy.conf
        sed -i "s/Hostname=Zabbix proxy/Hostname=${name}/" ${prefix}/etc/zabbix_proxy.conf
        sed -i "s?# Include=/usr/local/etc/zabbix_proxy.conf.d/? Include=${prefix}/etc/zabbix_proxy.conf.d/?"  ${prefix}/etc/zabbix_proxy.conf
        sed -i "s/DBName=zabbix_proxy/DBName=zabbix/"  ${prefix}/etc/zabbix_proxy.conf
        sed -i "s/# Timeout=3/Timeout=30/"  ${prefix}/etc/zabbix_proxy.conf
        sed -i "s/DBUser=root/DBUser=zabbix/"  ${prefix}/etc/zabbix_proxy.conf
        sed -i "s/# DBPassword=/ DBPassword=zabbix/"  ${prefix}/etc/zabbix_proxy.conf
        sed -i "s/# ProxyMode=0/  ProxyMode=0/" ${prefix}/etc/zabbix_proxy.conf
        sed -i "s?# ConfigFrequency=3600? ConfigFrequency=300?"  ${prefix}/etc/zabbix_proxy.conf
#       sed -i "s?LogFile=/tmp/zabbix_proxy.log?#LogFile=/tmp/zabbix_proxy.log?" ${prefix}/etc/zabbix_proxy.conf
        # for agent
        cp ${prefix}/etc/zabbix_agentd.conf ${prefix}/etc/zabbix_agentd.conf-old
#        sed -i "s?LogFile=/tmp/zabbix_agentd.log?#LogFile=/tmp/zabbix_agentd.log?" ${prefix}/etc/zabbix_agentd.conf
        sed -i "s/Hostname=Zabbix server/Hostname=${name}/" ${prefix}/etc/zabbix_agentd.conf
        sed -i "s/# Timeout=3/Timeout=30/"  ${prefix}/etc/zabbix_agentd.conf
        sed -i "s?# Include=/usr/local/etc/zabbix_agentd.conf.d/\*.conf? Include=${prefix}/etc/zabbix_agentd.conf.d/\*.conf?"  ${prefix}/etc/zabbix_agentd.conf
#

}
init
install
config