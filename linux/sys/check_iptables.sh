#!/bin/bash
#
# Developers: Rhommel Lamas
# Purpose: zabbix Plugin for Iptables Rules load check
# Version 0.5
#
PARAM1=$1
TABLE=$2
MINRULES=$3
PARAM4=$4
LOG=/var/log/iptables/iptables.log
CHKIPTBLS=`sudo /sbin/iptables -n -t filter -L |egrep "(ACCEPT|DROP)" |grep -v policy|wc -l`
mkdir -p /var/log/iptables/

#
# Parameter Validation
##

if [ "$PARAM1" != "-T" -o "$TABLE" == "" -o "$MINRULES" != "-r" -o "$PARAM4" == "" ]; then
		echo "Usage: $0 -T <table> -r <min rules>"
		echo ""
		exit 3
                # zabbix exit code 3 = status UNKNOWN = orange


if [ "$PARAM1" == "-h" ]; then
		echo ""
		echo " 		-h = Display's this Help"
        echo " 		-T = Table to check" 
		echo "				 Available Tables:"
		echo "					nat"
		echo "					mangle"
		echo "					filter"		
        echo " 		-r = Minimun quantity of rules"
		echo ""
        # zabbix exit code 3 = status UNKNOWN = orange
                exit 3
   fi
fi

##
#	DO NOT MODIFY ANYTHING BELOW THIS
##

$CHKIPTBLS >/dev/null 2>/dev/null

if [ "$CHKIPTBLS" == 0 ]; then
	TOTRULES=$CHKIPTBLS
else
	TOTRULES=$CHKIPTBLS
fi


if [ "$TOTRULES" == "$PARAM4" ]; then
                    echo "$TOTRULES"
                    # Zabbix exit code 0 = status OK = green
                    exit 0
else
                    echo  "$TOTRULES"
#					for i in `w  -h | cut -f1 -d" " | sort | uniq`
#					do
#							
#						echo "`date '+%d/%m/%Y - %H:%M:%S'` - CRITICAL - $i is logged in and there are only $TOTRULES loaded" >> $LOG
#					done
                    # zabbix exit code 2 = status CRITICAL = red
                	exit 2                
fi