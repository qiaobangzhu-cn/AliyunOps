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
change_port(){
sed -i 's/.*Port .*/Port 40022/g' /etc/ssh/sshd_config
}
  echo " Starting run_check"
  run_check
  echo " Finished run_check"

  echo " Starting change_port"
  change_port
  echo -e "$GREEN The sshd_Port is changed to 40022,Please restart sshd service! $NO_COLOR" >&2
