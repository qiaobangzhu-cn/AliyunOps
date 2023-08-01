#!/bin/bash
groupadd zabbix
useradd -g zabbix zabbix -M
echo -ne "Do you want to install zabbix of following ones"
echo -ne "\n6:install centos 6 zabbix "
echo -ne "\n7:install centos 7 zabbix "
echo -ne "\n8:install  ubuntu zabbix "
echo -ne "\ntype the number of you want to do : "
read yn
if [ "$yn" = "6" ]; then
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/zabbix/zabbix-centos-6.tar.gz -O /usr/local/zabbix-centos-6.tar.gz
cd /usr/local && tar zxvf /usr/local/zabbix-centos-6.tar.gz
sed -i "s/Hostname=aia-proxy/Hostname=$HOSTNAME/" /usr/local/zabbix-agentd/etc/zabbix_agentd.conf
sed -i "s/Server=192.168.248.39/Server=bj-monitor.jiagouyun.com/" /usr/local/zabbix-agentd/etc/zabbix_agentd.conf
mv /usr/local/zabbix_agentd /etc/init.d/
echo "/etc/init.d/zabbix_agentd start" >> /etc/rc.local 
fi
if [ "$yn" = "7" ]; then
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/zabbix/zabbix-centos-7.tar.gz -O /usr/local/zabbix-centos-7.tar.gz
cd /usr/local && tar zxvf /usr/local/zabbix-centos-7.tar.gz
sed -i "s/Hostname=iZuf6j46jt594r5y6pgc6vZ/Hostname=$HOSTNAME/" /usr/local/zabbix-agentd/etc/zabbix_agentd.conf
mv /usr/local/zabbix-agentd/zabbix_agentd /etc/init.d/
echo "/etc/init.d/zabbix_agentd start" >> /etc/rc.local
fi
if [ "$yn" = "8" ]; then
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/zabbix/zabbix-ubuntu.tar.gz -O /usr/local/zabbix-ubuntu.tar.gz
cd /usr/local && tar zxvf /usr/local/zabbix-ubuntu.tar.gz
sed -i "s/Hostname=shiwo-official/Hostname=$HOSTNAME/" /usr/local/zabbix-agentd/etc/zabbix_agentd.conf
mv /usr/local/zabbix-agentd/zabbix-agent /etc/init.d/
echo "/etc/init.d/zabbix-agent start" >> /etc/rc.local
fi

/etc/init.d/zabbix_agentd start || /etc/init.d/zabbix-agent start