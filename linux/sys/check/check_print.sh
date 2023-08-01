#!/bin/bash

#Script created 2016-07-20
#Modify by 2016-07-23,mark:
 ## ifconfig modify /sbin/ifconfig ,because bug for env

DATE=$(date +%Y%m%d)
HOSTNAME=$(hostname)

ETH0=""
ETH1=""
SYSTEM="NULL"
IPTABLES="OFF"
FILE_PRINT=""
VERSION="1.1"

ip_print(){
	if /sbin/ifconfig eth1 &> /dev/null;then
		ETH1=$(/sbin/ifconfig eth1 | grep inet | awk '{print $2}' | awk -F ":" '{print $2}')
	fi
	ETH0=$(/sbin/ifconfig eth0 | grep inet | awk '{print $2}' | awk -F ":" '{print $2}')
}

system_print(){
	if cat /etc/issue &> /dev/null;then
		SYSTEM=$(cat /etc/issue | head -n 1)
	fi
}

i_print(){
  if iptables -L -n &> /dev/null;then
     ICOUNT=$(iptables -L -n |wc -l)
     if [ $ICOUNT -le 8 ];then
         IPTABLES="OFF"
     else
         IPTABLES="ON"
     fi
  fi
}

iptables_print(){
if /sbin/ifconfig eth1 &> /dev/null;then
	i_print
else
  if ping www.baidu.com -c 3 &> /dev/null;then
		i_print
  fi
fi
}

file_print(){
    mkdir -p /tmp/file_print/
	rm -f /tmp/file_print/*
	FILE_PRINT=/tmp/file_print/${HOSTNAME}"_"${ETH0}"_"${DATE}
	echo "HOSTNAME:$HOSTNAME"  > $FILE_PRINT
	echo "ETH0:$ETH0" >> $FILE_PRINT
	echo "ETH1:$ETH1" >> $FILE_PRINT
	echo "SYSTEM:$SYSTEM" >> $FILE_PRINT
	echo "IPTABLES:$IPTABLES" >> $FILE_PRINT
	echo "version:$VERSION" >> $FILE_PRINT
	cat $FILE_PRINT
}

ip_print
system_print
iptables_print
file_print