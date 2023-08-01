#!/bin/bash
./mysql/install-mysql.sh
echo "---------- rc init ok ----------" >> tmp.log
TMP_PASS=$(date | md5sum |head -c 10)
/alidata/mysql/bin/mysqladmin -u root password "$TMP_PASS"
cat > /alidata/account.log << END
##########################################################################
# 
# thank you for using aliyun virtual machine
# 
##########################################################################


MySQL:
account:root
mysql_password:mysql_password
END

sed -i s/'mysql_password:mysql_password'/mysql_password:${TMP_PASS}/g /alidata/account.log
echo "---------- mysql init ok ----------" >> tmp.log
mkdir /alidata/init
echo '#!/bin/bash
chmod 755 /alidata/account.log
#modify mysql passwd
PASS=$(date | md5sum |head -c 10)
OLDPASSWD=$(grep mysql_password /alidata/account.log|cut -d: -f2)
/alidata/mysql/bin/mysqladmin -uroot -p$OLDPASSWD password $PASS
sed -i "s/mysql_password:${OLDPASSWD}/mysql_password:${PASS}/" /alidata/account.log
chmod 400 /alidata/account.log
sed -i "/\/alidata\/init.*/d" /etc/rc.local' > /alidata/init/initPasswd.sh

\cp ./init/firstlogin.sh /alidata/init/
echo "sh /alidata/init/initPasswd.sh" >> /etc/rc.local
./env/openssl.sh

echo '
LoginNum=$(grep "session opened for user root"  /var/log/secure  | grep sshd | wc -l)
if [ $LoginNum -le 5 ];then
/alidata/init/firstlogin.sh
else
sed -i "/LoginNum/,$ d" /root/.bashrc
fi' >> /root/.bashrc


echo 0 > /var/log/secure
bash
