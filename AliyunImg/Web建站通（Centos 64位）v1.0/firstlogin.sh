#!/bin/bash
if [ "Linux version 2.6.32-431.23.3.el6.x86_64 (mockbuild@c6b8.bsys.dev.centos.org) (gcc version 4.4.7 20120313 (Red Hat 4.4.7-4) (GCC) ) #1 SMP Thu Jul 31 17:20:51 UTC 2014" != "" ];then
   export LANG=zh_CN.UTF-8
fi

message() {
whiptail --title "镜像环境及命令简介" --msgbox "尊敬的用户，为了更好的服务于你们，请您仔细阅读本文档。\n1.镜像目录环境\n安装目录及配置文件:/alidata/server\n日志目录:/alidata/log\n网站主目录:/alidata/www/\n镜像中ftp和mysql随机密码：/alidata/account.log文件中\n2.一键重启命令\n/etc/init.d/amh-start \n3.请按回车键退出" --ok-button 退出 --fb 25 65
}

message

if grep "/alidata/init/firstlogin.sh" /root/.bash_profile >/dev/null;then
sed -i "/\/alidata\/init\/firstlogin.sh/d"  /root/.bash_profile
fi
