#!/bin/bash
app=zabbix-proxy-mysql
host="10.26.38.229"
user="zabbix"
password="zy123"
database="zabbix_proxy"
docker ps -a -f name=$app --format '{{.ID}}' | grep -Eq '[a-z]+'
if [ $? -ne 0  ];then
    if [ "$1x" == "deletex" ];then
        echo "$pp 不存在."
        exit 1
    fi
    #mkdir -p /usr/local/$app/etc >/dev/null 2>&1 
    docker run -d  \
    -p 10051:10051 \
    -p 10052:10052 \
    -v /etc/localtime:/etc/localtime:ro \
    --name $app \
    --env="ZBX_PROXYMODE=0" \
    --env="ZBX_HOSTNAME=zhuyun-`uname -n`"  \
    --env="ZBX_SERVER_HOST=bj-monitor.jiagouyun.com"  \
    --env="DB_SERVER_HOST=$host" \
    --env="MYSQL_USER=$user"  \
    --env="MYSQL_PASSWORD=$password"  \
    --env="MYSQL_DATABASE=$database" \
    --env="ZBX_JAVAGATEWAY_ENABLE=true"  \
    --env="ZBX_HOSTNAMEITEM=zhuyun.host"  \
    --env="ZBX_CONFIGFREQUENCY=3600"  \
    --env="ZBX_DATASENDERFREQUENCY=1"  \
    --env="ZBX_STARTPOLLERS=25"  \
    --env="ZBX_IPMIPOLLERS=0"  \
    --env="ZBX_STARTPOLLERSUNREACHABLE=1"  \
    --env="ZBX_STARTTRAPPERS=15"  \
    --env="ZBX_STARTPINGERS=5"  \
    --env="ZBX_STARTDISCOVERERS=1"  \
    --env="ZBX_STARTHTTPPOLLERS=1"  \
    --env="ZBX_JAVAGATEWAY=zabbix-java-gateway"  \
    --env="ZBX_JAVAGATEWAYPORT=10052"  \
    --env="ZBX_STARTJAVAPOLLERS=0"  \
    --env="ZBX_STARTVMWARECOLLECTORS=0"  \
    --env="ZBX_VMWAREFREQUENCY=60"  \
    --env="ZBX_VMWAREPERFFREQUENCY=60"  \
    --env="ZBX_VMWARECACHESIZE=8M"  \
    --env="ZBX_VMWARETIMEOUT=10"  \
    --env="ZBX_ENABLE_SNMP_TRAPS=false"  \
    --env="ZBX_CACHESIZE=8M"  \
    registry.cn-hangzhou.aliyuncs.com/zhuyun11/$app
    while [ 1 ]
    do
        echo -n " . "
        sleep 1
        containerId=`docker ps -a -f name=$app --format '{{.ID}}'`
        if [ ! -z "$containerId" ];then
            echo 
            break
        fi
    done
fi
containerId=`docker ps -a -f name=$app --format '{{.ID}}'`
case $1 in 
start)
    docker start $app
    echo "启动完成$app"
    ;;
stop)
    echo  "关闭$app"
    docker stop $app
    ;;
status)
    if [ ! -z "$containerId" ];then
        docker exec $containerId supervisorctl -c /etc/supervisor/supervisord.conf   -u zbx -p password status
    fi
    ;;
reload)
    if [ ! -z "$containerId" ];then
        docker exec $containerId supervisorctl -c /etc/supervisor/supervisord.conf   -u zbx -p password reload
    fi
    ;;
restart)
    echo  "关闭$app"
    docker stop $app
    sleep 3
    docker start $app
    echo "启动完成$app"
    ;;
delete)
    docker stop $app
    docker rm $containerId
    ;;
logs)
    docker logs $app
    ;;
*)
    echo $0 action
    ;;
esac
