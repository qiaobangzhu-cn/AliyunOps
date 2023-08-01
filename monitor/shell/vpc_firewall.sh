#!/bin/bash
s_uname=`uname -n`
echo $s_uname | grep -q -E '^dmz-'
if [ $? -eq 0 ];then
    iptables -F INPUT
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -p icmp -j ACCEPT
    #开通内网
    iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT
    iptables -A INPUT -s 172.16.0.0/12 -j ACCEPT
    iptables -A INPUT -s 10.0.0.0/8 -j ACCEPT
    iptables -A INPUT -s 127.0.0.1 -j ACCEPT
    #开通csos
    iptables -A INPUT -p tcp --dport 9998 -j ACCEPT
    #csos tcp agent
    iptables -A INPUT -p tcp --dport 40000:50000 -j ACCEPT
    #zabbix 
    iptables -A INPUT -p tcp -s bj-monitor.jiagouyun.com --dport 10051 -j ACCEPT
    
    #开通跳板机ssh
    iptables -A INPUT -p tcp -s 115.29.244.224 --dport 40022 -j ACCEPT
    #开通应用访问端口
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    
    #拒绝所有
    iptables -A INPUT -j DROP
fi

if [ "${s_uname}x" == "dmz-gatewayx" ];then
    s=`ip route | grep default | sed -n 's/[^0-9]*\([0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1/p'`
    s_ip=`ip addr show dev eth0 | sed -n 's/[^0-9]*\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1/p'`
	iptables -t nat -A POSTROUTING -s ${s}.0.0/16 -j SNAT --to-source  $s_ip
fi
