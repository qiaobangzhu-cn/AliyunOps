#/bin/sh

# Header line will be added togather
#echo ${CommonHeader}FwIdx_num,FwIdx_prot,FwIdx_rule > Network_Firewall.csv

iptables --line-numbers -vnL INPUT|sed '1,2d' > FwInput.tmp

awk '{print $1" "$4","$5","$7","$8","$9","$10","}' FwInput.tmp > fw1.tmp

awk '{$1=$2=$3=$4=$5=$6=$7=$8=$9=$10=""}1' FwInput.tmp|sed 's/^ *//g' > rule1.tmp
# add Index
awk '$0=NR" "$0' rule1.tmp > rule2.tmp

join -a1 -a2 fw1.tmp rule2.tmp > FwInput2.tmp


# truncate reject all part
sed -i '/ DROP,all,\*,\*,0.0.0.0\/0,0.0.0.0\/0,/,$d' FwInput2.tmp

# remove DROP REJECT lo icmp
fgrep -v " DROP," FwInput2.tmp|fgrep -v " REJECT,"|fgrep -v ",lo,"|fgrep -v ",icmp," > FwInput3.tmp

if [ "${ETH1}" ] ; then
	sed -i '/,eth0,/d' FwInput3.tmp
fi

# remove "state RELATED,ESTABLISHED"
sed -i '/, state RELATED,ESTABLISHED$/d' FwInput3.tmp

fgrep ",*,*,0.0.0.0/0," FwInput3.tmp > FwInput4.tmp

sed -i 's/ /,/' FwInput4.tmp
sed -i 's/, /,/' FwInput4.tmp

awk -F',' '{print ENVIRON["CommonInfo"]$1","$3","$8}' FwInput4.tmp >> Network_Firewall.csv

mv Network_Firewall.csv ../${UploadDir}/firewalls/
