#!/bin/bash

# Header line will be added togather
#echo ${CommonHeader}passwordEmptyUsers > Password_EmptyUsers.csv

if  uname -a |grep -E "el6|el7"  > /dev/null
then
   iscentos=1
else
   iscentos=0
fi

echo '###空密码用户' 1>&2
CAN_LOGIN_USER=`cat /etc/passwd |grep -v /sbin/nologin |grep /bin/bash |awk -F":" '{print $1}'`
NOPASSWD_USER=`cat /etc/shadow |grep ':!!:' |awk -F":" '{print $1}'`
passwordEmptyUsers=$(echo $CAN_LOGIN_USER $NOPASSWD_USER|sed 's/ /\n/g' |sort |uniq -c |grep -v "1 " |awk '{print $2}'|tr '\n' ';' )

echo ${CommonInfo}${passwordEmptyUsers%;} >> Password_EmptyUsers.csv

mv Password_EmptyUsers.csv ../${UploadDir}/
