#!/bin/bash
#########################################################
# ZY aliyun  post script for 
# change hostname
# zabbix_agentd hostname
# @Author  : yinchuan@jiagouyun.com
#########################################################
# 2015-04-14  post script
#
#set -x
zabbix_agentd_prefix="/usr/local/zabbix-agentd"
ETH1=""
if ifconfig eth1 &> /dev/null;then
   ETH1=$(ifconfig eth1 | grep inet | awk '{print $2}' | awk -F ":" '{print $2}')
fi
ETH0=$(ifconfig eth0 | grep inet | awk '{print $2}' | awk -F ":" '{print $2}')

hostname_check(){
    HOSTNAME=$1
    while [ -z "$HOSTNAME" ];do
        printf "Please input %s: " "hostname"
        read HOSTNAME
    done
}


change_hostname(){
    # change hostname for server
    hostname $HOSTNAME
    echo $HOSTNAME > /etc/hostname
    #echo "127.0.0.1 $HOSTNAME" >> /etc/hosts
    sed -ri "s/^${ETH0}.*/${ETH0} ${HOSTNAME}/g" /etc/hosts
    #sed -ri "s/^HOSTNAME.*/HOSTNAME=$HOSTNAME/g" /etc/sysconfig/network
    #sed -ri "s/^${ETH0}.*/${ETH0} ${HOSTNAME}/g" /etc/hosts
}

change_zabbix_agentd_config(){
  ##change zabbix agentd Hostname config##
    name=$HOSTNAME
    sed -ri "s/^Hostname=.*/Hostname=${name}/" ${zabbix_agentd_prefix}/etc/zabbix_agentd.conf
}



change_zyadmin_passwd(){
    echo zyadmin:"$PASS" | chpasswd
    # set random password
    
    MATRIX1="0123456789"
    MATRIX2="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    MATRIX3="abcdefghijklmnopqrstuvwxyz"
    MATRIX4="./*&^%$#@!()"
    # May change 'LENGTH' for longer password, of course.
    LENGTH="8"
    
    
    ii=1
    while [ "${n:=1}" -le "$LENGTH" ]; do
        MATRIX=`eval echo "$"MATRIX${ii}`
        PASS="$PASS${MATRIX:$(($RANDOM%${#MATRIX})):1}"
        PASS2="$PASS2${MATRIX:$(($RANDOM%${#MATRIX})):1}"
        let n+=1
        ii=`expr $ii + 1`
        if [ $ii -eq 5 ];then
            ii=1
        fi
    done
    
    echo zyadmin:$PASS | chpasswd
    echo www:$PASS2 | www

}

output_passwd(){
    PASS_FILE=/tmp/pass_temp
    HOSTNAME=$HOSTNAME
    echo "----SYSTEM INFORMATION---- " > $PASS_FILE
    if [ ! "$ETH1" = "" ];then
      echo "    eth1 is $ETH1" >> $PASS_FILE
    fi
    
    echo "    eth0 is $ETH0
    hostname is $HOSTNAME
    username is zyadmin
    port is 40022
    password zyadmin is $PASS
    password www is $PASS2
-----------END-----------" >> $PASS_FILE
    cat $PASS_FILE
    rm -rf $PASS_FILE
    exit 0
}

restart_zabbix_agentd(){
    /etc/init.d/zabbix-agent restart
}



main(){
   
      #start change hostname#
    hostname_check
      while [[ "$HOSTNAME" != srv-*-* ]];do
          echo "Wrong name,example:srv-xxx-xxx"; hostname_check
      done
    change_hostname
    #end change hostname#
    
    change_zabbix_agentd_config
    restart_zabbix_agentd


    change_zyadmin_passwd
    output_passwd
}

main


