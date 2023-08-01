#!/bin/bash

ETH0=$(ifconfig eth0 | grep inet | awk '{print $2}' | awk -F ":" '{print $2}')

if [ "$(cat /proc/version | grep centos)" != "" ];then
   INIT_SCRIPT_URI="http://git.jiagouyun.com/operation/operation/raw/master/linux/centos/zy_centos6_init.sh"
   INIT_SCRIPT_NAME=`basename $INIT_SCRIPT_URI`
   if [ ! -s $INIT_SCRIPT_NAME ]; then
      wget -c $INIT_SCRIPT_URI
   fi
   echo "srv-test-test" | bash $INIT_SCRIPT_NAME &>/dev/null
   HOSTNAME=zhuyun-img
   hostname $HOSTNAME
   sed -ri "s/^HOSTNAME.*/HOSTNAME=$HOSTNAME/g" /etc/sysconfig/network
   sed -ri "s/^${ETH0}.*/${ETH0} ${HOSTNAME}/g" /etc/hosts
   ##default zyadmin passwd####
   PASS=ujguWgXT
   echo "$PASS" | passwd zyadmin --stdin
elif [ "$(cat /proc/version | grep ubuntu)" != "" ];then
   INIT_SCRIPT_URI="http://git.jiagouyun.com/operation/operation/raw/master/linux/ubuntu/zy_ubuntu_init.sh"
   INIT_SCRIPT_NAME=`basename $INIT_SCRIPT_URI`
   if [ ! -s $INIT_SCRIPT_NAME ]; then
      wget -c $INIT_SCRIPT_URI
   fi
   echo "srv-test-test" | bash $INIT_SCRIPT_NAME &>/dev/null
   HOSTNAME=zhuyun-img
   hostname $HOSTNAME
   echo $HOSTNAME > /etc/hostname
   sed -ri "s/^${ETH0}.*/${ETH0} ${HOSTNAME}/g" /etc/hosts
   ##default zyadmin passwd####
   PASS=ujguWgXT
   echo zyadmin:"$PASS" | chpasswd
fi

###install zabbix  client#####
ZABBIX_SCRIPT_URI="http://git.jiagouyun.com/operation/operation/raw/master/zabbix/zabbix_agentd-2.2.3.sh"
ZABBIX_SCRIPT_NAME=`basename $ZABBIX_SCRIPT_URI`

if [ ! -s $ZABBIX_SCRIPT_NAME ]; then
      wget -c $ZABBIX_SCRIPT_URI
fi
bash $ZABBIX_SCRIPT_NAME


###install salt minion###
SALT_SCRIPT_URI="http://git.jiagouyun.com/operation/operation/raw/master/saltstack/salt_client_install.sh"
SALT_SCRIPT_NAME=`basename $SALT_SCRIPT_URI`

if [ ! -s $SALT_SCRIPT_NAME ]; then
      wget -c $SALT_SCRIPT_URI
fi


if [ "$(cat /proc/version | grep centos)" != "" ];then
   echo "zhuyun-img" |  bash $SALT_SCRIPT_NAME #&>/dev/null
   echo "zhuyun-img" |  bash $SALT_SCRIPT_NAME #&>/dev/null
else 
   echo "zhuyun-img" |  bash $SALT_SCRIPT_NAME #&>/dev/null
   update-rc.d salt-minion defaults
fi


###set iptables####
IPTABLES_SCRIPT_URI="http://git.jiagouyun.com/operation/operation/raw/master/linux/sys/iptables.sh"
IPTABLES_SCRIPT_NAME=`basename $IPTABLES_SCRIPT_URI`

if [ ! -s $IPTABLES_SCRIPT_NAME ]; then
      wget -c $IPTABLES_SCRIPT_URI
fi
bash $IPTABLES_SCRIPT_NAME
mv $IPTABLES_SCRIPT_NAME /etc/
echo bash -x /etc/$IPTABLES_SCRIPT_NAME >> /etc/rc.local


###update openssl###
if [ "$(cat /proc/version | grep centos)" != "" ];then
   yum install -y openssl-devel
elif [ "$(cat /proc/version | grep ubuntu)" != "" ];then
   apt-get install -y libssl-dev
fi 


if ls /usr/local/ssl > /dev/null ;then
   if openssl version -a |grep "OpenSSL 1.0.1h"  > /dev/null;then 
      exit 0
   fi
fi
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
rm -rf openssl-1.0.1h
if [ ! -f openssl-1.0.1h.tar.gz ];then
   wget http://t-down.oss-cn-hangzhou.aliyuncs.com/openssl-1.0.1h.tar.gz
fi
tar zxvf openssl-1.0.1h.tar.gz
cd openssl-1.0.1h
\mv /usr/local/ssl /usr/local/ssl.OFF
./config shared zlib
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
\mv /usr/bin/openssl /usr/bin/openssl.OFF
\mv /usr/include/openssl /usr/include/openssl.OFF
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/ssl/include/openssl /usr/include/openssl
if ! cat /etc/ld.so.conf| grep "/usr/local/ssl/lib" >> /dev/null;then
   echo "/usr/local/ssl/lib" >> /etc/ld.so.conf
fi
ldconfig -v
openssl version -a

if [ "$(cat /proc/version | grep centos)" != "" ];then
   /etc/init.d/sshd restart
else
   /etc/init.d/ssh restart
fi


mkdir /alidata
if [ "$(cat /proc/version | grep centos)" != "" ];then
cp script/zy_centos_system_config.sh   /alidata
else
cp script/zy_ubuntu_system_config.sh  /alidata
fi 
