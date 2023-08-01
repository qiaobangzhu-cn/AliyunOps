#!/bin/bash

if  uname -a |grep -E "el6|el7"  > /dev/null
then
   iscentos=1
else
   iscentos=0
fi
echo '##密码长度最小值'
if [ "$iscentos" -eq "1" ]
then
cat /etc/pam.d/system-auth |grep minlen > /dev/null && \
cat /etc/pam.d/system-auth |grep minlen|awk -F"minlen=" '{print $2}'|awk '{print $1}' ||cat /etc/login.defs |grep PASS_MIN_LEN |grep -v '#'|awk '{print $2}'
else
###ubuntu
cat /etc/pam.d/common-password |grep minlen |grep -v "^#" > /dev/null && \
cat /etc/pam.d/common-password |grep minlen |grep -v "^#" |awk -F"minlen=" '{print $2}'|awk '{print $1}' ||cat /etc/login.defs |grep PASS_MIN_LEN |grep -v '#'|awk '{print $2}'
fi
