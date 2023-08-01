#!/bin/bash
# add cmd tracking
RED="\033[0;31m"
GREEN="\033[0;32m"
NO_COLOR="\033[0m"
run_check(){
    # check for user ID - has to be root
    if ! id |grep "uid=0(root)" &> /dev/null; then
      echo -e "$RED ERROR: You need to run this script as ROOT user $NO_COLOR" >&2
      exit 2
    fi
}

cmd_track(){
  echo 'export LESS=" -R "
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
setup_rsyslog(){

echo "# Log zy_profile generated CMD log messages to file
local4.notice /var/log/cmd_track.log
#:msg, contains, "REM" /opt/zyscripts/cmd_track.log

# Uncomment the following to stop logging anything that matches the last rule.
# Doing this will stop logging kernel generated UFW log messages to the file
# normally containing kern.* messages (eg, /var/log/kern.log)
& ~" > /etc/rsyslog.d/cmd_track.conf
/etc/init.d/rsyslog restart &> /dev/null
}
  echo "Setup run_check"
  run_check
  echo "Finished run_check"
  
  echo "Setup cmd_track"
  cmd_track
  echo "Finished cmd_track"

  echo "Setup log system"
  setup_rsyslog
  echo "Finished log system"
  echo -e "$GREEN-The cmd_track is finished,Please input 'tail -f /var/log/cmd_track.log' to see. $NO_COLOR"
