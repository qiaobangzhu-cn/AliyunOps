@echo off
SetLocal EnableDelayedExpansion
rem rule EsteemAudit

rem RDP

rem http://www.freebuf.com/sectool/132029.html

set Affected=1
set NotAffected=0

set InsInfoFile=%~1

rem Affected If kernel version NT6.0 NT5.2

call GetKeyValue2.bat "%InsInfoFile%" "SYSTEM"
set SYSTEM=%Value%

echo !SYSTEM!|find /i "Server 2008 R2">nul
if errorlevel 1 (
	echo !SYSTEM!|find /i "Server 2008">nul
	if NOT errorlevel 1 (
		set kernel=NT6.0
	)
) else set kernel=NT6.1

echo !SYSTEM!|find /i "Server 2003">nul
if NOT errorlevel 1 set kernel=NT5.2

set Return=%NotAffected%

if "!kernel!"=="NT6.0" set Return=%Affected%
if "!kernel!"=="NT5.2" set Return=%Affected%

exit/b %Return%
