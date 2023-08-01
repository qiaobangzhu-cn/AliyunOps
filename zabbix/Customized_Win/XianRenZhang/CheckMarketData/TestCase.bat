@echo off
SetLocal
pushd "%~dp0"
for /l %%A in (1,0,1) do (
	call Main.bat
	timeout 9
)
popd
EndLocal
