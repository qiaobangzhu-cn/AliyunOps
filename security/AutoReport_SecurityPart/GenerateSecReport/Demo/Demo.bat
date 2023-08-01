@echo off

set OldPwd=%cd%

cd/d "%~dp0"

path %cd%\Function;%cd%\Rule;%path%

cd/d "%OldPwd%"

call Rule_CVE-2017-6074.bat "\\zypy\c\users\zpy\GIT\OperSecPatrol_Info\cancan\х╓ед\srv-danqoo-mongo1_10.162.52.82_218.244.132.231.csv"
echo %errorlevel%

call Rule_CVE-2016-10229.bat "\\zypy\c\users\zpy\GIT\OperSecPatrol_Info\cancan\х╓ед\srv-danqoo-mongo1_10.162.52.82_218.244.132.231.csv"
echo %errorlevel%
