@echo off
SetLocal

set ServerFilename=DnsServer.txt

set TmpFile=%tmp%\%~n0.tmp
set NsList=%tmp%\NsL.tmp
set NsList_Sorted=%tmp%\NsL_S.tmp

if NOT DEFINED DebugLevel SET DebugLevel=0

if "%~1"=="" (
	set /p InDomain=Input a ^(sub^) domain name:
) else set InDomain=%~1

if "%InDomain%"=="" exit/b 1

pushd "%~dp0%"
del /a /f /q %ServerFilename% 2>nul

if %DebugLevel% gtr 0 echo %InDomain%

for /f "delims=" %%A in (".%InDomain%") do (
	set D-1=%%~xA
	set Domain=%%~nA
)

for /f "delims=" %%A in ("%Domain%") do (
	set D-2=%%~xA
	set Domain=%%~nA
)

rem gTLD related
set List1=com net org gov edu mil
for %%A in (%List1%) do (
	if /I "%D-2%"==".%%A" set Flag=1
)

rem Chinese provinces related
set List2=ac ah bj cq fj gd gs gx gz ha hb he hi hk hl hn jl js jx ln mo nm nx qh sc sd sh sn sx tj tw xj yn zj
for %%A in (%List2%) do (
	if /I "%D-2%"==".%%A" set Flag=1
)

if "%Flag%"=="1" for /f "delims=" %%A in ("%Domain%") do (
	set D-3=%%~xA
)

set Domain=%D-3%%D-2%%D-1%
set Domain=%Domain:~1%.

if %DebugLevel% gtr 0 echo %Domain%
rem if NOT "%Domain:~-1"=="." set Domain=%Domain%.

nslookup -q=ns %Domain% 2>nul|find /i "nameserver = "> "%TmpFile%"

if errorlevel 1 (
	popd
	exit/b 2
) else if errorlevel 0 (
	for /f "usebackq delims== tokens=2" %%A in (`type "%TmpFile%"`) do (
		echo %%~A>> "%NsList%"
	)
)

sort "%NsList%" /O "%NsList_Sorted%"
set /p NameServer=< "%NsList_Sorted%"

echo %NameServer:~1%>%ServerFilename%

del /a /f /q "%TmpFile%"
del /a /f /q "%NsList%"
del /a /f /q "%NsList_Sorted%"

popd

EndLocal
