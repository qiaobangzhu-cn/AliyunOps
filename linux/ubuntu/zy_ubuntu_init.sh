#!/bin/bash
#########################################################
# ZY aliyun  post script for el6
#########################################################
# 2017-02-24  post script
# 2018-08-03  modify by ruijie.qiao
#        1. Delete www users
#        2. Increase the password SSH login
#        3. Add zy_tty
#
# set -x
RED="\033[0;31m"
NO_COLOR="\033[0m"
name=`hostname`
ETH1=""
if ifconfig eth1 &> /dev/null;then
   ETH1=$(ip a | grep -A 0 "eth1" | awk -F "[ /]*" '/inet/ {print $3}')
fi
ETH0=$(ip a | grep -A 0 "eth0" | awk -F "[ /]*" '/inet/ {print $3}')

# set random password
MATRIX1="0123456789"
MATRIX2="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
MATRIX3="abcdefghijklmnopqrstuvwxyz"
MATRIX4="./*&^%$#@!()"
# May change 'LENGTH' for longer password, of course.
LENGTH="16"

ii=1
while [ "${n:=1}" -le "$LENGTH" ]; do
    MATRIX=`eval echo "$"MATRIX${ii}`
    PASS="$PASS${MATRIX:$(($RANDOM%${#MATRIX})):1}"
    let n+=1
    ii=`expr $ii + 1`
    if [ $ii -eq 5 ];then
        ii=1
    fi
done

# echo "$PASS" # ==> Or, redirect to file, as desired.
# exit 0

hostname_check(){
HOSTNAME=$1

  while [ -z "$HOSTNAME" ];do
        echo -en "$RED Example:hostname is xxx-xxx-xxx,Please input hostname : $NO_COLOR"
        read HOSTNAME
  done
}

hostname_check

while [[ "$HOSTNAME" != *-*-* ]];do
	echo -e "$RED Wrong name,example:xxx-xxx-xxx $NO_COLOR"; hostname_check
done

change_hostname(){
# change hostname for server
  hostname $HOSTNAME
  echo $HOSTNAME > /etc/hostname
  sed -i "s/^${ETH0}.*/${ETH0} ${HOSTNAME}/g" /etc/hosts
  }

user_tunning(){
while :
do
  echo -e "$RED If you use a password to log on, please select Y or y, If you use SSH key login, select N or n or enter, but remember to save the private key to your local. $NO_COLOR" 
  echo -en "$RED Please: [Y|y|N|n] $NO_COLOR" 
  read value
  if [ Z$value == Z"Y" ] || [ Z$value == Z"y" ]  || [ Z$value == Z"" ];then
    # delete unused users
    cp -p /etc/passwd /etc/passwd.bak
    cp -p /etc/shadow /etc/shadow.bak
    cp -p /etc/group /etc/group.bak
    # add common user and allow ssh
    /usr/sbin/groupadd -g 4999 sshers
    useradd -G sshers -m zyadmin -s /bin/bash
    useradd -M -s /sbin/nologin www

    echo zyadmin:"$PASS" | chpasswd
    break
  fi
  if [ Z$value == Z"N" ] || [ Z$value == Z"n" ];then
    # delete unused users
    cp -p /etc/passwd /etc/passwd.bak
    cp -p /etc/shadow /etc/shadow.bak
    cp -p /etc/group /etc/group.bak
    # add common user and allow ssh
    /usr/sbin/groupadd -g 4999 sshers
    useradd -G sshers -m zyadmin -s /bin/bash
    useradd -M -s /sbin/nologin www
    
    oldDirectory=`pwd`
    mkdir -p /home/zyadmin/.ssh && ssh-keygen -f /home/zyadmin/.ssh/id_rsa -t rsa -P '' -C zyadmin@$HOSTNAME && \
    chmod 700 /home/zyadmin/.ssh && cat /home/zyadmin/.ssh/id_rsa.pub >> /home/zyadmin/.ssh/authorized_keys && \
    chmod 600 /home/zyadmin/.ssh/authorized_keys && sed -ri 's/.*PasswordAuthentication\s+yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
    chown -R zyadmin:zyadmin /home/zyadmin/.ssh
    PASS=`cat /home/zyadmin/.ssh/id_rsa`
    cd ${oldDirectory}
    break
  fi
  continue
done

  echo '
zyadmin        ALL=(ALL)       NOPASSWD: ALL
Defaults:zyadmin   !requiretty' >>/etc/sudoers

#sed -i 's/^Defaults.*env_reset$/Defaults        env_reset\nDefaults    env_keep += "ZY_USER"/' /etc/sudoers #old version
  echo 'Defaults    env_keep += "ZY_USER"' >> /etc/sudoers
}

