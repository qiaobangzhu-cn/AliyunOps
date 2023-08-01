#!/bin/bash
#created by yutao 2017.11.13
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/oracle122010.tar.gz"
PKG_NAME=`basename $SRC_URI`

sed -i 's/id:3:initdefault:/id:5:initdefault:/' /etc/inittab

free -m
dd if=/dev/zero of=/home/swap bs=1024 count=8092000
mkswap /home/swap
swapon /home/swap
echo "/home/swap swap swap defaults 0 0" >> /etc/fstab

cat >> /etc/security/limits.conf << "E"OF
oracle soft nproc   2047
oracle hard nproc   16384
oracle soft nofile  2047
oracle hard nofile  65536
EOF

cat >> /etc/sysctl.conf << "E"OF
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
fs.file-max = 6815744
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_max = 1048576
fs.aio-max-nr = 1048576
EOF

sysctl -p

yum groupinstall -y   "Desktop"   "Desktop Platform"   "Desktop Platform Development"　 "Fonts" 　"General Purpose Desktop"　 "Graphical Administration Tools"　 "Graphics Creation Tools" 　"Input Methods" 　"X Window System" 　"Chinese Support [zh]"　"Internet Browser"
yum install -y libaio-devel
yum install -y compat-libstdc++-33
yum install -y elfutils-libelf-devel
yum install -y expect
yum install -y xclock
yum install -y lrzsz
yum install -y sysstat
yum install -y smartmontools
yum install -y ksh
yum install -y gcc-c++-4.4.7
yum install -y libstdc++-devel-4.4.7
yum install -y compat-libcap1-1.10
yum install -y unzip
groupadd -g 502 dba && groupadd oinstall && useradd -u 502 -g oinstall -G dba oracle

if [ ! -s $PKG_NAME ]; then
    wget -c $SRC_URI
fi
tar zxvfP ${PKG_NAME}

cat >> /home/oracle/.bash_profile << "E"OF
export ORACLE_BASE=/alidata/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/12.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:/sbin:/bin:/usr/sbin:/usr/bin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/lib32
export NLS_LANG="Simplified Chinese"_China.AL32UTF8
export PS1=[`whoami`@`hostname`:'$PWD']"$ "
export ORACLE_SID=prod
EOF

chown -R oracle:oinstall /home/oracle/.bash_profile
chmod -R 644 /home/oracle/.bash_profile
su - oracle -c "source /home/oracle/.bash_profile"

echo "oracle" | passwd --stdin oracle

LISTENERIP=$(ifconfig | grep "inet addr:" | grep -vP "`curl icanhazip.com 2>/dev/null`|127.0.0.1" |awk -F "[ :]*" '{print $4}')
sed -i "s/LISTENERIP/${LISTENERIP}/" /alidata/app/oracle/product/12.2.0/dbhome_1/network/admin/listener.ora

/alidata/app/oraInventory/orainstRoot.sh
expect -c "
     spawn /alidata/app/oracle/product/12.2.0/dbhome_1/root.sh
     expect {
             \"Enter the full pathname of the local bin directory\" {set timeout 10; send \"\r\"; exp_continue }
             \"Do you want to setup Oracle Trace File Analyzer (TFA) now\" { send \"yes\r\"; }
            }
expect eof"

\rm ${PKG_NAME} $0