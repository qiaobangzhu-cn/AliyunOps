#!/bin/bash
echo -ne "Do you want to install the following ones"
echo -ne "\n1:install iptables-monitor"
echo -ne "\n2:install nginx-monitor" 
echo -ne "\n3:install apache-monitor" 
echo -ne "\n4:install tomcat-monitor" 
echo -ne "\n5:install zookeeper-monitor" 
echo -ne "\n6:install rds-mysql-monitor" 
echo -ne "\n7:install mysql-monitor" 
echo -ne "\n8:install disk-IO-monitor" 
echo -ne "\n9:install memcache-monitor"
echo -ne "\n10:install jboss-monitor"
echo -ne "\ntype the number of you want to do : "
read yn
if [ "$yn" = "1" ]; then
wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/iptables-monitor.sh -O /usr/local/zabbix-agentd/monitor_scripts/install-iptables-monitor.sh
sh /usr/local/zabbix-agentd/monitor_scripts/install-iptables-monitor.sh
fi

if [ "$yn" != "1" -a "$yn" != "2" -a "$yn" != "3" -a "$yn" != "4" -a "$yn" != "5" -a "$yn" != "6" -a "$yn" != "7" -a "$yn" != "8" -a "$yn" != "9" ]; then
echo "plese type "1" --> "9" "
fi


##############zabbix 添加 apache 监控#############################
if [ "$yn" = "3" ]; then
echo -ne "plese write apache conf in here (完整路径/lj)："
read lj
if ! grep "<location /server-status>" $lj;then
cat >> "$lj" << 'EOF'
ExtendedStatus On
<location /server-status>
SetHandler server-status
Order Deny,Allow
Deny from all
Allow from 127.0.0.1
</location>
EOF

else
echo "apache status 页面配置已经存在"
fi

/etc/init.d/httpd reload
echo "configure httpd OK"
echo "wget apache-monitor.sh and apache-monitor.conf"

mkdir -p /usr/local/zabbix-agentd/monitor_scripts
#wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/apache-monitor.sh -O /usr/local/zabbix-agentd/monitor_scripts/apache-monitor.sh

cat > /usr/local/zabbix-agentd/monitor_scripts/apache-monitor.sh << 'EOF'
#!/bin/bash
if [[ "$1" = "Workers" ]]; then
wget --quiet -O - http://127.0.0.1/server-status?auto | grep Score | grep -o "\." | wc -l
else
wget --quiet -O - http://127.0.0.1/server-status?auto | head -n 9 | grep $1 | awk -F ":" '{print $2}'
fi
EOF

#wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/apache-monitor.conf -O /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/apache-monitor.conf

echo "UserParameter=apache[*],bash /usr/local/zabbix-agentd/monitor_scripts/apache-monitor.sh \$1" > /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/apache-monitor.conf

