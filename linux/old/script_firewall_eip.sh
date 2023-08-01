#!/bin/bash
################################################
# Script Firewall for regulare host
#
# Description:
# - restrictived inbound + outbound
################################################
################################################
################################################

version_num=20141021

########################################################
# Script settings
########################################################
IPT=/sbin/iptables
IPT_SAVE=/sbin/iptables-save
DATE=/bin/date
DATE_FORMAT="+%y%m%d_%H%M%S"
TC=/sbin/tc

# depending if this is CentOS / RH -- Debian
# Red-Hat - CentOS
if [ -f /etc/redhat-release ]; then
  IPT_SAVE_FILE=/etc/sysconfig/iptables
  IPT_HISTORY_FOLDER=/etc/sysconfig/iptables_history
# Debian - Ubuntu
elif [ -f /etc/debian_version ]; then
  IPT_SAVE_FILE=/etc/iptables
  IPT_HISTORY_FOLDER=etc/iptables_history
else
  IPT_SAVE_FILE=
  IPT_HISTORY_FOLDER=
  echo -e "$RED ERROR: The OS has detected neither RedHat / CentOS / Debian $NO_COLOR" >&2
  echo -e "$RED ERROR: Enter manually the location of the Save / History files $NO_COLOR" >&2
  exit 1
fi

# define interfaces IP
MY_ETH0_IP=$(ifconfig eth0 | grep inet | awk '{print $2}' | awk -F ":" '{print $2}')
MY_ETH0_IP_SEG="${MY_ETH0_IP%.*}.0/24"

########################################################
# Ports Definition
########################################################
HIGH_SOURCE_PORTS=1024:65535
HTTP_PORT=80
HTTPS_PORT=443
FTP_PORT=21
SSH_PORT=40022
ZY_SSH_PORT=30022
DNS_PORT=53
NTP_PORT=123
SMTP_PORT=25
POP3_PORT=110
LDAP_PORT=389
LDAPS_PORT=636
IMAP_PORT=143
IMAPS_PORT=993
SYSLOG_PORT=5544
MYSQL_PORT=3306
MEMCACHED_PORT=11211
POSTGRESQL_PORT=5432
BACULA_DIR_PORT=9101
BACULA_SD_PORT=9103
BACULA_FD_PORT=9102
ZABBIX_AGENT_PORT=10050:10051
SSH_BACKUP_PORT=40024
LDAP_SSH_PORT=60022
# define custom services ports below (HTTP - FTP - custom ports - etc.)
HTTPS_CUSTOM_PORT=

########################################################
# Location IPs
########################################################
SRV_ZY_SSH1_IP=115.29.244.224/32
SRV_ZY_SSH2_IP=42.96.192.168/32

ZABBIX_SERVER_IP=114.215.177.175/32
SYSLOG_SERVER_IP=115.29.213.132/32
#BACKUP_SERVER_IP=61.129.13.23/32

##### %START_EXTRA HOST definition
##### %END_EXTRA HOST definition

########################################################
# Font color
########################################################
RED="\033[0;31m"
GREEN="\033[0;32m"
NO_COLOR="\033[0m"

########################################################
# run checking - valid script + right user
########################################################
run_check() {
  if ifconfig eth1 &> /dev/null;then
	echo -e "$RED ERROR: This os found eth1,please : \"wget http://git.jiagouyun.com/operation/operation/raw/master/linux/sys/script_firewall.sh\" ! $NO_COLOR" >&2
	exit 1
  fi

  if ! ping 114.215.177.175 -c 2 &> /dev/null;then
	echo -e "$RED ERROR: This os can't networking,please don't set up a firewall ! $NO_COLOR"
	exit 1
  fi

  # check for user ID - has to be root
  if ! id |grep "uid=0(root)" &> /dev/null; then
    echo -e "$RED ERROR: You need to run this script as ROOT user $NO_COLOR" >&2
    exit 2
  fi

  # $MY_ETH0_IP is not defined, or empty
  if [ -z "$MY_ETH0_IP" ]; then
    echo -e "$RED ERROR: You need to configure the script and edit MY_ETH0_IP $NO_COLOR" >&2
    exit 2
  fi
}

########################################################
# Backup iptables rules
########################################################
backup_rules() {
  # Backup current iptables rules
  if [ ! -d $IPT_HISTORY_FOLDER ]; then
    echo "Creating $IPT_HISTORY_FOLDER to store previous iptables settings: "
    mkdir -p $IPT_HISTORY_FOLDER
    if [ $? -ne 0 ]; then
      echo -e "$RED ERROR: Error on creation of: $IPT_HISTORY_FOLDER $NO_COLOR" >&2
      exit 2
    fi
  fi

  # Save current iptables settings
  echo "Saving iptables rules: "
  IPT_BACKUP_FILE=$IPT_HISTORY_FOLDER/iptables.`$DATE "$DATE_FORMAT"`
  $IPT_SAVE > $IPT_BACKUP_FILE
  if [ $? -ne 0 ]; then
    echo -e "$RED ERROR: Error on saving backup rules in: $IPT_BACKUP_FILE $NO_COLOR" >&2
    exit 2
  else
    echo -e "$GREEN Iptables rules saved in $IPT_BACKUP_FILE $NO_COLOR"
  fi
}

