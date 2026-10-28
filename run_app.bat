@echo off
setlocal enabledelayedexpansion
title SmartFood Delivery Platform (pos_db)

echo ======================================================================
echo   SmartFood Multi-Tenant Food Delivery ^& Merchant POS Platform
echo   Connecting to MySQL (pos_db) on 127.0.0.1:3306
echo ======================================================================

:: 0. Ensure MySQL Service is Running
sc query MySQL80 | findstr /I "RUNNING" >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Checking MySQL service...
    net start MySQL80 >nul 2>&1
    if %errorlevel% neq 0 (
        echo [*] MySQL80 is stopped. Requesting permission to start it...
        powershell -Command "Start-Process cmd -ArgumentList '/c net start MySQL80' -Verb RunAs -Wait"
    )
)

:: 1. Locate Flutter and Dart SDK automatically
set "FLUTTER_CMD=flutter"
set "DART_CMD=dart"

where flutter >nul 2>&1
if %errorlevel% neq 0 (
    if exist "C:\flutter\bin\flutter.bat" (
        set "FLUTTER_CMD=C:\flutter\bin\flutter.bat"
        set "DART_CMD=C:\flutter\bin\dart.bat"
    ) else if exist "C:\src\flutter\bin\flutter.bat" (
        set "FLUTTER_CMD=C:\src\flutter\bin\flutter.bat"
        set "DART_CMD=C:\src\flutter\bin\dart.bat"
    ) else if exist "%USERPROFILE%\flutter\bin\flutter.bat" (
        set "FLUTTER_CMD=%USERPROFILE%\flutter\bin\flutter.bat"
        set "DART_CMD=%USERPROFILE%\flutter\bin\dart.bat"
    ) else if exist "D:\flutter\bin\flutter.bat" (
        set "FLUTTER_CMD=D:\flutter\bin\flutter.bat"
        set "DART_CMD=D:\flutter\bin\dart.bat"
    ) else (
        echo [ERROR] Flutter SDK not found in PATH or standard installation paths!
        echo Please make sure Flutter is installed and added to PATH.
        pause
        exit /b 1
    )
)

:: 2. Choose an open port (8085 avoids conflicts with Java/Tomcat on 8080)
set "WEB_PORT=8085"
netstat -ano | findstr /R ":8085 " >nul 2>&1
if %errorlevel% equ 0 (
    set "WEB_PORT=8090"
)

echo [1/3] Starting SmartFood API Backend Server (Port 8081)...
echo       Automatically detecting MySQL pos_db credentials...
start "SmartFood API Server" /min cmd /c ""%DART_CMD%" run bin/server.dart"

timeout /t 3 /nobreak >nul

echo [2/3] Opening Browser at http://127.0.0.1:!WEB_PORT!...
start "" "http://127.0.0.1:!WEB_PORT!"

echo [3/3] Launching Flutter Web Server on port !WEB_PORT!...
"%FLUTTER_CMD%" run -d web-server --web-port=!WEB_PORT! --web-hostname=127.0.0.1

pause
