@echo off
set "ROOT=%~dp0.."
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%ROOT%\src\OverlayLeve.ps1" -NoClickThrough
