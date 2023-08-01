#!/bin/bash
# set random password
RED="\033[0;31m"
GREEN="\033[0;32m"
NO_COLOR="\033[0m"

MATRIX="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz./*&^%$#@!()"
# May change 'LENGTH' for longer password, of course.
LENGTH="16"

  while [ "${n:=1}" -le "$LENGTH" ]; do
      PASS="$PASS${MATRIX:$(($RANDOM%${#MATRIX})):1}"
      let n+=1
  done
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
while :
do
  echo -e "$RED If you use a password to log on, please select Y or y, If you use SSH key login, select N or n or enter, but remember to save the private key to your local. $NO_COLOR" 
  echo -en "$RED Please: [Y|y|N|n] $NO_COLOR"
  read value
  if [ Z$value == Z"Y" ] || [ Z$value == Z"y" ] || [ Z$value == Z"" ];then
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
output_passwd(){
PASS_FILE=/tmp/pass_temp
HOSTNAME=`hostname`
echo "----SYSTEM INFORMATION---- " > $PASS_FILE

echo "hostname is $HOSTNAME
zyadmin password/key is
$PASS
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

    echo "Starting user_tunning"
    output_passwd
    echo "Finished user_tunning"
