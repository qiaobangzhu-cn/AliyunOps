#!/bin/bash
app=mysql-server
datapath="/var/lib/mysql"
password="zy123"
if [ "$2x" != "x" ];then
    password="$1"
fi
docker ps -a -f name=$app --format '{{.ID}}' | grep -Eq '[a-z]+'
if [ $? -ne 0 ];then
    mkdir -p $datapath >/dev/null 2>&1 
    docker run -d  \
    -v $datapath:/var/lib/mysql \
    -v /etc/localtime:/etc/localtime:ro \
    -p 3306:3306  \
    --env="MYSQL_ROOT_PASSWORD=$password" \
    --name $app \
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
    echo 'root password' $password
    #docker cp $containerId:/config/conf /alidata/nginx/
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
    echo "手动删除vol $datapath"
    ;;
logs)
    docker logs $app
    ;;
*)
    echo $0 action
    ;;
esac