########################################################
# Clean iptables and set new rules
########################################################
clean_iptables() {
  # Cleanup old rules
  # At this time firewall is in a secure, closed state
  echo "Cleaning rules - setting policies - flush rules - delete chains: "
  $IPT -P INPUT ACCEPT
  $IPT -P OUTPUT ACCEPT
  $IPT -P FORWARD DROP

  $IPT --flush        # Flush all rules, but keep policies
  $IPT -t nat --flush	# Flush NAT table as well
  $IPT --delete-chain
  $IPT -t mangle -F
  #$TC qdisc del dev eth1 root &> /dev/null
  echo -e "$GREEN Cleaning done. $NO_COLOR"
}

inbound_rules() {
  # return value
  return_val=0 ; return_val=$((return_val+$?))

  # Local traffic - allow all on lo interface
  $IPT -A INPUT -i lo -j ACCEPT
  
  # Local traffic - allow all on intranet interface
  $IPT -A INPUT -p tcp -m state --state NEW -m tcp -s $MY_ETH0_IP_SEG -j ACCEPT
  
  #Main Firewall rules start ###########################
  # create a LOGDROP chain to allow DROP then LOG
  echo "Creating custom log chains: "
  $IPT -N LOGDROP_ILLEGAL_PACKET
  $IPT -A LOGDROP_ILLEGAL_PACKET -j LOG -m limit --limit 120/minute --log-prefix "IPTFW-bad-flag " --log-level debug
  $IPT -A LOGDROP_ILLEGAL_PACKET -j DROP
  echo -e "$GREEN Custom log chains created. $NO_COLOR"

  # For the following rules we log and drop illegal network traffic
  # can be set to a new log file by defining --log-level
  # First thing, drop illegal packets.
  echo "Dropping illegal INBOUND traffic - packets + networks: "
  # $IPT -A INPUT -p tcp ! --syn -m state --state NEW -j LOGDROP_ILLEGAL_PACKET # New not SYN
  $IPT -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j LOGDROP_ILLEGAL_PACKET
  $IPT -A INPUT -p tcp --tcp-flags ALL ALL -j LOGDROP_ILLEGAL_PACKET
  $IPT -A INPUT -p tcp --tcp-flags ALL NONE -j LOGDROP_ILLEGAL_PACKET  # NULL packets
  $IPT -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j LOGDROP_ILLEGAL_PACKET
  $IPT -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j LOGDROP_ILLEGAL_PACKET # XMAS
  $IPT -A INPUT -p tcp --tcp-flags FIN,ACK FIN -j LOGDROP_ILLEGAL_PACKET  # FIN packet
  $IPT -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j LOGDROP_ILLEGAL_PACKET

  echo -e "$GREEN Illegal INBOUND traffic dropped. $NO_COLOR"

  #### HOLES ####
  echo -en "Creating rules for allowed INBOUND traffic: $RED\n"
  # Established - should be tightened to allowed IP later
  $IPT -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

  ## ICMP / Ping - should be tightened to allowed IP later
  $IPT -A INPUT -p icmp -m icmp --icmp-type echo-request -m limit --limit 10/second -j ACCEPT
  $IPT -A INPUT -p icmp -m icmp --icmp-type echo-reply -m limit --limit 10/second -j ACCEPT
  $IPT -A INPUT -p icmp -m icmp --icmp-type time-exceeded -m limit --limit 10/second -j ACCEPT
  $IPT -A INPUT -p icmp -m icmp --icmp-type destination-unreachable -m limit --limit 10/second -j ACCEPT
  $IPT -A INPUT -p icmp -j DROP

  ###### DHCP Rules ######
  $IPT -A INPUT -p udp --dport 67:68 --sport 67:68 -j ACCEPT

  ###### SSH inbound -- only from the main interface - to be changed in the future if we want to access it only through the private IF
  $IPT -A INPUT -p tcp -m state --state NEW -m tcp -s $SRV_ZY_SSH1_IP --sport $HIGH_SOURCE_PORTS --dport $SSH_PORT -j ACCEPT
  $IPT -A INPUT -p tcp -m state --state NEW -m tcp -s $SRV_ZY_SSH2_IP --sport $HIGH_SOURCE_PORTS --dport $SSH_PORT -j ACCEPT
  ###### SSH inbound -- can access for any.

  ###### Zabbix agentd inbound - from the main IF only until further change
  $IPT -A INPUT -p tcp -m state --state NEW -m tcp -s $ZABBIX_SERVER_IP --sport $HIGH_SOURCE_PORTS --dport $ZABBIX_AGENT_PORT -j ACCEPT
  
  ###### %START_EXTRA CUSTOM inbound
#  $IPT -A INPUT -p tcp -m state --state NEW -m tcp -s <source_address> --sport $HIGH_SOURCE_PORTS --dport <destnation_port> -j ACCEPT
  ###### %END_EXTRA CUSTOM inbound

  $IPT -A INPUT -j DROP
  echo -e "$GREEN INBOUND holes created. $NO_COLOR"
}

