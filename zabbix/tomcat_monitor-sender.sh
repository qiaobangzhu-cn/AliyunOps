#!/bin/bash
source /usr/local/zabbix-agentd/monitor_scripts/tomcat_monitor-sender.sh.conf

#cmdline-jmxclient-0.10.3.jar存放路径
jmxclient=/usr/local/zabbix-agentd/monitor_scripts
#zabbix_sender的路径
zabbix_sender_client=/usr/local/zabbix-agentd/bin
#ZABBIX_SERVER地址
ZABBIX_SERVER=zabbix.jiagouyun.com
#ZABBIX_SERVER端口
ZABBIX_PORT=10051
#每行代码运行时间间隔
SLEEP_TIME=1
#获取jmx端口和tomcat自动发现配套使用
tmpfile="/tmp/tomcat.tmp"

while true;do
if [ ! -s /tmp/tomcat.tmp ]
then
sleep 300
fi
sender_data(){
  $zabbix_sender_client/zabbix_sender -z $ZABBIX_SERVER -p $ZABBIX_PORT -s "$HOSTNAME"  -k tomcat[$TOMCAT_PORT,$KEY] -o $MONITOR_DATA > /dev/null
  sleep $SLEEP_TIME
}
#发送监控数据
num=$(cat "$tmpfile" |wc -l)
while read line;do
  TOMCAT_PORT=$(echo $line | awk '{print $1}')
source /usr/local/zabbix-agentd/monitor_scripts/tomcat_monitor-sender.sh.conf
#获取数据
MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT java.lang:type=Memory HeapMemoryUsage 2>&1|grep used: |grep -oP "\d{1,}"`
KEY=memory_used
sender_data
#已经使用堆内存

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT java.lang:type=Memory HeapMemoryUsage 2>&1|grep committed: |grep -oP "\d{1,}"`
KEY=memory_committed
sender_data
#已提交的堆内存


MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT java.lang:type=Memory HeapMemoryUsage 2>&1|grep max: |grep -oP "\d{1,}"`
KEY=memory_max
sender_data
#最大堆内存

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT Catalina:type=Server serverInfo 2>&1 | awk -F : '{print $4}'`
KEY=tomcat_version
sender_data
#检查tomcat版本信息

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT java.lang:type=ClassLoading LoadedClassCount 2>&1 | awk -F : '{print $4}'`
KEY=tomcat_loadclass
sender_data
#已加载的类

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT java.lang:type=ClassLoading TotalLoadedClassCount 2>&1 | awk -F : '{print $4}'`
KEY=tomcat_totalclass
sender_data
#类的总数


MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT java.lang:type=ClassLoading UnloadedClassCount 2>&1 | awk -F : '{print $4}'`
KEY=tomcat_unloadclass
sender_data
#未加载类的数量

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT java.lang:type=Threading PeakThreadCount 2>&1 | awk -F : '{print $4}'`
KEY=tomcat_peakthreadcount
sender_data
#tomcat峰值线程

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT java.lang:type=Threading ThreadCount 2>&1 | awk -F : '{print $4}'`
KEY=tomcat_threadcount
sender_data
#tomcat活动线程

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT java.lang:type=Threading TotalStartedThreadCount 2>&1 | awk -F : '{print $4}'`
KEY=tomcat_totalstartthreadcount
sender_data
#tomcat线程总计

#ajp_bio=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT|sort 2>&1 |grep -oP "ajp-.*-\d{1,}"|head -1`
#获取ajp-bio的端口号

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT 'Catalina:name="'$ajp_bio'",type=ThreadPool' maxThreads 2>&1| awk -F ":" '{print $4}'`
KEY=tomcat_ajp_maxThreads
sender_data
#ajp-bio的最大线程数

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT 'Catalina:name="'$ajp_bio'",type=ThreadPool' currentThreadCount 2>&1| awk -F ":" '{print $4}'`
KEY=tomcat_ajp_currentThreadCount
sender_data
#ajp-bio的当前线程数

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT 'Catalina:name="'$ajp_bio'",type=ThreadPool' currentThreadsBusy 2>&1| awk -F ":" '{print $4}'`
KEY=tomcat_ajp_currentThreadsBusy
sender_data
#ajp-bio当前繁忙线程

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT 'Catalina:name="'$ajp_bio'",type=GlobalRequestProcessor' bytesSent 2>&1| awk -F ":" '{print $4}'`
KEY=tomcat_ajp_bytesSent
sender_data
#ajp-bio发送字节数

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT 'Catalina:name="'$ajp_bio'",type=GlobalRequestProcessor' bytesReceived 2>&1| awk -F ":" '{print $4}'`
KEY=tomcat_ajp_bytesReceived
sender_data
#ajp-bio接收字节数


MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT 'Catalina:name="'$ajp_bio'",type=GlobalRequestProcessor' requestCount 2>&1| awk -F ":" '{print $4}'`
KEY=tomcat_ajp_requestCount
sender_data
#ajp-bio请求次数


#http_bio=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT|sort 2>&1 |grep -oP "http-.*-\d{1,}"|head -1`
#获取http-bio的端口号


MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT 'Catalina:name="'$http_bio'",type=ThreadPool' maxThreads 2>&1| awk -F ":" '{print $4}'`
KEY=tomcat_bio_maxThreads
sender_data
#bio的最大线程数

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT 'Catalina:name="'$http_bio'",type=ThreadPool' currentThreadCount 2>&1| awk -F ":" '{print $4}'`
KEY=tomcat_bio_currentThreadCount
sender_data
#bio的当前线程数

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT 'Catalina:name="'$http_bio'",type=ThreadPool' currentThreadsBusy 2>&1| awk -F ":" '{print $4}'`
KEY=tomcat_bio_currentThreadsBusy
sender_data
#bio当前繁忙线程

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT 'Catalina:name="'$http_bio'",type=GlobalRequestProcessor' bytesSent 2>&1| awk -F ":" '{print $4}'`
KEY=tomcat_bio_bytesSent
sender_data
#bio发送字节数

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT 'Catalina:name="'$http_bio'",type=GlobalRequestProcessor' bytesReceived 2>&1| awk -F ":" '{print $4}'`
KEY=tomcat_bio_bytesReceived
sender_data
#bio接收字节数

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT 'Catalina:name="'$http_bio'",type=GlobalRequestProcessor' requestCount 2>&1| awk -F ":" '{print $4}'`
KEY=tomcat_bio_requestCount
sender_data
#bio请求次数

MONITOR_DATA=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$TOMCAT_PORT java.lang:type=Memory HeapMemoryUsage 2>&1 | grep max: |wc -l`
KEY=check_status
sender_data
#检查监控状态
((num--))
  [ "$num" == 0 ] && break
  done < "$tmpfile"
done