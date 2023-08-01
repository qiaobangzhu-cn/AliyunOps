#!/bin/bash
if [ "$(cat /proc/version | grep centos)" != "" ];then
   export LANG=zh_CN.UTF-8
fi
message() {
whiptail --title "镜像环境及命令简介" --msgbox "尊敬的用户，为了更好的为您服务，请您仔细阅读本文档。\n1.镜像目录环境\n安装目录及配置文件:/alidata/\n2.请按回车键下一步" --ok-button 下一步 --fb 20 60
welcome
}
welcome() {
OPTION=$(whiptail --title "欢迎使用上海驻云镜像" --menu "请选择一项,如果您不确定请按回车键\nhelp:需要用到键盘的tab键,方向键,回车键" 15 60 4  1 "切换Java1.6版本" 2 "切换Java1.7版本" 3 "切换Java1.8版本" --fb --ok-button 确定 --cancel-button 取消 3>&1 1>&2 2>&3)
if [ "$OPTION" = "1" ]; then
        bash /root/jdk-1.6.45.sh

elif [ "$OPTION" = "2" ]; then
        bash /root/jdk-1.7.71.sh

elif [ "$OPTION" = "3" ]; then
 	bash /root/jdk-1.8.40.sh


else
	exit
fi
}
message
