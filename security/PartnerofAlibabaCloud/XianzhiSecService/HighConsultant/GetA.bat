@echo off
SetLocal EnableDelayedExpansion

set tmpfile1="%tmp%\%~n0_1.tmp"
set tmpfile2="%tmp%\%~n0_2.tmp"

set DomainName=%1.
set Dns=%2

for %%A in (%~n0) do set FileName=%%A
set RRType=%FileName:Get=%

rem for standalone run
if NOT defined DomainListFile3 set DomainListFile3=^&2

nslookup -q=%RRType% %DomainName% %Dns% 2>nul >%tmpfile1%

for /f "usebackq skip=2 delims=" %%A in (`type %tmpfile1%`) do echo %%~A>>%tmpfile2%

findstr/r /i /c:"^Address.*:" %tmpfile2% >nul 2>&1

if errorlevel 1 (
	set Return=1
) else if errorlevel 0 (
	for /f "usebackq delims=" %%A in (`type %tmpfile2%^|find /v "%~1"`) do (
		echo %%~A|find ":" > nul
		if errorlevel 1 (
			for /f "usebackq" %%C in (`echo %%~A`) do set RRData=%%~C
		) else if errorlevel 0 (
			for /f "usebackq tokens=2" %%C in (`echo %%~A`) do set RRData=%%~C
		)
		echo %1,%RRType%,!RRData!>>%DomainListFile3%
	)
	set Return=0
)

del /a /f /q %tmpfile1% 2>nul
del /a /f /q %tmpfile2% 2>nul

EndLocal & exit/b %Return%
