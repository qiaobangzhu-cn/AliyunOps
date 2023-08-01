@echo off

for /f "delims=. tokens=1,*" %%A in ("%1") do (
	set Major=%%A
	rem echo %1_B=%%B
	set Minor=%%B
)
