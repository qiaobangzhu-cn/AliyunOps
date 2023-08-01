@echo off
SetLocal

set Count=0

pushd "%~dp0ReportSecurity"

for /d %%A in (*) do (
	if exist "%%A\urls\CheckUrlStatus.csv" (
		set /a Count+=1
		find /c "HTTP/1.1 502 Bad Gateway" %%A\urls\CheckUrlStatus.csv > nul
		if NOT errorlevel 1 (
			echo "502" is found in project %%A.
		)
	)
)

echo.
echo %Count% files is checked.

popd
EndLocal