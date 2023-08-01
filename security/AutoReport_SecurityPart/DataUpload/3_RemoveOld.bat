@echo off
SetLocal EnableDelayedExpansion

pushd "%~dp0"

for /f "usebackq delims=" %%A in (`dir /ad /b ReportSecurity`) do (
	if exist "Dealed\%%~A" (
		echo %%~A
		rd /s /q "Dealed\%%~A"
	)
)

popd