outbound_rules() {
  echo -en "Creating OUTBOUND rules: $RED\n"
  # Local traffic allowed accept al on lo interface
  $IPT -A OUTPUT -o lo -j ACCEPT

  # Local traffic - allow all on intranet interface
  $IPT -A OUTPUT -p tcp -m state --state NEW -d $MY_ETH0_IP_SEG -j ACCEPT
  
  # allow established connections
  $IPT -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

  # allow output ICMP traffic (ping - traceroute - etc.)
  $IPT -A OUTPUT -p icmp -m icmp --icmp-type echo-request -m limit --limit 10/second -j ACCEPT
  $IPT -A OUTPUT -p icmp -m icmp --icmp-type echo-reply -m limit --limit 10/second -j ACCEPT
  $IPT -A OUTPUT -p icmp -m icmp --icmp-type time-exceeded -m limit --limit 10/second -j ACCEPT
  $IPT -A OUTPUT -p icmp -m icmp --icmp-type destination-unreachable -m limit --limit 10/second -j ACCEPT
  $IPT -A OUTPUT -p icmp -j DROP

  ###### DHCP Rules ######
  $IPT -A OUTPUT -p udp --dport 67:68 --sport 67:68 -j ACCEPT

  # until further notice all traffic is restriction is applied to the main interface
  # DNS - NTP - HTTP - SMTP - SYSLOG
  # allow DNS traffic
  $IPT -A OUTPUT -p udp -m state --state NEW --dport $DNS_PORT -j ACCEPT

  # allow NTP traffic
  $IPT -A OUTPUT -p udp -m state --state NEW --dport $NTP_PORT -j ACCEPT

  # allow FTP traffic -- for system update
  $IPT -A OUTPUT -p tcp -m state --state NEW --dport $FTP_PORT -j ACCEPT

  # allow HTTP traffic -- for system update
  $IPT -A OUTPUT -p tcp -m state --state NEW --dport $HTTP_PORT -j ACCEPT

  # allow HTTPS traffic -- for system update
  $IPT -A OUTPUT -p tcp -m state --state NEW --dport $HTTPS_PORT -j ACCEPT

  # allow SMTP traffic for emails
  $IPT -A OUTPUT -p tcp -m state --state NEW --dport $SMTP_PORT -j ACCEPT

  # allow SSH traffic for internal communications
  $IPT -A OUTPUT -p tcp -m state --state NEW --dport $SSH_PORT -j ACCEPT

  # allow ZY SSH traffic for internal communications
  $IPT -A OUTPUT -p tcp -m state --state NEW -d $SRV_ZY_SSH1_IP --dport $ZY_SSH_PORT -j ACCEPT
  $IPT -A OUTPUT -p tcp -m state --state NEW -d $SRV_ZY_SSH2_IP --dport $ZY_SSH_PORT -j ACCEPT
  
  # allow SYSLOG traffic for emails
  $IPT -A OUTPUT -p tcp -m state --state NEW -d $SYSLOG_SERVER_IP --dport $SYSLOG_PORT -j ACCEPT

  ###### %START_EXTRA CUSTOM outbound
#  $IPT -A OUTPUT -p tcp -m state --state NEW -d <destnation_address> --dport <destnation_port> -j ACCEPT
  ###### %END_EXTRA CUSTOM outbound

  $IPT -A OUTPUT -j DROP
  echo -e "$GREEN OUTBOUND rules created $NO_COLOR"
}

#######################################
# Main function
#######################################
main() {
  echo "############################################"
  echo $(basename $0)
  printf "Version: %s\n" $version_num
  echo "############################################"
  
  run_check
  backup_rules
    if [ $? -ne 0 ]; then echo -e "$RED ERROR: Error during iptables rules backup $NO_COLOR" >&2; exit 2; fi
  clean_iptables
    if [ $? -ne 0 ]; then echo -e "$RED ERROR: Error during iptables cleanup $NO_COLOR" >&2; exit 2; fi
  inbound_rules
    if [ $? -ne 0 ]; then echo -e "$RED ERROR: Error during iptables inbound rules definition $NO_COLOR" >&2; exit 2; fi
  outbound_rules
    if [ $? -ne 0 ]; then echo -e "$RED ERROR: Error during iptables outbound rules definition $NO_COLOR" >&2; exit 2; fi

  echo "############################################"
  echo "Done. \o/"
}

# check that at least one parameter has been added when lauching the script
if [ "$1" = "-h" ] || [ "$1" = "-H" ] || [ "$1" = "--help" ] || [ "$1" = "--HELP" ]; then
   echo "Please run in the root user: bash script_firewall.sh !!"
   exit 2
fi
# run main function
main
