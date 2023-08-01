#!/bin/bash
. /usr/local/zabbix-agentd/monitor_scripts/jboss_monitor-sender.sh.conf

cmdline-jmxclient-0.10.3.jar存放路径
jmxclient=/usr/local/zabbix-agentd/monitor_scripts
#zabbix_sender的路径
zabbix_sender_client=/usr/local/zabbix-agentd/bin
#ZABBIX_SERVER地址
ZABBIX_SERVER=zabbix.jiagouyun.com
#ZABBIX_SERVER端口
ZABBIX_PORT=10051
#每行代码运行时间间隔
SLEEP_TIME=2
#获取jmx端口和tomcat自动发现配套使用
tmpfile="/tmp/jboss.tmp"

while true;do
if [ ! -s /tmp/jboss.tmp ]
then
sleep 300
fi
sender_data(){
  $zabbix_sender_client/zabbix_sender -z $ZABBIX_SERVER -p $ZABBIX_PORT -s "$HOSTNAME"  -k jboss[$JBOSS_PORT,$KEY] -o $MONITOR_DATA > /dev/null
  sleep $SLEEP_TIME
}
#发送监控数据
num=$(cat "$tmpfile" |wc -l)
while read line;do
  JBOSS_PORT=$(echo $line | awk '{print $1}')
. /usr/local/zabbix-agentd/monitor_scripts/jboss_monitor-sender.sh.conf
#获取数据
MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$JBOSS_PORT java.lang:type=Memory HeapMemoryUsage 2>&1|grep used: |grep -oP "\d{1,}"`
KEY=memory_used
sender_data
#已经使用堆内存

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$JBOSS_PORT java.lang:type=Memory HeapMemoryUsage 2>&1|grep committed: |grep -oP "\d{1,}"`
KEY=memory_committed
sender_data
#已提交的堆内存


MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$JBOSS_PORT java.lang:type=Memory HeapMemoryUsage 2>&1|grep max: |grep -oP "\d{1,}"`
KEY=memory_max
sender_data
#最大堆内存

#MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$JBOSS_PORT Catalina:type=Server serverInfo 2>&1 | awk -F : '{print $4}'`
#KEY=tomcat_version
#sender_data
##检查tomcat版本信息
#
MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$JBOSS_PORT java.lang:type=ClassLoading LoadedClassCount 2>&1 | awk -F : '{print $4}'`
KEY=jboss_loadclass
sender_data
#已加载的类

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$JBOSS_PORT java.lang:type=ClassLoading TotalLoadedClassCount 2>&1 | awk -F : '{print $4}'`
KEY=jboss_totalclass
sender_data
#类的总数


MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$JBOSS_PORT java.lang:type=ClassLoading UnloadedClassCount 2>&1 | awk -F : '{print $4}'`
KEY=jboss_unloadclass
sender_data
#未加载类的数量

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$JBOSS_PORT java.lang:type=Threading PeakThreadCount 2>&1 | awk -F : '{print $4}'`
KEY=jboss_peakthreadcount
sender_data
#tomcat峰值线程

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$JBOSS_PORT java.lang:type=Threading ThreadCount 2>&1 | awk -F : '{print $4}'`
KEY=jboss_threadcount
sender_data
#jboss活动线程
#
MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$JBOSS_PORT java.lang:type=Threading TotalStartedThreadCount 2>&1 | awk -F : '{print $4}'`
KEY=jboss_totalstartthreadcount
sender_data
#jboss线程总计

#
MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$JBOSS_PORT java.lang:type=Memory HeapMemoryUsage 2>&1 | grep max: |wc -l`
KEY=check_status
sender_data
#检查监控状态
((num--))
  [ "$num" == 0 ] && break
  done < "$tmpfile"
done