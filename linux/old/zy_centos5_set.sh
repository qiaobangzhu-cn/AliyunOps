#!/bin/bash
#########################################################
# ZY aliyun  post script for el5
#########################################################
# 2014-06-19  post script
#
#set -x

########################################################
# Font color
########################################################
RED="\033[0;31m"
GREEN="\033[0;32m"
NO_COLOR="\033[0m"

ETH1=""
if ifconfig eth1 &> /dev/null;then
   ETH1=$(ifconfig eth1 | grep inet | awk '{print $2}' | awk -F ":" '{print $2}')
fi
ETH0=$(ifconfig eth0 | grep inet | awk '{print $2}' | awk -F ":" '{print $2}')

# set random password

MATRIX="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ \
abcdefghijklmnopqrstuvwxyz./*&^%$#@!()"
# May change 'LENGTH' for longer password, of course.
LENGTH="8"

  while [ "${n:=1}" -le "$LENGTH" ]; do
      PASS="$PASS${MATRIX:$(($RANDOM%${#MATRIX})):1}"
      let n+=1
  done

#echo "$PASS" # ==> Or, redirect to file, as desired.
#exit 0
run_check(){
  # check for user ID - has to be root
  if ! id |grep "uid=0(root)" &> /dev/null; then
    echo -e "$RED ERROR: You need to run this script as ROOT user $NO_COLOR" >&2
    exit 2
  fi

  if /usr/bin/id zyadmin &> /dev/null;then
    echo -e "$RED ERROR: Account zyadmin has already exists, Don't run the scripts twice. $NO_COLOR" >&2
    exit 2  
  fi

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
  useradd -G sshers zyadmin
  echo "$PASS" | passwd zyadmin --stdin
  if ! cat /etc/sudoers |grep "zyadmin        ALL=(ALL)       NOPASSWD: ALL" &> /dev/null;then
	echo 'zyadmin        ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers
	echo 'Defaults:zyadmin   !requiretty' >> /etc/sudoers
  fi
  if ! cat /etc/sudoers | grep "ZY_USER";then
    sed -i 's/XAUTHORITY/XAUTHORITY ZY_USER/' /etc/sudoers
  fi
}

repo_tunning(){
echo '
[epel]
name=Extra Packages for Enterprise Linux 5 - $basearch
#baseurl=http://download.fedoraproject.org/pub/epel/5/$basearch
mirrorlist=http://mirrors.fedoraproject.org/metalink?repo=epel-5&arch=$basearch
failovermethod=priority
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-5

[epel-debuginfo]
name=Extra Packages for Enterprise Linux 5 - $basearch - Debug
#baseurl=http://download.fedoraproject.org/pub/epel/5/$basearch/debug
mirrorlist=http://mirrors.fedoraproject.org/metalink?repo=epel-debug-5&arch=$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-5
gpgcheck=0

[epel-source]
name=Extra Packages for Enterprise Linux 5 - $basearch - Source
#baseurl=http://download.fedoraproject.org/pub/epel/5/SRPMS
mirrorlist=http://mirrors.fedoraproject.org/metalink?repo=epel-source-5&arch=$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-5
gpgcheck=0
'> /etc/yum.repos.d/epel.repo
}

base_service_tunning(){
  if ! cat /etc/ssh/sshd_config | grep "AcceptEnv ZY_USER" &> /dev/null;then
     echo "AcceptEnv ZY_USER" >> /etc/ssh/sshd_config
  fi
  /etc/init.d/sshd restart
}

base_system_tunning(){
  ## bash prompt
  if ! grep 'source /etc/bashrc' /etc/profile >/dev/null; then
  echo 'if [ $SHELL == /bin/bash ]; then
source /etc/bashrc
fi
  ' >> /etc/profile
  fi

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

  # add cmd tracking
  echo 'export HISTCONTROL=ignorespace
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

setup_syslog(){
echo "local4.notice /var/log/cmd_track.log" >> /etc/syslog.conf
/etc/init.d/syslog restart
}

output_passwd(){
PASS_FILE=/tmp/pass_temp
HOSTNAME=$(hostname)
PORT=$(netstat -ntpl|grep sshd|awk '{print $4}'|awk -F: '{print $2}')
echo "----SYSTEM INFORMATION---- " > $PASS_FILE
if [ ! "$ETH1" = "" ];then
  echo "    eth1 is $ETH1" >> $PASS_FILE
fi

echo "    eth0 is $ETH0
    hostname is $HOSTNAME
    username is zyadmin
    port is $PORT
    password is $PASS
-----------END-----------" >> $PASS_FILE
cat $PASS_FILE
rm -rf $PASS_FILE
exit 0
}

echo "Starting run_check"
run_check
echo "Finished run_check"

echo "Starting user_tunning"
user_tunning
echo "Finished user_tunning"

echo "Starting repo_tunning"
repo_tunning
echo "Finished repo_tunning"

echo "Starting base_service_tunning"
base_service_tunning
echo "Finished base_service_tunning"

echo "Starting base_system_tunning"
base_system_tunning
echo "Finished base_system_tunning"

echo "Setup log system"
setup_syslog
echo "Finished log system"

echo "output system user password"
output_passwd
echo "Finished output passowrd"
echo "$GREEN Please send the output information to the administrator to update KeePass $NO_COLOR"

