#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/ftp/config-ftp.tar.gz"
PKG_NAME=`basename $SRC_URI`
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l) 
if [ `uname -m` == "x86_64" ];then
  machine=x86_64
else
  machine=i686
fi
ifrpm=$(cat /proc/version | grep -E "redhat|centos")
ifdpkg=$(cat /proc/version | grep -Ei "ubuntu|debian")
ifcentos=$(cat /proc/version | grep centos)
ifubuntu=$(cat /proc/version | grep ubuntu)

userdel www
groupadd www

if [ "$ifubuntu" != "" ];then
useradd -g www -M -d /alidata/www -s /usr/sbin/nologin www &> /dev/null
else
useradd -g www -M -d /alidata/www -s /sbin/nologin www &> /dev/null
fi

rpm -qa | grep vsftpd
if [ "$?" -eq "0" ];then
    if [ "$ifrpm" != "" ];then
	    yum -y remove vsftpd
    else
	    apt-get -y remove vsftpd
    fi
else
    echo "vsftpd is not"
fi

mkdir -p /alidata/www/default
mkdir -p /alidata/install
cd /alidata/install
if [ ! -s $PKG_NAME ]; then
    wget -c $SRC_URI
fi
tar -zxvf $PKG_NAME

if [ "$ifrpm" != "" ];then
	yum -y install vsftpd
	\cp -f ./config-ftp/rpm_ftp/* /etc/vsftpd/
else
	apt-get -y install vsftpd
	if cat /etc/shells | grep /sbin/nologin ;then
		echo ""
	else
		echo /sbin/nologin >> /etc/shells
	fi
	\cp -fR ./config-ftp/apt_ftp/* /etc/
fi

if [ "$ifcentos" != "" ] && [ "$machine" == "i686" ];then
    rm -rf /etc/vsftpd/vsftpd.conf
	\cp -f ./config-ftp/vsftpdcentosi686.conf /etc/vsftpd/vsftpd.conf
fi

if [ "$ifubuntu" != "" ];then
    mv /etc/pam.d/vsftpd /etc/pam.d/vsftpd.bak
	ln -s /lib/init/upstart-job  /etc/init.d/vsftpd
fi

cat /etc/redhat-release |grep 7\..*|grep -i centos>/dev/null
if [ ! $? -ne  0 ] ;then
   echo "systemctl start vsftpd.service" >> /etc/rc.local
   systemctl start vsftpd.service
else  
    echo "/etc/init.d/vsftpd start" >> /etc/rc.local
	/etc/init.d/vsftpd start
fi

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

echo "FTP user:www"
echo "FTP PASSWD:${PASS}"
echo "FTP  user:www  password:${PASS}" > /alidata/account.log
chmod 400 /alidata/account.log


