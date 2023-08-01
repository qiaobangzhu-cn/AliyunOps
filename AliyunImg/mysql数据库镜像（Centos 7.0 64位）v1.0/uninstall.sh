#!/bin/bash

if [ "$1" != "in" ];then
	echo "Before cleaning the installation script environment !"
	echo "Please backup your data !!"
	read -p "Enter the y or Y to continue:" isY
	if [ "${isY}" != "y" ] && [ "${isY}" != "Y" ];then
	   exit 1
	fi
fi

mkdir -p /alidata
if which mkfs.ext4 > /dev/null ;then
	if ls /dev/xvdb1 &> /dev/null;then
	   if cat /etc/fstab|grep /alidata > /dev/null ;then
			if cat /etc/fstab|grep /alidata|grep ext3 > /dev/null ;then
				sed -i "/\/alidata/d" /etc/fstab
			fi
	   else
			echo '/dev/xvdb1             /alidata                 ext4    defaults        0 0' >> /etc/fstab
	   fi
	   mount -a
	fi
else
	if ls /dev/xvdb1 &> /dev/null;then
	   if cat /etc/fstab|grep /alidata > /dev/null ;then
			echo ""
	   else
			echo '/dev/xvdb1             /alidata                 ext3    defaults        0 0' >> /etc/fstab
	   fi
	   mount -a
	fi
fi

/etc/init.d/mysqld stop &> /dev/null
killall mysqld &> /dev/null




echo ""
echo "--------> Delete directory"
echo "/alidata/server/mysql             delete ok!" 
rm -rf /alidata/server/mysql
echo "rm -rf /alidata/server/mysql-*    delete ok!"
rm -rf /alidata/server/mysql-*


echo "/alidata/log/mysql                delete ok!"
rm -rf /alidata/log/mysql



echo ""
echo "--------> Delete file"
echo "/etc/my.cnf                delete ok!"
rm -f /etc/my.cnf
echo "/etc/init.d/mysqld         delete ok!"
rm -f /etc/init.d/mysqld



echo ""
ifrpm=$(cat /proc/version | grep -E "redhat|centos")
ifdpkg=$(cat /proc/version | grep -Ei "ubuntu|debian")
ifcentos=$(cat /proc/version | grep centos)
echo "--------> Clean up files"
echo "/etc/rc.local                   clean ok!"
if [ "$ifrpm" != "" ];then
	if [ -L /etc/rc.local ];then
		echo ""
	else
		\cp /etc/rc.local /etc/rc.local.bak
		rm -rf /etc/rc.local
		ln -s /etc/rc.d/rc.local /etc/rc.local
	fi
	sed -i "/\/etc\/init\.d\/mysqld.*/d" /etc/rc.d/rc.local
else
	sed -i "/\/etc\/init\.d\/mysqld.*/d" /etc/rc.local
fi

echo ""
echo "/etc/profile                    clean ok!"
sed -i "/export PATH=\$PATH\:\/alidata\/server\/mysql\/bin.*/d" /etc/profile
source /etc/profile

rm -rf /alidata
echo "uninstall is OK!"