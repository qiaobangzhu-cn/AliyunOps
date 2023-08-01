#!/bin/bash

CsvFileName=Password_NeverExpire.csv
KeyWord=passwordNeverExpire

# Header line will be added togather
#echo ${CommonHeader}${KeyWord} > ${CsvFileName}

if  uname -a |grep -E "el6|el7"  > /dev/null
then
   iscentos=1
else
   iscentos=0
fi
echo '### 永不过期密码用户' 1>&2

CAN_LOGIN_USER=`cat /etc/passwd |grep -v /sbin/nologin |grep /bin/bash |awk -F":" '{print $1}'`
LONG_TIME_USER=`cat /etc/shadow |grep :99999:|awk -F":" '{print $1}'`
passwordNeverExpire=$(echo $CAN_LOGIN_USER $LONG_TIME_USER|sed 's/ /\n/g' |sort |uniq -c |grep -v "1 " |awk '{print $2}'|tr '\n' ';' )

echo ${CommonInfo}${passwordNeverExpire%;} >> ${CsvFileName}

mv ${CsvFileName} ../${UploadDir}/
