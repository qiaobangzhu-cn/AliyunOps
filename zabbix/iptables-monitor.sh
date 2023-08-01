#!/bin/bash
if [ -f /usr/local/zabbix-agentd/monitor_scripts/iptables-monitor.sh ] || [ -f /alidata/check_iptables.sh ]
then
echo "iptables is monitor"
exit
else
mkdir -p /usr/local/zabbix-agentd/monitor_scripts
wget http://git.jiagouyun.com/operation/operation/raw/master/linux/sys/check_iptables.sh -O /usr/local/zabbix-agentd/monitor_scripts/iptables-monitor.sh
if ! grep "zabbix ALL=(ALL) NOPASSWD: /sbin/iptables" /etc/sudoers >> /dev/null
then
cat >> /etc/sudoers << 'EOF'
zabbix ALL=(ALL) NOPASSWD: /sbin/iptables
Defaults:zabbix !requiretty
EOF
fi

for CONF in `find / -type f -name zabbix_agentd.conf`
do
if ! grep "Include=/usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d" $CONF && ! grep "UserParameter=ipts" $CONF;then
mkdir -p /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d
echo "Include=/usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d" >> $CONF
fi
done

cat > /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/iptables-monitor.conf << 'EOF'
UserParameter=ipts,bash /usr/local/zabbix-agentd/monitor_scripts/iptables-monitor.sh -T filter -r 1
EOF
chown -R zabbix:zabbix /usr/local/zabbix-agentd/monitor_scripts
chmod 755 /usr/local/zabbix-agentd/monitor_scripts/*
/etc/init.d/zabbix_agentd restart 2>/dev/null || /etc/init.d/zabbix-agentd restart 2>/dev/null || /etc/init.d/zabbix-agent restart
fi