package_tunning(){
  mkfs.ext4 /dev/vdb && mkdir -p /alidata && /bin/mount /dev/vdb /alidata
  echo "/bin/mount /dev/vdb /alidata" >> /etc/rc.local

  apt-get update
  apt-get install -y iftop iotop atop htop telnet lsof tcpdump rsync screen lrzsz tmux numactl tcpdump sysstat rpm mlocate 2> /dev/null
}

base_service_tunning(){
# remove "exit 0"
  sed -i --follow-symlinks 's/exit 0//' /etc/rc.local
  
# sshd config
  sed -ri 's/.*UseDNS\s+yes/UseDNS\tno/g;s/.*PermitRootLogin\s+yes/PermitRootLogin\tno/g;s/.*AllowTcpForwarding\s+yes/AllowTcpForwarding no/g' /etc/ssh/sshd_config
  if ! grep 'AllowGroups sshers' /etc/ssh/sshd_config >/dev/null;then echo "AllowGroups sshers" >> /etc/ssh/sshd_config;fi
  echo "AcceptEnv ZY_USER" >> /etc/ssh/sshd_config

# change ssh port from 22 to 40022
  sed -i 's/.*Port 22/Port 40022/g' /etc/ssh/sshd_config
}

base_system_tunning(){
# bash prompt
  if ! grep 'source /etc/bashrc' /etc/profile >/dev/null; then
  echo 'if [ $SHELL == /bin/bash ]; then
source /etc/bashrc
fi' >> /etc/profile
  fi
  
# motd text
  for i in motd issue issue.net; do
    if ! grep "Authorized users only.  All activity may be monitored and reported" /etc/"$i" >/dev/null; then
      echo "Authorized users only.  All activity may be monitored and reported" >> /etc/"$i"
    fi
  done

# Add useful settings to /etc/sysctl.conf
# change hashsize
   modprobe ip_conntrack
   echo 'modprobe ip_conntrack' >> /etc/rc.local
   echo 'echo "64000" > /sys/module/nf_conntrack/parameters/hashsize' >> /etc/rc.local

    grep 'kernel.panic' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "# Reboot a minute after an Oops" >> /etc/sysctl.conf
            echo "kernel.panic = 60" >> /etc/sysctl.conf
    else
            sed -i s/"kernel.panic = [0-9]*"/"kernel.panic = 60"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.tcp_syncookies' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "# Syncookies make SYN flood attacks ineffective" >> /etc/sysctl.conf
            echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.tcp_syncookies = [0-9]*"/"net.ipv4.tcp_syncookies = 1"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.icmp_echo_ignore_broadcasts' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "# Ignore bad ICMP" >> /etc/sysctl.conf
            echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.icmp_echo_ignore_broadcasts = [0-9]*"/"net.ipv4.icmp_echo_ignore_broadcasts = 1"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.icmp_ignore_bogus_error_responses' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.icmp_ignore_bogus_error_responses = [0-9]*"/"net.ipv4.icmp_ignore_bogus_error_responses = 1"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.conf.all.arp_announce' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "# Reply to ARPs only from correct interface (required for DSR load-balancers)" >> /etc/sysctl.conf
            echo "net.ipv4.conf.all.arp_announce = 2" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.conf.all.arp_announce = [0-9]*"/"net.ipv4.conf.all.arp_announce = 2"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.conf.all.arp_ignore' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.ipv4.conf.all.arp_ignore = 1" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.conf.all.arp_ignore = [0-9]*"/"net.ipv4.conf.all.arp_ignore = 1"/ /etc/sysctl.conf
    fi

    grep 'fs.file-max' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "# limit set in the kernel on how many open file descriptors are allowed on the system"
            echo "fs.file-max = 1024000" >> /etc/sysctl.conf
    else
            sed -i s/"fs.file-max = [0-9]*"/"fs.file-max = 1024000"/ /etc/sysctl.conf
    fi
 
    grep 'net.ipv4.tcp_max_syn_backlog' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.ipv4.tcp_max_syn_backlog = 65536" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.tcp_max_syn_backlog = [0-9]*"/"net.ipv4.tcp_max_syn_backlog = 65536"/ /etc/sysctl.conf
    fi

    grep 'net.core.netdev_max_backlog' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.core.netdev_max_backlog = 32768" >> /etc/sysctl.conf
    else
            sed -i s/"net.core.netdev_max_backlog = [0-9]*"/"net.core.netdev_max_backlog = 32768"/ /etc/sysctl.conf
    fi

    grep 'net.core.somaxconn' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.core.somaxconn = 32768" >> /etc/sysctl.conf
    else
            sed -i s/"net.core.somaxconn = [0-9]*"/"net.core.somaxconn = 32768"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.tcp_timestamps' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.ipv4.tcp_timestamps = 0" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.tcp_timestamps = [0-9]*"/"net.ipv4.tcp_timestamps = 0"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.tcp_synack_retries' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.ipv4.tcp_synack_retries = 2" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.tcp_synack_retries = [0-9]*"/"net.ipv4.tcp_synack_retries = 2"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.tcp_syn_retries' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.ipv4.tcp_syn_retries = 2" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.tcp_syn_retries = [0-9]*"/"net.ipv4.tcp_syn_retries = 2"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.tcp_tw_recycle' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.ipv4.tcp_tw_recycle = 0" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.tcp_tw_recycle = [0-9]*"/"net.ipv4.tcp_tw_recycle = 0"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.tcp_tw_reuse' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.tcp_tw_reuse = [0-9]*"/"net.ipv4.tcp_tw_reuse = 1"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.ip_local_port_range' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.ipv4.ip_local_port_range = 1024  65535" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.ip_local_port_range = .*"/"net.ipv4.ip_local_port_range = 1024  65535"/ /etc/sysctl.conf
    fi
	
    grep 'net.ipv4.tcp_keepalive_time' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.ipv4.tcp_keepalive_time = 1200" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.tcp_keepalive_time = [0-9]*"/"net.ipv4.tcp_keepalive_time = 1200"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.tcp_keepalive_intvl' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.ipv4.tcp_keepalive_intvl = 15" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.tcp_keepalive_intvl = [0-9]*"/"net.ipv4.tcp_keepalive_intvl = 15"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.tcp_keepalive_probes' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.ipv4.tcp_keepalive_probes = 5" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.tcp_keepalive_probes = [0-9]*"/"net.ipv4.tcp_keepalive_probes = 5"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.tcp_fin_timeout' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.ipv4.tcp_fin_timeout = 30" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.tcp_fin_timeout = [0-9]*"/"net.ipv4.tcp_fin_timeout = 30"/ /etc/sysctl.conf
    fi
	
  sysctl -p



### add history date ###
  if ! grep 'export HISTTIMEFORMAT="%F %T' /etc/bashrc 2>/dev/null; then
    echo 'export HISTTIMEFORMAT="%F %T "' >>/etc/bashrc
  fi

### change the command history #######
  sed -i '/^HISTSIZE=/c\HISTSIZE=10240' /etc/profile


# add cmd tracking
  echo '# add syntax highlight for LESS
export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
export LESS=" -R "
export HISTCONTROL=ignorespace
# add sudo alias
sudo_zy() { if [ x"$*" == x"su -" ]; then /usr/bin/sudo -i; else /usr/bin/sudo $*; fi; }
alias sudo=sudo_zy  
# add cmd tracking
REAL_LOGNAME_DECLARE=`/usr/bin/who am i | cut -d" " -f1`
if [ $USER == root ]; then
        PROMT_DECLARE="#"
else
        PROMT_DECLARE="$"
fi

if [ x"$ZY_USER" == x ]; then
        REMOTE_USER_DECLARE=UNKNOW
else
        REMOTE_USER_DECLARE=$ZY_USER
fi

PPPID=$(pstree -p | grep $$ | sed '"'"'s/.*sshd(//g; s/).*//g'"'"')

h2l_declare='"'"'
    THIS_HISTORY="$(history 1)"
    __THIS_COMMAND="${THIS_HISTORY/*:[0-9][0-9] /}"
    if [ x"$LAST_HISTORY" != x"$THIS_HISTORY" ];then
        if [ x"$__LAST_COMMAND" != x ]; then
           __LAST_COMMAND="$__THIS_COMMAND"
           LAST_HISTORY="$THIS_HISTORY"
           logger -p local4.notice -t $REAL_LOGNAME_DECLARE "REMOTE_USER_DECLARE=$REMOTE_USER_DECLARE [$USER@$HOSTNAME $PWD]$PROMT_DECLARE $__LAST_COMMAND"
        else
           __LAST_COMMAND="$__THIS_COMMAND"
           LAST_HISTORY="$THIS_HISTORY"
        fi
    fi'"'"'
trap "$h2l_declare" DEBUG' > /etc/profile.d/zy_profile.sh

  chmod a+x /etc/profile.d/zy_profile.sh
}

