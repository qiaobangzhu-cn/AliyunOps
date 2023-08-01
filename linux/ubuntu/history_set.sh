#!/bin/bash
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
change_history(){
if ! grep 'source /etc/bashrc' /etc/profile &> /dev/null; then
  echo 'if [ $SHELL == /bin/bash ]; then
source /etc/bashrc
fi
  ' >> /etc/profile
fi

### add history date ###
if ! grep 'export HISTTIMEFORMAT="%F %T' /etc/bashrc &> /dev/null; then
  echo 'export HISTTIMEFORMAT="%F %T "' >>/etc/bashrc
fi

### change the command history #######
if cat /etc/profile | grep HISTSIZE &> /dev/null;then
  sed -i '/^HISTSIZE=/c\HISTSIZE=10240' /etc/profile
else
  echo "HISTSIZE=10240" >> /etc/profile
fi
}
  echo " Starting run_check"
  run_check
  echo " Finished run_check"

  echo " Starting change_history"
  change_history
  echo -e "$GREEN History has been completed$NO_COLOR" >&2
