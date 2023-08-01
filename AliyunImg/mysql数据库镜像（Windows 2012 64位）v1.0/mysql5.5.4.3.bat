@echo off
echo ----------------------------------------------
echo Mysql下载中,请耐心等待,下载时间取决于您的带宽.
echo 没有报错,请不要关闭程序,如果报错,请重新启动!
echo ----------------------------------------------
::下载mysql文件
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/mysql/mysql-5.5.43-winx64.zip -O c:\websoft\mysql.zip
::解压下载的mysql文件
echo -----------------------------------------------
echo        解决开始，请等待解压完成
echo -----------------------------------------------
C:\websoft\unzip.exe c:\websoft\mysql.zip -d c:\websoft\
rename c:\websoft\mysql-5.5.43-winx64 mysql
echo -----------------------------------------------
echo        解压完成
echo ------------------------------------------------ 
echo -----------------------------------------------
echo        开始安装
echo ------------------------------------------------
::设置path环境
set path_=C:\websoft\mysql\bin
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "%path%;%path_%" /f   
gpupdate /force
::下载一份my.ini文件
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/mysql/my.ini -O c:\websoft\mysql\my.ini
::启用临时的环境变量
set path=%path%;C:\websoft\mysql\bin
::把mysql注册为服务
C:\websoft\mysql\bin\mysqld.exe --install MySql --defaults-file=c:\websoft\mysql\my.ini"
::启动MySql服务
net start MySql
::删除mysql安装包
del c:\websoft\mysql.zip
set mysqlpw=fdsjakg6735
echo mysql账号: root>>account.txt
echo mysql密码: %mysqlpw%>>account.txt
mysqladmin -uroot  password %mysqlpw%
echo Mysql安装成功,账号和密码请查看C盘下的websoft文件夹中的account.txt
pause