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

