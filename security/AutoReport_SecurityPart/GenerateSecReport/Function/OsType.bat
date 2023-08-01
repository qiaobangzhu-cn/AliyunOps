@echo off
 
set InsInfoFile=%~1

type "%InsInfoFile%"|findstr /r /c:"^.kernel.," >nul
if NOT errorlevel 1 (
	set OsType=Linux
	call RuleLinux.bat "%InsInfoFile%"
)

type "%InsInfoFile%"|findstr /r /c:"^SYSTEM:.*Windows" >nul
if NOT errorlevel 1 (
	set OsType=Windows
	call RuleWindows.bat "%InsInfoFile%"
)
