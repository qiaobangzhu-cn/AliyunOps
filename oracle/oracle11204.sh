#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/oracle11204.tar.gz"
PKG_NAME=`basename $SRC_URI`
LISTENERIP=$(ifconfig | grep "inet addr:" | grep -vP "`curl icanhazip.com 2>/dev/null`|127.0.0.1" |awk -F "[ :]*" '{print $4}')

sed -i 's/id:3:initdefault:/id:5:initdefault:/' /etc/inittab

cat >> /etc/security/limits.conf << "E"OF
oracle	soft	nproc	2047
oracle	hard	nproc	16384
oracle	soft	nofile  1024
oracle	hard	nofile  65536
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
yum install libaio-devel -y
yum install compat-libstdc++-33 -y
yum install elfutils-libelf-devel -y
yum install expect -y
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/pdksh-5.2.14-37.el5_8.1.i386.rpm && yum install pdksh-5.2.14-37.el5_8.1.i386.rpm -y
groupadd -g 502 dba && groupadd oinstall && useradd -u 502 -g oinstall -G dba oracle

if [ ! -s $PKG_NAME ]; then
    wget -c $SRC_URI
fi
tar zxvfP ${PKG_NAME}

sed -i "s/LISTENERIP/${LISTENERIP}/" /alidata/app/oracle/product/11.2.0/dbhome_1/network/admin/listener.ora

cat >> /home/oracle/.bash_profile << "E"OF
export ORACLE_HOME=/alidata/app/oracle/product/11.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:/sbin:/bin:/usr/sbin:/usr/bin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/lib32
export ORACLE_BASE=/alidata/app/oracle/
export NLS_LANG="Simplified Chinese"_China.AL32UTF8
EOF

chown -R oracle:oinstall /home/oracle/.bash_profile
chmod -R 644 /home/oracle/.bash_profile
su - oracle -c "source /home/oracle/.bash_profile"


/alidata/app/oraInventory/orainstRoot.sh
expect -c "
                spawn /alidata/app/oracle/product/11.2.0/dbhome_1/root.sh
                expect {
                                \"Enter the full pathname of the local bin directory\" {set timeout 9000; send \"\r\";}
                }
expect eof"
\rm pdksh-5.2.14-37.el5_8.1.i386.rpm ${PKG_NAME} $0
