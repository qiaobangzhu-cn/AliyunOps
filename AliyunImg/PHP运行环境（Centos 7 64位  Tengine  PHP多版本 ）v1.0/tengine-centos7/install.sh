#!/bin/bash

####---- global variables ----begin####
export nginx_version=2.1.0
export mysql_version=5.6.21
#export phpwind_version=8.7
#export phpmyadmin_version=4.1.8
export vsftpd_version=2.2.2
#export sphinx_version=0.9.9
export install_ftp_version=0.0.0

####---- global variables ----end####
web=nginx
install_log=/alidata/website-info.log
php52=5.2.17
php53=5.3.29
php54=5.4.23
php55=5.5.7
php56=5.6.8


####---- Clean up the environment ----begin####
echo "will be installed, wait ..."
./uninstall.sh in &> /dev/null
####---- Clean up the environment ----end####


web_dir=nginx-${nginx_version}
php52_dir=php-${php52}
php53_dir=php-${php53}
php54_dir=php-${php54}
php55_dir=php-${php55}
php56_dir=php-${php56}


if [ `uname -m` == "x86_64" ];then
machine=x86_64
else
machine=i686
fi


####---- global variables ----begin####
export web
export web_dir
export mysql_dir=mysql-${mysql_version}
export mysql_dir=mysql-${mysql_version}
export vsftpd_dir=vsftpd-${vsftpd_version}
#export sphinx_dir=sphinx-${sphinx_version}
export php52_dir
export php53_dir
export php54_dir
export php55_dir
export php56_dir
####---- global variables ----end####


ifredhat=$(cat /proc/version | grep redhat)
ifcentos=$(cat /proc/version | grep centos)
ifubuntu=$(cat /proc/version | grep ubuntu)
ifdebian=$(cat /proc/version | grep -i debian)
ifgentoo=$(cat /proc/version | grep -i gentoo)
ifsuse=$(cat /proc/version | grep -i suse)

####---- install dependencies ----begin####
if [ "$ifcentos" != "" ] || [ "$machine" == "i686" ];then
rpm -e httpd-2.2.3-31.el5.centos gnome-user-share &> /dev/null
fi

\cp /etc/rc.local /etc/rc.local.bak > /dev/null
if [ "$ifredhat" != "" ];then
rpm -e --allmatches mysql MySQL-python perl-DBD-MySQL dovecot exim qt-MySQL perl-DBD-MySQL dovecot qt-MySQL mysql-server mysql-connector-odbc php-mysql mysql-bench libdbi-dbd-mysql mysql-devel-5.0.77-3.el5 httpd php mod_auth_mysql mailman squirrelmail php-pdo php-common php-mbstring php-cli &> /dev/null
fi

if [ "$ifredhat" != "" ];then
  \mv /etc/yum.repos.d/rhel-debuginfo.repo /etc/yum.repos.d/rhel-debuginfo.repo.bak &> /dev/null
  \cp ./res/rhel-debuginfo.repo /etc/yum.repos.d/
  yum makecache
  yum -y remove mysql MySQL-python perl-DBD-MySQL dovecot exim qt-MySQL perl-DBD-MySQL dovecot qt-MySQL mysql-server mysql-connector-odbc php-mysql mysql-bench libdbi-dbd-mysql mysql-devel-5.0.77-3.el5 httpd php mod_auth_mysql mailman squirrelmail php-pdo php-common php-mbstring php-cli &> /dev/null
  yum -y install gcc gcc-c++ gcc-g77 make libtool autoconf patch unzip automake fiex* libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl libmcrypt libmcrypt-devel libpng libpng-devel libjpeg-devel openssl openssl-devel curl curl-devel libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl autoconf automake freetype-devel libaio*
  iptables -F
elif [ "$ifcentos" != "" ];then
#	if grep 5.10 /etc/issue;then
	  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5 &> /dev/null
#	fi
  sed -i 's/^exclude/#exclude/' /etc/yum.conf
  yum makecache
  yum -y remove mysql MySQL-python perl-DBD-MySQL dovecot exim qt-MySQL perl-DBD-MySQL dovecot qt-MySQL mysql-server mysql-connector-odbc php-mysql mysql-bench libdbi-dbd-mysql mysql-devel-5.0.77-3.el5 httpd php mod_auth_mysql mailman squirrelmail php-pdo php-common php-mbstring php-cli &> /dev/null
  yum -y install gcc gcc-c++ gcc-g77 make libtool autoconf patch unzip  automake libxml2 libxml2-devel   ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl libmcrypt libmcrypt-devel libpng libpng-devel libjpeg-devel openssl openssl-devel curl curl-devel libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl autoconf automake freetype-devel libaio*
  yum -y update bash
  #ln -s /usr/lib64/mysql/libmysqlclient.so   /usr/lib/libmysqlclient.so   mysql-devel mysql
  #ln -s /usr/lib64/mysql/libmysqlclient_r.so   /usr/lib/libmysqlclient_r.so
  iptables -F
