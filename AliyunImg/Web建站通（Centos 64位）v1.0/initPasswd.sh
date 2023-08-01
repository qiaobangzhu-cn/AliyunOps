#!/bin/bash

##set mysql pass##
function InputMysqlPass()
{
	MysqlPass=$(date +%s%N  | md5sum |head -c 10)
}
##set AMH Pass##
function InputAMHPass()
{
	AMHPass=$(date +%s%N | md5sum |head -c 10)
}

function AMHMysqlPass()
{
OldMysqlPass=`cat /alidata/account.log  | grep 'mysql password' | awk -F':' '{print$2}'`;
SedMysqlPass=${MysqlPass//&/\\\&};
SedMysqlPass=${SedMysqlPass//\'/\\\\\'};
SedAMHPass=${AMHPass//&/\\\&};
SedAMHPass=${SedAMHPass//\'/\\\\\\\\\'\'};
mysql -hlocalhost -uroot -p$OldMysqlPass <<EOF
use amh;
update amh_user set user_password=md5(md5('${SedAMHPass}_amysql-amh')) where user_name='admin';
USE mysql;
UPDATE user set password=password('$SedMysqlPass') WHERE User='root';
FLUSH PRIVILEGES;
EOF
}
##set nginx port##
function Nginxport()
{
OldPort=`cat /alidata/account.log | grep url | awk -F':' '{print$4}'`;
sed -i "s/'$OldMysqlPass'/'$SedMysqlPass'/g" /home/wwwroot/index/web/Amysql/Config.php;
Domain=`ifconfig  | grep 'inet addr:'| egrep -v ":192.168|:172.1[6-9].|:172.2[0-9].|:172.3[0-2].|:10.|:127." | cut -d: -f2 | awk '{ print $1}'`;
sed -i 's/www.amysql.com/'$Domain'/g' /usr/local/nginx/conf/nginx.conf;
port=`echo $(($(($RANDOM%500))+10000))`
sed -i 's/'$OldPort'/'$port'/g' /usr/local/nginx/conf/nginx.conf
}

function Printpass()
{
mkdir /alidata/
cat > /alidata/account.log << END
-------------------------------------

	AMD url: http://$Domain:$port
	AMD user:admin
	AMD password:$AMHPass
	mysql user:root
	mysql password:$MysqlPass
	
--------------------------------------
END
}
function init()
{
sed -i "/\/alidata\/init\/init.*/d" /etc/rc.d/rc.local
}

InputMysqlPass;
InputAMHPass;
AMHMysqlPass;
Nginxport;
Printpass;
init;


/bin/bash /etc/init.d/amh-start
