@echo off
rem SetLocal
rem SetLocal EnableDelayedExpansion
rem Check 'delayed environment variable expansion'
if NOT "%OS%"=="!OS!" (
	SetLocal EnableDelayedExpansion
	set FlagLocal=1
)

rem Debug setting
if Defined DbgLvl set DebugLevel=%DbgLvl%
if defined DebugLevel (
	echo DebugLevel=%DebugLevel%
) else (
	set DebugLevel=0
)
set DbgChk=if !DebugLevel!

%DbgChk% LSS 1 (
	set "NoOut=> nul"
	set "NoErr=2> nul"
	set "NoAll=> nul 2>&1"
)


%DbgChk% GEQ 5 echo This is debug info.
rem here is main

rem find sftp cli tool
for /f "usebackq delims=" %%A in (`reg query hklm\SOFTWARE\VanDyke\SecureFX\Install /v "Main Directory"^|find "Main Directory"`) do set str=%%~A
for /f "tokens=1,*" %%A in ("%str:Main Directory=%") do path %%~B;%PATH%

rem set Log= /Log sfxcl.log

rem Get Passphrase
if "%~1"=="" (
	set PPFile=%USERPROFILE%\AppData\%~n0.txt
) else set PPFile=%~1
for /f "usebackq delims=" %%A in ("%PPFile%") do set Passphrase=%%~A

rem create flag
echo _>ReportSecurity.txt

sfxcl/DefaultType binary %Log% /I "%USERPROFILE%\AppData\Roaming\VanDyke\zpy_jiagouyun-com" /P !Passphrase! /Q "%~dp0ReportSecurity.zip" sftp://zyadmin@118.31.40.169:40022//home/zyadmin/ReportSecurity/
sfxcl/DefaultType binary %Log% /I "%USERPROFILE%\AppData\Roaming\VanDyke\zpy_jiagouyun-com" /P !Passphrase! /Q "%~dp0ReportSecurity.txt" sftp://zyadmin@118.31.40.169:40022//home/zyadmin/ReportSecurity/

if Defined FlagLocal (
	EndLocal
)
