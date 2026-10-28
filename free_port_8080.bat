@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo   Checking and Freeing Port 8080
echo ===================================================
echo.

set FOUND=0
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8080 ^| findstr LISTENING') do (
    set FOUND=1
    echo [FOUND] Process with PID %%a is using port 8080.
    echo Terminating process PID %%a...
    taskkill /F /PID %%a
)

if "!FOUND!"=="0" (
    echo [OK] Port 8080 is already free. No process is using it.
) else (
    echo.
    echo [SUCCESS] Port 8080 has been successfully freed!
)

echo.
pause
