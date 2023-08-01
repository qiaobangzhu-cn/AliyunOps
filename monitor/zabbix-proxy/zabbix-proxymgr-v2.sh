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
    -p 11051:10051 \
    -p 11052:10052 \
    -v /etc/localtime:/etc/localtime:ro \
    --env="ZJ_enabled=false" \
    --env="ZA_enabled=false" \
    --env="ZW_enabled=false" \
    --env="ZS_DBHost=$host" \
    --env="ZS_DBPort=3306" \
    --env="ZS_DBName=$database" \
    --env="ZS_DBUser=$user" \
    --env="ZS_DBPassword=$password" \
    registry.cn-hangzhou.aliyuncs.com/zhuyun11/$app:v2
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
*)
    echo $0 action
    ;;
esac
