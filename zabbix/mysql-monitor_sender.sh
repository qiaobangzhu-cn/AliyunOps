#!/bin/bash
source /usr/local/zabbix-agentd/monitor_scripts/mysql-monitor.sh.conf
##数据连接
MYSQL_CONN="mysqladmin -u${MYSQL_USER} -p${MYSQL_PWD} -h${MYSQL_HOST} -P${MYSQL_PORT}"
##主从状态检查
MYSQL_SLAVE="mysql -u${MYSQL_USER} -p${MYSQL_PWD} -h${MYSQL_HOST} -P${MYSQL_PORT}"
# 参数是否正确
if [ $# -ne "1" ];then
echo "arg error!"
fi

#zabbix_sender的路径
zabbix_sender_client=/usr/local/zabbix-agentd/bin
#ZABBIX_SERVER地址
ZABBIX_SERVER=zabbix.jiagouyun.com
#ZABBIX_SERVER端口
ZABBIX_PORT=10051
#每行代码运行时间间隔
SLEEP_TIME=5
#HOSTNAME=oichina-web

while true;do

sender_data(){
  $zabbix_sender_client/zabbix_sender -z $ZABBIX_SERVER -p $ZABBIX_PORT -s "$HOSTNAME"  -k mysql.status[$KEY] -o $result > /dev/null
  sleep $SLEEP_TIME
}

sender_mysqlping(){
  $zabbix_sender_client/zabbix_sender -z $ZABBIX_SERVER -p $ZABBIX_PORT -s "$HOSTNAME"  -k mysql.ping -o $result > /dev/null
  sleep $SLEEP_TIME
}
sender_mysqlversion(){
  $zabbix_sender_client/zabbix_sender -z $ZABBIX_SERVER -p $ZABBIX_PORT -s "$HOSTNAME"  -k mysql.version -o $result > /dev/null
  sleep $SLEEP_TIME
}

sender_mysqlprocess(){
  $zabbix_sender_client/zabbix_sender -z $ZABBIX_SERVER -p $ZABBIX_PORT -s "$HOSTNAME"  -k mysql.process -o $result > /dev/null
  sleep $SLEEP_TIME
}


#while read line;do



# 获取数据

source /usr/local/zabbix-agentd/monitor_scripts/mysql-monitor.sh.conf
result=`mysql.version,mysql -V | cut -f6 -d" " | sed 's/,//'`
sender_mysqlversion


result=`mysqladmin -u${MYSQL_USER} -p${MYSQL_PWD} -h${MYSQL_HOST} -P${MYSQL_PORT} ping 2>/dev/null | grep -c alive`
sender_mysqlping

result=`mysql -u${MYSQL_USER} -p${MYSQL_PWD} -h${MYSQL_HOST} -P${MYSQL_PORT} -e "show processlist" 2>/dev/null|wc -l`
sender_mysqlprocess


##运行时间
KEY=Uptime
result=`${MYSQL_CONN} status 2>/dev/null |cut -f2 -d":"|cut -f1 -d"T"`
sender_data

##主从状态
#KEY=slave_status
#result=`${MYSQL_SLAVE}  -e 'show slave status\G' 2>/dev/null |grep -E "Slave_IO_Running|Slave_SQL_Running"|awk '{print $2}'|grep -c Yes`
#sender_data


KEY=Com_update
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Com_update"|cut -d"|" -f3`
sender_data

KEY=Slow_queries
result=`${MYSQL_CONN} status 2>/dev/null |cut -f5 -d":"|cut -f1 -d"O"`
sender_data

KEY=Com_select
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Com_select"|cut -d"|" -f3`
sender_data

KEY=Com_rollback
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Com_rollback"|cut -d"|" -f3`
sender_data

KEY=Questions
result=`${MYSQL_CONN} status 2>/dev/null |cut -f4 -d":"|cut -f1 -d"S"`
sender_data

KEY=Com_insert
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Com_insert"|cut -d"|" -f3`
sender_data

KEY=Com_delete
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Com_delete"|cut -d"|" -f3`
sender_data

KEY=Com_commit
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Com_commit"|cut -d"|" -f3`
sender_data

KEY=Bytes_sent
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Bytes_sent" |cut -d"|" -f3`
sender_data

KEY=Bytes_received
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Bytes_received" |cut -d"|" -f3`
sender_data

KEY=Com_begin
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Com_begin"|cut -d"|" -f3`
sender_data

done
