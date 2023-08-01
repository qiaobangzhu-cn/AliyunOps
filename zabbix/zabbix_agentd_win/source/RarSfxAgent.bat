@echo off

rem By Pale_Cheung@hotmail.com
rem This agent is designed to make sure that MAIN program will run in 64 bit environment on 64 bit windows when it is called by 32 bit WinRAR SFX module.

setlocal EnableDelayedExpansion

set DefaultBinaryName=WinRARSFX.exe

set NumberOfFolder=0

if NOT DEFINED Main (
	for /f "usebackq delims=" %%A in (`dir /ad /b .`) do (
		set /a NumberOfFolder+=1
	)
	if !NumberOfFolder! equ 1 (
		for /f "usebackq delims=" %%A in (`dir /ad /b .`) do set Main=%%~nA\Main.bat
	) else (
		cd
		set/p Main=Input main script:^(SampleName\Main.bat^)
	)
)

for /f "usebackq tokens=3" %%A in (`wmic process call create '%~dp0%Main% %sfxpar%'^|findstr /i /r /c:"ProcessId ="`) do set ProcessId=%%A

echo Waiting processid %ProcessId:~0,-1% to quit ...

:loop

tasklist /fi "pid eq %ProcessId:~0,-1%" /nh /fo:csv|find "%ProcessId:~0,-1%">nul
if NOT errorlevel 1 (
	timeout/t 1 >nul
	goto loop
)
