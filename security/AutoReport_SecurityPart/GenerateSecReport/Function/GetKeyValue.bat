@echo off
rem Get Value
rem SetLocal EnableDelayedExpansion

if defined Return set ReturnOld=%Return%
set InsInfoFile=%~1
set Key=%~2


for /f "usebackq delims=, tokens=1,*" %%A in (`type %InsInfoFile%^|find /i "%Key%"`) do (
	set Key=%%~A
	if %%B==null (
		set Return=1
	) else (
		set Value=%%~B
		set Return=0
	)
)

set Return=%ReturnOld% & exit/b %Return%
