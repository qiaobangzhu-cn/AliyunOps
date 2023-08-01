@echo off
SetLocal EnableDelayedExpansion

set Output="Readme.md"

Set cols=0
rem escape for later
Set PartofHeaderLine=^^^|---

if "%~1"=="" (
	set/p Csv=Input csv file's path:
) else set Csv=%~1
if "%Csv%"=="" set Csv=%~dp0ReportSecurity.csv

set Csv=%Csv:"=%

for %%A in ("%Csv%") do (
	set WorkDir=%%~dpA
	set Filename=%%~nA
	if NOT defined Output set Output="%%~dpnA.md"
)

pushd "%WorkDir%"

rem First line
set/p FirstLine=< "%Csv%"
echo %FirstLine:,= ^| %> %Output%

rem Get number of cols
for %%A in (%FirstLine:,= %) do (
	set /a cols+=1
)

for /l %%A in (1,1,%cols%) do (
	set SecondLine=!SecondLine!%PartofHeaderLine%
)

rem Second line
echo !SecondLine:~1!>> %Output%

rem rest lines
for /f "usebackq skip=1 delims=" %%A in (`type %Csv%`) do (
	set str=%%A
	echo !str:,= ^| !>> %Output%
)

popd

EndLocal