elif [ "$ifubuntu" != "" ];then
  apt-get -y update
  \mv /etc/apache2 /etc/apache2.bak &> /dev/null
  \mv /etc/nginx /etc/nginx.bak &> /dev/null
  \mv /etc/php5 /etc/php5.bak &> /dev/null
  \mv /etc/mysql /etc/mysql.bak &> /dev/null
  apt-get -y autoremove apache2 nginx php5 mysql-server &> /dev/null
  apt-get -y install unzip build-essential libncurses5-dev libfreetype6-dev  libxml2-dev  libssl-dev libcurl4-openssl-dev libjpeg62-dev libpng12-dev libfreetype6-dev libsasl2-dev libpcre3-dev autoconf libperl-dev libtool libaio*
  apt-get -y install --only-upgrade bash
  #ln -s /usr/lib/x86_64-linux-gnu/libmysqlclient_r.so /usr/lib/libmysqlclient_r.so  mysql-client libmysqld-dev
  #ln -s /usr/lib/x86_64-linux-gnu/libmysqlclient.so /usr/lib/libmysqlclient.so

  iptables -F
elif [ "$ifdebian" != "" ];then
  apt-get -y update
  \mv /etc/apache2 /etc/apache2.bak &> /dev/null
  \mv /etc/nginx /etc/nginx.bak &> /dev/null
  \mv /etc/php5 /etc/php5.bak &> /dev/null
  \mv /etc/mysql /etc/mysql.bak &> /dev/null
  apt-get -y autoremove apache2 nginx php5 mysql-server &> /dev/null
  apt-get -y install unzip psmisc build-essential libncurses5-dev libfreetype6-dev libxml2-dev libssl-dev libcurl4-openssl-dev libjpeg62-dev libpng12-dev libfreetype6-dev libsasl2-dev libpcre3-dev autoconf libperl-dev libtool libaio*
  apt-get -y install --only-upgrade bash
  iptables -F
elif [ "$ifgentoo" != "" ];then
  emerge net-misc/curl
elif [ "$ifsuse" != "" ];then
  zypper install -y libxml2-devel libopenssl-devel libcurl-devel
fi
####---- install dependencies ----end####

####---- install software ----begin####
rm -f tmp.log
echo tmp.log

./env/install_set_sysctl.sh
./env/install_set_ulimit.sh

if [ -e /dev/xvdb ] && [ "$ifsuse" == "" ] ;then
	./env/install_disk.sh
fi

./env/install_dir.sh
echo "---------- make dir ok ----------" >> tmp.log

./env/install_env_php.sh
echo "---------- env ok ----------" >> tmp.log

./mysql/install_${mysql_dir}.sh
echo "---------- ${mysql_dir} ok ----------" >> tmp.log

./nginx/install_tengine-2.1.0.sh

####install multi php####
#$php52 $php53 $php54 $php55 $php56
for php_version in  $php52 $php53 $php54 $php55 $php56
do
    ./php/install_nginx_php-${php_version}.sh
done	

####set default php version####
ln -s /alidata/server/$php54_dir  /alidata/server/php
ln -s /etc/init.d/php-fpm54 /etc/init.d/php-fpm
\cp ./php/switch    /bin/switch
chmod 755  /bin/switch



./ftp/install_${vsftpd_dir}.sh
install_ftp_version=$(vsftpd -v 0> vsftpd_version && cat vsftpd_version |awk -F: '{print $2}'|awk '{print $2}' && rm -f vsftpd_version)
echo "---------- vsftpd-$install_ftp_version  ok ----------" >> tmp.log


#./res/install_soft.sh
#  echo "---------- phpwind-$phpwind_version ok ----------" >> tmp.log
#  echo "---------- phpmyadmin-$phpmyadmin_version ok ----------" >> tmp.log
#  echo "---------- web init ok ----------" >> tmp.log

