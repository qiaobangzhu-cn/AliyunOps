#!/bin/bash

#Script created 2016-07-20
#Modify by 2016-07-23,mark:
## ifconfig modify /sbin/ifconfig ,because bug for env

DATE=$(date +%Y%m%d)
HOSTNAME=$(hostname)
export HOSTNAME

ETH0=""
ETH1=""
SYSTEM="NULL"
IPTABLES="OFF"
FILE_PRINT=""
VERSION="1.1"

ip_print(){
	if /sbin/ifconfig eth1 >/dev/null 2>&1 ;then
		ETH1=$(/sbin/ifconfig eth1 | grep "inet "| awk '{print $2}' | awk -F ":" '{print $NF}')
		export public_ip=${ETH1}
	fi
	ETH0=$(/sbin/ifconfig eth0 | grep "inet "| awk '{print $2}' | awk -F ":" '{print $NF}')
	export private_ip=${ETH0}
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
#    mkdir -p /tmp/file_print/
#	rm -f /tmp/file_print/*
#	FILE_PRINT=/tmp/file_print/${HOSTNAME}"_"${ETH0}"_"${DATE}
#	echo "HOSTNAME:$HOSTNAME"  > $FILE_PRINT
#	echo "ETH0:$ETH0" >> $FILE_PRINT
#	echo "ETH1:$ETH1" >> $FILE_PRINT
#	echo "SYSTEM:$SYSTEM" >> $FILE_PRINT
#	echo "IPTABLES:$IPTABLES" >> $FILE_PRINT
#	echo "version:$VERSION" >> $FILE_PRINT
	OutputFile=${project_id}_${HOSTNAME}_${ETH0}_${ETH1}.csv
}

ip_print
#system_print
#iptables_print
file_print

check(){
# color settings
RED="\033[0;31m"
GREEN="\033[0;32m"
NO_COLOR="\033[0m"

#SYSTEM_VERSION=`lsb_release -a 2>/dev/null|grep Description |awk -F ":" '{print $2}'`
DistribInfo(){
if [ -f /etc/redhat-release ] ; then
	awk '{print $1" "$3}' /etc/redhat-release 
	exit 0
fi

lsb_release >/dev/null 2>&1
if [ $? = 0 ]
then
  lsb_release -ds | sed 's/^\"//g;s/\"$//g'
# a bunch of fallbacks if no lsb_release is available
# first trying /etc/os-release which is provided by systemd
elif [ -f /etc/os-release ]
then
  source /etc/os-release
  if [ -n "${PRETTY_NAME}" ]
  then
    printf "${PRETTY_NAME}\n"
  else
    printf "${NAME}"
    [[ -n "${VERSION}" ]] && printf " ${VERSION}"
    printf "\n"
  fi
# now looking at distro-specific files
elif [ -f /etc/arch-release ]
then
  printf "Arch Linux\n"
elif [ -f /etc/gentoo-release ]
then
  cat /etc/gentoo-release
elif [ -f /etc/fedora-release ]
then
  cat /etc/fedora-release
elif [ -f /etc/redhat-release ]
then
  cat /etc/redhat-release
elif [ -f /etc/debian_version ]
then
  printf "Debian GNU/Linux " ; cat /etc/debian_version
else
  printf "Unknown\n"
fi
}

SYSTEM_VERSION=$(DistribInfo)

SHELL_VERSION=`bash --version |head -n 1 |awk -F "-" '{print $1}'`
OPENSSL_VERSION=`openssl version |awk -F " " '{print $2}'`
KERNEL_RELEASE=`uname -r |awk -F "-" '{print $1}'`
PROCESSOR=`uname -m`

check_tomcat(){
TOMCAT_PROCESS=`ps aux |grep tomcat |grep config.file | awk -F "-classpath" '{print $2}' |awk -F "/bin" '{print $1}'`
ls ${TOMCAT_PROCESS}/bin/version.sh &> /dev/null
if [ $? -eq 0 ]
then
tomcat_version=\"`bash ${TOMCAT_PROCESS}/bin/version.sh |grep 'Server version' |awk -F "/" '{print $2}'`\"
else
tomcat_version=null
fi
}

check_nginx(){
`nginx -v &> /dev/null`
if [ $? -eq 0 ]
then
nginx_version=\"`nginx -v 2>&1`\"
else
nginx_version=null
fi
}

check_apache(){
`httpd -v &> /dev/null`
if [ $? -eq 0 ]
then
apache_version=\"`httpd -v |head -n 1 | awk -F "/" '{print $2}'`\"
else
apache_version=null
fi
}

check_iptables(){

#iptables input all
#echo -e "${GREEN}---------iptables_input_all_list-------
#num  target   source$NO_COLOR"
#iptables -vnL INPUT --line-numbers |grep 'ACCEPT ' |egrep -v 'type|RELATED|lo|Chain' |grep all|awk -F " " '{print $1"    "$4"   "$9"   ""(all)"}'

#iptables input dcp
echo \#iptables INPUT exception:
#echo -e "${GREEN}---------iptables_input_dcp_list-------$NO_COLOR"
echo "num,dpt"
iptables -nL INPUT --line-numbers |egrep "'ACCEPT '|dpt" |awk -F " " '{print $1","$NF}'

#iptables output dcp
#echo -e "${GREEN}---------iptables_ouput_dcp_list-------
#num  dcp$NO_COLOR"
#iptables -nL OUTPUT --line-numbers |egrep "'ACCEPT '|dpt" |awk -F " " '{print $1 $10}' |awk -F "dpt:" '{print $1"    "$2}'

}

#echo -e "${GREEN}The SYSTEM_VERSION is "${SYSTEM_VERSION}" ${KERNEL_RELEASE} ${PROCESSOR}
#The Shell_VERSION is "${SHELL_VERSION}"
#The OpenSSL_VERSION is "${OPENSSL_VERSION}" $NO_COLOR"
check_apache
check_tomcat
check_nginx

# New output
echo -e "\"kernel\",\"${KERNEL_RELEASE}\""
echo -e "\"architeture\",\"${PROCESSOR}\""
echo -e "\"distribution\",\"${SYSTEM_VERSION}\""
echo -e "\"shell\",\"${SHELL_VERSION}\""
echo -e "\"openssl\",\"${OPENSSL_VERSION}\""
echo -e "\"apache\",${apache_version}"
echo -e "\"tomcat\",${tomcat_version}"
echo -e "\"nginx\",${nginx_version}"


check_iptables

}

export CommonHeader=project_id,hostname,private_ip,public_ip,
CommonInfo=${project_id},$(hostname),${ETH0},${ETH1},
export CommonInfo

#bash check.sh > ${OutputFile}

check > ${OutputFile}
mv ${OutputFile} ..

# check_network
sh check_log/log_boot.sh
#sh check_log/log_wtmp.sh
#sh check_log/log_secure.sh

# check_network
sh check_network/Network_CheckUrlStatus.sh
sh check_network/Network_CheckFirewall.sh

sh check_pswdpolicy/PswdPolicy_EmptyPswd.sh
sh check_pswdpolicy/PswdPolicy_ComplexPswd.sh
sh check_pswdpolicy/PswdPolicy_NeverExpire.sh

sh check_user/UserSudoer.sh
sh check_user/UserFtpUser.sh