chmod 755 /usr/local/zabbix-agentd/monitor_scripts/*
chown zabbix:zabbix /usr/local/zabbix-agentd/monitor_scripts/*
/etc/init.d/zabbix_agentd restart 2>/dev/null || /etc/init.d/zabbix-agentd restart 2>/dev/null || /etc/init.d/zabbix-agent restart
fi
##############zabbix 添加 apache 监控 完毕#############################




##############zabbix 添加 nginx 监控#############################
if [ "$yn" = "2" ]; then
echo -ne "plese write nginx conf in here (完整路径/nginxlj)："
read nginxlj
echo -ne "plese write nginx status port in here (status页面port/nginxport)："
read nginxport
if ! grep "localhost:$nginxport" $nginxlj >/dev/null;then
cat >> "$nginxlj" << EOF
server {
listen localhost:$nginxport;
stub_status on;
access_log off;
allow 127.0.0.1;
deny all;
}
EOF
fi
/etc/init.d/nginx reload || echo "plese reload nginx"
echo "configure nginx OK"

echo "wget nginx-monitor.sh and nginx-monitor.conf"
#wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/nginx-monitor.sh -O /usr/local/zabbix-agentd/monitor_scripts/nginx-monitor.sh

cat > /usr/local/zabbix-agentd/monitor_scripts/nginx-monitor.sh << 'EOF'
#!/bin/bash
source /usr/local/zabbix-agentd/monitor_scripts/nginx-monitor.sh.conf
accepts(){
  curl localhost:$PORT 2>/dev/null |sed -n '3p'|awk '{print $1}'
}
handled(){
  curl localhost:$PORT 2>/dev/null |sed -n '3p'|awk '{print $2}'
}
requests(){
  curl localhost:$PORT 2>/dev/null |sed -n '3p'|awk '{print $3}'
}
active(){
  curl localhost:$PORT 2>/dev/null |sed -n '1p'|awk '{print $3}'
}
reading(){
  curl localhost:$PORT 2>/dev/null |sed -n '4p'|awk '{print $2}'
}
writing(){
  curl localhost:$PORT 2>/dev/null |sed -n '4p'|awk '{print $4}'
}
waiting(){
  curl localhost:$PORT 2>/dev/null |sed -n '4p'|awk '{print $6}'
}
case $1 in 
   accepts)
       accepts
   ;;
   handled)
       handled
   ;;
   requests)
       requests
   ;;
   active)
       active
   ;;
   reading)
       reading
   ;;
   writing)
       writing
   ;;
   waiting)
       waiting
   ;;
  *)
   ;;
esac
EOF

cat > /usr/local/zabbix-agentd/monitor_scripts/nginx-monitor.sh.conf << EOF
####定义nginx状态页面的端口#####
PORT=$nginxport
EOF
#wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/nginx-monitor.conf -O /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/nginx-monitor.conf
echo "UserParameter=nginx[*],bash /usr/local/zabbix-agentd/monitor_scripts/nginx-monitor.sh \$1" > /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/nginx-monitor.conf
chmod 755 /usr/local/zabbix-agentd/monitor_scripts/*
chown zabbix:zabbix /usr/local/zabbix-agentd/monitor_scripts/*
/etc/init.d/zabbix_agentd restart 2>/dev/null || /etc/init.d/zabbix-agentd restart 2>/dev/null || /etc/init.d/zabbix-agent restart
fi
##############zabbix 添加 nginx 监控 完毕#############################



##############zabbix 添加 tomcat 监控#############################
if [ "$yn" = "4" ]; then
mkdir -p /usr/local/zabbix-agentd/monitor_scripts
#cd /usr/local/zabbix-agentd/monitor_scripts && wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/tomcat_monitor.sh

cat > /usr/local/zabbix-agentd/monitor_scripts/tomcat_monitor.sh << 'EOF'
#!/bin/bash
tomcat_port=$1
tomcat_key=$2
jmxclient=/usr/local/zabbix-agentd/monitor_scripts
java=/usr/bin
memory_used(){
  memory_used=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port java.lang:type=Memory HeapMemoryUsage 2>&1|grep used: |grep -oP "\d{1,}"`
  echo $memory_used
}
#已经使用堆内存

memory_committed(){
  memory_committed=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port java.lang:type=Memory HeapMemoryUsage 2>&1|grep committed: |grep -oP "\d{1,}"`
  echo $memory_committed
}
#已提交的堆内存

memory_max(){
  memory_max=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port java.lang:type=Memory HeapMemoryUsage 2>&1|grep max: |grep -oP "\d{1,}"`
  echo $memory_max
}
#最大堆内存

tomcat_version(){
  tomcat_version=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port Catalina:type=Server serverInfo 2>&1 | awk -F : '{print $4}'`
  echo $tomcat_version
}
#检查tomcat版本信息

tomcat_loadclass(){
  tomcat_loadclass=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port java.lang:type=ClassLoading LoadedClassCount 2>&1 | awk -F : '{print $4}'`
  echo $tomcat_loadclass
}
#已加载的类

tomcat_totalclass(){
  tomcat_totalclass=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port java.lang:type=ClassLoading TotalLoadedClassCount 2>&1 | awk -F : '{print $4}'`
  echo $tomcat_totalclass
}
#类的总数

tomcat_unloadclass(){
  tomcat_unloadclass=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port java.lang:type=ClassLoading UnloadedClassCount 2>&1 | awk -F : '{print $4}'`
  echo $tomcat_unloadclass
}
#未加载类的数量

tomcat_peakthreadcount(){
  tomcat_peakthreadcount=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port java.lang:type=Threading PeakThreadCount 2>&1 | awk -F : '{print $4}'`
  echo $tomcat_peakthreadcount
}
#tomcat峰值线程

tomcat_threadcount(){  
  tomcat_threadcount=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port java.lang:type=Threading ThreadCount 2>&1 | awk -F : '{print $4}'`
  echo $tomcat_threadcount
}
#tomcat活动线程

tomcat_totalstartthreadcount(){  
  tomcat_totalstartthreadcount=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port java.lang:type=Threading TotalStartedThreadCount 2>&1 | awk -F : '{print $4}'`
  echo $tomcat_totalstartthreadcount
}
#tomcat线程总计

ajp_bio(){
  ajp_bio=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port|sort 2>&1 |grep -oP "ajp-bio-\d{1,}"|head -1`
}
#获取ajp-bio的端口号
tomcat_ajp_maxThreads(){
  ajp_bio
  tomcat_ajp_maxThreads=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port 'Catalina:name="'$ajp_bio'",type=ThreadPool' maxThreads 2>&1| awk -F ":" '{print $4}'`
  echo $tomcat_ajp_maxThreads
}
#ajp-bio的最大线程数

tomcat_ajp_currentThreadCount(){
  ajp_bio
  tomcat_ajp_currentThreadCount=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port 'Catalina:name="'$ajp_bio'",type=ThreadPool' currentThreadCount 2>&1| awk -F ":" '{print $4}'`
  echo $tomcat_ajp_currentThreadCount
}
#ajp-bio的当前线程数

tomcat_ajp_currentThreadsBusy(){
  ajp_bio
  tomcat_ajp_currentThreadsBusy=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port 'Catalina:name="'$ajp_bio'",type=ThreadPool' currentThreadsBusy 2>&1| awk -F ":" '{print $4}'`
  echo $tomcat_ajp_currentThreadsBusy
}
#ajp-bio当前繁忙线程

tomcat_ajp_bytesSent(){
  ajp_bio
  tomcat_ajp_bytesSent=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port 'Catalina:name="'$ajp_bio'",type=GlobalRequestProcessor' bytesSent 2>&1| awk -F ":" '{print $4}'`
  echo $tomcat_ajp_bytesSent
}
#ajp-bio发送字节数

tomcat_ajp_bytesReceived(){
  ajp_bio
  tomcat_ajp_bytesReceived=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port 'Catalina:name="'$ajp_bio'",type=GlobalRequestProcessor' bytesReceived 2>&1| awk -F ":" '{print $4}'`
  echo $tomcat_ajp_bytesReceived
}
#ajp-bio接收字节数

tomcat_ajp_requestCount(){
  ajp_bio
  tomcat_ajp_requestCount=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port 'Catalina:name="'$ajp_bio'",type=GlobalRequestProcessor' requestCount 2>&1| awk -F ":" '{print $4}'`
  echo $tomcat_ajp_requestCount
}
#ajp-bio请求次数

http_bio(){
  http_bio=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port|sort 2>&1 |grep -oP "http-bio-\d{1,}"|head -1`
}
#获取http-bio的端口号
tomcat_bio_maxThreads(){
  http_bio
  tomcat_bio_maxThreads=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port 'Catalina:name="'$http_bio'",type=ThreadPool' maxThreads 2>&1| awk -F ":" '{print $4}'`
  echo $tomcat_bio_maxThreads
}
#bio的最大线程数

tomcat_bio_currentThreadCount(){
  http_bio
  tomcat_bio_currentThreadCount=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port 'Catalina:name="'$http_bio'",type=ThreadPool' currentThreadCount 2>&1| awk -F ":" '{print $4}'`
  echo $tomcat_bio_currentThreadCount
}
#bio的当前线程数

tomcat_bio_currentThreadsBusy(){
  http_bio
  tomcat_bio_currentThreadsBusy=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port 'Catalina:name="'$http_bio'",type=ThreadPool' currentThreadsBusy 2>&1| awk -F ":" '{print $4}'`
  echo $tomcat_bio_currentThreadsBusy
}
#bio当前繁忙线程

tomcat_bio_bytesSent(){
  http_bio
  tomcat_bio_bytesSent=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port 'Catalina:name="'$http_bio'",type=GlobalRequestProcessor' bytesSent 2>&1| awk -F ":" '{print $4}'`
  echo $tomcat_bio_bytesSent
}
#bio发送字节数

tomcat_bio_bytesReceived(){
  http_bio
  tomcat_bio_bytesReceived=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port 'Catalina:name="'$http_bio'",type=GlobalRequestProcessor' bytesReceived 2>&1| awk -F ":" '{print $4}'`
  echo $tomcat_bio_bytesReceived
}
#bio接收字节数

tomcat_bio_requestCount(){
  http_bio
  tomcat_bio_requestCount=`$java/java -jar $jmxclient/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:$tomcat_port 'Catalina:name="'$http_bio'",type=GlobalRequestProcessor' requestCount 2>&1| awk -F ":" '{print $4}'`
  echo $tomcat_bio_requestCount
}
#bio请求次数

check_status(){
  http_bio >&/dev/null
  status=`echo $http_bio 2>&1 | grep http-bio|wc -l`
  echo $status
}
case $2 in 
   memory_used)
       memory_used
   ;;
   memory_committed)
       memory_committed
   ;;
   memory_max)
       memory_max
   ;;
   tomcat_version)
       tomcat_version
   ;;
   tomcat_loadclass)
       tomcat_loadclass
   ;;
   tomcat_totalclass)
       tomcat_totalclass
   ;;
   tomcat_unloadclass)
       tomcat_unloadclass
   ;;
  tomcat_peakthreadcount)
      tomcat_peakthreadcount
   ;;
  tomcat_threadcount)
      tomcat_threadcount
   ;;
  tomcat_totalstartthreadcount)
       tomcat_totalstartthreadcount
   ;;
  tomcat_bio_maxThreads)
       tomcat_bio_maxThreads
  ;; 
  tomcat_bio_currentThreadCount)
       tomcat_bio_currentThreadCount
  ;;
  tomcat_bio_currentThreadsBusy)
       tomcat_bio_currentThreadsBusy
  ;;  
  tomcat_bio_bytesSent)
       tomcat_bio_bytesSent
  ;;
  tomcat_bio_bytesReceived)
       tomcat_bio_bytesReceived
  ;;
  tomcat_bio_requestCount)
       tomcat_bio_requestCount
  ;;
  tomcat_ajp_maxThreads)
       tomcat_ajp_maxThreads
  ;; 
  tomcat_ajp_currentThreadCount)
       tomcat_ajp_currentThreadCount
  ;;
  tomcat_ajp_currentThreadsBusy)
       tomcat_ajp_currentThreadsBusy
  ;;  
  tomcat_ajp_bytesSent)
       tomcat_ajp_bytesSent
  ;;
  tomcat_ajp_bytesReceived)
       tomcat_ajp_bytesReceived
  ;;
  tomcat_ajp_requestCount)
       tomcat_ajp_requestCount
  ;;
  check_status)
       check_status
  ;;
  *)
   ;;
esac
EOF


#wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/tomcat_discovery.sh -O /usr/local/zabbix-agentd/monitor_scripts/tomcat_discovery.sh
cat > /usr/local/zabbix-agentd/monitor_scripts/tomcat_discovery.sh << 'EOF'
#!/bin/bash
#Function: low-level discovery tomcat
#Script_name: tomcat_discovery.sh
tomcat_discovery()
{

  cd /tmp
  local tmpfile="/tmp/tomcat.tmp"
  :> "$tmpfile"
  /bin/ps aux | grep -oP "jmxremote.port=\d{1,}"|grep -oP "\d{1,}" > "$tmpfile"
  chmod 777 "$tmpfile" 2&>/dev/null
  local num=$(cat "$tmpfile" | wc -l)
  printf '{\n'
  printf '\t"data":[ '
  while read line;do
    TOMCAT_PORT=$(echo $line | awk '{print $1}')
    printf '\n\t\t{'
    printf "\"{#TOMCAT_PORT}\":\"${TOMCAT_PORT}\"}"
    ((num--))
    [ "$num" == 0 ] && break
    printf ","
  done < "$tmpfile"
  printf '\n\t]\n'
  printf '}\n'
}
case "$1" in
  tomcat_discovery)
    "$1"
    ;;
  *)
    echo "Bad Parameter."
    echo "Usage: $0 tomcat_discovery"
    exit 1
    ;;
esac
EOF


echo "UserParameter=tomcat[*],/bin/bash /usr/local/zabbix-agentd/monitor_scripts/tomcat_monitor.sh \$1 \$2" > /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/tomcat_monitor.conf
echo "UserParameter=tomcat_discovery,/bin/bash /usr/local/zabbix-agentd/monitor_scripts/tomcat_discovery.sh tomcat_discovery" > /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/tomcat_discovery.conf
cd /usr/local/zabbix-agentd/monitor_scripts
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/zabbix/cmdline-jmxclient-0.10.3.jar
chmod 755 /usr/local/zabbix-agentd/monitor_scripts/*
chown zabbix:zabbix /usr/local/zabbix-agentd/monitor_scripts/*
/etc/init.d/zabbix_agentd restart 2>/dev/null || /etc/init.d/zabbix-agentd restart 2>/dev/null || /etc/init.d/zabbix-agent restart

####nohup start sender scripts#########
echo "如果下面出现端口信息，则JMX端口自动发现成功"
sh /usr/local/zabbix-agentd/monitor_scripts/tomcat_discovery.sh tomcat_discovery
chown zabbix.zabbix /tmp/tomcat.tmp
fi
##############zabbix 添加 tomcat 监控 完毕#############################






##############zabbix 添加 zookeeper 监控#############################
if [ "$yn" = "5" ]; then
echo "wget zookeeper-monitor.sh and zookeeper-monitor.conf zookeeper-monitor.sh.conf"

cat > /usr/local/zabbix-agentd/monitor_scripts/zookeeper-monitor.sh << 'EOF'
#!/bin/bash
####读取额外配置文件########
source /usr/local/zabbix-agentd/monitor_scripts/zookeeper-monitor.sh.conf
########获取数据脚本##########
(echo "stat";sleep 1)|telnet 127.0.0.1 $ZOOKEEPER_PORT 2>/dev/null | grep $1 | awk -F: '{print $2}'
EOF

cat > /usr/local/zabbix-agentd/monitor_scripts/zookeeper-monitor.sh.conf << 'EOF'
######zookeeper端口#######
ZOOKEEPER_PORT=3762
EOF


echo "UserParameter=zookeeper[*],sh /usr/local/zabbix-agentd/monitor_scripts/zookeeper-monitor.sh \$1" > /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/zookeeper-monitor.conf
chmod 755 /usr/local/zabbix-agentd/monitor_scripts/*
chown zabbix:zabbix /usr/local/zabbix-agentd/monitor_scripts/*
/etc/init.d/zabbix_agentd restart 2>/dev/null || /etc/init.d/zabbix-agentd restart 2>/dev/null || /etc/init.d/zabbix-agent restart
fi
##############zabbix 添加 zookeeper 监控 完毕#############################









##############zabbix 添加 rds-mysql 监控#############################
if [ "$yn" = "6" ]; then

mkdir -p /usr/local/zabbix-agentd/monitor_scripts
echo -ne "\ndo you upload git 'api/rdsPF.py','zabbix/zabbixRds.py','zabbix/rdsServer.py' to server?(y/n): "
        read up
if [ "$up" = "n" ]; then
echo "plese upload it"
exit
fi

#wget http://git.jiagouyun.com/operation/operation/raw/master/api/rdsPF.py -O /usr/local/zabbix-agentd/monitor_scripts/rdsPF.py
chown zabbix:zabbix /usr/local/zabbix-agentd/monitor_scripts/rdsPF.py
chmod u+x /usr/local/zabbix-agentd/monitor_scripts/rdsPF.py
echo -ne "\nplese write the DBInstanceId for this ECS (rds实例ID): "
        read id
echo -ne "\nplese write the diyu for this RDS (rds实例地域): "
        read dy
echo -ne "\nplese write the acid for this RDS (rds实例access key id): "
        read acid
echo -ne "\nplese write the ackey for this RDS (rds实例access key sert): "
        read ackey
python /usr/local/zabbix-agentd/monitor_scripts/rdsPF.py --acid=$acid --ackey=$ackey config
chown zabbix:zabbix /etc/.rdsjm

##下载脚本
#cd /usr/local/zabbix-agentd/monitor_scripts/
#wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/zabbixRds.py
#wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/rdsServer.py
if ! cat /etc/crontab |grep "zabbixRds.py" > /dev/null
then
echo "*/1 * * * * root python /usr/local/zabbix-agentd/monitor_scripts/zabbixRds.py --Key=all --DBInstanceId=$id --RegionId=$dy --CONFIGFILE=/etc/.rdsjm > /usr/local/zabbix-agentd/monitor_scripts/rds-output" >> /etc/crontab
fi
##初始化到rds-output
python /usr/local/zabbix-agentd/monitor_scripts/zabbixRds.py --Key=all --DBInstanceId=$id --RegionId=$dy --CONFIGFILE=/etc/.rdsjm > /usr/local/zabbix-agentd/monitor_scripts/rds-output

