#!/bin/bash

####---- global variables ----begin####
export httpd_version=2.2.29
export mysql_version=5.6
export php_version=5.2/5.3/5.4/5.5
export vsftpd_version=2.2.2
export sphinx_version=0.9.9
export install_ftp_version=0.0.0
####---- global variables ----end####


web=apache
install_log=/alidata/website-info.log


####---- version selection ----begin####
echo "You select the version :"
echo "apache : $httpd_version"
echo "php    : $php_version"
echo "mysql  : $mysql_version"
read -p "Enter the y or Y to continue:" isY
if [ "${isY}" != "y" ] && [ "${isY}" != "Y" ];then
   exit 1
fi
####---- version selection ----end####


####---- Clean up the environment ----begin####
echo "will be installed, wait ..."
./uninstall.sh in &> /dev/null
####---- Clean up the environment ----end####

if [ `uname -m` == "x86_64" ];then
machine=x86_64
else
machine=i686
fi

####---- install dependencies ----begin####
rpm -e httpd-2.2.3-31.el5.centos gnome-user-share &> /dev/null

\cp /etc/rc.local /etc/rc.local.bak > /dev/null

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5 &> /dev/null
sed -i 's/^exclude/#exclude/' /etc/yum.conf
yum makecache
yum -y remove mysql MySQL-python perl-DBD-MySQL dovecot exim qt-MySQL perl-DBD-MySQL dovecot qt-MySQL mysql-server mysql-connector-odbc php-mysql mysql-bench libdbi-dbd-mysql mysql-devel-5.0.77-3.el5 httpd php mod_auth_mysql mailman squirrelmail php-pdo php-common php-mbstring php-cli &> /dev/null
yum -y install gcc gcc-c++ gcc-g77 make libtool autoconf patch unzip automake libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl libmcrypt libmcrypt-devel libpng libpng-devel libjpeg-devel openssl openssl-devel curl curl-devel libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl autoconf automake libaio*
yum -y update bash
iptables -F

####---- install dependencies ----end####

####---- install software ----begin####
rm -f tmp.log
echo tmp.log

./env/install_set_sysctl.sh
./env/install_set_ulimit.sh

./env/install_dir.sh
echo "---------- make dir ok ----------" >> tmp.log



./env/install_env_php.sh
echo "---------- env ok ----------" >> tmp.log



./mysql/install_mysql-5.6.21.sh
echo "----------mysql-5.6.21 ok ----------" >> tmp.log



./apache/install_httpd-3.sh
./apache/install_httpd-4.sh
./apache/install_httpd-5.sh
./apache/install_httpd-2.sh
echo "---------- apache  ok ----------" >> tmp.log

	
./php/install_httpd_php-5.2.17.sh
./php/install_httpd_php-5.4.23.sh
./php/install_httpd_php-5.5.7.sh
./php/install_httpd_php-5.3.29.sh
echo "---------- php  ok ----------" >> tmp.log



./php/install_php_extension.sh
echo "---------- php extension ok ----------" >> tmp.log


./ftp/install_vsftpd-2.2.2.sh
install_ftp_version=$(vsftpd -v 0> vsftpd_version && cat vsftpd_version |awk -F: '{print $2}'|awk '{print $2}' && rm -f vsftpd_version)
echo "---------- vsftpd-$install_ftp_version  ok ----------" >> tmp.log

./res/install_soft.sh
echo "---------- phpinfo ok ----------" >> tmp.log
####---- install software ----end####


####---- Start command is written to the rc.local ----begin####

if ! cat /etc/rc.local | grep "/etc/init.d/mysqld" > /dev/null;then 
	echo "/etc/init.d/mysqld start" >> /etc/rc.local
fi
if ! cat /etc/rc.local | grep "/etc/init.d/httpd" > /dev/null;then 
	echo "/etc/init.d/httpd start" >> /etc/rc.local
fi
if ! cat /etc/rc.local | grep "/etc/init.d/vsftpd" > /dev/null;then 
	echo "/etc/init.d/vsftpd start" >> /etc/rc.local
fi

####---- Start command is written to the rc.local ----end####


####---- centos yum configuration----begin####

sed -i 's/^#exclude/exclude/' /etc/yum.conf

mkdir -p /var/lock/subsys/

####---- centos yum configuration ----end####

####---- mysql password initialization ----begin####
echo "---------- rc init ok ----------" >> tmp.log
TMP_PASS=$(date | md5sum |head -c 10)
/alidata/server/mysql/bin/mysqladmin -u root password "$TMP_PASS"
sed -i s/'mysql_password:mysql_password'/mysql_password:${TMP_PASS}/g /alidata/account.log
echo "---------- mysql init ok ----------" >> tmp.log
####---- mysql password initialization ----end####


####---- Environment variable settings ----begin####
\cp /etc/profile /etc/profile.bak

/etc/init.d/httpd restart &> /dev/null

echo 'export PATH=$PATH:/alidata/server/mysql/bin:/alidata/server/httpd/bin:/alidata/server/php/sbin:/alidata/server/php/bin' >> /etc/profile
export PATH=$PATH:/alidata/server/mysql/bin:/alidata/server/httpd/bin:/alidata/server/php/sbin:/alidata/server/php/bin
####---- Environment variable settings ----end####


####---- restart ----begin####

/etc/init.d/httpd restart &> /dev/null
/etc/init.d/vsftpd restart &> /dev/null
####---- restart ----end####

####---- openssl update---begin####
./env/update_openssl.sh
####---- openssl update---end####

\cp -fr init    /alidata

if [ "$ifcentos" != "" ];then
  >/var/log/secure
  echo 'LoginNum=$(grep "session opened for user root"  /var/log/secure | grep sshd | wc -l)' >> /root/.bashrc
else
  >/var/log/auth.log
  echo 'LoginNum=$(grep "session opened for user root"  /var/log/auth.log | grep sshd | wc -l)' >> /root/.bashrc
fi 

echo 'if [ $LoginNum -le 5 ];then' >>/root/.bashrc

cat >>/root/.bashrc<<END
LoginNum=$(grep "session opened for user root"  /var/log/secure  | grep sshd | wc -l)
if [ $LoginNum -le 5 ];then
/alidata/init/firstlogin.sh
else
sed -i '/LoginNum/,$ d' .bashrc
fi
END

####---- log ----begin####
\cp tmp.log $install_log
cat $install_log
source /etc/profile &> /dev/null
source /etc/profile.d/profile.sh &> /dev/null
/etc/init.d/httpd restart &> /dev/null


echo "sh /alidata/init/initPasswd.sh" >> /etc/rc.d/rc.local

chown www:www /alidata/www/ -R
##重读/etc/profile##
bash

####---- log ----end####

echo 0 > /var/log/secure


