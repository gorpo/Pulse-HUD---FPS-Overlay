@echo off
set "ROOT=%~dp0.."
set "PIDFILE=%ROOT%\.runtime\overlay.pid"

if exist "%PIDFILE%" (
    for /f %%p in (%PIDFILE%) do taskkill /PID %%p /F >nul 2>&1
    del "%PIDFILE%" >nul 2>&1
) else (
    powershell.exe -NoProfile -Command "Get-Process powershell -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -eq 'Overlay Leve' } | Stop-Process -Force" >nul 2>&1
)