##添加自定义key
cat > /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/rdsPF.conf <<'EOF'
UserParameter=mysql.api[*],cat /usr/local/zabbix-agentd/monitor_scripts/rds-output |grep $1\" |awk -F'"' '{print $$4}'
UserParameter=mysql.apii[*],cat /usr/local/zabbix-agentd/monitor_scripts/rds-output |grep $1\" |awk '{print $$2}'|awk -F"," '{print $$1}'
EOF
chmod 755 /usr/local/zabbix-agentd/monitor_scripts/*
chown zabbix.zabbix /usr/local/zabbix-agentd/monitor_scripts/*

echo "获取当前rds的总连接数"
cat /usr/local/zabbix-agentd/monitor_scripts/rds-output |grep "MySQL_Sessions_total_session" |awk -F'"' '{print $4}'
echo "获取rds的最大IOPS"
cat /usr/local/zabbix-agentd/monitor_scripts/rds-output |grep "MaxIOPS" |awk '{print $2}'|awk -F"," '{print $1}'

echo "如果以上2个数据能够正常获取到数字值，则rds for mysql 监控基本已经添加成功"
/etc/init.d/zabbix_agentd restart 2>/dev/null || /etc/init.d/zabbix-agentd restart 2>/dev/null || /etc/init.d/zabbix-agent restart
fi
##############zabbix 添加 rds-mysql 监控 完毕#############################




##############zabbix 添加 自建mysql 监控#############################
if [ "$yn" = "7" ]; then
#wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/mysql-monitor.sh -O /usr/local/zabbix-agentd/monitor_scripts/mysql-monitor.sh

cat > /usr/local/zabbix-agentd/monitor_scripts/mysql-monitor.sh << 'EOF'
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
# 获取数据
case $1 in
Uptime)
result=`${MYSQL_CONN} status 2>/dev/null |cut -f2 -d":"|cut -f1 -d"T"`
echo $result
;;
slave_status)
result=`${MYSQL_SLAVE}  -e 'show slave status\G' 2>/dev/null |grep -E "Slave_IO_Running|Slave_SQL_Running"|awk '{print $2}'|grep -c Yes`
echo $result
;;
Com_update)
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Com_update"|cut -d"|" -f3`
echo $result
;;
Slow_queries)
result=`${MYSQL_CONN} status 2>/dev/null |cut -f5 -d":"|cut -f1 -d"O"`
echo $result
;;
Com_select)
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Com_select"|cut -d"|" -f3`
echo $result
;;
Com_rollback)
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Com_rollback"|cut -d"|" -f3`
echo $result
;;
Questions)
result=`${MYSQL_CONN} status 2>/dev/null |cut -f4 -d":"|cut -f1 -d"S"`
echo $result
;;
Com_insert)
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Com_insert"|cut -d"|" -f3`
echo $result
;;
Com_delete)
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Com_delete"|cut -d"|" -f3`
echo $result
;;
Com_commit)
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Com_commit"|cut -d"|" -f3`
echo $result
;;
Bytes_sent)
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Bytes_sent" |cut -d"|" -f3`
echo $result
;;
Bytes_received)
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Bytes_received" |cut -d"|" -f3`
echo $result
;;
Com_begin)
result=`${MYSQL_CONN} extended-status 2>/dev/null |grep -w "Com_begin"|cut -d"|" -f3`
echo $result
;;
*)
echo "Usage:$0(Uptime|slave_status|Com_update|Slow_queries|Com_select|Com_rollback|Questions|Com_insert|Com_delete|Com_commit|Bytes_sent|Bytes_received|Com_begin)"
;;
esac
EOF



#########创建自建mysql数据库账号密码、端口等配置##########

echo -ne "\nplese write the mysql user (mysql用户): "
        read user
echo -ne "\nplese write the mysql password (mysql密码): "
        read password
echo -ne "\nplese write the mysql port (mysql端口): "
        read port

cat > /usr/local/zabbix-agentd/monitor_scripts/mysql-monitor.sh.conf << EOF
# 用户名
MYSQL_USER=$user
# 密码
MYSQL_PWD=$password
# 主机地址/IP
MYSQL_HOST='127.0.0.1'
# 端口
MYSQL_PORT=$port
EOF

chown zabbix:zabbix /usr/local/zabbix-agentd/monitor_scripts/*
chmod u+x /usr/local/zabbix-agentd/monitor_scripts/*
cat > /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/mysql-monitor.conf << EOF
#####此文件请放在zabbix agent配置文件中定义的Include= 目录下##################
UserParameter=mysql.status[*],bash /usr/local/zabbix-agentd/monitor_scripts/mysql-monitor.sh \$1
#获取mysql版本
UserParameter=mysql.version,mysql -V | cut -f6 -d" " | sed 's/,//'
##获取mysql运行状态
UserParameter=mysql.ping,mysqladmin -u$user -p$password -P$port -h127.0.0.1 ping 2>/dev/null | grep -c alive
UserParameter=mysql.process,mysql -u$user -p$password -P$port -h127.0.0.1 -e "show processlist" 2>/dev/null|wc -l
EOF
/etc/init.d/zabbix_agentd restart 2>/dev/null || /etc/init.d/zabbix-agent restart 2>/dev/null || /etc/init.d/zabbix-agentd restart
fi
##############zabbix 添加 自建mysql 监控 完毕#############################




##############zabbix 添加 disk IO 监控#############################
if [ "$yn" = "8" ]; then
mkdir -p /usr/local/zabbix-agentd/monitor_scripts
wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/diskio-discovery-monitor.sh -O /usr/local/zabbix-agentd/monitor_scripts/diskio-discovery-monitor.sh
chmod 755 /usr/local/zabbix-agentd/monitor_scripts/diskio-discovery-monitor.sh
chown zabbix:zabbix /usr/local/zabbix-agentd/monitor_scripts/diskio-discovery-monitor.sh
echo -ne "\n请填写你的zabbix agent配置文件中定义的 “Include =”  匹配的完整目录路径在此处 : "
read WZLJ
if [ -z $WZLJ ];then
WZLJ=/usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d
fi
wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/diskio-discovery-monitor.conf -O "$WZLJ"/diskio-discovery-monitor.conf
echo "下面出现磁盘信息，说明配置成功，如果没有，请检查！"
/bin/bash /usr/local/zabbix-agentd/monitor_scripts/diskio-discovery-monitor.sh mount_disk_discovery
chown zabbix.zabbix /tmp/mounts.tmp
/etc/init.d/zabbix_agentd restart 2>/dev/null || /etc/init.d/zabbix-agent restart 2>/dev/null || /etc/init.d/zabbix-agentd restart
fi
##############zabbix 添加 disk IO 监控 完毕#############################



##############zabbix 添加 memcache 监控#############################
if [ "$yn" = "9" ]; then
cat > /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/memcache-monitor.conf << 'EOF'
UserParameter=memcached_stats[*],(echo stats; sleep 0.1) | telnet 127.0.0.1 $1 2>&1 | awk '/STAT $2 / {print $NF}'
EOF
/etc/init.d/zabbix_agentd restart 2>/dev/null || /etc/init.d/zabbix-agent restart 2>/dev/null || /etc/init.d/zabbix-agentd restart
fi
##############zabbix 添加 memcache 监控 完毕#############################

##############zabbix 添加 jboss trap 监控#############################
if [ "$yn" = "10" ]; then
mkdir -p /usr/local/zabbix-agentd/monitor_scripts
cat > /usr/local/zabbix-agentd/monitor_scripts/jboss_monitor-sender.sh << 'EOF'
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
SLEEP_TIME=1
#获取jmx端口和tomcat自动发现配套使用
tmpfile="/tmp/jboss.tmp"

while true;do
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
EOF

cat > /usr/local/zabbix-agentd/monitor_scripts/jboss_monitor-sender.sh.conf << 'EOF'
#java命令路径
java=/usr/local/java/jdk1.7/bin

##cmdline-jmxclient-0.10.3.jar存放路径
jmxclient=/usr/local/zabbix-agentd/monitor_scripts


###与zabbix_agentd中的hostname相同
#HOSTNAME=centos
EOF

echo -ne "\ntype the hostname in zabbix of you host : "
read name
echo "HOSTNAME=$name" >> /usr/local/zabbix-agentd/monitor_scripts/jboss_monitor-sender.sh.conf

#wget http://git.jiagouyun.com/operation/operation/raw/master/zabbix/tomcat_discovery.sh -O /usr/local/zabbix-agentd/monitor_scripts/tomcat_discovery.sh

cat > /usr/local/zabbix-agentd/monitor_scripts/jboss_discovery.sh << 'EOF'
#!/bin/bash
#Function: low-level discovery jboss
#Script_name: jboss_discovery.sh
jboss_discovery()
{

  cd /tmp
  local tmpfile="/tmp/jboss.tmp"
  :> "$tmpfile"
  /bin/ps aux | grep -oP "jmxremote.port=\d{1,}"|grep -oP "\d{1,}" > "$tmpfile"
  chmod 777 "$tmpfile" 2&>/dev/null
  local num=$(cat "$tmpfile" | wc -l)
  printf '{\n'
  printf '\t"data":[ '
  while read line;do
    JBOSS_PORT=$(echo $line | awk '{print $1}')
    printf '\n\t\t{'
    printf "\"{#JBOSS_PORT}\":\"${JBOSS_PORT}\"}"
#    ((num--))
#    [ "$num" == 0 ] && break
#    printf ","
  done < "$tmpfile"
  printf '\n\t]\n'
  printf '}\n'
}
case "$1" in
  jboss_discovery)
    "$1"
    ;;
  *)
    echo "Bad Parameter."
    echo "Usage: $0 jboss_discovery"
    exit 1
    ;;
esac
EOF


echo "UserParameter=jboss_discovery,/bin/bash /usr/local/zabbix-agentd/monitor_scripts/jboss_discovery.sh jboss_discovery" > /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/jboss_discovery.conf
cd /usr/local/zabbix-agentd/monitor_scripts
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/zabbix/cmdline-jmxclient-0.10.3.jar
chmod 755 /usr/local/zabbix-agentd/monitor_scripts/*
chown zabbix:zabbix /usr/local/zabbix-agentd/monitor_scripts/*
/etc/init.d/zabbix_agentd restart 2>/dev/null || /etc/init.d/zabbix-agentd restart 2>/dev/null || /etc/init.d/zabbix-agent restart

####nohup start sender scripts#########
cd /usr/local/zabbix-agentd/monitor_scripts/ && nohup sh /usr/local/zabbix-agentd/monitor_scripts/jboss_monitor-sender.sh >/dev/null 2>&1 &
if grep "nohup sh /usr/local/zabbix-agentd/monitor_scripts/jboss_monitor-sender.sh" /etc/rc.d/rc.local >/dev/null;then
echo "开机启动已添加"
else
echo "nohup sh /usr/local/zabbix-agentd/monitor_scripts/jboss_monitor-sender.sh >/dev/null 2>&1 &" >> /etc/rc.d/rc.local
fi
fi
##############zabbix 添加 jboss trap 监控 完毕#############################