#!/bin/bash
if [ "$(cat /proc/version | grep centos)" != "" ];then
   export LANG=zh_CN.UTF-8
fi

message() {
whiptail --title "镜像环境及命令简介" --msgbox "尊敬的用户，为了更好的服务于你们，请您仔细阅读本文档。\n1.镜像mysql安装目录:/alidata/mysql\n2.mysql密码位置：/alidata/account.log\n3.相关命令：/etc/init.d/mysqld start|stop|restart \n请按回车键退出" --ok-button 退出 --fb 30 60
}

message