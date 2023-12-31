#!/bin/bash
#########################################################
# ZY aliyun  post script for el6
#########################################################
# 2014-05-27  post script
#
#set -x

ETH1=""
if ifconfig eth1 &> /dev/null;then
   ETH1=$(ifconfig eth1 | grep inet | awk '{print $2}' | awk -F ":" '{print $2}')
fi
ETH0=$(ifconfig eth0 | grep inet | awk '{print $2}' | awk -F ":" '{print $2}')

# set random password

MATRIX1="0123456789"
MATRIX2="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
MATRIX3="abcdefghijklmnopqrstuvwxyz"
MATRIX4="./*&^%$#@!()"
# May change 'LENGTH' for longer password, of course.
LENGTH="8"


ii=1
while [ "${n:=1}" -le "$LENGTH" ]; do
    MATRIX=`eval echo "$"MATRIX${ii}`
    PASS="$PASS${MATRIX:$(($RANDOM%${#MATRIX})):1}"
    PASS2="$PASS2${MATRIX:$(($RANDOM%${#MATRIX})):1}"
    let n+=1
    ii=`expr $ii + 1`
    if [ $ii -eq 5 ];then
        ii=1
    fi
done

echo $PASS
echo $PASS2

#echo "$PASS" # ==> Or, redirect to file, as desired.
#exit 0

hostname_check(){
HOSTNAME=$1

  while [ -z "$HOSTNAME" ];do
        printf "Please input %s: " "hostname"
        read HOSTNAME
  done
}

hostname_check

while [[ "$HOSTNAME" != *-* ]];do
echo "Wrong name,example:xx-*"; hostname_check
done

change_hostname(){
  # change hostname for server
  hostname $HOSTNAME 
  echo $HOSTNAME > /etc/hostname #  echo "127.0.0.1	$HOSTNAME" >> /etc/hosts
  sed -i "s/^${ETH0}.*/${ETH0} ${HOSTNAME}/g" /etc/hosts

}

user_tunning(){
  # delete unused users
  cp -p /etc/passwd /etc/passwd.bak
  cp -p /etc/shadow /etc/shadow.bak
  cp -p /etc/group /etc/group.bak
#  sed -ri 's/(^news:|^games:|^gopher:|^ftp).*\n//g' /etc/passwd
#  sed -ri 's/(^news:|^games:|^gopher:|^ftp).*\n//g' /etc/shadow
#  sed -ri 's/(^news:|^games:|^gopher:|^ftp).*\n//g' /etc/group
  # add common user and allow ssh
  /usr/sbin/groupadd -g 4999 sshers
  useradd -G sshers -m zyadmin -s /bin/bash
  useradd -G sshers -m  -s /bin/bash www
  echo zyadmin:"$PASS" | chpasswd
  echo www:"$PASS2" | chpasswd
  echo '
zyadmin        ALL=(ALL)       NOPASSWD: ALL
Defaults:zyadmin   !requiretty
' >>/etc/sudoers
  sed -i 's/^Defaults.*env_reset$/Defaults        env_reset\nDefaults        env_keep += "ZY_USER"/' /etc/sudoers
}

package_tunning(){
#   apt update 
     apt-get update
#   install lvm
     apt-get install -y lvm2

#   create lvm first
    ls /dev/xvdb >/dev/null 2>&1;
    if [ $? = 0 ]; then
        /sbin/pvcreate /dev/xvdb
        /sbin/vgcreate domuvg /dev/xvdb
    	/sbin/lvcreate -L 1G -n swap domuvg
        /sbin/mkswap /dev/domuvg/swap
        /sbin/swapon /dev/domuvg/swap
        #echo "/dev/domuvg/swap        swap                    swap    defaults        0 0" >> /etc/fstab
        swapon /dev/domuvg/swap >>/etc/rc.local
		
		mkdir -p /alidata
		/sbin/lvcreate -l +100%FREE -n alidata domuvg
        /sbin/mkfs.ext4 /dev/domuvg/alidata
#        if [ `ls -r /alidata |wc -l` = 0 ]; then
#       /bin/mount /dev/domuvg/alidata /alidata  
#        echo mount /dev/domuvg/alidata /alidata   >>/etc/rc.local
#        #echo "/dev/domuvg/alidata         /alidata                    ext4    defaults        0 0" >> /etc/fstab
#        fi
    fi


#  apt-get install -y telnet iftop htop tmux source-highlight lrzsz atop numactl sendmail tcpdump sysstat chkconfig mailutils rpm
  apt-get install -y telnet iftop htop tmux  lrzsz atop numactl tcpdump sysstat chkconfig rpm

  for i in messagebus restorecond netfs mcstrans ip6tables
  do
    if chkconfig --list | grep $i >/dev/null
    then
      chkconfig "$i" off
    fi
  done

#  chkconfig sendmail --level 2345 off
  chkconfig ntpd --level 2345 on
  chkconfig nscd --level 2345 on

  for i in ip6tables messagebus
  do
    if chkconfig --list | grep $i >/dev/null
    then
      chkconfig --del "$i"
    fi
  done
}

