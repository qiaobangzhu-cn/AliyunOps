#!/bin/env sh

# conflict !
export UniqHeader=Index,Account,AccountTimes,Host,HostTimes

cat /var/log/secure-${ChkYear}${ChkMonthNum}?? > secure

fgrep " sshd[" secure|fgrep -i " failed "|sed "s/ for /;/g"|sed "s/ from /;/g"|sed "s/ port /;/g"|awk -F';' '{print $2" "$3}' > secure2

awk '{print $1}' secure2|sort|uniq -c|sort -bgr|head -3|awk '{print $1","$2}' > LogSecAccount.tmp
echo -e ",\n,\n,\n" >> LogSecAccount.tmp
head -3 LogSecAccount.tmp > LogSecAccount2.tmp
awk '$0=NR" "$0' LogSecAccount2.tmp > LogSecAccount3.tmp

awk '{print $2}' secure2|sort|uniq -c|sort -bgr|head -3|awk '{print $1","$2}' > LogSecHost.tmp
echo -e ",\n,\n,\n" >> LogSecHost.tmp
head -3 LogSecHost.tmp > LogSecHost2.tmp
awk '$0=NR" "$0' LogSecHost2.tmp > LogSecHost3.tmp

echo ${CommonHeader}${UniqHeader} > Log_Secure.csv

join -a1 -a2 LogSecAccount3.tmp LogSecHost3.tmp|awk '{print ENVIRON["CommonInfo"]$1","$2","$3}' >> Log_Secure.csv

mv Log_Secure.csv ../${UploadDir}
