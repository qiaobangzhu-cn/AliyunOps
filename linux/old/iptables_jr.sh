#!/bin/bash
################################################
# Script Firewall jingrong yun for INPUT and OUTPUT rules
################################################
version_num=20150525
RED="\033[0;31m"
GREEN="\033[0;32m"
NO_COLOR="\033[0m"

backup_rules() {
  echo "Saving iptables rules: "
  mkdir -p /etc/iptables_history
  IPT_BACKUP_FILE=/etc/iptables_history/iptables.$(date +%y%m%d_%H%M%S)
  iptables-save > $IPT_BACKUP_FILE
  echo -e "$GREEN Iptables rules saved in $IPT_BACKUP_FILE $NO_COLOR"
}

clean_iptables() {
  echo "Cleaning rules - setting policies - flush rules - delete chains: "
  iptables -P INPUT ACCEPT
  iptables -P OUTPUT ACCEPT
  iptables -P FORWARD DROP

  iptables --flush        # Flush all rules, but keep policies
  iptables -t nat --flush	# Flush NAT table as well
  iptables --delete-chain
  iptables -t mangle -F
  echo -e "$GREEN Cleaning done. $NO_COLOR"
}

input_rules() {
  echo -en "Creating rules for allowed INPUT traffic: $RED\n"
  iptables -A INPUT -i lo -j ACCEPT

  ###### SSH inbound -- only from the main interface - to be changed in the future if we want to access it only through the private IF
  tiaobanji="115.29.244.224 42.96.192.168 115.29.209.204 121.42.151.134 112.124.212.223 10.0.0.0/8"
  for ip in $tiaobanji
    do
      iptables -A INPUT -i eth0 -p tcp -m state --state NEW -m tcp -s $ip --dport 40022 -j ACCEPT
    done

  iptables -A INPUT -i eth0 -p tcp -m state --state NEW -m tcp --dport 40022 -j DROP
  echo -e "$GREEN INPUT rules created done. $NO_COLOR"
}

output_rules() {
  #echo -en "Creating rules for allowed OUTPUT traffic: $RED\n"
  iptables -A OUTPUT -j ACCEPT
  
  echo -e "$GREEN OUTPUT rules created done. $NO_COLOR"
}

if ! id |grep "uid=0(root)" &> /dev/null; then
	echo -e "$RED ERROR: You need to run this script as ROOT user $NO_COLOR" >&2
	exit 2
fi
if [ "$1" = "-h" ] || [ "$1" = "-H" ] || [ "$1" = "--help" ] || [ "$1" = "--HELP" ]; then
   echo "Please run in the root user: bash script_firewall_jr.sh !!"
   exit 2
fi

echo "############################################"
echo $(basename $0)
printf "Version: %s\n" $version_num
echo "############################################"
backup_rules
clean_iptables
input_rules
output_rules
echo "############################################"
echo "Done. "
