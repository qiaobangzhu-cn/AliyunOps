#!/bin/bash

Enabled=2
Disabled=1

# Header line will be added togather
#echo ${CommonHeader}passwordComplexity > Password_Complexity.csv

if  uname -a |grep -E "el6|el7"  > /dev/null
then
   iscentos=1
else
   iscentos=0
fi

echo '###是否启用密码复杂性要求' 1>&2

if [ "$iscentos" -eq "1" ]
then
cat /etc/pam.d/system-auth |grep requisite|grep password |grep difok |grep -v "^#" > /dev/null  && passwordComplexity=${Enabled} ||passwordComplexity=${Disabled}
else
###ubuntu
cat /etc/pam.d/common-password |grep requisite|grep password |grep difok |grep -v "^#" > /dev/null  && passwordComplexity=${Enabled} ||passwordComplexity=${Disabled}
fi

echo ${CommonInfo}${passwordComplexity} >> Password_Complexity.csv

mv Password_Complexity.csv ../${UploadDir}/
