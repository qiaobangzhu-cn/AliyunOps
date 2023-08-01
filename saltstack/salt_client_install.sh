#!/bin/bash
###install saltstack client v1.0.1
###System: CentOS Ubuntu

rpm=`rpm -qa | grep salt | wc -l`
apt=`apt-cache search salt-minion | wc -l`

if [ "$(cat /etc/issue | grep -i centos)" != "" ];then
	if [ "$rpm" != 0 ]; then
		exit
	else
		yum -y install salt salt-minion
	fi
elif [ "$(cat /etc/issue | grep -i ubuntu)" != "" ];then
	if [ "$apt" != 0 ]; then
		exit
	else
		apt-get install -y python-software-properties && add-apt-repository ppa:saltstack/salt && apt-get update && apt-get -y install salt-minion
	fi
fi
read -p "Please input hostname:" id
sed -i "s/#id:/id: $id/g" /etc/salt/minion
sed -i 's/#master: salt/master: 121.40.28.126/g' /etc/salt/minion

/etc/init.d/salt-minion restart
