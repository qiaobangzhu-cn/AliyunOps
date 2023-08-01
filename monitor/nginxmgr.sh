#!/bin/bash
app=nginx
registryurl="registry.cn-hangzhou.aliyuncs.com/zhuyun11/$app"
function create() {
    test -d /alidata/nginx || mkdir -p /alidata/nginx/logs
    docker run -d  \
    -v /alidata:/alidata \
    -v /etc/localtime:/etc/localtime:ro \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/resolv.conf:/etc/resolv.conf:ro \
    --net host \
    --name $app \
    $registryurl
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
    if [ -d "/alidata/nginx/conf" ];then
        echo 'nginx 配置文件已经存在.'
    else
        docker cp $app:/config/conf /alidata/nginx/
        stop
    fi
}

function start() {
    docker start $app
    echo "启动完成$app"
}

function stop() {
    echo  "关闭$app"
    docker stop $app 
}

function delete() {
    stop
    docker rm $containerId
}

docker ps -a -f name=$app --format '{{.ID}}' | grep -Eq '[a-z]+'
if [ $? -ne 0 ];then
    if [ "${1}x" == "deletex" ];then
        echo "容器不存在"
        exit 1
    fi
    create
    stop
    #docker cp $containerId:/config/conf /alidata/nginx/
fi
containerId=`docker ps -a -f name=$app --format '{{.ID}}'`
case $1 in 
start)
    start
    ;;
stop)
    stop
    ;;
restart)
    stop
    sleep 3
    start
    ;;
delete)
    delete
    echo "volume 请手动维护 $datapath"
    ;;
logs)
    docker logs $containerId
    ;;
update)
    delete
    docker pull $registryurl
    create
    start
    ;;
*)
    if [ ! -z "$1" ];then
        docker exec $app /usr/local/nginx/sbin/nginx -s $1
    else
        echo "help: $0 <action>"
    fi
    ;;
esac
