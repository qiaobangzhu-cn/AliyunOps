#!/bin/bash
#Author: diaodebao
#Date & Time: 20161110
#Description: nginx 1.10.2版本，含upstram check模块
#Version : 0.1

app=nginx
docker ps -a -f name=$app --format '{{.ID}}' | grep -Eq '[a-z]+'
if [ $? -ne 0 ];then
    if [ -d "/alidata/nginx" ];then
        echo "/alidata/nginx目录已存在"
        exit 1
    fi
    mkdir -p /alidata/nginx/logs >/dev/null 2>&1 
    mkdir -p /alidata/www >/dev/null 2>&1 
    docker run -d  \
    -v /alidata/nginx/conf:/usr/local/nginx/conf \
    -v /alidata/nginx/logs:/usr/local/nginx/logs \
    -v /alidata/www:/alidata/www \
    -p 80:80  \
    -p 443:443  \
    --name $app \
    registry.cn-hangzhou.aliyuncs.com/zhuyun11/nginx
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
    docker cp $containerId:/config/conf /alidata/nginx/
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
reload)
    if [ ! -z "$containerId" ];then
        docker exec $containerId /usr/local/nginx/sbin/nginx -s reload
    fi
    ;;
restart)
    echo  "关闭$app"
    docker stop $app
    sleep 3
    docker start $app
    echo "启动完成$app"
    ;;
*)
    echo nginxmgr.sh action
    ;;
esac
