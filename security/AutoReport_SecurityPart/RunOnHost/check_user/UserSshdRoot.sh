echo '###是否禁止root通过ssh连接'
LOGIN=`cat /etc/ssh/sshd_config |grep PermitRootLogin |grep -v "^#" |awk '{print $2}'`
if [ "$LOGIN" == "yes" ]
then
echo "未禁止"
else
echo "已禁止"
fi
