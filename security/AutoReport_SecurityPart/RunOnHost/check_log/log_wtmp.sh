#!/bin/env sh

# conflict !
export UniqHeader=Index,Account,AccountTimes,Host,HostTimes

last -F -w|egrep " ${ChkMonthAbbr} .* ${ChkYear} "|egrep -iv "^reboot "|fgrep -iv "tty"|awk '{print $1}'|sort|uniq -c|sort -bgr|head -3|awk '{print $1","$2}' > LogWtmpAccount.tmp
echo -e ",\n,\n,\n" >> LogWtmpAccount.tmp
head -3 LogWtmpAccount.tmp > LogWtmpAccount2.tmp
awk '$0=NR" "$0' LogWtmpAccount2.tmp > LogWtmpAccount3.tmp

last -F -w|egrep " ${ChkMonthAbbr} .* ${ChkYear} "|egrep -iv "^reboot "|fgrep -iv "tty"|awk '{print $3}'|sort|uniq -c|sort -bgr|head -3|awk '{print $1","$2}' > LogWtmpHost.tmp
echo -e ",\n,\n,\n" >> LogWtmpHost.tmp
head -3 LogWtmpHost.tmp > LogWtmpHost2.tmp
awk '$0=NR" "$0' LogWtmpHost2.tmp > LogWtmpHost3.tmp

# create header line

echo ${CommonHeader}${UniqHeader} > Log_Wtmp.csv

join -a1 -a2 LogWtmpAccount3.tmp LogWtmpHost3.tmp|awk '{print ENVIRON["CommonInfo"]$1","$2","$3}' >> Log_Wtmp.csv

mv Log_Wtmp.csv ../${UploadDir}
