@echo off

set GTR=1
set EQU=0
SET LSS=-1

set Arg1=%~1
set Arg2=%~2

rem echo --Init--
rem echo %Arg1% %Arg2%

if "%Arg1%"=="%Arg2%" (
	rem echo %EQU%
	exit/b %EQU%
)


set Str1=%Arg1%
set Str2=%Arg2%

call GetSector.bat %Str1%
set Major1=%Major%
set Minor1=%Minor%

call GetSector.bat %Str2%
set Major2=%Major%
set Minor2=%Minor%

rem echo %Major1% %Major2% %Minor1% %Minor2%

if %Major1% gtr %Major2% (
	rem echo F %GTR%
	exit/b %GTR%
) else if %Major1% lss %Major2% (
	rem echo F %LSS%
	exit/b %LSS%
) ELSE (
	if "%Minor1%"=="" (
		rem echo %Minor1%
		exit/b %LSS%
	)
	if "%Minor2%"=="" (
		exit/b %GTR%
	)
	rem set Str1=%Minor1%
	rem set Str2=%Minor2%
)

rem pause
call "%~f0" "%Minor1%" "%Minor2%"
