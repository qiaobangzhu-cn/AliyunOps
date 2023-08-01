#!/bin/bash

prefix="/usr/local/zabbix-agentd"
name=`hostname`
#if  grep -i centos /etc/issue  >> /dev/null
#then
#	iscentos=1
#else
#	iscentos=0
#fi
function initgcc {
	#if [ "$iscentos" -eq "1" ]
	if [ -f /etc/redhat-release ]
	then
		yum install -y gcc
	else 
		apt-get update
		apt-get install -y build-essential
	fi
}
function install {
	cd /opt
	if [ ! -f "zabbix-2.2.3.tar.gz" ]
	then
		wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/server/zabbix-2.2.3.tar.gz -O zabbix-2.2.3.tar.gz
		tar xzf zabbix-2.2.3.tar.gz
	fi
	cd zabbix-2.2.3
	if [ -d "$prefix" ]
	then
		echo "/usr/local/zabbix-agentd existed"
		exit 
	fi
	./configure --enable-agent  --prefix=${prefix}
	make -j 2
	make install
	groupadd zabbix
	useradd -g zabbix zabbix -M
	if [ -f /etc/redhat-release ] 
	then
		cp misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
		chmod +x /etc/init.d/zabbix_agentd
		sed -i "s#BASEDIR=/usr/local#BASEDIR=${prefix}#" /etc/init.d/zabbix_agentd
		chkconfig zabbix_agentd --add
		chkconfig zabbix_agentd on
	else
		cp misc/init.d/debian/zabbix-agent /etc/init.d/
		chmod +x /etc/init.d/zabbix-agent
	#	sed -i "s#BASEDIR=/usr/local#BASEDIR=${prefix}#" /etc/init.d/zabbix-agent
		sed -i "s#DAEMON=/usr/local/sbin#DAEMON=${prefix}/sbin#" /etc/init.d/zabbix-agent
		update-rc.d zabbix-agent defaults
	fi
	
	##install disk IO monitor
	mkdir -p /usr/local/zabbix-agentd/monitor_scripts
    wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/diskio-discovery-monitor.sh -O /usr/local/zabbix-agentd/monitor_scripts/diskio-discovery-monitor.sh
    chmod 755 /usr/local/zabbix-agentd/monitor_scripts/diskio-discovery-monitor.sh
    chown zabbix:zabbix /usr/local/zabbix-agentd/monitor_scripts/diskio-discovery-monitor.sh
    wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/diskio-discovery-monitor.conf -O /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/diskio-discovery-monitor.conf
    echo "下面出现磁盘信息，说明配置成功，如果没有，请检查！"
    /bin/bash /usr/local/zabbix-agentd/monitor_scripts/diskio-discovery-monitor.sh mount_disk_discovery
    chown zabbix.zabbix /tmp/mounts.tmp
    
    ##### install iptables number monitor
    mkdir -p /usr/local/zabbix-agentd/monitor_scripts
    wget http://git.jiagouyun.com/operation/operation/raw/master/linux/sys/check_iptables.sh -O /usr/local/zabbix-agentd/monitor_scripts/iptables-monitor.sh
    if ! grep "zabbix ALL=(ALL) NOPASSWD: /sbin/iptables" /etc/sudoers >> /dev/null
    then
    echo -e "zabbix ALL=(ALL) NOPASSWD: /sbin/iptables\nDefaults:zabbix !requiretty" >> /etc/sudoers
    fi

    echo "UserParameter=ipts,bash /usr/local/zabbix-agentd/monitor_scripts/iptables-monitor.sh -T filter -r 1" > /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/iptables-monitor.conf

    chown -R zabbix:zabbix /usr/local/zabbix-agentd/monitor_scripts
    chmod 755 /usr/local/zabbix-agentd/monitor_scripts/*
	
}

function config {
#	echo "ListenPort=30005" >> ${prefix}/etc/zabbix_agentd.conf
	cp ${prefix}/etc/zabbix_agentd.conf ${prefix}/etc/zabbix_agentd.conf-old
#	sed -i "s?LogFile=/tmp/zabbix_agentd.log?#LogFile=/tmp/zabbix_agentd.log?" ${prefix}/etc/zabbix_agentd.conf
	sed -i "s/Server=127.0.0.1/Server=monitor.jiagouyun.com/" ${prefix}/etc/zabbix_agentd.conf
	sed -i "s?# Timeout=3? Timeout=10?" ${prefix}/etc/zabbix_agentd.conf
	sed -i "s/Hostname=Zabbix server/Hostname=${name}/" ${prefix}/etc/zabbix_agentd.conf
	sed -i "s/ServerActive=127.0.0.1/#ServerActive=127.0.0.1/" ${prefix}/etc/zabbix_agentd.conf
	sed -i "s?# Include=/usr/local/etc/zabbix_agentd.conf.d/? Include=${prefix}/etc/zabbix_agentd.conf.d/?"  ${prefix}/etc/zabbix_agentd.conf
#	echo "LogFile=/tmp/zabbix_agentd.log
#	#DebugLevel=3
#	Server=zabbix.jiagouyun.com
#	#ServerActive=zabbix.jiagouyun.com
#	Hostname= 
#	Include=${prefix}/etc/zabbix_agentd.conf.d/">${prefix}/etc/zabbix_agentd.conf
#	${prefix}/sbin/zabbix_agentd
	echo "please check the hostname in the zabbix_agentd.conf"
}
initgcc
install
config