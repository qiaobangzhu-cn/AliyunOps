#!/bin/bash
#install pptpd 2015/05/19
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/vpn/pptp-release-current.noarch.rpm"
PKG_NAME=`basename $SRC_URI`

cat /etc/issue | grep -iq 'ubuntu'
if [  "$?" -eq "0" ];then
echo "installing pptpd, please wait ten minutes"

cat >> /usr/bin/vpnuser << "E"OF
#! /bin/bash
# vpnuser	Add/Del user to chap-secrets for VPN
# Version 1.0 beta

config="/etc/ppp/chap-secrets"
ERROR="Usage:\n$0 add <username> <passwd> or\n$0 del <username> or\n$0 show [<username>] or\n$0 domain <username> <domain>"

# See how we were called.
case "$1" in
  add)
        if [ "$(echo $2)" != "" ] & [ "$(echo $3)" != "" ]; then
	    echo -e "$2\t*\t$3\t*" >> $config
            chmod 600 $config
	else
	    echo -e $ERROR
	    exit 1
	fi
	;;
  del)
        if [ "$(echo $2)" != "" ]; then
	    grep -vw "$2" $config > /tmp/vpnblaat
            mv /tmp/vpnblaat $config
            chmod 600 $config
	else
	    echo -e $ERROR
	    exit 1
	fi
	;;
  show)
	    echo -e "User\tServer\tPasswd\tIPnumber"
	    echo "---------------------------------"
        if [ "$(echo $2)" != "" ]; then
	    grep -w $2 $config
	else
	    cat $config
	fi
	;;
  domain)
        if [ "$(echo $2)" != "" ] & [ "$(echo $3)" != "" ]; then
	    grep -vw "$2" $config > /tmp/vpnblaat
	    DATA=`grep -w "$2" $config`
	    mv /tmp/vpnblaat $config
	    DOM=`echo $3 | tr a-z A-Z`
	    dom=`echo $3 | tr A-Z a-z`
            echo "$DOM\\\\$DATA" >> $config
            echo "$dom\\\\$DATA" >> $config
	    chmod 600 $config
	else
	    echo -e $ERROR
	    exit 1
	fi
	;;
  *)
	echo -e $ERROR
	exit 1
esac
EOF
chmod +x /usr/bin/vpnuser

apt-get -y install pptpd > /dev/null 2>&1

mv /etc/ppp/pptpd-options /etc/ppp/pptpd-options.bak
cat >> /etc/ppp/pptpd-options << "E"OF
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
proxyarp
lock
nobsdcomp
novj
novjccomp
nologfd
idle 2592000 
ms-dns 114.114.114.114
ms-dns 8.8.8.8
EOF

mv /etc/pptpd.conf /etc/pptpd.conf.bak
cat >> /etc/pptpd.conf << "E"OF
option /etc/ppp/pptpd-options
logwtmp
localip 192.168.250.1
remoteip 192.168.250.100-254
EOF

sed -i "/^net.ipv4.ip_forward/d" /etc/sysctl.conf
sed -i "s/\(^net.ipv4.tcp_syncookies\)/#\1/g" /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p > /dev/null 2>&1

echo `ufw status` | grep -q 'inactive'
	if [ "$?" -eq "0" ];then
		apt-get update -y > /dev/null 2>&1
		apt-get install curl -y > /dev/null 2>&1
		iptables-save >> /root/iptables.run.zhuyunbak
		iptables -I INPUT -p gre -j ACCEPT
		iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 1723 -j ACCEPT
		iptables -I FORWARD -s 192.168.250.0/24 -j ACCEPT
		iptables -I FORWARD -d 192.168.250.0/24 -j ACCEPT
		iptables -t nat -A POSTROUTING -s 192.168.250.0/24 -j SNAT --to-source `curl icanhazip.com 2>/dev/null`
		iptables-save >> /root/iptables.rules
	else
		echo "must iptables support"
		exit 1
	fi

/etc/init.d/pptpd start 1>/dev/null
sleep 3
/etc/init.d/pptpd restart > /dev/null 2>&1
	if [ "$?" -eq "0" ];then
		echo "vpn install ok, please use command(vpnuser) add vpnname.For example: vpnuser add vpnname vpnpassword"
	else
		echo "vpn install fail"
	fi
else


echo "installing pptpd, please wait ten minutes"


rpm -Uvh ${SRC_URI} > /dev/null 2>&1
yum install -y pptpd-* > /dev/null 2>&1

mv /etc/ppp/options.pptpd /etc/ppp/options.pptpd.bak
cat >> /etc/ppp/options.pptpd << "E"OF
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
proxyarp
lock
nobsdcomp
novj
novjccomp
nologfd
idle 2592000 
ms-dns 114.114.114.114
ms-dns 8.8.8.8
EOF

mv /etc/pptpd.conf /etc/pptpd.conf.bak
cat >> /etc/pptpd.conf << "E"OF
option /etc/ppp/options.pptpd
logwtmp
localip 192.168.250.1
remoteip 192.168.250.100-254
EOF

sed -i "/^net.ipv4.ip_forward/d" /etc/sysctl.conf
sed -i "s/\(^net.ipv4.tcp_syncookies\)/#\1/g" /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p > /dev/null 2>&1

iptables-save >> /etc/sysconfig/iptables.run.zhuyunbak
iptables -I INPUT -p gre -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 1723 -j ACCEPT
iptables -I FORWARD -s 192.168.250.0/24 -j ACCEPT
iptables -I FORWARD -d 192.168.250.0/24 -j ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.250.0/24 -j SNAT --to-source `curl icanhazip.com 2>/dev/null`
iptables-save >> /etc/sysconfig/iptables

/etc/init.d/pptpd start 1>/dev/null
/etc/init.d/pptpd restart 1>/dev/null
	if [ "$?" -eq "0" ];then
		echo "vpn install ok, please use command(vpnuser) add vpnname.For example: vpnuser add vpnname vpnpassword"
	else
		echo "vpn install fail"
	fi
fi