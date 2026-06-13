@echo off
rem Stops the running overlay by the PID file created at startup.
set "ROOT=%~dp0.."
set "PIDFILE=%ROOT%\.runtime\overlay.pid"

if exist "%PIDFILE%" (
    rem Normal path: stop the exact process that wrote overlay.pid.
    for /f %%p in (%PIDFILE%) do taskkill /PID %%p /F >nul 2>&1
    del "%PIDFILE%" >nul 2>&1
) else (
    rem Fallback for a stale/missing PID file.
    powershell.exe -NoProfile -Command "Get-Process powershell -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -eq 'Overlay Leve' } | Stop-Process -Force" >nul 2>&1
)
