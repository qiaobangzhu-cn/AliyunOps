#!/bin/bash
ip=$1
ping -c2 $ip -w 1 | grep time= &>/dev/null
if [ $? -eq 0 ]
then
ping -c1 $ip | grep time= | awk -F "[  = ]+" '{print $10}'
else
echo 0
fi

