@echo off   
::ע���cmd��ǰ׺
title MySql��װ
echo ���ڰ�װMySql����ȴ�.......
if not exist "c:\websoft" (md c:\websoft)
call mysql5.5.4.3.bat
rd /S /Q c:\$Recycle.Bin
pause
