@echo off
SetLocal
pushd "%tmp%"

del/a/f/q sec*.tmp 2>nul

rem Get First 4 cols
rem for /f "usebackq delims=, tokens=1-4" %%A in (`type "%~dp0..\Database\Table\ReportSecurity.csv"`) do echo %%~A,%%~B,%%~C,%%~D>> sec1.tmp
copy "%~dp0..\Database\Table\ReportSecurity.csv" sec1.tmp >nul

for %%a in (Dealed ReportSecurity) do (
	for /f "usebackq delims=," %%A in (`dir /ad /b %~dp0%%~a`) do (
		type sec1.tmp|findstr /r /v "^%%~A,">> sec3.tmp
		move /y sec3.tmp sec1.tmp >nul
	)
)

type sec1.tmp|find /v /i "NoPermission"|find /v /i "Migrating"|find /v /i "Pending"
type sec1.tmp|find /v /i "NoPermission"|find /v /i "Migrating"|find /v /i "Pending"|clip

timeout 5

del/a/f/q sec*.tmp

popd
