@echo off
title Remote Akses Monitor - Install
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Minta akses administrator...
    powershell start-process cmd -ArgumentList "/c `"%~f0`"" -Verb runas
    exit /b
)

echo ============================================
echo   Remote Akses Monitor
echo   Install Sunshine + Virtual Display
echo ============================================
echo.

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
echo.
echo Selesai! Lihat PETUNJUK.txt untuk cara pakai.
pause