setup_tty(){
echo '#!/bin/bash

#By default, it is used to display the real host name of the system.
HOSTNAME="\H"

#Optional, display the custom hostname in TTY, and the real hostname remains unchanged.
#HOSTNAME=""

ETH0=$(ip a | grep -A 0 "eth0" | awk -F "[ /]*" '"'"'/inet/ {print $3}'"'"')
IPADDRS="eth0 = $ETH0"

if ifconfig eth1 &> /dev/null;then
   ETH1=$(ip a | grep -A 0 "eth1" | awk -F "[ /]*" '"'"'/inet/ {print $3}'"'"')
   IPADDRS="$IPADDRS       eth1 = $ETH1"
fi

if [ $UID -eq 0 ]
then
        PS1="\n\n\033[1;34m[\u@$HOSTNAME]\e[m  \033[1;33m$IPADDRS\e[m \n[\t] PWD => \033[1;35m\w\e[m\n\#># "
else
        PS1="\n\n\033[1;34m[\u@$HOSTNAME]\e[m  \033[1;33m$IPADDRS\e[m \n[\t] PWD => \033[1;35m\w\e[m\n\#>\$ "
fi

if [ "$(cat /proc/version | grep ubuntu)" != "" ];then
    if /usr/bin/id zyadmin &> /dev/null && [ -f /home/zyadmin/.profile ]; then
       if ! cat /home/zyadmin/.profile | grep "source /etc/profile.d/zy_tty.sh" &> /dev/null ;then
          echo "source /etc/profile.d/zy_tty.sh" >> /home/zyadmin/.profile
       fi
    fi

    if [ -f /root/.profile ];then
       if ! cat /root/.profile | grep "source /etc/profile.d/zy_tty.sh" &> /dev/null ;then
          echo "source /etc/profile.d/zy_tty.sh" >> /root/.profile
       fi
    fi
fi' > /etc/profile.d/zy_tty.sh

}

