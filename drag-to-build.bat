@echo off
if "%~1"=="" (
    echo Please drag and drop an extension folder onto this file.
    pause
    exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build.ps1" "%~1"
pause
