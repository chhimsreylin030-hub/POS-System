@echo off
echo ===================================================
echo   Starting MySQL 8.0 Database Service
echo ===================================================
echo.

net start MySQL80 >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] MySQL80 service is now RUNNING!
    goto done
)

echo Requesting Administrator permission to start MySQL80...
powershell -Command "Start-Process cmd -ArgumentList '/c net start MySQL80 & pause' -Verb RunAs"

:done
echo.
echo Checking MySQL service status...
sc query MySQL80 | findstr STATE
echo.
pause