base_service_tunning(){
  # sshd config
  sed -ri 's/#UseDNS\s+yes/UseDNS\tno/g; s/PermitRootLogin\s+yes/PermitRootLogin\tno/g; s/#AllowTcpForwarding\s+yes/AllowTcpForwarding\tno/g' /etc/ssh/sshd_config
  if ! grep 'AllowGroups sshers' /etc/ssh/sshd_config >/dev/null;then echo "AllowGroups sshers" >> /etc/ssh/sshd_config;fi
  echo "AcceptEnv ZY_USER" >> /etc/ssh/sshd_config
  
  # change ssh port from 22 to 40022
  sed -i 's/Port 22/Port 40022/g' /etc/ssh/sshd_config

  ## change ntp conf
  sed -i s/server\ 0.*/'server 0.asia.pool.ntp.org'/ /etc/ntp.conf
  sed -i s/server\ 1.*/'server 1.asia.pool.ntp.org'/ /etc/ntp.conf
  sed -i s/server\ 2.*/'server 2.asia.pool.ntp.org'/ /etc/ntp.conf
  sed -i "/.*127.127.1.0/s/^/#/" /etc/ntp.conf

  ## Logrotate
  #sed -i 's/\#compress/compress/' /etc/logrotate.conf

}

base_system_tunning(){
  #remove "exit 0"
  sed -i 's/exit 0//' /etc/rc.local
  
  # set language US
  if ! grep 'LANGUAGE=en_US.UTF-8' /etc/profile >/dev/null; then
  echo 'export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
  ' >> /etc/profile
  fi

  ## bash prompt
  if ! grep 'source /etc/bashrc' /etc/profile >/dev/null; then
  echo 'if [ $SHELL == /bin/bash ]; then
source /etc/bashrc
fi
  ' >> /etc/profile
  fi


  # Add serial tty
  if ! grep 'ttyS0' /etc/securetty >/dev/null; then echo 'ttyS0' >> /etc/securetty; fi

  # disable ipv6
  if [ ! -f /etc/modprobe.d/net.conf ]; then touch /etc/modprobe.d/net.conf; fi
  if ! grep 'options ipv6 disable=1' /etc/modprobe.d/net.conf >/dev/null; then echo "options ipv6 disable=1" >> /etc/modprobe.d/net.conf; fi
  if ! grep 'alias net-pf-10 off' /etc/modprobe.d/net.conf >/dev/null; then echo "alias net-pf-10 off" >> /etc/modprobe.d/net.conf; fi

  rm -rf /etc/udev/rules.d/70-persistent-net.rules

  # motd text
  for i in motd issue issue.net; do
    if ! grep "Authorized users only.  All activity may be monitored and reported" /etc/"$i" >/dev/null; then
      echo "Authorized users only.  All activity may be monitored and reported" >> /etc/"$i"
    fi
  done

  # Remove ctrlaltdel
  # sed -i 's/ca::ctrlaltdel:/#ca::ctrlaltdel:/g' /etc/inittab

  # Add useful settings to /etc/sysctl.conf
    # change hashsize
	modprobe ip_conntrack
    echo 'modprobe ip_conntrack' >> /etc/rc.local
    echo 'echo 64000 > /sys/module/nf_conntrack/parameters/hashsize' >> /etc/rc.local
  
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

    grep 'net.ipv4.conf.all.accept_redirects' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "# Disable ICMP Redirect Acceptance" >> /etc/sysctl.conf
            echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.conf.all.accept_redirects = [0-9]*"/"net.ipv4.conf.all.accept_redirects = 0"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.conf.all.rp_filter' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "# Enable IP spoofing protection, turn on source route verification" >> /etc/sysctl.conf
            echo "net.ipv4.conf.all.rp_filter = 0" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.conf.all.rp_filter = [0-9]*"/"net.ipv4.conf.all.rp_filter = 0"/ /etc/sysctl.conf
    fi

    grep 'net.ipv4.conf.all.log_martians' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "# Log Spoofed Packets, Source Routed Packets, Redirect Packets" >> /etc/sysctl.conf
            echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf
    else
            sed -i s/"net.ipv4.conf.all.log_martians = [0-9]*"/"net.ipv4.conf.all.log_martians = 1"/ /etc/sysctl.conf
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

    grep 'vm.swappiness' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "vm.swappiness = 0" >> /etc/sysctl.conf
    else
            sed -i s/"vm.swappiness = [0-9]*"/"vm.swappiness = 0"/ /etc/sysctl.conf
    fi

    grep 'net.nf_conntrack_max' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.nf_conntrack_max = 655350" >> /etc/sysctl.conf
    else
            sed -i s/"net.nf_conntrack_max = [0-9]*"/"net.nf_conntrack_max = 655350"/ /etc/sysctl.conf
    fi

  # increase for more connection

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

    grep 'net.netfilter.nf_conntrack_tcp_timeout_time_wait' /etc/sysctl.conf &> /dev/null
    if [ $? != 0 ] ; then
            echo "net.netfilter.nf_conntrack_tcp_timeout_time_wait = 30" >> /etc/sysctl.conf
    else
            sed -i s/"net.netfilter.nf_conntrack_tcp_timeout_time_wait = [0-9]*"/"net.netfilter.nf_conntrack_tcp_timeout_time_wait = 30"/ /etc/sysctl.conf
    fi

#    grep 'perf_event_paranoid' /etc/sysctl.conf &> /dev/null
#    if [ $? != 0 ] ; then
#            echo "#vulnerability from 2.6.37 till 3.8.8" >> /etc/sysctl.conf
#            echo "perf_event_paranoid = 2" >> /etc/sysctl.conf
#    else
#            sed -i s/"perf_event_paranoid = [0-9]*"/"perf_event_paranoid = 2"/ /etc/sysctl.conf
#    fi

  sysctl -p

  ### add  ulimit for all user ###
  echo '
*                soft   nofile          65536
*                hard   nofile          65536
'>> /etc/security/limits.conf

  # change open file ulimit started by root
  echo 'root                soft   nofile          65536' >>/etc/security/limits.conf
  echo 'root                hard   nofile          65536' >>/etc/security/limits.conf

  ### add history date ###
  if ! grep 'export HISTTIMEFORMAT="%F %T' /etc/bashrc >/dev/null; then
    echo 'export HISTTIMEFORMAT="%F %T "' >>/etc/bashrc
  fi

  ### change the command history #######
  if cat /etc/profile | grep HISTSIZE &> /dev/null;then
	sed -i '/^HISTSIZE=/c\HISTSIZE=10240' /etc/profile
  else
    echo "export HISTSIZE=10240"
  fi

  # change lvm config
  sed -i 's/umask = 077/umask = 022/g' /etc/lvm/lvm.conf

  # add cmd tracking
  echo '# add syntax highlight for LESS
export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
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

## Configure iptables
#wget http://git.jiagouyun.com/operation/operation/raw/master/linux/sys/iptables.sh -O /etc/iptables.sh

#bash -x /etc/iptables.sh

#echo "bash -x /etc/iptables.sh" >> /etc/rc.local

## Configure zabbix agent
wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/zabbix_agentd-2.2.3.sh -O /home/zabbix_agentd-2.2.3.sh
bash -x /home/zabbix_agentd-2.2.3.sh

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
  echo "    eth1 is $ETH1" >> $PASS_FILE
fi

echo "    eth0 is $ETH0
    hostname is $HOSTNAME
    port is 40022
    zyadmin password is $PASS
    www     password is $PASS2
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

#    echo "Download firewall scrtip"
#    download_firewall_scripts
#    echo "Finished Download"

    echo "Setup log system"
    setup_rsyslog
    echo "Finished log system"

    echo "output system user password"
    output_passwd
    echo "Finished output passowrd"
    echo "Please send the output information to the administrator to update KeePass"
	
fi