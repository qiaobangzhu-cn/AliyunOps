@echo off   
::注解掉cmd的前缀
title MySql安装
echo 正在安装MySql，请等待.......
if not exist "c:\websoft" (md c:\websoft)
call mysql5.5.4.3.bat
rd /S /Q c:\$Recycle.Bin
pause
