@echo off

SetLocal

set IndexFile="%~dp0..\Database\Table\report_customer_relation.csv"

pushd "%~dp0"

for %%A in (Dealed Queue ReportSecurity) do (
	pushd "%%~A"
	for /d %%C in (*) do (
		findstr "^%%C," %IndexFile% 1> nul
		if errorlevel 1 (
			echo %%~A\%%C
			rd /s /q "%%~C"
		)
	)
	popd
)

popd
Endlocal
