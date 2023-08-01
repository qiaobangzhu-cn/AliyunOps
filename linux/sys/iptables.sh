#!/bin/bash
################################################
# Script Firewall for INPUT and OUTPUT rules
#监控ip通过域名添加，每次重启iptables会自动解析监控的域名，跳板机也需要用域名，
#用域名的好处是执行bash /etc/iptables.sh的时候会解析域名到ip，但是不会实时的去获取最新的域名解析
################################################
version_num=20170214
RED="\033[0;31m"
GREEN="\033[0;32m"
NO_COLOR="\033[0m"

# define interfaces IP
MY_ETH0_IP=$(ip a | grep -A 0 "eth0" | awk -F "[ /]*" '/inet/ {print $3}')
MY_ETH0_IP_SEG="${MY_ETH0_IP%.*}.0/24"

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
  iptables -P FORWARD ACCEPT

  iptables --flush        # Flush all rules, but keep policies
  iptables -t nat --flush	# Flush NAT table as well
  iptables --delete-chain
  iptables -t mangle -F
  echo -e "$GREEN Cleaning done. $NO_COLOR"
}

input_rules() {
  echo -en "Creating rules for allowed INPUT traffic: $RED\n"
  iptables -A INPUT -i lo -j ACCEPT
  if ifconfig eth1 &> /dev/null;then
	iptables -A INPUT -i eth0 -j ACCEPT
  else
    # Local traffic - allow all on intranet interface. <<<Apply to VPC environment>>>
    iptables -A INPUT -p tcp -m state --state NEW -m tcp -s $MY_ETH0_IP_SEG -j ACCEPT
  fi
  
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p icmp -m icmp --icmp-type echo-request -m limit --limit 10/second -j ACCEPT
  iptables -A INPUT -p icmp -m icmp --icmp-type echo-reply -m limit --limit 10/second -j ACCEPT
  iptables -A INPUT -p icmp -m icmp --icmp-type time-exceeded -m limit --limit 10/second -j ACCEPT
  iptables -A INPUT -p icmp -m icmp --icmp-type destination-unreachable -m limit --limit 10/second -j ACCEPT
  iptables -A INPUT -p icmp -j DROP

  ###### SSH inbound -- only from the main interface - to be changed in the future if we want to access it only through the private IF
  tiaobanji="ssh1.jiagouyun.com ssh2.jiagouyun.com ssh3.jiagouyun.com ssh4.jiagouyun.com"
  for ip in $tiaobanji
    do
      iptables -A INPUT -p tcp -m state --state NEW -m tcp -s $ip --dport 40022 -j ACCEPT
    done

  ###### Zabbix agentd inbound
  iptables -A INPUT -p tcp -m state --state NEW -m tcp -s hz-monitor.jiagouyun.com --dport 10050:10051 -j ACCEPT
  iptables -A INPUT -p tcp -m state --state NEW -m tcp -s bj-monitor.jiagouyun.com --dport 10050:10051 -j ACCEPT

  ###### Add the input rules here:
#  iptables -A INPUT -p tcp -m state --state NEW -m tcp -s <source_address> --dport <destnation_port> -j ACCEPT
  ###### Add an end
  
  iptables -A INPUT -j DROP
  echo -e "$GREEN INPUT rules created done. $NO_COLOR"
}

output_rules() {
  echo -en "Creating rules for allowed OUTPUT traffic: $RED\n"
  # Local traffic allowed accept al on lo interface
  iptables -A OUTPUT -j ACCEPT
  
  ###### Add the output rules here:
#  iptables -A OUTPUT -p tcp -m state --state NEW -m tcp -s <source_address> --dport <destnation_port> -j ACCEPT
  ###### Add an end
  
  echo -e "$GREEN OUTPUT rules created done. $NO_COLOR"
}

if ! id |grep "uid=0(root)" &> /dev/null; then
	echo -e "$RED ERROR: You need to run this script as ROOT user $NO_COLOR" >&2
	exit 2
fi
if [ "$1" = "-h" ] || [ "$1" = "-H" ] || [ "$1" = "--help" ] || [ "$1" = "--HELP" ]; then
   echo "Please run in the root user: bash script_firewall.sh !!"
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
