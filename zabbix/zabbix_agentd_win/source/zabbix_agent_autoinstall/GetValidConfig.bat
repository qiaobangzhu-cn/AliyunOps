@echo off&mode con cols=175 lines=45
SetLocal EnableDelayedExpansion

pushd "%~dp0.."
if exist zabbix_agents.win (
	cd zabbix_agents.win
) else cd ..

set pwd=%cd%

if "%~1"=="" (
	echo Show any "zabbix_agentd.win.conf" in "%pwd%" and its sub folders.
	echo.
	pause
	echo ----------------------------------------------------------------
	for /f "usebackq delims=" %%A in (`dir /a-d /b /s zabbix_agentd.win.conf`) do (
		set FullFilepath=%%~A
		echo "!FullFilepath:%cd%=.!"
		echo.
		call :Function "%%~A"
	)
) else (
	call :Function "%~1"
)

popd

EndLocal
goto :EOF

:Function
findstr /n /v /r /c:"^#" "%~1" | findstr /r /c:":."
echo.
pause
echo ----------------------------------------------------------------
goto :EOF
