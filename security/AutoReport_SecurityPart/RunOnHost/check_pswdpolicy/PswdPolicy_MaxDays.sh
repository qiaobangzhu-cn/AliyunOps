#!/bin/bash

if  uname -a |grep -E "el6|el7"  > /dev/null
then
   iscentos=1
else
   iscentos=0
fi
echo '###密码最长使用期限'
cat /etc/login.defs |grep PASS_MAX_DAYS |grep -v "^#" |awk '{print $2}'
