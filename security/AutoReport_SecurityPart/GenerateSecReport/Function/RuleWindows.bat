@echo off
SetLocal EnableDelayedExpansion
set InsInfoFile=%~1
set InsInfoFile_n=%~n1

set Affected=1
set NotAffected=0

pushd "%~dp0..\Rule\Windows"

for /f "usebackq delims=" %%A in (`dir /a /b *.bat`) do (
	for /f "delims=_ tokens=2" %%C in ("%%~nA") do set VulName=%%C
	call "%%~A" "!InsInfoFile!"
	if errorlevel !Affected! (
		for /f "usebackq delims=" %%E in (`call DealNonStandardHostname.bat !InsInfoFile_n!`) do echo !project_id!,!VulName!,!OsType!,%%E,>> "!ProjectReportFile!"
	)
)

popd
