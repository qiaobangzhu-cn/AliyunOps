#!/bin/bash
###init ftp password##
chmod 755 /alidata/account.log
ifrpm=$(cat /proc/version | grep -E "redhat|centos")
MATRIX="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
LENGTH="9"
while [ "${n:=1}" -le "$LENGTH" ]
do
        PASS="$PASS${MATRIX:$(($RANDOM%${#MATRIX})):1}"
        let n+=1
done
if [ "$ifrpm" != "" ];then
echo $PASS | passwd --stdin www
else
echo "www:$PASS" | chpasswd
fi

sed -ri s/'^ftp_password.*'/ftp_password:${PASS}/g  /alidata/account.log


###init mysql password##
TMP_PASS=$(date | md5sum |head -c 10)
OLD_PASS=`awk -F:  '/mysql/ {print $2}' /alidata/account.log`
if [ "$OLD_PASS" = "mysql_password" ]
then
/alidata/server/mysql/bin/mysqladmin -uroot password "$TMP_PASS"
else
/alidata/server/mysql/bin/mysqladmin -uroot -p$OLD_PASS password "$TMP_PASS"
fi

sed -ri s/'^mysql_password.*'/mysql_password:${TMP_PASS}/g /alidata/account.log

chmod 400 /alidata/account.log

#if grep "/alidata/init/initPasswd.sh" /root/.bashrc >/dev/null;then
#sed -i "/\/alidata\/init\/initPasswd.sh/d"  /root/.bashrc
#fi

echo "password in /alidata/account.log"