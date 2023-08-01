#!/bin/bash
source /usr/local/zabbix-agentd/monitor_scripts/cassandra_monitor_sh.conf
cassandra_key=$1
while true;do
sender_data(){
  $zabbix_sender_client/zabbix_sender -z $ZABBIX_SERVER -p $ZABBIX_PORT -s "$HOSTNAME"  -k cassandra[$KEY] -o $MONITOR_DATA > /dev/null
  sleep $SENDER_SLEEP_TIME #避免sender数据太频繁导致zabbix server 压力过大
}
#生成监控信息
sudo $cassandra_nodetool_dir/nodetool info >"$cassandra_tmp" 2>/dev/null
if [ $? -eq 0 ]; then #判断命令是否执行成功
#监控Cassandra的工作时长，服务重启之后归零
    MONITOR_DATA=`cat $cassandra_tmp |grep Uptime|cut -d : -f2`
    KEY=Uptime
    sender_data
#监控Cassandra已经使用的堆内存大小
    MONITOR_DATA=`cat $cassandra_tmp|grep "^Heap Memory" | cut -d : -f2 | cut -d / -f1`
    KEY=Heap_Memory_Used
    sender_data
#监控Cassandra堆内存总量
    MONITOR_DATA=`cat $cassandra_tmp| grep "^Heap Memory" | cut -d : -f2 | cut -d / -f2`
    KEY=Heap_Memory_Total
    sender_data
#监控cassandra缓存内存总量
    MONITOR_DATA=`cat $cassandra_tmp|grep "Off Heap Memory" | cut -d : -f2`
    KEY=Off_Heap_Memory
    sender_data
#监控Cassandra key cache的总量
    MONITOR_DATA=`cat $cassandra_tmp|grep "Key Cache" | cut -d : -f2 | cut -d , -f3 | awk '{print $2}'`
    KEY=Key_Cache_capacity
    sender_data
#监控Cassandra key cache的使用量
     MONITOR_DATA=`cat $cassandra_tmp|grep "Key Cache" | cut -d : -f2 | cut -d , -f2 | awk '{print $2}'`
     KEY=Key_Cache_size
     sender_data
#监控Cassandra 加载的磁盘空间大小
     MONITOR_DATA=`cat $cassandra_tmp|grep "Load" | cut -d : -f2 | awk '{print $1}'`
     KEY=load
     sender_data
#监控cassandra 缓存的内容命中率
     MONITOR_DATA=`cat $cassandra_tmp| grep "Key Cache" | cut -d : -f2 | cut -d , -f6 | awk '{print $1}'`
     KEY=recent_hit_rate
     sender_data
     MONITOR_DATA=1
     KEY=status
     sender_data
else
     MONITOR_DATA=0
     KEY=status
     sender_data
fi
#通过sleep控制nodetool工具运行的周期，执行太频繁，会对服务器造成压力过大
sleep $SLEEP_TIME
done