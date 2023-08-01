#!/bin/bash
if [ "$(cat /proc/version | grep centos)" != "" ];then
   export LANG=zh_CN.UTF-8
fi

message() {
whiptail --title "镜像环境及命令简介" --msgbox "尊敬的用户，为了更好的服务于你们，请您仔细阅读本文档。\n1.镜像目录环境\n安装目录及配置文件:/alidata/server\n日志目录:/alidata/log\n网站主目录:/alidata/www/\n镜像中ftp和mysql随机密码：在/alidata/account.log文件中\n2.相关命令\n/etc/init.d/httpd start|stop|restart\n/etc/init.d/mysqld start|stop|restart\n/etc/init.d/vsftpd start|stop|restart\n镜像默认安装的php版本为5.4.23，需要更换php版本请执行switch命令\n3.请按回车键退出" --ok-button 退出 --fb 25 65
}

message
