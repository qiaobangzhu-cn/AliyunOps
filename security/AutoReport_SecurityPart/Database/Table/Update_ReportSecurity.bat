@echo off
SetLocal EnableDelayedExpansion

set RmdPrj="%tmp%\RmdPrj.txt"
set NewPrj="%tmp%\NewPrj.txt"

pushd "%~dp0"

rem Get removed projects

for /f "usebackq skip=1 delims=, tokens=1" %%A in (`type .\ReportSecurity.csv`) do (
	findstr/r /c:"^%%~A," .\report_customer_relation.csv> nul
	if errorlevel 1 (
		echo %%~A>>%RmdPrj%
	)
)
rem remove
move .\ReportSecurity.csv "%tmp%\1.tmp"> nul

echo Removed projects
type %RmdPrj%

for /f "usebackq delims=," %%A in (`type %RmdPrj%`) do (
	findstr /r /v /c:"^%%~A," "%tmp%\1.tmp"> "%tmp%\2.tmp"
	move "%tmp%\2.tmp" "%tmp%\1.tmp"> nul
)

rem Get new projects

for /f "usebackq skip=1 delims=, tokens=1,*" %%A in (`type .\report_customer_relation.csv`) do (
	findstr/r /c:"^%%~A," "%tmp%\1.tmp"> nul
	if errorlevel 1 (
		set str=%%~B
		echo %%~A,!str:,NULL,=,,!>>%NewPrj%
	)
)

rem Add
rem for /f "usebackq delims=," %%A in (`type %NewPrj%`) do findstr /r /c:"^%%~A," .\report_customer_relation.csv>> .\ReportSecurity.csv

copy "%tmp%\1.tmp" /B + %NewPrj% /B .\ReportSecurity.csv /B> nul

del /a /f /q %RmdPrj% %NewPrj% "%tmp%\1.tmp"

popd
EndLocal
