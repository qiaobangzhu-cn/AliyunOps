#!/bin/bash

yum -y install vsftpd
\cp -f ./ftp/config-ftp/rpm_ftp/* /etc/vsftpd/

rm -rf /etc/vsftpd/vsftpd.conf
\cp -f ./ftp/config-ftp/vsftpdcentosi686.conf /etc/vsftpd/vsftpd.conf

chown -R www:www /alidata/www

#bug kill: '500 OOPS: vsftpd: refusing to run with writable root inside chroot()'
chmod a-w /alidata/www

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

sed -i s/'ftp_password:ftp_password'/ftp_password:${PASS}/g /alidata/account.log