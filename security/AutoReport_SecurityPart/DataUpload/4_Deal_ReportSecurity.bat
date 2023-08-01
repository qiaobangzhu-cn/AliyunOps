@echo off
setlocal EnableDelayedExpansion

pushd "%~dp0"

path %~dp0Func;%PATH%

call Get_WinRAR_Path
rem echo %WinRAR_Path%
path %WinRAR_Path%;%PATH%

if "%~1"=="" (
	set SecurityDataFolder=ReportSecurity
) else set SecurityDataFolder=%~1

pushd "%SecurityDataFolder%"

rem extract all
for /f "usebackq delims=" %%A in (`dir /ad /b`) do (
	rem copy standard to each project folder
	robocopy ..\ReportSecurity_Std\project_id "%%~A" /e /xx /np /ns /nc /NJH /NJS
	cd /d "%%~A"
	if exist "%%~A*.tar" winrar x -iBCK "%%~A*.tar"
	if exist "%%~A*.zip" winrar x -iBCK "%%~A*.zip"
	if exist "%%~A*.rar" rar x -iBCK "%%~A*.rar"
	cd ..
)

rem generate vulnerability report for every projects
call ..\..\GenerateSecReport\GenerateSecReport.bat .

rem Deal each project's check list
for /f "usebackq delims=" %%A in (`dir /ad /b`) do (
	rem rename vulnerability report
	move "%%~A_Report.csv" "%%~A\vulnerability\vulnerability.csv"
	rem change dir to project folder
	cd /d "%%~A"
	for /f "usebackq delims=" %%C in (`dir /ad /b %%~A_*`) do (
		rem change to host folder
		cd "%%~C"
		rem move logs to project's folder
		if exist logs robocopy logs ..\logs /E /move /np /ns /nc /NJH /NJS
		rem combine each host's info to one file
		for /f "usebackq delims=" %%E in (`dir /a-d /b *.csv`) do type "%%~E" >> "..\%%~E"
		if exist firewalls\Network_Firewall.csv type firewalls\Network_Firewall.csv >> ..\firewalls\Network_Firewall.csv
		if exist urls\CheckUrlStatus.csv type urls\CheckUrlStatus.csv >> ..\urls\CheckUrlStatus.csv
		cd ..
		rem remove host info's folder
		rd /s /q "%%~C"
		del /a /f /q "%%~C_*.csv" "%%~C_*.txt" 2>nul
	)
	rem Remove Empty File
	for /f "usebackq delims=" %%E in (`dir /a-d /s /b *.csv`) do (
		call RemoveEmptyFile.bat "%%~E"
	)
	rem remove empty folder
	rd firewalls 2>nul
	rd logs\log_boot 2>nul
	rd logs\Log_cron 2>nul
	rd logs 2>nul
	rd urls 2>nul
	rd vulnerability 2>nul
	cd ..
)

popd
popd

timeout 99
