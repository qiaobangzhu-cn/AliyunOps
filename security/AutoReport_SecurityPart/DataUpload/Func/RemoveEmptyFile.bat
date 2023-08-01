@echo off

setLocal EnableDelayedExpansion

for /f "usebackq delims=" %%A in (`find /c "," "%~1"`) do (
	set str=%%~A
	for /f "delims=# tokens=2" %%C in ("!str:: =#!") do (
		if "%%~C"=="1" (
			del /a /f /q "%~1"
		)
	)
)
