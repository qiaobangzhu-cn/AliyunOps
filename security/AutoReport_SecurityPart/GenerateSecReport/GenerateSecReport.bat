@echo off
SetLocal
set ReportSuffix=_Report.csv

set OpMainFolder=%~1

set OldPwd=%cd%
cd/d "%~dp0"
path %cd%\Function;%cd%\Rule\Linux;%cd%\Rule\Windows;%path%
cd/d "%OldPwd%"

pushd "%OpMainFolder%"

for /f "usebackq delims=" %%A in (`dir /ad /b`) do (
	set ProjectReportFile=%cd%\%%~A%ReportSuffix%
	echo project_id,Vulnerability,OsType,hostname,private_ip,public_ip,> "%cd%\%%~A%ReportSuffix%"
	for /f "delims=_" %%B in ("%%A") do set project_id=%%~B
	pushd "%%~A"
	for %%C in (*.csv *.txt) do (
		call OsType.bat "%%~fC"
	)
	popd
	set ProjectReportFile=
)

popd