setup_rsyslog(){

echo "# Log zy_profile generated CMD log messages to file
local4.notice /var/log/cmd_track.log
#:msg, contains, "REM" /opt/zyscripts/cmd_track.log

# Uncomment the following to stop logging anything that matches the last rule.
# Doing this will stop logging kernel generated UFW log messages to the file
# normally containing kern.* messages (eg, /var/log/kern.log)
& ~" > /etc/rsyslog.d/cmd_track.conf
}

output_passwd(){
PASS_FILE=/tmp/pass_temp
HOSTNAME=$(hostname)
echo "----SYSTEM INFORMATION---- " > $PASS_FILE
if [ ! "$ETH1" = "" ];then
  echo "eth1 is $ETH1" >> $PASS_FILE
fi

echo "eth0 is $ETH0
hostname is $HOSTNAME
port is 40022
zyadmin password/rsa key is 
$PASS
-----------END-----------" >> $PASS_FILE
cat $PASS_FILE
rm -rf $PASS_FILE
exit 0
}


/usr/bin/id zyadmin >/dev/null 2>&1;

if [ $? = 0 ]; then

    echo "Account zyadmin has already exists, Don't run the scripts twice.";

else

    echo "Starting change_hostname"
    change_hostname
    echo "Finished change_hostname"

    echo "Starting user_tunning"
    user_tunning
    echo "Finished user_tunning"

    echo "Starting package_tunning"
    package_tunning
    echo "Finished package_tunning"

    echo "Starting base_service_tunning"
    base_service_tunning
    echo "Finished base_service_tunning"

    echo "Starting base_system_tunning"
    base_system_tunning
    echo "Finished base_system_tunning"

    echo "Starting setup_tty"
    setup_tty
    echo "Finished setup_tty"

    echo "Setup log system"
    setup_rsyslog
    echo "Finished log system"
	
    echo "output system user password"
    output_passwd
    echo "Finished output passowrd"
    echo "Please send the output information to the administrator to update KeePass"
	
fi
