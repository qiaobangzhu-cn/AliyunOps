#!/bin/bash

#By default, it is used to display the real host name of the system.
HOSTNAME_SET="\H"

#Optional, display the custom hostname in TTY, and the real hostname remains unchanged.
#HOSTNAME_SET=""

ETH0=$(ip a | grep -A 0 "eth0" | awk -F "[ /]*" '/inet/ {print $3}')
IPADDRS="eth0 = $ETH0"

if ifconfig eth1 &> /dev/null;then
   ETH1=$(ip a | grep -A 0 "eth1" | awk -F "[ /]*" '/inet/ {print $3}')
   IPADDRS="$IPADDRS       eth1 = $ETH1"
fi

if [ $UID -eq 0 ]
then
        PS1="\n\n\033[1;34m[\u@$HOSTNAME_SET]\e[m  \033[1;33m$IPADDRS\e[m \n[\t] PWD => \033[1;35m\w\e[m\n\#># "
else
        PS1="\n\n\033[1;34m[\u@$HOSTNAME_SET]\e[m  \033[1;33m$IPADDRS\e[m \n[\t] PWD => \033[1;35m\w\e[m\n\#>\$ "
fi

if [ "$(cat /proc/version | grep ubuntu)" != "" ];then
	if /usr/bin/id zyadmin &> /dev/null && [ -f /home/zyadmin/.profile ]; then
	   if ! cat /home/zyadmin/.profile | grep "source /etc/profile.d/zy_tty.sh" &> /dev/null ;then
	      echo "source /etc/profile.d/zy_tty.sh" >> /home/zyadmin/.profile
	   fi
	fi

    if [ -f /root/.profile ];then
	   if ! cat /root/.profile | grep "source /etc/profile.d/zy_tty.sh" &> /dev/null ;then
	      echo "source /etc/profile.d/zy_tty.sh" >> /root/.profile
	   fi
    fi
fi