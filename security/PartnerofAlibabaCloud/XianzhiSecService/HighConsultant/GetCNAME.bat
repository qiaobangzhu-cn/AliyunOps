@echo off
SetLocal EnableDelayedExpansion

set DomainName=%1.
set Dns=%2

for %%A in (%~n0) do set FileName=%%A
set RRType=%FileName:Get=%

rem for standalone run
if NOT defined DomainListFile3 set DomainListFile3=^&2

nslookup -q=%RRType% %DomainName% %Dns% 2>nul|find /i "canonical name =">nul

if errorlevel 1 (
	set Return=1
) else if errorlevel 0 (
	for /f "usebackq delims== tokens=2" %%A in (`nslookup -q^=%RRType% %DomainName% %Dns% 2^>nul^|find /i "canonical name ="`) do (
		set RRData=%%~A
	)
	echo %1,%RRType%,!RRData:~1!>>%DomainListFile3%
	set Return=0
)

EndLocal & exit/b %Return%
