@echo off
SetLocal

set FileName=%~1

rem remove project_id
for /f "delims=_ tokens=1,*" %%A in ("%FileName%") do set FileName=%%~B

set FileName=%FileName:.=#%

set FileName=%FileName:_=.%

for /f %%A in ("%FileName%") do (
	set Head=%%~nA
	set Str=%%~xA
)
for /f %%A in ("%Head%") do (
	set Head=%%~nA
	set Str=%%~xA%Str%
)	

set Str=%Head:.=_%%Str:.=,%
echo %str:#=.%
