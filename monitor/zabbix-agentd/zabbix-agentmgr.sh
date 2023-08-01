#!/bin/bash
app=zabbix-agentd
docker ps -a -f name=$app --format '{{.ID}}' | grep -Eq '[a-z]+'
if [ $? -ne 0 ];then
    mkdir -p /usr/local/$app/etc >/dev/null 2>&1 
    docker run -d  \
    -v /usr/local/zabbix-agentd/etc/:/etc/zabbix/ \
    -v /etc/localtime:/etc/localtime:ro \
    -p 10050:10050  \
    --name $app \
    registry.cn-hangzhou.aliyuncs.com/zhuyun11/zabbix-agentd
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
    #docker cp $containerId:/config/conf /alidata/nginx/
    curl -ksS \
        https://git.jiagouyun.com/operation/operation/raw/master/monitor/zabbix-agentd/zabbix_agentd.conf \
        -o /usr/local/zabbix-agentd/etc/zabbix_agentd.conf
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