####---- mysql password initialization ----begin####
echo "---------- rc init ok ----------" >> tmp.log

echo "---------- mysql init ok ----------" >> tmp.log
####---- mysql password initialization ----end####


####---- Environment variable settings ----end####
if ! cat /etc/profile | grep "export PATH=$PATH:/alidata/server/mysql/bin:/alidata/server/nginx/sbin:/alidata/server/php/sbin:/alidata/server/php/bin" &> /dev/null;then
    echo 'export PATH=$PATH:/alidata/server/mysql/bin:/alidata/server/nginx/sbin:/alidata/server/php/sbin:/alidata/server/php/bin' >> /etc/profile
    #export PATH=$PATH:/alidata/server/mysql/bin:/alidata/server/nginx/sbin:/alidata/server/php/sbin:/alidata/server/php/bin
fi
source /etc/profile

####---- Start command is written to the rc.local ----end####
if ! cat /etc/rc.local | grep "/etc/init.d/mysqld" > /dev/null;then 
    echo "/etc/init.d/mysqld start" >> /etc/rc.local
fi

if ! cat /etc/rc.local | grep "/etc/init.d/php-fpm start" &> /dev/null;then
    echo "/etc/init.d/php-fpm start" >> /etc/rc.local
fi

if ! cat /etc/rc.local | grep "/etc/init.d/nginx start" &> /dev/null;then
    echo "/etc/init.d/nginx start" >> /etc/rc.local
fi

if grep -i "CentOS Linux release 7" /etc/redhat-release  &> /dev/null; then
   systemctl enable vsftpd
elif ! cat /etc/rc.local | grep "/etc/init.d/vsftpd" &> /dev/null;then 
    echo "/etc/init.d/vsftpd start" >> /etc/rc.local
fi


####---- centos yum configuration----begin####
if [ "$ifcentos" != "" ] && [ "$machine" == "x86_64" ];then
sed -i 's/^#exclude/exclude/' /etc/yum.conf
fi
if [ "$ifubuntu" != "" ] || [ "$ifdebian" != "" ];then
	mkdir -p /var/lock
	sed -i 's#exit 0#touch /var/lock/local#' /etc/rc.local
else
	mkdir -p /var/lock/subsys/
fi
####---- centos yum configuration ----end####



####---- make configure soft link----start#### 
mkdir /etc/nginx
ln -s /alidata/server/nginx/conf /etc/nginx/
mkdir /etc/php
ln -s /alidata/server/php/etc/php.ini /etc/php/
ln -s /alidata/server/php/etc/php-fpm.conf /etc/php/
ln -s /etc/my.cnf /alidata/server/mysql/my.cnf

####---- make configure soft link----end#### 

####---- restart ----begin####
/etc/init.d/mysqld  restart &> /dev/null
/etc/init.d/php-fpm restart &> /dev/null
/etc/init.d/nginx restart &> /dev/null
if grep -i "CentOS Linux release 7" /etc/redhat-release  &> /dev/null; then
   systemctl restart vsftpd
elif ! cat /etc/rc.local | grep "/etc/init.d/vsftpd" &> /dev/null;then 
  /etc/init.d/vsftpd restart &> /dev/null
fi



####---- restart ----end####


####---- openssl update---begin####
./env/update_openssl-1.0.2a.sh
####---- openssl update---end####

####set root login####
\cp -fr init    /alidata
\cp account.log  /alidata/account.log


if [ "$ifcentos" != "" ];then
  >/var/log/secure
  echo 'LoginNum=$(grep -a "session opened for user root"  /var/log/secure | grep sshd | wc -l)' >> /root/.bashrc
else
  >/var/log/auth.log
  echo 'LoginNum=$(grep -a "session opened for user root"  /var/log/auth.log | grep sshd | wc -l)' >> /root/.bashrc
fi 

echo 'if [ $LoginNum -le 5 ];then' >>/root/.bashrc
#/alidata/init/initPasswd.sh
cat >>/root/.bashrc<<END
/alidata/init/firstlogin.sh 
else
sed -i '/LoginNum/,$ d' .bashrc
fi
END
 
/alidata/init/initPasswd.sh
if grep -i "CentOS Linux release 7" /etc/redhat-release  &> /dev/null; then
  chmod +x /etc/rc.d/rc.local
fi
####---- log ----begin####
\cp tmp.log $install_log
cat $install_log
source /etc/profile &> /dev/null
source /etc/profile.d/profile.sh &> /dev/null
####---- log ----end####