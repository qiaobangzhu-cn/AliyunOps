@echo off

rem Script created 2016-12-09
setlocal EnableDelayedExpansion

path %~dp0;%path%

set WorkFolder=%tmp%\file_print
set IpTmp1=%WorkFolder%\ipaddress.csv
set FILE_PRINT_WIN_FILEEXT=.txt

set ETH0=
set ETH1=
set SYSTEM=NULL
set IPTABLES=OFF
set FILE_PRINT=
set VERSION=1.1

set/p project_id=Input project_id:

rem Save Code Page
for /f "usebackq delims=: tokens=2" %%A in (`chcp`) do set Code_Page=%%~A

rem ---DATE_WIN---

for /f "usebackq delims=" %%A in (`wmic path Win32_LocalTime get Year /value^|find /i "Year"`) do set %%~A

for /f "usebackq delims=" %%A in (`wmic path Win32_LocalTime get Month /value^|find /i "Month"`) do set %%~A
if %Month% lss 10 set Month=0%Month%

for /f "usebackq delims=" %%A in (`wmic path Win32_LocalTime get Day /value^|find /i "Day"`) do set %%~A
if %Day% lss 10 set Day=0%Day%

set DATE_WIN=%Year%%Month%%Day%

rem ---Hostname---
set HOSTNAME=%COMPUTERNAME%

rem ---
md "!WorkFolder!" 2>nul
del /a/f/q "!WorkFolder!\*"
set /a NUM=-1

pushd "!WorkFolder!"

rem ---ip_print---
wmic /output:"%IpTmp1%" nicconfig get ipaddress /format:csv

for /f "usebackq skip=2 delims=, tokens=2" %%A in (`type %IpTmp1%`) do (
	set /a NUM+=1
	set ETH!NUM!=%%~A
)

for /l %%D in (0,1,!NUM!) DO (
	FOR /F %%F IN ("!ETH%%D!") DO (
		set STR=%%~F
		set STR=!STR:{=!
		set STR=!STR:}=!
		FOR /F "DELIMS=;" %%H IN ("!STR!") DO (
			SET ETH%%D=%%H
		)
	)
)

rem check reserve IP address
if "!ETH0:~0,8!"=="169.254." (
	for /l %%D in (0,1,!NUM!) DO (
		set/a Plus=%%D+1
		call set ETH%%D=%%ETH!Plus!%%
	)
	set /a NUM=-1
)

IF !NUM! LSS 1 SET NUM=1


rem ---system_print---
for /f "usebackq delims=" %%A in (`reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName`) do (
	set ProductName=%%~A
)

for /f "tokens=1,*" %%C in ("!ProductName:ProductName=!") do (
	set SYSTEM=%%D
)

rem ---i_print---
chcp 437 >nul

set FW_Final_STATE=1
netsh adv show currentprofile state|find /i "State" >nul 2>&1
if errorlevel 1 (
	set IPTABLES=OFF
) else if errorlevel 0 (
	for /f "usebackq tokens=2" %%A in (`netsh adv show currentprofile state^|find /i "State"`) do (
		if /i "%%~A"=="ON" (
			set FW_STATE=1
		) else if /i "%%~A"=="OFF" (
			set FW_STATE=0
		)
		set /a FW_Final_STATE*=!FW_STATE!
	)
	if !FW_Final_STATE! equ 1 set IPTABLES=ON
)

chcp !Code_Page! >nul
echo.

rem ---iptables_print---
rem Nothing to do

rem ---file_print---

rem set FILE_PRINT=!WorkFolder!\!HOSTNAME!_!ETH0!_!DATE_WIN!!FILE_PRINT_WIN_FILEEXT!
set FILE_PRINT=!WorkFolder!\!project_id!_!HOSTNAME!_!ETH0!_!ETH1!!FILE_PRINT_WIN_FILEEXT!

echo HOSTNAME:!HOSTNAME!>>"!FILE_PRINT!"

(for /l %%D in (0,1,!NUM!) DO (
	ECHO ETH%%D:!ETH%%D!
)
)>>"!FILE_PRINT!"

echo SYSTEM:!SYSTEM!>>"!FILE_PRINT!"
echo IPTABLES:!IPTABLES!>>"!FILE_PRINT!"
echo version:!VERSION!>>"!FILE_PRINT!"

type "!FILE_PRINT!"
echo.
echo ----------------EOF----------------
ECHO.
ECHO.

del /a/f/q "!IpTmp1!"

set UploadDir=%project_id%_%COMPUTERNAME%
md %UploadDir%

set CommonInfo=%project_id%,%COMPUTERNAME%,%ETH0%,%ETH1%,
call "%~dp0UserWinAdmin.bat"
call "%~dp0UpdateInstalledThisMonth.bat"

"%~dp0rar.exe" a %UploadDir%.rar %UploadDir% "!project_id!_!HOSTNAME!_!ETH0!_!ETH1!!FILE_PRINT_WIN_FILEEXT!"
echo.
echo ----------------End of Rar----------------

clip <"!FILE_PRINT!"
echo.
echo The Content of "!FILE_PRINT!" has been copied to system's clipboard.
echo Using Ctrl + V to paste it to your text editor.
echo.
echo And
ECHO.
echo "!WorkFolder!" will be opened in explorer.exe .
rem timeout/t 15

explorer "!WorkFolder!"

popd

echo.
echo Do NOT close the window utill your copy the file.
echo.
pause

rd /s /q "!WorkFolder!"

rem del /a /f /q "%~f0" & logoff
