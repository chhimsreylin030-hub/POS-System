@echo off
setlocal enabledelayedexpansion
title SmartFood MySQL pos_db Setup

echo ======================================================================
echo   SmartFood Database Initializer (pos_db)
echo   Imports all 14 tables, 10 corporate accounts, 21 restaurants, 68 dishes
echo ======================================================================
echo.

:: 1. Locate mysql.exe
set "MYSQL_CMD=mysql"
where mysql >nul 2>&1
if %errorlevel% neq 0 (
    if exist "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" (
        set "MYSQL_CMD=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
    ) else if exist "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" (
        set "MYSQL_CMD=C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe"
    ) else if exist "C:\xampp\mysql\bin\mysql.exe" (
        set "MYSQL_CMD=C:\xampp\mysql\bin\mysql.exe"
    ) else if exist "C:\laragon\bin\mysql\mysql-8.0\bin\mysql.exe" (
        set "MYSQL_CMD=C:\laragon\bin\mysql\mysql-8.0\bin\mysql.exe"
    ) else (
        echo [ERROR] MySQL CLI client (mysql.exe) was not found in PATH or standard directories.
        echo Please install MySQL Server or XAMPP, or add mysql to your PATH.
        pause
        exit /b 1
    )
)

echo Found MySQL at: !MYSQL_CMD!
echo.
set /p DB_PASS="Enter MySQL root password (press Enter for 'sinoeun2026', or type your password): "
if "!DB_PASS!"=="" set "DB_PASS=sinoeun2026"

echo.
echo Importing pos_db_complete_setup.sql into MySQL...
"!MYSQL_CMD!" -u root -p!DB_PASS! < pos_db_complete_setup.sql

if %errorlevel% equ 0 (
    echo.
    echo ======================================================================
    echo   [SUCCESS] pos_db was created and populated successfully!
    echo   * 10 Corporate Merchant Accounts
    echo   * 21 Restaurants
    echo   * 68 Menu Items
    echo   * 4 Delivery Drivers
    echo   * 4 Promo Vouchers
    echo ======================================================================
) else (
    echo.
    echo [ERROR] Failed to import database. Please verify your root password and ensure MySQL service is running.
)

echo.
pause
