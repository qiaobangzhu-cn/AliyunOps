#!/bin/bash
port_array=(`netstat -tnlp|egrep -i "$1"|awk {'print $4'}|awk -F':' '{if ($NF~/^[0-9]*$/) print $NF}'|sort |uniq   2>/dev/null`)
length=${#port_array[@]}
printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$length;i++))
do
        printf '\n\t\t{'
        printf "\"{#TCP_PORT}\":\"${port_array[$i]}\"}"
        if [ $i -lt $[$length-1] ];then
                printf ','
        fi
done
printf  "\n\t]\n"
printf "}\n"