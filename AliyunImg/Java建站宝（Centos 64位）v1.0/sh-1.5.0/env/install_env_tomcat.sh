#!/bin/sh

CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ ! -f pcre-8.12.tar.gz ];then
	wget http://oss.aliyuncs.com/aliyunecs/onekey/pcre-8.12.tar.gz
fi
rm -rf pcre-8.12
tar zxvf pcre-8.12.tar.gz
cd pcre-8.12
./configure
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
cd ..

#load /usr/local/lib .so
touch /etc/ld.so.conf.d/usrlib.conf
echo "/usr/local/lib" > /etc/ld.so.conf.d/usrlib.conf
/sbin/ldconfig

#create account.log
cat > account.log << END
##########################################################################
# 
# thank you for using aliyun virtual machine
# 
##########################################################################

FTP:
account:www
password:ftp_password

MySQL:
account:root
password:mysql_password
END