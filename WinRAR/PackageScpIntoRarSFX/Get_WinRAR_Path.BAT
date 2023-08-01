@echo off

set Value64=exe64
set Value32=exe32

set Return=0

for /f "delims=_ tokens=2" %%A in ("%~n0") do set SoftName=%%~A

if NOT defined Path_%SoftName% (
	reg query HKLM\software\%SoftName% /v %Value64% >nul 2>&1
	if errorlevel 1 (
		if defined ProgramFiles^(x86^) pushd "%windir%\syswow64"
		reg query HKLM\software\%SoftName% /v %Value32% >nul 2>&1
		if errorlevel 1 (
			echo %SoftName% may NOT be installed.
			set Return=1
		) else if errorlevel 0 (
			for /f "usebackq tokens=2,*" %%A in (`reg query HKLM\software\%SoftName% /v %Value32%^|find /i "REG_SZ"`) do set Path_%SoftName%=%%~dpB
		)
		if defined ProgramFiles^(x86^) popd
	) else if errorlevel 0 (
		for /f "usebackq tokens=2,*" %%A in (`reg query HKLM\software\%SoftName% /v %Value64%^|find /i "REG_SZ"`) do set Path_%SoftName%=%%~dpB
	)
)

set Return=&exit/b %Return%
