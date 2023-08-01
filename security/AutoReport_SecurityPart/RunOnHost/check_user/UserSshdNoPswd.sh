echo '####是否禁止使用密码连接ssh'

PASSWD_LOGIN=`cat /etc/ssh/sshd_config |grep PasswordAuthentication |grep -v "^#" |awk '{print $2}'`
if [ $PASSWD_LOGIN == yes ]
then
echo "允许密码登录"
else
echo "不允许密码登录"
fi
