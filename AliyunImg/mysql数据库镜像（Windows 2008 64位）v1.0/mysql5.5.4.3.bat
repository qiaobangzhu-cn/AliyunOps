@echo off
echo ----------------------------------------------
echo Mysql������,�����ĵȴ�,����ʱ��ȡ�������Ĵ���.
echo û�б���,�벻Ҫ�رճ���,�������,����������!
echo ----------------------------------------------
::����mysql�ļ�
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/mysql/mysql-5.5.43-winx64.zip -O c:\websoft\mysql.zip
::��ѹ���ص�mysql�ļ�
echo -----------------------------------------------
echo        �����ʼ����ȴ���ѹ���
echo -----------------------------------------------
C:\websoft\unzip.exe c:\websoft\mysql.zip -d c:\websoft\
rename c:\websoft\mysql-5.5.43-winx64 mysql
echo -----------------------------------------------
echo        ��ѹ���
echo ------------------------------------------------ 
echo -----------------------------------------------
echo        ��ʼ��װ
echo ------------------------------------------------
::����path����
set path_=C:\websoft\mysql\bin
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "%path%;%path_%" /f   
gpupdate /force
::����һ��my.ini�ļ�
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/mysql/my.ini -O c:\websoft\mysql\my.ini
::������ʱ�Ļ�������
set path=%path%;C:\websoft\mysql\bin
::��mysqlע��Ϊ����
C:\websoft\mysql\bin\mysqld.exe --install MySql --defaults-file=c:\websoft\mysql\my.ini"
::����MySql����
net start MySql
::ɾ��mysql��װ��
del c:\websoft\mysql.zip
set mysqlpw=fdsjakg6735
echo mysql�˺�: root>>account.txt
echo mysql����: %mysqlpw%>>account.txt
mysqladmin -uroot  password %mysqlpw%
echo Mysql��װ�ɹ�,�˺ź�������鿴C���µ�websoft�ļ����е�account.txt
pause