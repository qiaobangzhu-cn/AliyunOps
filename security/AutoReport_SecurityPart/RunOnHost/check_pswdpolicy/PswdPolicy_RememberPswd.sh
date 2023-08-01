#!/bin/bash

if  uname -a |grep -E "el6|el7"  > /dev/null
then
   iscentos=1
else
   iscentos=0
fi
echo '###强制密码历史'
if [ "$iscentos" -eq "1" ]
then
cat /etc/pam.d/system-auth |grep sufficient |grep password |grep remember|grep -v "^#" > /dev/null && \
cat /etc/pam.d/system-auth |grep sufficient |grep password |grep remember|grep -v "^#" |awk -F"remember=" '{print $2}'|awk '{print $1}'  ||echo "未启用"
else
###ubuntu
cat /etc/pam.d/common-password |grep sufficient |grep password |grep remember|grep -v "^#" > /dev/null && \
cat /etc/pam.d/common-password |grep sufficient |grep password |grep remember|grep -v "^#"| awk -F"remember=" '{print $2}'|awk '{print $1}'  ||echo "未启用"
fi
