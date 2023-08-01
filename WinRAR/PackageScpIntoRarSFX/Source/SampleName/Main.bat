@echo off
SetLocal

echo All arguments
echo %*

echo.

echo First 4 arguments
choice /m "%1,%2,%3,%4"

echo.

echo ErrorLevel=%errorlevel%

pause

EndLocal
